part of badger.compiler;

class JsAstVisitor extends AstVisitor {
  StringBuffer buff;

  JsAstVisitor(this.buff);

  void visitForInStatement(ForInStatement statement) {

    this.buff.write('λfor(function(${statement.identifier}){var λ = {"${statement.identifier}":${statement.identifier}};');

    for (var s in statement.block.statements) {
      visitStatement(s);

      if (statement.block.statements.indexOf(statement) != statement.block.statements.length - 1) {
        buff.write(";");
      }
    }

    buff.write("},");
    visitExpression(statement.value);
    buff.write(")");
  }

  void visitImportDeclaration(ImportDeclaration declaration) {
  }

  void visitFeatureDeclaration(FeatureDeclaration declaration) {
  }

  void visitIfStatement(IfStatement statement) {
  }

  void visitWhileStatement(WhileStatement statement) {
  }

  void visitReturnStatement(ReturnStatement statement) {
    this.buff.write("return ");
    this.visitExpression(statement.expression);
    this.buff.write(";");
  }

  void visitBreakStatement(BreakStatement statement) {
  }

  void visitAssignment(Assignment assignment) {
    if (assignment.immutable) {
      this.buff.write("λlet(λ, '${assignment.reference}',");
      this.visitExpression(assignment.value);
      this.buff.write(");");
    } else {
      this.buff.write("λ.${assignment.reference} =");

      if (assignment.value != null) {
        this.visitExpression(assignment.value);
      } else {
        this.buff.write("null");
      }

      this.buff.write(";");
    }
  }

  void visitMethodCall(MethodCall call) {
    if (call.reference is String) {
      this.buff.write("${call.reference}(");
    }

    for (var exp in call.args) {
      this.visitExpression(exp);

      if (call.args.indexOf(exp) != call.args.length - 1) {
        this.buff.write(",");
      }
    }

    this.buff.write(")");
  }

  void visitStringLiteral(StringLiteral literal) {
    buff.write('"');
    var i = 0;
    for (var c in literal.components) {
      if (c is String) {
        buff.write(c);

        if (i == literal.components.length - 1) {
          buff.write('"');
        }
      } else {
        if (i != 0) {
          buff.write('"+');
        }

        visitExpression(c);

        if (i != literal.components.length - 1) {
          buff.write('"');
        }
      }
      i++;
    }
  }

  void visitIntegerLiteral(IntegerLiteral literal) {
    this.buff.write(literal.value.toString());
  }

  void visitDoubleLiteral(DoubleLiteral literal) {
    buff.write(literal.value);
  }

  void visitRangeLiteral(RangeLiteral literal) {
    buff.write("λrange(");
    visitExpression(literal.left);
    buff.write(", ");
    visitExpression(literal.right);
    buff.write(")");
  }

  void visitVariableReference(VariableReference reference) {
    this.buff.write("λ.${reference.identifier}");
  }

  void visitListDefinition(ListDefinition definition) {
    this.buff.write("[");

    for(var exp in definition.elements) {
      this.visitExpression(exp);

      if(definition.elements.indexOf(exp) != definition.elements.length - 1) {
        this.buff.write(",");
      }
    }

    this.buff.write("]");
  }

  void visitMapDefinition(MapDefinition definition) {
  }

  void visitNegate(Negate negate) {
  }

  void visitBooleanLiteral(BooleanLiteral literal) {
    buff.write(literal.value);
  }

  void visitHexadecimalLiteral(HexadecimalLiteral literal) {
    buff.write(literal.asHex());
  }

  void visitOperator(Operator operator) {
    visitExpression(operator.left);
    buff.write(" ");
    buff.write(operator.op);
    buff.write(" ");
    visitExpression(operator.right);
  }

  void visitAccess(Access access) {
  }

  void visitBracketAccess(BracketAccess access) {
  }

  void visitTernaryOperator(TernaryOperator operator) {
  }

  void visitFunctionDefinition(FunctionDefinition function) {
    this.buff.write("function ${function.name}(");

    if (function.args != null)
      this.buff.write(function.args.join(","));

    var m = ((function.args == null ? [] : function.args) as List).map((it) => '"${it}": ${it}').join(",");
    this.buff.write("){var λ = {${m}};");

    for(var statement in function.block.statements) {
      this.visitStatement(statement);

      if (function.block.statements.indexOf(statement) != function.block.statements.length - 1) {
        this.buff.write(";");
      }
    }

    this.buff.write("}");
  }

  void visitAnonymousFunction(AnonymousFunction function) {
    this.buff.write("function(");

    if(function.args != null)
      this.buff.write(function.args.join(","));

    this.buff.write("){");

    for(var statement in function.block.statements) {
      this.visitStatement(statement);

      if(function.block.statements.indexOf(statement) != function.block.statements.length - 1) {
        this.buff.write(",");
      }
    }

    this.buff.write("}.bind(this)");
  }
}

class JsCompilerTarget extends CompilerTarget<String> {

  StringBuffer buff = new StringBuffer();
  List<String> _names = <String>[];
  List<String> _bodies = <String>[];

  JsCompilerTarget();

  @override
  String compile(Program program) {
    addGlobal("λlet", """
      function(context, name, value) {
        Object.defineProperty(context, name, {
          enumerable: true,
          get: function() {
            return value;
          },
          set: function() {
            throw new Error('Unable to set ' + name + ', it is immutable.');
          }
        });
      }
    """);

    addGlobal("λfor", """
      function(block, value) {
        for (var i in value) {
          var v = value[i];
          block(v);
        }
      }
    """);

    addGlobal("λrange", """
      function(lower, upper) {
        var list = [];
        for (var i = lower; i <= upper; i++) {
          list.push(i);
        }
        return list;
      }
    """);

    addGlobal("print", "function(obj) {console.log(obj.toString());}");
    addGlobal("async", "function(cb) {setTimeout(cb, 0);}");

    writePrelude();
    new JsAstVisitor(buff).visit(program);
    writePostlude();

    return buff.toString();
  }

  void addGlobal(String name, String body) {
    _names.add(name);
    _bodies.add(minify(body));
  }

  void writePrelude() {
    buff.write("(function(${_names.join(",")}){var λ = {};");
  }

  final RegExp _WHITESPACE = new RegExp(r'''\s{2,}(?=([^"]*("|')[^"']*("|'))*[^"']*$)''');

  String minify(String input) {
    input = input.trim();
    input = input.replaceAll(_WHITESPACE, "");
    return input.trim().replaceAll("\n", "");
  }

  void writePostlude() {
    buff.write("})(${_bodies.join(",")});");
  }
}
