part of badger.parser;

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

  Map _generateStatement(Statement statement) {
    if (statement is MethodCall) {
      return {
        "type": "method call",
        "identifier": statement.identifier,
        "args": _generateExpressions(statement.args)
      };
    } else if (statement is Assignment) {
      return {
        "type": "assignment",
        "identifier": statement.identifier,
        "value": _generateExpression(statement.value),
        "immutable": statement.immutable
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
      throw new Exception("Failed to generate statement.");
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
    } else if (expression is MethodCall) {
      return {
        "type": "method call",
        "identifier": expression.identifier,
        "args": _generateExpressions(expression.args)
      };
    } else if (expression is ListDefinition) {
      return {
        "type": "list definition",
        "elements": _generateExpressions(expression.elements)
      };
    } else if (expression is VariableReference) {
      return {
        "type": "variable reference",
        "identifier": expression.identifier
      };
    } else if (expression is BracketAccess) {
      return {
        "type": "bracket access",
        "reference": _generateExpression(expression.reference),
        "index": _generateExpression(expression.index)
      };
    } else {
      throw new Exception("Failed to generate expression.");
    }
  }

  Map _generateStringLiteralComponents(List<dynamic> components) {
    var cm = [];
    for (var c in components) {
      if (c is Expression) {
        cm.add(_generateExpression(c));
      } else {
        cm.add(c);
      }
    }
    return cm;
  }
}

class BadgerJsonParser {
  final Map<String, dynamic> input;

  BadgerJsonParser(this.input);

  Program build() {
    var declarations = input["declarations"].map(_buildDeclaration).toList();
    var statements = input["statements"].map(_buildStatement).toList();

    return new Program(declarations, statements);
  }

  Declaration _buildDeclaration(Map it) {
    var type = it["type"];

    if (type == "feature declaration") {
      return new FeatureDeclaration(_buildStringLiteral(it["feature"]));
    } else {
      throw new Exception("Invalid Declaration");
    }
  }

  Statement _buildStatement(Map it) {
    var type = it["type"];

    if (type == "method call") {
      return _buildMethodCall(it);
    } else if (type == "assignment") {
      return new Assignment(it["identifier"], _buildExpression(it["value"]), it["immutable"]);
    } else if (type == "function definition") {
      return new FunctionDefinition(it["identifier"], it["args"], it["block"].map(_buildStatement).toList());
    } else if (type == "while") {
      return new WhileStatement(_buildExpression(it["condition"]), it["block"].map(_buildStatement).toList());
    } else if (type == "if") {
      return new IfStatement(
        _buildExpression(it["condition"]),
        it["block"].map(_buildStatement).toList(),
        it["elseBlock"] == null ? null : it["elseBlok"].map(_buildStatement).toList()
      );
    } else if (type == "for in") {
      return new ForInStatement(
        it["identifier"],
        _buildExpression(it["value"]),
        it["block"].map(_buildStatement).toList()
      );
    } else if (type == "return") {
      return new ReturnStatement(
        it["value"] == null ? null : _buildExpression(it["value"])
      );
    } else if (type == "break") {
      return new BreakStatement();
    } else {
      throw new Exception("Failed to build statement.");
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
    } else if (type == "list definition") {
      return new ListDefinition(it["elements"].map(_buildExpression).toList());
    } else if (type == "bracket access") {
      return new BracketAccess(_buildExpression(it["reference"]), _buildExpression(it["index"]));
    } else {
      throw new Exception("Failed to build expression.");
    }
  }

  MethodCall _buildMethodCall(Map it) {
    var id = it["identifier"];
    var args = it["args"].map(_buildExpression).toList();

    return new MethodCall(id, args);
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
