part of badger.parser;

class BadgerAstPrinter {
  IndentedStringBuffer _buff = new IndentedStringBuffer();
  bool _firstAssignment = true;

  String generate(Program program) {
    for (var decl in program.declarations) {
      printDeclaration(decl);
    }

    for (var statement in program.statements) {
      if (statement is Statement) {
        printStatement(statement);
      } else if (statement is Expression) {
        printExpression(statement);
        _buff.writeln();
      } else {
        throw new Exception("Failed to print program statement: ${statement}");
      }
    }

    return _buff.toString();
  }

  void printDeclaration(Declaration decl) {
    if (decl is FeatureDeclaration) {
      _buff.writeln('using feature "${decl.feature.components.join()}"');
    } else if (decl is ImportDeclaration) {
      _buff.writeln('import "${decl.location.components.join()}"');
    } else {
      throw new Exception("Unknown Declaration Type");
    }
  }

  void printStatement(Statement statement) {
    if (statement is MethodCall) {
      var ref = statement.reference;
      if (ref is String) {
        _buff.write(ref);
      } else {
        printExpression(ref);
      }
      _buff.write("(");
      var i = 0;
      for (var arg in statement.args) {
        printExpression(arg);

        if (i != statement.args.length - 1) {
          _buff.write(", ");
        }

        i++;
      }
      _buff.writeln(")");
    } else if (statement is ForInStatement) {
      _buff.write("for ${statement.identifier} in ");
      printExpression(statement.value);
      _buff.write(" {");
      _buff.increment();
      for (var x in statement.block.statements) {
        _buff.writeln();
        _buff.writeIndent();
        printStatement(x);
      }
      _buff.decrement();
      _buff.writeln("}");
    } else if (statement is IfStatement) {
      _buff.write("if ");
      printExpression(statement.condition);
      _buff.writeln("{");
      _buff.increment();
      for (var statement in statement.block.statements) {
        _buff.writeln();
        _buff.writeIndent();
        printStatement(statement);
      }
      _buff.decrement();
      _buff.writeln("}");
    } else if (statement is FunctionDefinition) {
      _buff.writeln("func ${statement.identifier}(${statement.args.join(", ")}) {");
      _buff.increment();
      var i = 0;
      for (var x in statement.block.statements) {
        if (i == 0) {
          _buff.writeln();
        }
        printStatement(x);
        i++;
      }
      _buff.write("}");
    } else if (statement is WhileStatement) {
      _buff.write("while ");
      printExpression(statement.condition);
      _buff.writeln("{");
      _buff.increment();
      for (var statement in statement.block.statements) {
        _buff.writeln();
        _buff.writeIndent();
        printStatement(statement);
      }
      _buff.decrement();
      _buff.writeln("}");
    } else if (statement is ReturnStatement) {
      _buff.write("return");

      if (statement.expression != null) {
        _buff.write(" ");
        printExpression(statement.expression);
      }
    } else if (statement is Assignment) {
      if (!_buff.toString().endsWith("\n\n")) {
        _buff.writeln();
      }

      if (statement.isInitialDefine) {
        if (statement.immutable) {
          _buff.write("let ");
        } else {
          _buff.write("var ");
        }
      }

      if (statement.reference is String) {
        _buff.write(statement.reference);
      } else {
        printExpression(statement.reference);
      }
      _buff.write(" = ");
      printExpression(statement.value);
    } else {
      throw new Exception("Failed to print statement: ${statement}");
    }
  }

  void printExpression(Expression expr) {
    if (expr is IntegerLiteral) {
      _buff.write(expr.value);
    } else if (expr is DoubleLiteral) {
      _buff.write(expr.value);
    } else if (expr is BooleanLiteral) {
      _buff.write(expr.value);
    } else if (expr is HexadecimalLiteral) {
      _buff.write("0x${expr.value.toRadixString(16)}");
    } else if (expr is RangeLiteral) {
      printExpression(expr.left);
      _buff.write("..");
      printExpression(expr.right);
    } else if (expr is MethodCall) {
      var ref = expr.reference;
      if (ref is String) {
        _buff.write(ref);
      } else {
        printExpression(ref);
      }
      _buff.write("(");
      var i = 0;
      for (var arg in expr.args) {
        printExpression(arg);

        if (i != expr.args.length - 1) {
          _buff.write(", ");
        }

        i++;
      }
      _buff.writeln(")");
    } else if (expr is Access) {
      printExpression(expr.reference);
      _buff.write(".");
      _buff.write(expr.identifier);
    } else if (expr is Operator) {
      printExpression(expr.left);
      _buff.write(" ${expr.op} ");
      printExpression(expr.right);
    } else if (expr is Negate) {
      _buff.write("!");
      printExpression(expr.expression);
    } else if (expr is VariableReference) {
      _buff.write(expr.identifier);
    } else if (expr is ListDefinition) {
      if (expr.elements.isNotEmpty) {
        _buff.writeln("[");
        _buff.increment();
        var i = 0;
        for (var x in expr.elements) {
          if (i != expr.elements.length - 1) {
            _buff.write(", ");
          }

          printExpression(x);

          i++;
        }
      } else {
        _buff.write("[]");
      }
    } else if (expr is StringLiteral) {
      _buff.write('"');
      for (var c in expr.components) {
        if (c is String) {
          _buff.write(c);
        } else {
          _buff.write("\$(");
          printExpression(c);
          _buff.write(")");
        }
      }
      _buff.write('"');
    } else if (expr is AnonymousFunction) {
      _buff.write("(${expr.args != null ? expr.args.join(", ") : ''}) -> {");
      _buff.increment();
      var i = 0;
      for (var statement in expr.block.statements) {
        if (i == 0) {
          _buff.writeln();
        }
        _buff.writeIndent();
        printStatement(statement);
        i++;
      }
      _buff.decrement();
      _buff.write("}");
    } else {
      throw new Exception("Failed to print expression: ${expr}");
    }
  }
}
