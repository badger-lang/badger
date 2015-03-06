part of badger.compiler;

class JsAstVisitor extends AstVisitor {
  StringBuffer buff;

  JsAstVisitor(this.buff);

  void visitForInStatement(ForInStatement statement) {
    buff.write('λfor(function(${statement.identifier}){var λ = {"${statement.identifier}":${statement.identifier}};');

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
    if (
      (statement.condition is BooleanLiteral && statement.condition.value == false) ||
      statement.block == null ||
      statement.block.statements.isEmpty
    ) {
      return;
    }

    buff.write("if (");
    buff.write("λbool(");
    visitExpression(statement.condition);
    buff.write(")) {");
    for (var s in statement.block.statements) {
      visitStatement(s);

      if (statement.block.statements.indexOf(statement) != statement.block.statements.length - 1) {
        buff.write(";");
      }
    }
    buff.write("}");
    if (statement.elseBlock != null) {
      buff.write(" else {");
      for (var s in statement.elseBlock.statements) {
        visitStatement(s);

        if (statement.elseBlock.statements.indexOf(statement) != statement.elseBlock.statements.length - 1) {
          buff.write(";");
        }
      }
      buff.write("}");
    }
  }

  void visitWhileStatement(WhileStatement statement) {
    if (
      (statement.condition is BooleanLiteral && statement.condition.value == false) ||
      statement.block == null ||
      statement.block.statements.isEmpty
    ) {
      return;
    }

    buff.write("while (");
    buff.write("λbool(");
    visitExpression(statement.condition);
    buff.write(")) {");
    for (var s in statement.block.statements) {
      visitStatement(s);

      if (statement.block.statements.indexOf(statement) != statement.block.statements.length - 1) {
        buff.write(";");
      }
    }
    buff.write("}");
  }

  void visitReturnStatement(ReturnStatement statement) {
    this.buff.write("return ");
    this.visitExpression(statement.expression);
  }

  void visitBreakStatement(BreakStatement statement) {
    buff.write("break");
  }

  void visitAssignment(Assignment assignment) {
    if (assignment.immutable) {
      buff.write('λlet(λ,"${assignment.reference}",');
      visitExpression(assignment.value);
      buff.write(")");
    } else {
      this.buff.write("λ.${assignment.reference} =");

      if (assignment.value != null) {
        this.visitExpression(assignment.value);
      } else {
        this.buff.write("null");
      }
    }
  }

  @override
  void visitStatement(Statement statement) {
    super.visitStatement(statement);
    if (buff.isNotEmpty && buff.toString()[buff.length - 1] != ";") {
      buff.write(";");
    }
  }

  void visitMethodCall(MethodCall call) {
    if (call.reference is String) {
      buff.write("${call.reference}(");
    } else {
      visitExpression(call.reference);
      buff.write("(");
    }

    for (var exp in call.args) {
      visitExpression(exp);

      if (call.args.indexOf(exp) != call.args.length - 1) {
        buff.write(",");
      }
    }

    buff.write(")");
  }

  void visitStringLiteral(StringLiteral literal) {
    if (literal.components.isEmpty) {
      buff.write('""');
      return;
    }

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

  void visitVariableReference(VariableReference reference, [bool isAccess = false]) {
    if (!isAccess) {
      buff.write("λ.");
    }
    buff.write("${reference.identifier}");
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
    buff.write("{");
    var i = 0;
    for (var entry in definition.entries) {
      visitExpression(entry.key);
      buff.write(":");
      visitExpression(entry.value);

      if (i != definition.entries.length - 1) {
        buff.write(",");
      }

      i++;
    }
    buff.write("}");
  }

  void visitNegate(Negate negate) {
    buff.write("!(");
    visitExpression(negate.expression);
    buff.write(")");
  }

  void visitBooleanLiteral(BooleanLiteral literal) {
    buff.write(literal.value);
  }

  void visitHexadecimalLiteral(HexadecimalLiteral literal) {
    buff.write(literal.asHex());
  }

  void visitOperator(Operator operator) {
    if (operator.op == "~/") {
      buff.write("~~(");
    }

    visitExpression(operator.left);
    buff.write(" ");
    buff.write(makeOperator(operator.op));
    buff.write(" ");

    visitExpression(operator.right);

    if (operator.op == "~/") {
      buff.write(")");
    }
  }

  String makeOperator(String op) {
    if (op == "==") {
      return "===";
    } else if (op == "!=") {
      return "!==";
    } else if (op == "~/") {
      return "/";
    } else {
      return op;
    }
  }

  void visitAccess(Access access) {
    if (access.reference is VariableReference) {
      visitVariableReference(access.reference, true);
    } else {
      visitExpression(access.reference);
    }
    buff.write(".");
    buff.write(access.identifiers.join("."));
  }

  void visitBracketAccess(BracketAccess access) {
    visitExpression(access.reference);
    buff.write("[");
    visitExpression(access.index);
    buff.write("]");
  }

  void visitTernaryOperator(TernaryOperator operator) {
    if (operator.condition is BooleanLiteral) {
      if (operator.condition.value) {
        visitExpression(operator.whenTrue);
      } else {
        visitExpression(operator.whenFalse);
      }

      return;
    }

    buff.write("λbool(");
    visitExpression(operator.condition);
    buff.write(") ? ");
    visitExpression(operator.whenTrue);
    buff.write(" : ");
    visitExpression(operator.whenFalse);
  }

  void visitFunctionDefinition(FunctionDefinition function) {
    this.buff.write("function ${function.name}(");

    if (function.args != null)
      this.buff.write(function.args.join(","));

    var m = ((function.args == null ? [] : function.args) as List).map((it) => '"${it}": ${it}').join(",");
    this.buff.write("){var λ = {${m}};");

    for(var statement in function.block.statements) {
      visitStatement(statement);
    }

    this.buff.write("}");
  }

  void visitAnonymousFunction(AnonymousFunction function) {
    this.buff.write("function(");

    if(function.args != null)
      this.buff.write(function.args.join(","));

    this.buff.write("){");

    for(var statement in function.block.statements) {
      visitStatement(statement);
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
          if (value.hasOwnProperty(i)) {
            block(value[i]);
          }
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

    addGlobal("λbool", """
      function(value) {
        if (value === null || typeof value === "undefined") {
          return false;
        } else if (typeof value === "number") {
          return value !== 0.0 && value !== 0;
        } else if (typeof value === "string") {
          return value.length !== 0;
        } else if (typeof value === "boolean") {
          return value === true;
        } else {
          return true;
        }
      }
    """);

    addGlobal("print", "function(obj) {console.log(obj.toString());}");
    addGlobal("async", "function(cb) {setTimeout(cb, 0);}");
    addGlobal("args", 'typeof process === "undefined" ? [] : process.argv.slice(2)');

    if (isTestSuite) {
      addTopLevel("__tests__", "[]");

      addGlobal("test", """
        function(name, func) {
          __tests__.push([name, func]);
        }
      """);

      if (!generateTeamCityTests) {
        addGlobal("runTests", """
        function() {
          for (var i in __tests__) {
            var t = __tests__[i];

            var name = t[0];
            var func = t[1];

            try {
              func();
            } catch (e) {
              console.log(name + ": Failed");
              console.log(e);
              continue;
            }

            console.log(name + ": Success");
          }
        }
      """);
      } else {
        addGlobal("runTests", """
          function() {
            for (var i in __tests__) {
              var t = __tests__[i];

              var name = t[0];
              var func = t[1];

              var begin = Date.now();
              var end;

              try {
                console.log("##teamcity[testStarted name='" + name + "]");
                func();
                end = Date.now();
              } catch (e) {
                end = Date.now();
                console.log("##teamcity[testFailed name='" + name + " message='" + e.toString() + "' details='" + e.toString() + "]");
                console.log("##teamcity[testFinished name='" + name + "' duration='" + (end - begin) + "']");
                continue;
              }

              console.log("##teamcity[testFinished name='" + name + "' duration='" + (end - begin) + "']");
            }
          }
        """);
      }

      addGlobal("testEqual", """
        function(a, b) {
          if (a !== b) {
            throw "Test Error: " + a + " != " + b;
          }
        }
      """);
    }

    var visitor = new JsAstVisitor(buff);
    visitor.visit(program);

    if (isTestSuite) {
      buff.write(";");
      visitor.visitStatement(new MethodCall("runTests", []));
    }

    return minify(generatePrelude() + buff.toString() + generatePostlude());
  }

  bool generateTeamCityTests = false;

  void addGlobal(String name, String body) {
    _names.add(name);
    _bodies.add(minify(body));
  }

  void addTopLevel(String a, [String b]) {
    if (b == null) {
      _topLevel.add(a);
    } else {
      addTopLevel("var ${a} = ${b}");
    }
  }

  List<String> _topLevel = [];
  Set<String> _includes = new Set<String>();

  String generatePrelude() {
    var x = buff.toString();
    _includes = _names.where((it) => x.contains(it)).toSet();

    var b = new StringBuffer();
    if (_topLevel.isNotEmpty) {
      b.write(_topLevel.join(";"));
      b.write(";");
    }
    b.write('(function(${_includes.join(",")}){var λ = {${_includes.contains("args") ? '"args": args' : ''}};');
    return b.toString();
  }

  final RegExp _WHITESPACE = new RegExp(r'''\s{2,}(?=([^"]*("|')[^"']*("|'))*[^"']*$)''');

  String minify(String input) {
    input = input.trim();
    input = input.replaceAll(_WHITESPACE, "");
    input = input.replaceAll("\n", "");
    input = input.replaceAll(";;", ";");
    return input;
  }

  String generatePostlude() {
    var map = {};

    var i = 0;
    for (var n in _names) {
      if (_includes.contains(n)) {
        map[n] = _bodies[i];
      }
      i++;
    }

    return "})(${_bodies.where((it) => map.values.contains(it)).join(",")});";
  }
}
