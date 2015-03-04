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
        "block": _generateStatements(statement.block.statements)
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
