part of badger.eval;

final Object VOID = new Object();
final Object _BREAK_NOW = new Object();

class Evaluator {
  static const List<String> SUPPORTED_FEATURES = const [
    "one based index"
  ];

  final Program program;
  final Set<String> features = new Set<String>();

  Evaluator(this.program);

  eval(Context ctx) async {
    await _processDeclarations(program.declarations);

    return ctx.createContext(() async {
      return await _evaluateBlock(program.statements);
    });
  }

  _processDeclarations(List<Declaration> declarations) async {
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
      } else {
        throw new Exception("Unable to Process Declaration");
      }
    }
  }

  _evaluateBlock(List<Statement> statements) async {
    for (var statement in statements) {
      var value = await _evaluateStatement(statement);

      if (value != null) {
        if (value is ReturnValue) {
          return value.value;
        } else if (value == _BREAK_NOW) {
          return _BREAK_NOW;
        }
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
      Context.current.setVariable(statement.identifier, value);
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
        } else {
          components.add(it);
        }
      }
      return components.join();
    } else if (expr is IntegerLiteral) {
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
    } else if (expr is TernaryOperator) {
      var value = await _resolveValue(expr.condition);
      var c = BadgerUtils.asBoolean(value);

      if (c) {
        return await _resolveValue(expr.whenTrue);
      } else {
        return await _resolveValue(expr.whenFalse);
      }
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

      if (features.contains("one based index") && index is int) {
        index = index - 1;
      }

      return (await _resolveValue(expr.reference))[index];
    } else {
      throw new Exception("Unable to Resolve Value: ${expr}");
    }
  }
}

class ReturnValue {
  final dynamic value;

  ReturnValue(this.value);
}
