part of badger.compiler;

class DartCompilerTarget extends CompilerTarget<String> {
  @override
  String compile(Program program) {
    var buff = new StringBuffer();
    writeHeader(buff);
    var visitor = new DartAstVisitor(buff);
    visitor.visit(program);
    writeFooter(buff);
    return buff.toString();
  }

  void writeHeader(StringBuffer buff) {
    buff.write("main(args) async {");
  }

  void writeFooter(StringBuffer buff) {
    buff.write("}");

    var str = buff.toString();

    if (str.contains("\$boolean")) {
      buff.write("""
      \$boolean(value) {
        if (value == null) {
          return false;
        } else if (value is int) {
          return value != 0;
        } else if (value is double) {
          return value != 0.0;
        } else if (value is String) {
          return value.isNotEmpty;
        } else if (value is bool) {
          return value;
        } else {
          return true;
        }
      }
      """.split("\n").map((it) => it.trim()).join("").trim());
    }
  }
}

class DartAstVisitor extends AstVisitor {
  final StringBuffer buff;

  DartAstVisitor(this.buff);

  @override
  void visitAccess(Access access) {
    visitExpression(access.reference);
    buff.write(".");
    buff.write(access.identifiers.join("."));
  }

  @override
  void visitAnonymousFunction(AnonymousFunction function) {
    buff.write("(${function.args.join(", ")}) {");
    visitStatements(function.block.statements);
    buff.write("}");
  }

  @override
  void visitStatements(List<Statement> statements) {
    var i = 0;
    for (var s in statements) {
      visitStatement(s);
      buff.write(";");
      i++;
    }
  }

  @override
  void visitAssignment(Assignment assignment) {
    if (assignment.isInitialDefine) {
      if (assignment.immutable) {
        buff.write("final ");
      } else {
        buff.write("var ");
      }
    }

    if (assignment.reference is String) {
      buff.write("${assignment.reference} = ");
      visitExpression(assignment.value);
    } else {
      visitExpression(assignment.reference);
      buff.write(" = ");
      visitExpression(assignment.value);
    }
  }

  @override
  void visitBooleanLiteral(BooleanLiteral literal) {
    buff.write(literal.value);
  }

  @override
  void visitBracketAccess(BracketAccess access) {
    visitExpression(access.reference);
    buff.write("[");
    visitExpression(access.index);
    buff.write("]");
  }

  @override
  void visitBreakStatement(BreakStatement statement) {
    buff.write("break");
  }

  @override
  void visitDoubleLiteral(DoubleLiteral literal) {
    buff.write(literal.value);
  }

  @override
  void visitFeatureDeclaration(FeatureDeclaration declaration) {
  }

  @override
  void visitForInStatement(ForInStatement statement) {
    buff.write("for (var ${statement.identifier} in ");
    visitExpression(statement.value);
    buff.write(" {");
    visitStatements(statement.block.statements);
    buff.write("}");
  }

  @override
  void visitFunctionDefinition(FunctionDefinition definition) {
    buff.write("${definition.name}(${definition.args.join(", ")}) {");
    visitStatements(definition.block.statements);
    buff.write("}");
  }

  @override
  void visitHexadecimalLiteral(HexadecimalLiteral literal) {
    buff.write("${literal.value.toRadixString(16)}");
  }

  @override
  void visitIfStatement(IfStatement statement) {
    buff.write("if (\$boolean(");
    visitExpression(statement.condition);
    buff.write(")) {");
    visitStatements(statement.block.statements);
    buff.write("}");
    if (statement.elseBlock != null) {
      buff.write(" else {");
      visitStatements(statement.elseBlock.statements);
      buff.write("}");
    }
  }

  @override
  void visitImportDeclaration(ImportDeclaration declaration) {
  }

  @override
  void visitIntegerLiteral(IntegerLiteral literal) {
    buff.write(literal.value);
  }

  @override
  void visitListDefinition(ListDefinition definition) {
    buff.write("[");
    var i = 0;
    for (var e in definition.elements) {
      visitExpression(e);
      if (i != definition.elements.length - 1) {
        buff.write(", ");
      }
      i++;
    }
    buff.write("]");
  }

  @override
  void visitMapDefinition(MapDefinition definition) {
    buff.write("{");
    var i = 0;
    for (var e in definition.entries) {
      visitExpression(e.key);
      buff.write(":");
      visitExpression(e.value);
      if (i != definition.entries.length - 1) {
        buff.write(",");
      }
      i++;
    }
  }

  @override
  void visitMethodCall(MethodCall call) {
    if (call.reference is String) {
      buff.write("${call.reference}(");
    } else {
      visitExpression(call.reference);
      buff.write("(");
    }

    var i = 0;
    for (var e in call.args) {
      visitExpression(e);
      if (i != call.args.length - 1) {
        buff.write(", ");
      }
      i++;
    }
    buff.write(")");
  }

  @override
  void visitNegate(Negate negate) {
    buff.write("!(\$boolean(");
    visitExpression(negate.expression);
    buff.write("))");
  }

  @override
  void visitOperator(Operator operator) {
    visitExpression(operator.left);
    buff.write(" ${operator.op} ");
    visitExpression(operator.right);
  }

  @override
  void visitRangeLiteral(RangeLiteral literal) {
    buff.write("λrange(");
    visitExpression(literal.left);
    buff.write(", ");
    visitExpression(literal.right);
    buff.write(")");
  }

  @override
  void visitReturnStatement(ReturnStatement statement) {
    buff.write("return");
    if (statement.expression != null) {
      buff.write(" ");
      visitExpression(statement.expression);
    }
  }

  @override
  void visitStringLiteral(StringLiteral literal) {
    var parts = [];
    var b = new StringBuffer();
    for (var c in literal.components) {
      if (c is Expression) {
        if (b.isNotEmpty) {
          parts.add(b.toString());
          b.clear();
        }

        parts.add(c);
      } else {
        b.write(c);
      }
    }

    if (b.isNotEmpty) {
      parts.add(b.toString());
      b.clear();
    }
    buff.write('"');
    for (var part in parts) {
      if (part is Expression) {
        buff.write('\${');
        visitExpression(part);
        buff.write('}');
      } else {
        buff.write(part);
      }
    }
    buff.write('"');
  }

  @override
  void visitTernaryOperator(TernaryOperator operator) {
    buff.write("\$boolean(");
    visitExpression(operator.condition);
    buff.write(") ? ");
    visitExpression(operator.whenTrue);
    buff.write(" : ");
    visitExpression(operator.whenFalse);
  }

  @override
  void visitVariableReference(VariableReference reference) {
    buff.write(reference.identifier);
  }

  @override
  void visitWhileStatement(WhileStatement statement) {
    buff.write("while (\$boolean(");
    visitExpression(statement.condition);
    buff.write(")) {");
    visitStatements(statement.block.statements);
    buff.write("}");
  }

  @override
  void visitNativeCode(NativeCode code) {
    buff.write(code.code);
  }
}
