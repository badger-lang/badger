part of badger.eval;

const Object VOID = const Object();

class Evaluator {
  static const List<String> SUPPORTED_FEATURES = const [
    "one based index"
  ];

  final Program program;
  final Context globalContext;
  final Set<String> features = new Set<String>();

  Evaluator(this.program, this.globalContext);

  void eval() {
    _processDeclarations(program.declarations);
    _evaluateBlock(program.statements);
  }

  void _processDeclarations(List<Declaration> declarations) {
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

  dynamic _evaluateBlock(List<Statement> statements, {Context context}) {
    if (context == null) {
      context = globalContext;
    }

    for (var statement in statements) {
      var value = _evaluateStatement(statement, context: context);

      if (value != null && value is ReturnValue) {
        return value.value;
      }
    }

    return VOID;
  }

  dynamic _evaluateStatement(Statement statement, {Context context}) {
    if (context == null) {
      context = globalContext;
    }

    if (statement is MethodCall) {
      var args = statement.args.map((it) => _resolveValue(it, context: context)).toList();
      context.invoke(statement.identifier, args);
    } else if (statement is Assignment) {
      var value = _resolveValue(statement.value, context: context);
      context.setVariable(statement.identifier, value);
    } else if (statement is ReturnStatement) {
      var value = null;

      if (statement.expression != null) {
        value = _resolveValue(statement.expression, context: context);
      }

      return new ReturnValue(value);
    } else if (statement is FunctionDefinition) {
      var name = statement.name;
      var argnames = statement.args;
      var block = statement.block;

      context.define(name, (args) {
        var i = 0;
        var inputs = {};
        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }
        var c = context.fork();

        for (var n in inputs.keys) {
          c.setVariable(n, inputs[n]);
        }

        return _evaluateBlock(block.statements, context: c);
      });
    } else {
      throw new Exception("Unable to Execute Statement");
    }

    return null;
  }

  dynamic _resolveValue(Expression expr, {Context context}) {
    if (context == null) {
      context = globalContext;
    }

    if (expr is StringLiteral) {
      var components = expr.components.map((it) {
        if (it is Expression) {
          return _resolveValue(it, context: context);
        } else {
          return it;
        }
      }).join();
      return components;
    } else if (expr is IntegerLiteral) {
      return expr.value;
    } else if (expr is VariableReference) {
      return context.getVariable(expr.identifier);
    } else if (expr is MethodCall) {
      var args = expr.args.map((it) =>_resolveValue(it, context: context)).toList();
      return context.invoke(expr.identifier, args);
    } else if (expr is ListDefinition) {
      return expr.elements.map((it) =>_resolveValue(it, context: context)).toList();
    } else if (expr is BracketAccess) {
      var index = _resolveValue(expr.index);

      if (features.contains("one based index")) {
        index = index - 1;
      }

      return _resolveValue(expr.reference, context: context)[index];
    } else {
      throw new Exception("Unable to Resolve Value: ${expr}");
    }
  }
}

class ReturnValue {
  final dynamic value;

  ReturnValue(this.value);
}
