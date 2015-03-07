part of badger.compiler;

class JsAstVisitor extends AstVisitor {
  StringBuffer buff;

  JsAstVisitor(this.buff);

  void visitForInStatement(ForInStatement statement) {
    buff.write('λfor(function(${statement.identifier}, λ){λlet(λ, "${statement.identifier}", ${statement.identifier});');

    for (var s in statement.block.statements) {
      visitStatement(s);

      if (statement.block.statements.indexOf(statement) != statement.block.statements.length - 1) {
        buff.write(";");
      }
    }

    buff.write("},");
    visitExpression(statement.value);
    buff.write(", λ)");
  }

  void visitImportDeclaration(ImportDeclaration declaration) {
  }

  void visitFeatureDeclaration(FeatureDeclaration declaration) {
  }

  void visitIfStatement(IfStatement statement) {
    if (
      (statement.condition is BooleanLiteral && (statement.condition as BooleanLiteral).value == false) ||
      statement.block == null ||
      statement.block.statements.isEmpty
    ) {
      return;
    }

    buff.write("λif(λ,");
    visitExpression(statement.condition);
    buff.write(",function(λ){");
    for (var s in statement.block.statements) {
      visitStatement(s);

      if (statement.block.statements.indexOf(statement) != statement.block.statements.length - 1) {
        buff.write(";");
      }
    }
    buff.write("}");
    if (statement.elseBlock != null) {
      buff.write(",function(λ){");
      for (var s in statement.elseBlock.statements) {
        visitStatement(s);

        if (statement.elseBlock.statements.indexOf(statement) != statement.elseBlock.statements.length - 1) {
          buff.write(";");
        }
      }
      buff.write("}");
    }
    buff.write(")");
  }

  void visitWhileStatement(WhileStatement statement) {
    if (
      (statement.condition is BooleanLiteral && (statement.condition as BooleanLiteral).value == false) ||
      statement.block == null ||
      statement.block.statements.isEmpty
    ) {
      return;
    }

    buff.write("λwhile(λ,");
    visitExpression(statement.condition);
    buff.write(",function(λ){");
    for (var s in statement.block.statements) {
      visitStatement(s);

      if (statement.block.statements.indexOf(statement) != statement.block.statements.length - 1) {
        buff.write(";");
      }
    }
    buff.write("})");
  }

  void visitReturnStatement(ReturnStatement statement) {
    this.buff.write("return ");
    this.visitExpression(statement.expression);
  }

  void visitBreakStatement(BreakStatement statement) {
    buff.write("throw λbreaker;");
  }

  void visitAssignment(Assignment assignment) {
    if (assignment.immutable) {
      buff.write('λlet(λ,"${assignment.reference}",');
      visitExpression(assignment.value);
      buff.write(")");
    } else {
      buff.write("λ.${assignment.reference} =");

      if (assignment.value != null) {
        visitExpression(assignment.value);
      } else {
        buff.write("null");
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
    buff.write("λ.");
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
    if (literal.components.every((c) => c is Expression)) {
      var i = 0;
      for (var x in literal.components) {
        buff.write("(");
        visitExpression(x);
        buff.write(")");
        buff.write(".toString()");

        if (i != literal.components.length - 1) {
          buff.write("+");
        }

        i++;
      }
      return;
    }

    if (literal.components.isEmpty) {
      buff.write('""');
      return;
    }

    var i = 0;
    for (var c in literal.components) {
      if (c is String) {
        if (i == 0) {
          buff.write('"');
        }

        buff.write(c);

        if (i == literal.components.length - 1) {
          buff.write('"');
        }
      } else {
        if (i != 0) {
          buff.write('"+');
        }

        visitExpression(c);

        if (i == 0) {
          buff.write("+");
        }

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
    buff.write("λ.");
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
      if ((operator.condition as BooleanLiteral).value) {
        visitExpression(operator.whenTrue);
      } else {
        visitExpression(operator.whenFalse);
      }

      return;
    }
    
    visitExpression(operator.condition);
    buff.write(" ? ");
    visitExpression(operator.whenTrue);
    buff.write(" : ");
    visitExpression(operator.whenFalse);
  }

  void visitFunctionDefinition(FunctionDefinition function) {
    this.buff.write("λ.${function.name} = function(");

    if (function.args != null) {
      this.buff.write(function.args.join(","));
    }

    var m = ((function.args == null ? [] : function.args) as List).map((it) => '"${it}": ${it}').join(",");
    buff.write("){λload(λ, {${m}});");

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

  @override
  void visitNativeCode(NativeCode code) {
    // TODO(kaendfinger): Look into a safer way to do this.
    buff.write(code.code);
  }

  @override
  void visitDefined(Defined defined) {
    buff.write('λ.hasOwnProperty("${defined.identifier}")');
  }

  @override
  void visitParentheses(Parentheses parens) {
    buff.write("(");
    visitExpression(parens.expression);
    buff.write(")");
  }
}

class JsCompilerTarget extends CompilerTarget<String> {

  StringBuffer buff = new StringBuffer();
  List<String> _names = <String>[];
  List<String> _bodies = <String>[];

  JsCompilerTarget();

  @override
  Future<String> compile(Program program) async {
    var isTestSuite = options["isTestSuite"] == true;
    var addHooks = options["hooks"] == true;
    var generateTeamCityTests = options["teamcity"] == true;

    addHelper("λlet", """
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

    addHelper("λfor", """
      function(b, v, λ) {
        for (var i = 0; i < v.length; i++) {
          try {
            b(v[i], Object.create(λ));
          } catch (e) {
            if (e === BADGER_BREAK_NOW) {
              break;
            }
          }
        }
      }
    """);

    addHelper("λwhile", """
      function(λ, c, t) {
        while (λbool(c)) {
          try {
            t(Object.create(λ));
          } catch (e) {
            if (e === λbreaker) {
              break;
            }
          }
        }
      }
    """);

    addHelper("λif", """
      function(λ, c, t, f) {
        if (λbool(c)) {
          t(Object.create(λ));
        } else if (typeof f !== "undefined") {
          f(Object.create(λ));
        }
      }
    """);

    addHelper("λrange", """
      function(l, u) {
        var m = [];
        for (var i = l; i <= u; i++) {
          m.push(i);
        }
        return m;
      }
    """);

    addTopLevel("λbool", """
      function(value) {
        if (value === null || typeof value === "undefined") {
          return false;
        } else if (typeof value === "number") {
          return value !== 0.0 && value !== 0;
        } else if (typeof value === "string") {
          return value.length !== 0;
        } else if (typeof value === "boolean") {
          return value;
        } else {
          return true;
        }
      }
    """, true);

    addTopLevel("λbreaker", """
    "BADGER_BREAK_NOW"
    """);

    addHelper("λload", """
      function(λ, m) {
        Object.keys(m).forEach(function(k) {
          λ[k] = m[k];
        });
      }
    """);

    if (addHooks) {
      addGlobal("print", 'function(obj) {(typeof badgerPrint !== "undefined" ? badgerPrint : console.log)(obj.toString());}');
    } else {
      addGlobal("print", 'function(obj) {console.log(obj.toString());}');
    }
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

    return minify(generatePrelude() + buff.toString() + generatePostlude()).replaceAll(new RegExp(r"(\λ\.)+(\λ)"), "λ");
  }

  void addHelper(String name, String body) {
    _names.add(name);
    _bodies.add(minify(body));
  }

  void addGlobal(String name, String body) {
    _globals.add([name, body]);
  }

  List<List<String>> _globals = [];

  void addTopLevel(String a, [String b, bool always = false]) {
    if (b == null) {
      _topLevel.add([a]);
    } else {
      _topLevel.add([a, b, always]);
    }
  }

  List<List<String>> _topLevel = [];
  Set<String> _includes = new Set<String>();

  String generatePrelude() {
    var str = buff.toString();
    var x = buff.toString();
    _includes = _names.where((it) => x.contains(it)).toSet();

    var ti = _topLevel.where((it) => str.contains(it[0]) || it.length == 3 && it[2] == true).toList();
    var b = new StringBuffer();
    if (ti.isNotEmpty) {
      b.write(ti.map((it) => it.length == 1 ? it[0] : "var ${it[0]} = " + it[1]).join(";"));
      b.write(";");
    }
    var n = ["λ"];
    n.addAll(_includes.toList());
    b.write('(function(${n.join(",")}){');

    if (options["hooks"] == true) {
      b.write('typeof badgerInjectGlobal !== "undefined" ? badgerInjectGlobal(λ) : null;');
    }

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
    var str = buff.toString();
    var map = {};
    var ctx = "{";

    var used = _globals.where((it) => str.contains(it[0])).toList();
    ctx += used.map((it) {
      var name = it[0];
      var body = it[1];

      return '"${name}"' + ':' + '${body}';
    }).join(",");

    ctx += "}";

    var i = 0;
    for (var n in _names) {
      if (_includes.contains(n)) {
        map[n] = _bodies[i];
      }
      i++;
    }

    var c = [ctx];
    c.addAll(_bodies.where((it) => map.values.contains(it)));

    return "})(${c.join(",")});";
  }
}
