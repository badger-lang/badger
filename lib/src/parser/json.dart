part of badger.parser;

class ImportMapEnvironment extends Environment {
  final Map<String, Program> programs;

  ImportMapEnvironment(this.programs);

  @override
  Future<Program> import(String location) async => programs[location];
}

class BadgerSnapshotParser {
  final Map input;

  BadgerSnapshotParser(this.input);

  Map<String, Program> parse() {
    var progs = {};

    for (var loc in input.keys) {
      progs.addAll(go(loc, input[loc]));
    }

    return progs;
  }

  Map<String, Program> go(String name, Map it) {
    if (!it.containsKey("statements") && !it.containsKey("g")) {
      var map = {};
      for (var key in it.keys) {
        var x = go(key, it[key]);
        map[key] = x;
      }
      var c = null;

      if (map["_"].containsKey("_")) {
        c = map["_"]["_"];
      } else {
        c = map["_"];
      }

      map.remove("_");

      map[name] = c;
      return map;
    } else {
      return {
        (name): new BadgerJsonParser().build(it)
      };
    }
  }
}

class BadgerJsonBuilder {
  final Program program;

  BadgerJsonBuilder(this.program);

  Map build() {
    return {
      "declarations": _generateDeclarations(program.declarations),
      "statements": _generateStatements(program.statements)
    };
  }

  List<Map> _generateStatements(List<Statement> input) {
    var statements = [];

    for (var s in input) {
      statements.add(_generateStatement(s));
    }

    return statements;
  }

  List<Map> _generateDeclarations(List<Declaration> declarations) {
    return declarations.map((it) {
      if (it is FeatureDeclaration) {
        return _generateFeatureDeclaration(it);
      } else if (it is ImportDeclaration) {
        return _generateImportDeclaration(it);
      } else {
        throw new Exception("Unable to generate declaration.");
      }
    }).toList();
  }

  Map _generateFeatureDeclaration(FeatureDeclaration decl) {
    return {
      "type": "feature declaration",
      "feature": _generateStringLiteralComponents(decl.feature.components)
    };
  }

  Map _generateImportDeclaration(ImportDeclaration decl) {
    return {
      "type": "import declaration",
      "location": _generateStringLiteralComponents(decl.location.components)
    };
  }

  Map _generateStatement(dynamic statement) {
    if (statement is MethodCall) {
      return {
        "type": "method call",
        "reference": statement.reference is String ? statement.reference : _generateExpression(statement.reference),
        "args": _generateExpressions(statement.args)
      };
    } else if (statement is Assignment) {
      return {
        "type": "assignment",
        "reference": statement.reference is String ? statement.reference : _generateExpression(statement.reference),
        "value": _generateExpression(statement.value),
        "immutable": statement.immutable,
        "isInitialDefine": statement.isInitialDefine
      };
    } else if (statement is FunctionDefinition) {
      return {
        "type": "function definition",
        "identifier": statement.name,
        "block": _generateStatements(statement.block.statements),
        "args": statement.args
      };
    } else if (statement is WhileStatement) {
      return {
        "type": "while",
        "condition": _generateExpression(statement.condition),
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is IfStatement) {
      return {
        "type": "if",
        "condition": _generateExpression(statement.condition),
        "block": _generateStatements(statement.block.statements),
        "else": statement.elseBlock != null ? _generateStatements(statement.elseBlock.statements) : null
      };
    } else if (statement is ForInStatement) {
      return {
        "type": "for in",
        "identifier": statement.identifier,
        "value": _generateExpression(statement.value),
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is ReturnStatement) {
      return {
        "type": "return",
        "value": statement.expression != null ? _generateExpression(statement.expression) : null
      };
    } else if (statement is BreakStatement) {
      return {
        "type": "break"
      };
    } else {
      return _generateExpression(statement);
    }
  }

  List<Map> _generateExpressions(List<Expression> expressions) => expressions.map(_generateExpression).toList();

  Map _generateExpression(Expression expression) {
    if (expression is StringLiteral) {
      return {
        "type": "string literal",
        "components": _generateStringLiteralComponents(expression.components)
      };
    } else if (expression is IntegerLiteral) {
      return {
        "type": "integer literal",
        "value": expression.value
      };
    } else if (expression is DoubleLiteral) {
      return {
        "type": "double literal",
        "value": expression.value
      };
    } else if (expression is HexadecimalLiteral) {
      return {
        "type": "hexadecimal literal",
        "value": expression.value
      };
    } else if (expression is MethodCall) {
      return {
        "type": "method call",
        "reference": expression.reference is String ? expression.reference : _generateExpression(expression.reference),
        "args": _generateExpressions(expression.args)
      };
    } else if (expression is Operator) {
      return {
        "type": "operator",
        "left": _generateExpression(expression.left),
        "right": _generateExpression(expression.right),
        "op": expression.op
      };
    } else if (expression is Negate) {
      return {
        "type": "negate",
        "value": _generateExpression(expression.expression)
      };
    } else if (expression is ListDefinition) {
      return {
        "type": "list definition",
        "elements": _generateExpressions(expression.elements)
      };
    } else if (expression is RangeLiteral) {
      return {
        "type": "range literal",
        "left": _generateExpression(expression.left),
        "right": _generateExpression(expression.right)
      };
    } else if (expression is VariableReference) {
      return {
        "type": "variable reference",
        "identifier": expression.identifier
      };
    } else if (expression is MapDefinition) {
      return {
        "type": "map definition",
        "entries": _generateExpressions(expression.entries)
      };
    } else if (expression is MapEntry) {
      return {
        "type": "map entry",
        "key": _generateExpression(expression.key),
        "value": _generateExpression(expression.value)
      };
    } else if (expression is BracketAccess) {
      return {
        "type": "bracket access",
        "reference": _generateExpression(expression.reference),
        "index": _generateExpression(expression.index)
      };
    } else if (expression is TernaryOperator) {
      return {
        "type": "ternary",
        "condition": _generateExpression(expression.condition),
        "whenTrue": _generateExpression(expression.whenTrue),
        "whenFalse": _generateExpression(expression.whenFalse)
      };
    } else if (expression is AnonymousFunction) {
      return {
        "type": "anonymous function",
        "args": expression.args,
        "block": _generateStatements(expression.block.statements)
      };
    } else if (expression is Access) {
      return {
        "type": "access",
        "reference": _generateExpression(expression.reference),
        "identifiers": expression.identifiers
      };
    } else if (expression is BooleanLiteral) {
      return {
        "type": "boolean literal",
        "value": expression.value
      };
    } else if (expression is NativeCode) {
      return {
        "type": "native code",
        "code": expression.code
      };
    } else {
      throw new Exception("Failed to generate expression for ${expression}");
    }
  }

  List<dynamic> _generateStringLiteralComponents(List<dynamic> components) {
    var cm = [];
    var cn = [];
    for (var c in components) {
      if (c is Expression) {
        if (cn.isNotEmpty) {
          cm.add(cn.join());
          cn.clear();
        }

        cm.add(_generateExpression(c));
      } else {
        cn.add(c);
      }
    }

    if (cn.isNotEmpty) {
      cm.add(cn.join());
      cn.clear();
    }
    return cm;
  }
}

class BadgerJsonParser {
  Program build(Map input) {
    if (!input.containsKey("statements") && input.containsKey("g")) {
      input = TinyAstCompilerTarget.expand(input);
    }

    var declarations = input["declarations"].map(_buildDeclaration).toList();
    var statements = input["statements"].map(_buildStatement).toList();

    return new Program(declarations, statements);
  }

  Declaration _buildDeclaration(Map it) {
    var type = it["type"];

    if (type == "feature declaration") {
      return new FeatureDeclaration(_buildStringLiteral(it["feature"]));
    } else if (type == "import declaration") {
      return new ImportDeclaration(_buildStringLiteral(it["location"]));
    } else {
      throw new Exception("Invalid Declaration");
    }
  }

  dynamic _buildStatement(Map it) {
    var type = it["type"];

    if (type == "method call") {
      return _buildMethodCall(it);
    } else if (type == "assignment") {
      return new Assignment(
        it["reference"] is String ? it["reference"] : _buildExpression(it["reference"]),
        _buildExpression(it["value"]),
        it["immutable"],
        it["isInitialDefine"]
      );
    } else if (type == "function definition") {
      return new FunctionDefinition(it["identifier"], it["args"], new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "while") {
      return new WhileStatement(_buildExpression(it["condition"]), new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "if") {
      return new IfStatement(
        _buildExpression(it["condition"]),
        new Block(it["block"].map(_buildStatement).toList()),
        new Block(it["elseBlock"] == null ? [] : it["elseBlock"].map(_buildStatement).toList())
      );
    } else if (type == "for in") {
      return new ForInStatement(
        it["identifier"],
        _buildExpression(it["value"]),
        new Block(it["block"].map(_buildStatement).toList())
      );
    } else if (type == "return") {
      return new ReturnStatement(
        it["value"] == null ? null : _buildExpression(it["value"])
      );
    } else if (type == "break") {
      return new BreakStatement();
    } else {
      return _buildExpression(it);
    }
  }

  Expression _buildExpression(Map it) {
    var type = it["type"];

    if (type == "string literal") {
      return _buildStringLiteral(it["components"]);
    } else if (type == "variable reference") {
      return new VariableReference(it["identifier"]);
    } else if (type == "method call") {
      return _buildMethodCall(it);
    } else if (type == "integer literal") {
      return new IntegerLiteral(it["value"]);
    } else if (type == "double literal") {
      return new DoubleLiteral(it["value"]);
    } else if (type == "operator") {
      return new Operator(_buildExpression(it["left"]), _buildExpression(it["right"]), it["op"]);
    } else if (type == "negate") {
      return new Negate(_buildExpression(it["value"]));
    } else if (type == "range literal") {
      return new RangeLiteral(_buildExpression(it["left"]), _buildExpression(it["right"]));
    } else if (type == "hexadecimal literal") {
      return new HexadecimalLiteral(it["value"]);
    } else if (type == "boolean literal") {
      return new BooleanLiteral(it["value"]);
    } else if (type == "ternary") {
      return new TernaryOperator(
        _buildExpression(it["condition"]),
        _buildExpression(it["whenTrue"]),
        _buildExpression(it["whenFalse"])
      );
    } else if (type == "access") {
      return new Access(_buildExpression(it["reference"]), it["identifiers"]);
    } else if (type == "map definition") {
      return new MapDefinition(it["entries"].map(_buildExpression).toList());
    } else if (type == "map entry") {
      return new MapEntry(_buildExpression(it["key"]), _buildExpression(it["value"]));
    } else if (type == "list definition") {
      return new ListDefinition(it["elements"].map(_buildExpression).toList());
    } else if (type == "bracket access") {
      return new BracketAccess(_buildExpression(it["reference"]), _buildExpression(it["index"]));
    } else if (type == "anonymous function") {
      return new AnonymousFunction(it["args"], new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "native code") {
      return new NativeCode(it["code"]);
    } else {
      throw new Exception("Failed to build expression for ${it}");
    }
  }

  MethodCall _buildMethodCall(Map it) {
    var ref = it["reference"];
    var args = it["args"].map(_buildExpression).toList();

    if (ref is Map) {
      ref = _buildExpression(ref);
    }

    return new MethodCall(ref, args);
  }

  StringLiteral _buildStringLiteral(List components) {
    var c = [];
    for (var m in components) {
      if (m is String) {
        c.add(m);
      } else {
        c.add(_buildExpression(m));
      }
    }
    return new StringLiteral(c);
  }
}
