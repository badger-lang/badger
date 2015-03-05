part of badger.compiler;

class JsTarget extends Target<String> {

  @override
  String compile(Program program) {
    var buff = new StringBuffer();
    buff.write("(function() {");

    /*
    for (var declaration in program.declarations) {
      if (declaration is FeatureDeclaration) {
        buff.writeln("Badger.usingFeature(\"" + declaration.feature.components.join() + "\");");
      }
    }
    */

    for (var statement in program.statements) {
      buff.writeln(_compileStatement(statement));
    }

    buff.writeln("});");

    return buff.toString();
  }

  String _compileStatement(Statement statement) {
    var buff = new StringBuffer();
    if (statement is MethodCall) {
      buff.write('Badger.callMethod("');
      buff.write(statement.identifier);
      buff.write('", [');

      var expressions = statement.args.map(_compileExpression).join(", ");

      buff.write(expressions);

      buff.write("]);");
      return buff.toString();
    } else if (statement is Assignment) {
      buff.write('Badger.setVariable("${statement.identifier}", ${_compileExpression(statement.value)}, ${statement.immutable});');
      return buff.toString();
    } else {
      throw new Exception("Unsupported");
    }
  }

  String _compileExpression(Expression expr) {
    var buff = new StringBuffer();
    if (expr is StringLiteral) {
      var lastWasExpr = false;
      buff.write('"');
      for (var c in expr.components) {
        if (c is String) {
          if (lastWasExpr) {
            buff.write('"');
          }

          buff.write(c);
        } else {
          lastWasExpr = true;
          buff.write('" + ' + _compileExpression(c));
        }
      }

      if (!lastWasExpr) {
        buff.write('"');
      }

      return buff.toString();
    }  else if (expr is IntegerLiteral) {
      buff.write(expr.value);
      return buff.toString();
    } else if (expr is VariableReference) {
      buff.write('Badger.getVariable("${expr.identifier}")');
      return buff.toString();
    } else {
      throw new Exception("Unsupported");
    }
  }
}
