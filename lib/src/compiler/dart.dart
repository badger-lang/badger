part of badger.compiler;

const String _DART_CODE = r"""
@BEGIN boolean helper
$boolean(value) {
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
@END
""";

class DartCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    var buff = new StringBuffer();
    writeHeader(buff);
    var visitor = new DartAstVisitor(buff, this);
    visitor.visit(program);
    writeFooter(buff);
    return buff.toString();
  }

  void writeHeader(StringBuffer buff) {
    buff.write("main(args) async {");
  }

  void writeFooter(StringBuffer buff) {
    buff.write("}");

    var map = {};
    var lines = _DART_CODE.split("\n");
    lines.removeWhere((it) => it.trim().isEmpty);
    var current = "";
    for (var line in lines) {
      var trimmed = line.trim();
      if (trimmed.startsWith("@BEGIN ")) {
        var name = trimmed.substring(7);
        current = name;
        map[current] = [];
      } else if (trimmed == "@END") {
        current = "";
      } else if (trimmed.isEmpty) {
        continue;
      } else if (current.isEmpty) {
        throw new Exception(
          "Tried to write line '${line}' as code line," +
          " but no name was given. Try adding '@BEGIN my name'" +
          " at the top and '@END' at the bottom"
        );
      } else {
        map[current].add(line);
      }
    }

    for (var code in _codes) {
      var lns = map[code];

      if (lns == null) {
        throw new Exception("Unknown code: ${code}");
      }

      buff.write(lns.join("\n"));
    }
  }

  final Set<String> _codes = new Set<String>();
}

class DartAstVisitor extends AstVisitor {
  final StringBuffer buff;
  final DartCompilerTarget target;

  List<String> ctxids = [];
  String currentContext;

  DartAstVisitor(this.buff, this.target);

  String enterContext([Map<String, String> vars = const {}]) {
    if (ctxids.isEmpty) {
      ctxids.add("a");
      currentContext = "a";
      buff.write("var a = {};");
      return "a";
    }

    var last = currentContext;
    var lastctx = last;
    var c = last[last.length - 1];

    if (c == "z") {
      last += "a";
    } else {
      last = last.substring(0, last.length - 1);
      last += ALPHABET[ALPHABET.indexOf(c) + 1];
    }

    currentContext = last;
    ctxids.add(last);

    buff.write("var ${currentContext} = new Map.from(${lastctx});");

    for (var v in vars.keys) {
      buff.write('${currentContext}["${v}"] = ${vars[v]};');
    }

    return last;
  }

  String exitContext() {
    var idx = ctxids.indexOf(currentContext);

    if (idx == 0) {
      currentContext = null;
      return null;
    }

    var now = ctxids[idx - 1];
    currentContext = now;
    return currentContext;
  }

  @override
  void visit(Program program) {
    enterContext();
    super.visit(program);
    exitContext();
  }

  @override
  void visitAccess(Access access) {
  }

  @override
  void visitAnonymousFunction(AnonymousFunction function) {
    buff.write("(${function.args.join(", ")}) {");
    enterContext();
    visitStatements(function.block.statements);
    exitContext();
    buff.write("}");
  }

  @override
  void visitStatements(List<Statement> statements) {
    for (var s in statements) {
      visitStatement(s);
      buff.write(";");
    }
  }

  @override
  void visitAssignment(Assignment assignment) {
    if (assignment.reference is String) {
      buff.write('${currentContext}');
      buff.write('["${assignment.reference}"] = ');
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
    buff.write("${currentContext}.");
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
    enterContext();
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
    target._codes.add("boolean helper");
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
    target._codes.add("boolean helper");
    buff.write("!(\$boolean(");
    visitExpression(negate.expression);
    buff.write("))");
  }

  @override
  void visitOperator(Operator operator) {
    if (operator.op == "in") {
      throw new Exception("Compiler does not yet support the in operator.");
    } else {
      visitExpression(operator.left);
      buff.write(" ${operator.op} ");
      visitExpression(operator.right);
    }
  }

  @override
  void visitRangeLiteral(RangeLiteral literal) {
    buff.write(r"$range(");
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
    target._codes.add("boolean helper");
    buff.write("\$boolean(");
    visitExpression(operator.condition);
    buff.write(") ? ");
    visitExpression(operator.whenTrue);
    buff.write(" : ");
    visitExpression(operator.whenFalse);
  }

  @override
  void visitVariableReference(VariableReference reference) {
    buff.write('${currentContext}["');
    buff.write(reference.identifier);
    buff.write('"]');
  }

  @override
  void visitWhileStatement(WhileStatement statement) {
    target._codes.add("boolean helper");
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

  @override
  void visitDefined(Defined defined) {
    buff.write('${currentContext}.containsKey("${defined.identifier}")');
    throw new Exception("Defined operator (${defined.identifier}?) is not yet implemented.");
  }

  @override
  void visitParentheses(Parentheses parens) {
    buff.write("(");
    visitExpression(parens.expression);
    buff.write(")");
  }

  @override
  void visitSwitchStatement(SwitchStatement statement) {
    buff.write("switch (");
    visitExpression(statement.expression);
    for (var c in statement.cases) {
      buff.write("case ");
      visitExpression(c.expression);
      buff.write(":");
      for (var statement in c.block.statements) {
        visitStatement(statement);
      }
    }
  }

  @override
  void visitNullLiteral(NullLiteral literal) {
    buff.write("null");
  }

  @override
  void visitMultiAssignment(MultiAssignment assignment) {

  }

  @override
  void visitNamespaceBlock(NamespaceBlock block) {
    var name = enterContext();
    visitStatements(block.block.statements);
    exitContext();
  }

  @override
  void visitTypeBlock(TypeBlock block) {
    // TODO: implement visitTypeBlock
  }

  @override
  void visitReferenceCreation(ReferenceCreation creation) {
    // TODO: implement visitReferenceCreation
  }

  @override
  void visitTryCatchStatement(TryCatchStatement statement) {
    // TODO: implement visitTryCatchStatement
  }
}
