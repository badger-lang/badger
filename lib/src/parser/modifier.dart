part of badger.parser;

class BadgerModifier {
  Program modify(Program program) {
    var declarations = program.declarations.map(modifyDeclaration).toList();
    var statements = program.statements.map((it) => it is Statement ? modifyStatement(it) : modifyExpression(it)).toList();

    return new Program(declarations, statements);
  }

  Declaration modifyImportDeclaration(ImportDeclaration declaration) {
    return declaration;
  }

  Declaration modifyDeclaration(Declaration declaration) {
    if (declaration is ImportDeclaration) {
      return modifyDeclaration(declaration);
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

  Expression modifyAccess(Access access) {
    return access;
  }

  Statement modifyStatement(Statement statement) {
    if (statement is MethodCall) {
      return modifyMethodCall(statement);
    } else if (statement is Assignment) {
      return modifyAssignment(statement);
    } else {
      return statement;
    }
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

  Expression modifyDoubleLiteral(DoubleLiteral literal) {
    return literal;
  }

  Expression modifyStringLiteral(StringLiteral literal) {
    var c = [];

    for (var part in literal.components) {
      if (part is Expression) {
        c.add(modifyExpression(part));
      } else {
        c.add(part);
      }
    }

    return new StringLiteral(c);
  }
}
