part of badger.eval;

final Object VOID = new Object();
final Object _BREAK_NOW = new Object();

class Evaluator {
  static const List<String> SUPPORTED_FEATURES = const [];

  final Program mainProgram;
  final Environment environment;
  final bool simplify;
  final Set<String> features = new Set<String>();

  Evaluator(this.mainProgram, this.environment, {this.simplify: true});

  evaluate(Context ctx) async {
    var props = await environment.getProperties();

    props.addAll({
      "runtime.name": "badger",
      "runtime.features": SUPPORTED_FEATURES
    });

    return await evaluateProgram(mainProgram, ctx);
  }

  evaluateProgram(Program program, Context ctx) async {
    if (simplify) {
      program = new BadgerSimplifier().modify(program);
    }

    return ctx.run(() async {
      await _processDeclarations(program.declarations, ctx, program);
      var result = await _evaluateBlock(program.statements);

      if (result is ReturnValue) {
        result = result.value;
      }

      if (result is Immutable) {
        result = result.value;
      }

      return result;
    });
  }

  _processDeclarations(List<Declaration> declarations, Context ctx, Program program) async {
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
        await _import(decl.location.components.join(), decl.id, ctx, program);
      } else {
        throw new Exception("Unable to Process Declaration");
      }
    }
  }

  _import(String location, String id, Context ctx, Program source) async {
    var c = await ctx.createChild(() async {
      await environment.import(location, this, Context.current, source);
      return Context.current;
    });

    if (id == null) {
      ctx.merge(c);
    } else {
      ctx.setVariable(id, c);
    }
  }

  _evaluateBlock(List<dynamic> statements, [bool allowBreak = false]) async {
    var retval = VOID;

    for (var statement in statements) {
      if (statement is Statement) {
        var value = await _evaluateStatement(statement, allowBreak);

        if (value != null) {
          if (value is ReturnValue) {
            retval = value;
            break;
          } else if (value == _BREAK_NOW) {
            if (allowBreak) {
              retval = _BREAK_NOW;
              break;
            }
          } else {
            if (value is ReturnValue) {
              value = value.value;
            }

            if (value is Immutable) {
              value = value.value;
            }

            retval = value;
          }
        }
      } else if (statement is Expression) {
        retval = await _resolveValue(statement);
      } else {
        throw new Exception("Invalid Block Statement");
      }
    }

    return retval;
  }

  _evaluateStatement(Statement statement, [bool allowBreak = false]) async {
    if (statement is ExpressionStatement) {
      return await _resolveValue(statement.expression);
    } else if (statement is Assignment) {
      var value = await _resolveValue(statement.value);

      if (statement.immutable) {
        value = new Immutable(value);
      }

      if (statement.isNullable == true) {
        value = new Nullable(value);
      }

      var ref = statement.reference;

      if (ref is String) {
        Context.current.setVariable(ref, value, statement.isInitialDefine);
      } else {
        var n = ref.identifier;
        var x = await _resolveValue(ref.reference);

        if (x is BadgerObject) {
          x.setProperty(n, value);
        } else {
          BadgerUtils.setProperty(n, value, x);
        }
      }

      return value;
    } else if (statement is MultiAssignment) {
      var r = await _resolveValue(statement.value);

      var ids = statement.ids;

      var i = 0;
      for (var id in ids) {
        var v = r is List ? r[i] : r[id];
        if (statement.immutable) {
          v = new Immutable(v);
        }
        Context.current.setVariable(id, v, statement.isInitialDefine);
        i++;
      }

      return r;
    } else if (statement is ReturnStatement) {
      var value = null;

      if (statement.expression != null) {
        value = await _resolveValue(statement.expression);
      }

      return new ReturnValue(value);
    } else if (statement is SwitchStatement) {
      var value = await _resolveValue(statement.expression);

      for (var c in statement.cases) {
        var v = await _resolveValue(c.expression);

        if (value == v) {
          await _evaluateBlock(c.block.statements, allowBreak);
          break;
        }
      }
    } else if (statement is NamespaceBlock) {
      var ctx = await Context.current.createChild(() async {
        await _evaluateBlock(statement.block.statements);
        return Context.current;
      });

      Context.current.defineNamespace(statement.name, ctx);
    } else if (statement is ClassBlock) {
      var creator;
      creator = (args) async {
        var map = {};
        var i = 0;

        for (var n in statement.args) {
          if (i < statement.args.length) {
            map[n] = args[i];
          }
          i++;
        }

        for (var n in map.keys) {
          Context.current.setVariable(n, map[n]);
        }

        var x = statement.extension != null ? await Context.current.getType(statement.extension)([]) : null;

        return await Context.current.createChild(() async {
          Context.current.typeName = statement.name;
          if (x != null) {
            x.setVariable("extender", Context.current);
            Context.current.merge(x);
            Context.current.setVariable("super", x);
          }
          Context.current.setVariable("this", Context.current);
          await _evaluateBlock(statement.block.statements);
          return Context.current;
        });
      };

      Context.current.defineType(statement.name, creator);

      return creator;
    } else if (statement is IfStatement) {
      var value = await _resolveValue(statement.condition);
      var c = BadgerUtils.asBoolean(value);

      var v = await Context.current.createChild(() async {
        if (c) {
          return await _evaluateBlock(statement.block.statements, allowBreak);
        } else {
          if (statement.elseBlock != null) {
            return await _evaluateBlock(statement.elseBlock.statements, allowBreak);
          }
        }
      });

      return v;
    } else if (statement is TryCatchStatement) {
      var block = statement.tryBlock.statements;
      var catchBlock = statement.catchBlock.statements;

      try {
        await Context.current.createChild(() async {
          await _evaluateBlock(block);
        });
      } catch (e) {
        await Context.current.createChild(() async {
          Context.current.setVariable(statement.identifier, e);
          await _evaluateBlock(catchBlock);
        });
      }
    } else if (statement is WhileStatement) {
      while (BadgerUtils.asBoolean(await _resolveValue(statement.condition))) {
        var value = await Context.current.createChild(() async {
          return await _evaluateBlock(statement.block.statements, true);
        });

        if (value == _BREAK_NOW) {
          break;
        } else if (value is ReturnValue) {
          return value;
        }
      }
    } else if (statement is ForInStatement) {
      var i = statement.identifier;
      var n = await _resolveValue(statement.value);

      call(value) async {
        return Context.current.createChild(() async {
          Context.current.setVariable(i, value);
          return await _evaluateBlock(statement.block.statements, allowBreak);
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

      var ctx = Context.current;

      ctx.define(name, (args) async {
        var i = 0;
        var inputs = {};

        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }

        return ctx.createChild(() async {
          var cmt = Context.current;

          for (var n in inputs.keys) {
            cmt.setVariable(n, inputs[n]);
          }

          var result = await _evaluateBlock(block.statements, allowBreak);

          if (result is ReturnValue) {
            result = result.value;
          }

          return result;
        });
      }, wrap: false);
    } else if (statement is BreakStatement) {
      return _BREAK_NOW;
    } else {
      throw new Exception("Unable to Execute Statement");
    }

    return null;
  }

  _resolveValue(Expression expr) async {
    var v = await __resolveValue(expr);

    if (v is ReturnValue) {
      v = v.value;
    }

    if (v is Immutable) {
      v = v.value;
    }

    return v;
  }

  __resolveValue(Expression expr) async {
    if (expr is StringLiteral) {
      var components = [];
      for (var it in expr.components) {
        if (it is Expression) {
          components.add(await _resolveValue(it));
        } else {
          components.add(it);
        }
      }
      return _unescape(components.join());
    } else if (expr is IntegerLiteral) {
      return expr.value;
    } else if (expr is DoubleLiteral) {
      return expr.value;
    } else if (expr is HexadecimalLiteral) {
      return expr.value;
    } else if (expr is VariableReference) {
      return Context.current.getProperty(expr.identifier);
    } else if (expr is Parentheses) {
      return await _resolveValue(expr.expression);
    } else if (expr is AnonymousFunction) {
      var argnames = expr.args;
      var block = expr.block;
      var func = (args) async {
        var i = 0;
        var inputs = {};

        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }

        return await Context.current.createChild(() async {
          var c = Context.current;

          for (var n in inputs.keys) {
            c.setVariable(n, inputs[n]);
          }

          var result = await _evaluateBlock(block.statements);

          if (result is ReturnValue) {
            result = result.value;
          }

          if (result is Immutable) {
            result = result.value;
          }

          return result;
        });
      };

      return new Interceptor((a) async {
        return await func(a);
      });
    } else if (expr is MethodCall) {
      return await _callMethod(expr);
    } else if (expr is Defined) {
      return Context.current.hasVariable(expr.identifier);
    } else if (expr is NativeCode) {
      throw new Exception("Native Code is not supported on the evaluator.");
    } else if (expr is ReferenceCreation) {
      return Context.current.getReference(expr.variable.identifier);
    } else if (expr is Access) {
      var value = await _resolveValue(expr.reference);

      for (var p in expr.parts) {
        if (p is String) {
          if (value is BadgerObject) {
            value = await value.getProperty(p);
          } else {
            value = await BadgerUtils.getProperty(p, value);
          }
        } else {
          MethodCall c = p;
          value = await _callMethod(c, value);
        }
      }

      return value;
    } else if (expr is Negate) {
      return !(await _resolveValue(expr.expression));
    } else if (expr is RangeLiteral) {
      var step = expr.step != null ? await _resolveValue(expr.step) : 1;
      return _createRange(await _resolveValue(expr.left), await _resolveValue(expr.right), inclusive: !expr.exclusive, step: step);
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
    } else if (expr is NullLiteral) {
      return null;
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
    var a = () async => await _resolveValue(left);
    var b = () async => await _resolveValue(right);

    switch (op) {
      case "+":
        return (await a()) + (await b());
      case "-":
        return (await a()) - (await b());
      case "*":
        return (await a()) * (await b());
      case "/":
        return (await a()) / (await b());
      case "~/":
        return (await a()) ~/ (await b());
      case "<":
        return (await a()) < (await b());
      case ">":
        return (await a()) > (await b());
      case "<=":
        return (await a()) <= (await b());
      case ">=":
        return (await a()) >= (await b());
      case "==":
        return (await a()) == (await b());
      case "!=":
        return (await a()) != (await b());
      case "&":
        return (await a()) & (await b());
      case "in":
        var m = await b();
        var c = await a();
        if (m is Map) {
          return m.containsKey(c);
        } else {
          return m.contains(c);
        }
        break;
      case "|":
        return (await a ()) | (await b());
      case "||":
        return BadgerUtils.asBoolean((await a())) || BadgerUtils.asBoolean((await b()));
      case "&&":
        return BadgerUtils.asBoolean((await a())) && BadgerUtils.asBoolean((await b()));
      default:
        throw new Exception("Unsupported Operator");
    }
  }

  dynamic _callMethod(MethodCall call, [dynamic obj]) async {
    var args = [];

    for (var s in call.args) {
      args.add(await _resolveValue(s));
    }

    var ref = call.reference;

    if (ref is String && obj == null) {
      return await Context.current.invoke(ref, args);
    } else {
      var v = obj == null ? await _resolveValue(ref.reference) : obj;

      var l = call.reference;

      if (obj == null) {
        List<String> n = ref.identifiers;
        List<String> ids = new List<String>.from(n);
        ids.removeLast();

        for (var id in ids) {
          v = await BadgerUtils.getProperty(id, v);

          if (v is ReturnValue) {
            v = v.value;
          }

          if (v is Immutable) {
            v = v.value;
          }
        }

        l = n.last;
      }

      var z = await BadgerUtils.getProperty(l, v);

      if (z is ReturnValue) {
        z = z.value;
      }

      if (z is Immutable) {
        z = z.value;
      }

      return await Function.apply(z, args);
    }
  }
}

Iterable<int> _createRange(int lower, int upper, {bool inclusive: true, int step: 1}) {
  if (step == 1) {
    if (inclusive) {
      return new Iterable<int>.generate(upper - lower + 1, (i) => lower + i).toList();
    } else {
      return new Iterable<int>.generate(upper - lower - 1, (i) => lower + i + 1).toList();
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
