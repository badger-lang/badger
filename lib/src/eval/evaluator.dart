part of badger.eval;

final Object VOID = new Object();
final Object _BREAK_NOW = new Object();

abstract class Environment {
  Future<Program> import(String location);
}

class FileEnvironment extends Environment {
  static final BadgerParser _parser = new BadgerParser();

  final File file;

  FileEnvironment(this.file);

  eval(Context context) async {
    var program = _parse(await file.readAsString());
    return await new Evaluator(program, this).eval(context);
  }

  Future<Program> parse() async {
    return _parse(await file.readAsString());
  }

  Future<Map> generateJSON() async {
    return new BadgerJsonBuilder(await parse()).build();
  }

  Future<Program> parseJSON() async {
    return new BadgerJsonParser(JSON.decode(await file.readAsString())).build();
  }

  Future<Program> _parseJSON(String content) async {
    return new BadgerJsonParser(JSON.decode(content)).build();
  }

  buildEvalJSON(Context ctx) async {
    return await new Evaluator(await _parseJSON(JSON.encode(await generateJSON())), this).eval(ctx);
  }

  Program _parse(String content) {
    try {
      var json = JSON.decode(content);
      return new BadgerJsonParser(json).build();
    } catch (e) {
    }

    return _parser.parse(content).value;
  }

  @override
  Future<Program> import(String location) async {
    try {
      var uri = Uri.parse(location);

      if (uri.scheme == "file") {
        var file = new File(uri.toFilePath());
        return _parse(await file.readAsString());
      }
    } catch (e) {
    }

    var dir = file.parent;

    if (pathlib.isRelative(location)) {
      var f = new File("${dir.path}/${location}");
      return _parse(await f.readAsString());
    } else {
      return _parse(await new File(location).readAsString());
    }
  }
}

class Evaluator {
  static const List<String> SUPPORTED_FEATURES = const [];

  final Program program;
  final Environment environment;
  final Set<String> features = new Set<String>();

  Evaluator(this.program, this.environment);

  eval(Context ctx) async {
    return await _evalProgram(program, ctx);
  }

  _evalProgram(Program program, Context ctx) async {
    return ctx.run(() async {
      await _processDeclarations(program.declarations, ctx);
      return await _evaluateBlock(program.statements);
    });
  }

  _processDeclarations(List<Declaration> declarations, Context ctx) async {
    for (var decl in declarations) {
      if (decl is FeatureDeclaration) {
        if (decl.feature.components.any((it) => it is! String)) {
          throw new Exception("String Interpolation is not allowed in a feature declaration.");
        }

        var f = decl.feature.components.join();

        if (!SUPPORTED_FEATURES.contains(f)) {
          throw new Exception("Unsupported Feature: ${f}");
        }

        features.add(f);
      } else if (decl is ImportDeclaration) {
        await _import(decl.location.components.join(), ctx);
      } else {
        throw new Exception("Unable to Process Declaration");
      }
    }
  }

  _import(String location, Context ctx) async {
    var c = await ctx.createContext(() async {
      var tp = await environment.import(location);
      await _evalProgram(tp, ctx);
      return Context.current;
    });

    ctx.merge(c);
  }

  _evaluateBlock(List<dynamic> statements) async {
    for (var statement in statements) {
      if (statement is Statement) {
        var value = await _evaluateStatement(statement);

        if (value != null) {
          if (value is ReturnValue) {
            return value.value;
          } else if (value == _BREAK_NOW) {
            return _BREAK_NOW;
          }
        }
      } else if (statement is Expression) {
        return await _resolveValue(statement);
      } else {
        throw new Exception("Invalid Block Statement");
      }
    }

    return VOID;
  }

  _evaluateStatement(Statement statement) async {
    if (statement is MethodCall) {
      var args = [];
      for (var s in statement.args) {
        args.add(await _resolveValue(s));
      }

      return await Context.current.invoke(statement.identifier, args);
    } else if (statement is Assignment) {
      var value = await _resolveValue(statement.value);

      if (statement.immutable) {
        value = new Immutable(value);
      }

      Context.current.setVariable(statement.identifier, value, statement.isInitialDefine);
      return value;
    } else if (statement is ReturnStatement) {
      var value = null;

      if (statement.expression != null) {
        value = await _resolveValue(statement.expression);
      }

      return new ReturnValue(value);
    } else if (statement is IfStatement) {
      var value = await _resolveValue(statement.condition);
      var c = BadgerUtils.asBoolean(value);
      return Context.current.createContext(() async {
        if (c) {
          return await _evaluateBlock(statement.block.statements);
        } else {
          if (statement.elseBlock != null) {
            return await _evaluateBlock(statement.elseBlock.statements);
          }
        }
      });
    } else if (statement is WhileStatement) {
      while (BadgerUtils.asBoolean(await _resolveValue(statement.condition))) {
        var value = await _evaluateBlock(statement.block.statements);

        if (value == _BREAK_NOW) {
          return value;
        }
      }
    } else if (statement is ForInStatement) {
      var i = statement.identifier;
      var n = await _resolveValue(statement.value);

      call(value) async {
        return Context.current.createContext(() async {
          Context.current.setVariable(i, value);
          return await _evaluateBlock(statement.block.statements);
        });
      }

      if (n is Stream) {
        await for (var x in n) {
          var result = await call(x);

          if (result == _BREAK_NOW) {
            break;
          }
        }
      } else {
        for (var x in n) {
          call(x);
        }
      }
    } else if (statement is FunctionDefinition) {
      var name = statement.name;
      var argnames = statement.args;
      var block = statement.block;

      Context.current.define(name, (args) async {
        var i = 0;
        var inputs = {};

        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }

        return Context.current.createContext(() async {
          var cmt = Context.current;
          for (var n in inputs.keys) {
            cmt.setVariable(n, inputs[n]);
          }

          return await _evaluateBlock(block.statements);
        });
      });
    } else if (statement is BreakStatement) {
      return _BREAK_NOW;
    } else {
      throw new Exception("Unable to Execute Statement");
    }

    return null;
  }

  _resolveValue(Expression expr) async {
    if (expr is StringLiteral) {
      var components = [];
      for (var it in expr.components) {
        if (it is Expression) {
          components.add(await _resolveValue(it));
        } else if (it.startsWith("\\")) {
          components.add(_unescape(it));
        } else {
          components.add(it);
        }
      }
      return components.join();
    } else if (expr is IntegerLiteral) {
      return expr.value;
    } else if (expr is DoubleLiteral) {
      return expr.value;
    } else if (expr is HexadecimalLiteral) {
      return expr.value;
    } else if (expr is VariableReference) {
      return Context.current.getVariable(expr.identifier);
    } else if (expr is AnonymousFunction) {
      var argnames = expr.args;
      var block = expr.block;
      var func = (args) async {
        var i = 0;
        var inputs = {
        };
        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }

        return Context.current.createContext(() async {
          var c = Context.current;

          for (var n in inputs.keys) {
            c.setVariable(n, inputs[n]);
          }

          return await _evaluateBlock(block.statements);
        });
      };

      return func;
    } else if (expr is MethodCall) {
      var x = [];
      for (var e in expr.args) {
        x.add(await _resolveValue(e));
      }
      return await Context.current.invoke(expr.identifier, x);
    } else if (expr is Access) {
      var value = await _resolveValue(expr.reference);

      if (value is BadgerObject) {
        return value.getProperty(expr.identifier);
      } else {
        return BadgerUtils.getProperty(expr.identifier, value);
      }

      return value;
    } else if (expr is Negate) {
      return !(await _resolveValue(expr.expression));
    } else if (expr is RangeLiteral) {
      return _createRange(await _resolveValue(expr.left), await _resolveValue(expr.right));
    } else if (expr is TernaryOperator) {
      var value = await _resolveValue(expr.condition);
      var c = BadgerUtils.asBoolean(value);

      if (c) {
        return await _resolveValue(expr.whenTrue);
      } else {
        return await _resolveValue(expr.whenFalse);
      }
    } else if (expr is MapDefinition) {
      var map = {};
      for (var e in expr.entries) {
        var key = await _resolveValue(e.key);
        var value = await _resolveValue(e.value);
        map[key] = value;
      }
      return map;
    } else if (expr is ListDefinition) {
      var x = [];
      for (var e in expr.elements) {
        x.add(await _resolveValue(e));
      }
      return x;
    } else if (expr is BooleanLiteral) {
      return expr.value;
    } else if (expr is BracketAccess) {
      var index = await _resolveValue(expr.index);

      return (await _resolveValue(expr.reference))[index];
    } else if (expr is Operator) {
      var op = expr.op;

      return await _handleOperation(expr.left, expr.right, op);
    } else {
      throw new Exception("Unable to Resolve Value: ${expr}");
    }
  }

  _handleOperation(Expression left, Expression right, String op) async {
    var a = await _resolveValue(left);
    var b = await _resolveValue(right);

    switch (op) {
      case "+":
        return a + b;
      case "-":
        return a - b;
      case "*":
        return a * b;
      case "/":
        return a / b;
      case "~/":
        return a ~/ b;
      case "<":
        return a < b;
      case ">":
        return a > b;
      case "<=":
        return a <= b;
      case ">=":
        return a >= b;
      case "==":
        return a == b;
      case "&":
        return a & b;
      case "|":
        return a | b;
      case "||":
        return BadgerUtils.asBoolean(a) || BadgerUtils.asBoolean(b);
      case "&&":
        return BadgerUtils.asBoolean(a) && BadgerUtils.asBoolean(b);
      default:
        throw new Exception("Unsupported Operator");
    }
  }
}

Iterable<int> _createRange(int lower, int upper, {bool inclusive: true, int step: 1}) {
  if (step == 1) {
    if (inclusive) {
      return new Iterable<int>.generate(upper - lower + 1, (i) => lower + i);
    } else {
      return new Iterable<int>.generate(upper - lower - 1, (i) => lower + i + 1);
    }
  } else {
    var list = [];
    for (var i = inclusive ? lower : lower + step; inclusive ? i <= upper : i < upper; i += step) {
      list.add(i);
    }
    return list;
  }
}

class ReturnValue {
  final dynamic value;

  ReturnValue(this.value);
}
