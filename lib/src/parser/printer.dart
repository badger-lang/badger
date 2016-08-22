part of badger.parser;

class BadgerPrinter extends AstVisitor {
  final AstNode rootNode;
  final bool pretty;

  IndentedStringBuffer buff = new IndentedStringBuffer();

  BadgerPrinter(this.rootNode, {this.pretty: true}) {
    buff.enableIndent = pretty;
  }

  String print() {
    visitProgram(rootNode);
    return buff.toString();
  }

  @override
  void visitProgram(Program program) {
    for (var declaration in program.declarations) {
      visitDeclaration(declaration);
    }

    if (program.statements.isNotEmpty) {
      buff.writeln();

      if (pretty) {
        buff.writeln();
      }
    }

    visitStatements(program.statements);
  }

  @override
  void visitAccess(Access access) {
    visitExpression(access.reference);
    buff.write(".");
    var i = 0;
    for (var x in access.parts) {
      if (x is String) {
        buff.write(x);
      } else if (x is Identifier) {
        buff.write(x.name);
      } else {
        visitExpression(x);
      }
      if (i != access.parts.length - 1) {
        buff.write(".");
      }
      i++;
    }
  }

  @override
  void visitAnonymousFunction(AnonymousFunction function) {
    if (function.block.statements.length == 1 && function.block.statements.first is Expression) {
      buff.write("(${function.args.join(", ")}) => ");
      visitStatement(function.block.statements.first);
    } else {
      buff.write("(${function.args.join(", ")}) -> {");
      if (pretty) {
        buff.writeln();
      }
      buff.increment();
      visitStatements(function.block.statements);
      buff.decrement();
      if (pretty) {
        buff.writeln();
      }
      buff.write("}");
    }
  }

  String keyword(String word) {
    return word;
  }

  @override
  void visitBooleanLiteral(BooleanLiteral literal) {
    buff.write(constant(literal.value.toString()));
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
    buff.write(keyword("break"));
  }

  @override
  void visitDefined(Defined defined) {
    buff.write("${defined.identifier}?");
  }

  @override
  void visitDoubleLiteral(DoubleLiteral literal) {
    buff.write(constant(literal.value.toString()));
  }

  @override
  void visitFeatureDeclaration(FeatureDeclaration declaration) {
    buff.write('using feature "${declaration.feature.components.join()}"');
  }

  @override
  void visitForInStatement(ForInStatement statement) {
    buff.write(keyword("for"));
    buff.write(" ");
    buff.write(statement.identifier);
    buff.write(" ");
    buff.write(keyword("in"));
    buff.write(" ");
    visitExpression(statement.value);
    if (pretty) {
      buff.writeln(" {");
    } else {
      buff.write("{");
    }
    buff.increment();
    visitStatements(statement.block.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");
  }

  @override
  void visitStatements(List statements) {
    var i = 0;
    for (var statement in statements) {
      buff.writeIndent();
      visitStatement(statement);
      if (i != statements.length - 1) {
        if (pretty) {
          buff.writeln();
        } else {
          buff.write(";");
        }
      }
      i++;
    }
  }

  @override
  void visitFunctionDefinition(FunctionDefinition definition) {
    var sep = pretty ? ", " : ",";
    buff.write("${definition.name}(${definition.args.join(sep)})");
    if (pretty) {
      buff.write(" {");
    } else {
      buff.write("{");
    }
    buff.increment();
    if (pretty) {
      buff.writeln();
    }
    visitStatements(definition.block.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");
  }

  @override
  void visitHexadecimalLiteral(HexadecimalLiteral literal) {
    buff.write(constant("0x" + literal.value.toRadixString(16)));
  }

  @override
  void visitIfStatement(IfStatement statement) {
    buff.write(keyword('if'));
    buff.write(" ");
    visitExpression(statement.condition);
    if (pretty) {
      buff.writeln(" {");
    } else {
      buff.write("{");
    }
    buff.increment();
    visitStatements(statement.block.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");

    if (statement.elseBlock != null) {
      buff.increment();
      if (pretty) {
        buff.write(" ");
      }
      buff.write(keyword("else"));
      if (pretty) {
        buff.write(" ");
      }
      buff.write("{");
      if (pretty) {
        buff.writeln();
      }
      visitStatements(statement.elseBlock.statements);
      buff.decrement();
      if (pretty) {
        buff.writeln();
      }
      buff.writeIndent();
      buff.write("}");
    }
  }

  @override
  void visitImportDeclaration(ImportDeclaration declaration) {
    buff.write('${keyword('import')} "');
    buff.write(declaration.location.components.join());
    buff.write('"');

    if (declaration.id != null) {
      buff.write(" ");
      buff.write("${keyword('as')} ");
      buff.write(declaration.id);
    }
  }

  @override
  void visitIntegerLiteral(IntegerLiteral literal) {
    buff.write(constant(literal.value.toString()));
  }

  @override
  void visitListDefinition(ListDefinition definition) {
    buff.write("[");
    if (definition.elements.isNotEmpty) {
      buff.increment();
      var i = 0;
      for (var e in definition.elements) {
        if (pretty) {
          buff.writeln();
        }
        buff.writeIndent();
        visitExpression(e);
        if (i != definition.elements.length - 1) {
          buff.write(",");
        } else {
          if (pretty) {
            buff.writeln();
          }
        }
        i++;
      }

      buff.decrement();
    }
    buff.write("]");
  }

  @override
  void visitMapDefinition(MapDefinition definition) {
    if (pretty) {
      buff.writeln("{");
    } else {
      buff.write("{");
    }
    buff.increment();
    var i = 0;
    for (var x in definition.entries) {
      buff.writeIndent();
      visitExpression(x.key);
      buff.write(":");
      if (pretty) {
        buff.write(" ");
      }
      visitExpression(x.value);

      if (i != definition.entries.length - 1) {
        if (pretty) {
          buff.writeln(",");
        } else {
          buff.write(",");
        }
      }
      i++;
    }
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");
  }

  @override
  void visitMethodCall(MethodCall call) {
    if (call.reference is Identifier) {
      buff.write("${call.reference}");
    } else {
      visitExpression(call.reference);
    }

    buff.write("(");
    var i = 0;
    for (var x in call.args) {
      visitExpression(x);
      if (i != call.args.length - 1) {
        buff.write(",");
        if (pretty) {
          buff.write(" ");
        }
      }
      i++;
    }
    buff.write(")");
  }

  @override
  void visitNativeCode(NativeCode code) {
    buff.write("```");
    buff.write(code.code);
    buff.write("```");
  }

  @override
  void visitNegate(Negate negate) {
    buff.write("!");
    visitExpression(negate.expression);
  }

  @override
  void visitNullLiteral(NullLiteral literal) {
    buff.write(keyword("null"));
  }

  @override
  void visitOperation(Operation o) {
    visitExpression(o.left);
    if (pretty) {
      buff.write(" ");
    }
    buff.write("${operator(o.op)}");
    if (pretty) {
      buff.write(" ");
    }
    visitExpression(o.right);
  }

  @override
  void visitParentheses(Parentheses parens) {
    buff.write("(");
    visitExpression(parens.expression);
    buff.write(")");
  }

  @override
  void visitRangeLiteral(RangeLiteral literal) {
    visitExpression(literal.left);
    buff.write("..");
    if (literal.exclusive) {
      buff.write("<");
    }

    visitExpression(literal.right);

    if (literal.step != null) {
      buff.write(":");
      visitExpression(literal.step);
    }
  }

  @override
  void visitReturnStatement(ReturnStatement statement) {
    buff.write(keyword("return"));

    if (statement.expression != null) {
      buff.write(" ");
      visitExpression(statement.expression);
    }
  }

  @override
  void visitStringLiteral(StringLiteral literal) {
    buff.write(string('"'));
    for (var x in literal.components) {
      if (x is String) {
        buff.write(string(x));
      } else {
        buff.write(operator("\$("));
        visitExpression(x);
        buff.write(operator(")"));
      }
    }
    buff.write(string('"'));
  }

  @override
  void visitSwitchStatement(SwitchStatement statement) {
    buff.write("${keyword('switch')} ");
    visitExpression(statement.expression);
    buff.write(" {");
    if (statement.cases.isNotEmpty) {
      buff.increment();
      for (var c in statement.cases) {
        if (pretty) {
          buff.writeln();
        }
        buff.writeIndent();
        buff.write("${keyword('case')} ");
        visitExpression(c.expression);
        buff.write(":");
        buff.increment();
        visitStatements(c.block.statements);
        buff.decrement();
      }
      buff.decrement();
    }
  }

  @override
  void visitTernaryOperator(TernaryOperator operator) {
    visitExpression(operator.condition);
    if (pretty) {
      buff.write(" ");
    }
    buff.write("?");
    if (pretty) {
      buff.write(" ");
    }
    visitExpression(operator.whenTrue);
    if (pretty) {
      buff.write(" ");
    }
    buff.write(":");
    if (pretty) {
      buff.write(" ");
    }
    visitExpression(operator.whenFalse);
  }

  @override
  void visitVariableReference(VariableReference reference) {
    if (["this", "super"].contains(reference.identifier)) {
      buff.write(keyword(reference.identifier.name));
    } else {
      buff.write(reference.identifier);
    }
  }

  @override
  void visitWhileStatement(WhileStatement statement) {
    buff.write("${keyword('while')} ");
    visitExpression(statement.condition);
    if (pretty) {
      buff.writeln(" {");
    } else {
      buff.write("{");
    }
    buff.increment();
    visitStatements(statement.block.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");
  }

  @override
  void visitMultiAssignment(MultiAssignment assignment) {
    if (assignment.isInitialDefine) {
      buff.write(keyword(assignment.immutable ? "let" : "var"));

      if (assignment.isNullable) {
        buff.write("?");
      }

      buff.write(" ");
    }
    buff.write("{" + assignment.ids.join(", ") + "}");
    buff.write(" = ");
    visitExpression(assignment.value);
  }

  @override
  void visitNamespaceBlock(NamespaceBlock block) {
    buff.write(keyword("namespace"));
    buff.write(" ");
    buff.write(block.name);
    if (pretty) {
      buff.write(" ");
    }
    buff.write("{");
    buff.increment();
    if (pretty) {
      buff.writeln();
    }
    visitStatements(block.block.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");
  }

  @override
  void visitClassBlock(ClassBlock block) {
    buff.write("${keyword('class')} ${block.name}");

    if (block.args.isNotEmpty) {
      buff.write("(");
      buff.write(block.args.join(", "));
      buff.write(")");
    }

    buff.write(" {");
    if (block.block.statements.isNotEmpty) {
      buff.increment();
      if (pretty) {
        buff.writeln();
      }
      visitStatements(block.block.statements);
      buff.decrement();
      if (pretty) {
        buff.writeln();
      }
      buff.writeIndent();
    }
    buff.write("}");
  }

  @override
  void visitReferenceCreation(ReferenceCreation creation) {
    buff.write("&");
    visitVariableReference(creation.variable);
  }

  @override
  void visitTryCatchStatement(TryCatchStatement statement) {
    buff.write(keyword("try"));
    if (pretty) {
      buff.write(" ");
    }
    buff.write("{");
    if (pretty) {
      buff.writeln();
    }
    buff.increment();
    visitStatements(statement.tryBlock.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");

    if (pretty) {
      buff.write(" ");
    }
    buff.write(keyword("catch"));
    if (pretty) {
      buff.write(" ");
    }
    buff.write("(");
    buff.write(statement.identifier);
    buff.write(")");
    if (pretty) {
      buff.write(" ");
    }
    buff.write("{");
    if (pretty) {
      buff.writeln();
    }
    buff.increment();
    visitStatements(statement.catchBlock.statements);
    buff.decrement();
    if (pretty) {
      buff.writeln();
    }
    buff.writeIndent();
    buff.write("}");
  }

  String string(String l) {
    return l;
  }

  String constant(String l) {
    return l;
  }

  String operator(String l) {
    return l;
  }

  @override
  void visitAccessAssignment(AccessAssignment assignment) {
    visitAccess(assignment.reference);
    if (pretty) {
      buff.write(" ");
    }
    buff.write("=");
    if (pretty) {
      buff.write(" ");
    }
    visitExpression(assignment.value);
  }

  @override
  void visitFlatAssignment(FlatAssignment assignment) {
    buff.write(assignment.name);
    buff.write(" = ");
    visitExpression(assignment.value);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration decl) {
    if (decl.isImmutable) {
      buff.write(keyword("let"));
    } else {
      buff.write(keyword("var"));
    }

    if (decl.isNullable == true) {
      buff.write("?");
    }

    buff.write(" ");

    buff.write(decl.name);

    if (pretty) {
      buff.write(" ");
    }
    buff.write("=");
    if (pretty) {
      buff.write(" ");
    }

    visitExpression(decl.value);
  }
}
