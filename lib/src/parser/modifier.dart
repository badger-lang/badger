part of badger.parser;

class BadgerModifier {
  Program modify(Program program) {
    var declarations = program.declarations.map(modifyDeclaration).where((it) => it != null).toList();
    var statements = program.statements
      .map(modifyStatement)
      .where((it) => it != null)
      .toList();

    return new Program(declarations, statements);
  }

  Declaration modifyImportDeclaration(ImportDeclaration declaration) {
    return declaration;
  }

  Declaration modifyDeclaration(Declaration declaration) {
    if (declaration is ImportDeclaration) {
      return modifyImportDeclaration(declaration);
    } else {
      return declaration;
    }
  }

  dynamic modifyMethodCall(MethodCall call) {
    var ref = call.reference;
    var args = call.args;
    var nargs = [];

    if (ref is Expression) {
      ref = modifyExpression(ref);
    }

    for (var a in args) {
      nargs.add(modifyExpression(a));
    }

    return new MethodCall(ref, nargs);
  }

  Expression modifyVariableReference(VariableReference reference) {
    return reference;
  }

  Statement modifyAssignment(Assignment assignment) {
    var value = modifyExpression(assignment.value);
    var ref = assignment.reference;

    if (ref is Expression) {
      ref = modifyExpression(ref);
    }

    return new Assignment(ref, value, assignment.immutable, assignment.isInitialDefine, assignment.isNullable);
  }

  Statement modifyMultiAssignment(MultiAssignment assignment) {
    return assignment;
  }

  Expression modifyAccess(Access access) {
    return access;
  }

  Statement modifyStatement(Statement statement) {
    if (statement is ExpressionStatement) {
      return modifyExpressionStatement(statement);
    } else if (statement is Assignment) {
      return modifyAssignment(statement);
    } else if (statement is MultiAssignment) {
      return modifyMultiAssignment(statement);
    } else if (statement is FunctionDefinition) {
      return modifyFunctionDefinition(statement);
    } else if (statement is ForInStatement) {
      return modifyForInStatement(statement);
    } else if (statement is IfStatement) {
      return modifyIfStatement(statement);
    } else if (statement is WhileStatement) {
      return modifyWhileStatement(statement);
    } else {
      return statement;
    }
  }

  Statement modifyExpressionStatement(ExpressionStatement statement) {
    var c = modifyExpression(statement.expression);
    return new ExpressionStatement(c);
  }

  Statement modifyForInStatement(ForInStatement statement) {
    var expr = modifyExpression(statement.value);
    var statements = statement.block.statements.map(modifyStatement).where((it) => it != null).toList();
    return new ForInStatement(statement.identifier, expr, new Block(statements));
  }

  Statement modifyWhileStatement(WhileStatement statement) {
    var expr = modifyExpression(statement.condition);
    var statements = statement.block.statements.map(modifyStatement).where((it) => it != null).toList();
    return new WhileStatement(expr, new Block(statements));
  }

  Statement modifyIfStatement(IfStatement statement) {
    var expr = modifyExpression(statement.condition);
    var ifStatements = statement.block.statements.map(modifyStatement).where((it) => it != null).toList();
    var elseStatements = statement.elseBlock != null ? statement.elseBlock.statements.map(modifyStatement).where((it) => it != null).toList() : null;

    return new IfStatement(expr, new Block(ifStatements), elseStatements != null ? new Block(elseStatements) : null);
  }

  Expression modifyExpression(Expression expression) {
    if (expression is MethodCall) {
      return modifyMethodCall(expression);
    } else if (expression is IntegerLiteral) {
      return modifyIntegerLiteral(expression);
    } else if (expression is DoubleLiteral) {
      return modifyDoubleLiteral(expression);
    } else if (expression is StringLiteral) {
      return modifyStringLiteral(expression);
    } else if (expression is Operator) {
      return modifyOperator(expression);
    } else if (expression is HexadecimalLiteral) {
      return modifyHexadecimalLiteral(expression);
    } else if (expression is RangeLiteral) {
      return modifyRangeLiteral(expression);
    } else if (expression is BooleanLiteral) {
      return modifyBooleanLiteral(expression);
    } else if (expression is AnonymousFunction) {
      return modifyAnonymousFunction(expression);
    } else {
      return expression;
    }
  }

  Expression modifyOperator(Operator operator) {
    var left = modifyExpression(operator.left);
    var right = modifyExpression(operator.right);

    return new Operator(left, right, operator.op);
  }

  Expression modifyIntegerLiteral(IntegerLiteral literal) {
    return literal;
  }

  Expression modifyRangeLiteral(RangeLiteral literal) {
    return literal;
  }

  Expression modifyHexadecimalLiteral(HexadecimalLiteral literal) {
    return literal;
  }

  Expression modifyDoubleLiteral(DoubleLiteral literal) {
    return literal;
  }

  Expression modifyParentheses(Parentheses parens) {
    return parens;
  }

  Expression modifyBooleanLiteral(BooleanLiteral literal) {
    return literal;
  }

  Statement modifyFunctionDefinition(FunctionDefinition definition) {
    var statements = definition.block.statements.map(modifyStatement).where((it) => it != null).toList();
    return new FunctionDefinition(definition.name, definition.args, new Block(statements));
  }

  Expression modifyAnonymousFunction(AnonymousFunction function) {
    var statements = function.block.statements.map(modifyStatement).where((it) => it != null).toList();

    return new AnonymousFunction(function.args, new Block(statements));
  }

  Expression modifyStringLiteral(StringLiteral literal) {
    var c = [];

    for (var part in literal.components) {
      if (part is Expression) {
        var r = modifyExpression(part);

        if (r != null) {
          c.add(modifyExpression(part));
        }
      } else {
        c.add(part);
      }
    }

    return new StringLiteral(c);
  }
}
