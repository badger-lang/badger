part of badger.parser;

class BadgerSimplifier extends BadgerModifier {
  @override
  modifyIfStatement(IfStatement statement) {
    statement = super.modifyIfStatement(statement);

    if (statement.condition is BooleanLiteral) {
      var c = (statement.condition as BooleanLiteral).value;

      if (c == false && statement.elseBlock == null) {
        return null; // Get rid of this.
      }
    }

    return statement;
  }

  @override
  modifyExpressionStatement(ExpressionStatement statement) {
    return statement;
  }

  @override
  modifyWhileStatement(WhileStatement statement) {
    statement = super.modifyWhileStatement(statement);

    if (statement.condition is BooleanLiteral) {
      var c = (statement.condition as BooleanLiteral).value;

      if (c == false) {
        return null; // Get rid of this.
      }
    }

    return statement;
  }

  @override
  modifyOperator(Operation operator) {
    operator = super.modifyOperator(operator);
    if (operator.left is NumberLiteral && operator.right is NumberLiteral) {
      var left = (operator.left as NumberLiteral).value;
      var right = (operator.right as NumberLiteral).value;
      var op = operator.op;

      switch (op) {
        case "==":
          return new BooleanLiteral(left == right);
        case "!=":
          return new BooleanLiteral(left != right);
        case "+":
          return NumberLiteral.create(left + right);
        case "-":
          return NumberLiteral.create(left - right);
        case "*":
          return NumberLiteral.create(left * right);
        case "/":
          return NumberLiteral.create(left / right);
        case "~/":
          return NumberLiteral.create(left ~/ right);
        case "<=":
          return new BooleanLiteral(left <= right);
        case ">=":
          return new BooleanLiteral(left >= right);
        case "<":
          return new BooleanLiteral(left < right);
        case ">":
          return new BooleanLiteral(left > right);
        case "<<":
          return NumberLiteral.create(left << right);
        case ">>":
          return NumberLiteral.create(left >> right);
        case "|":
          return NumberLiteral.create(left | right);
        case "&":
          return NumberLiteral.create(left & right);
      }
    } else if (operator.left is StringLiteral && operator.right is StringLiteral) {
      var left = operator.left as StringLiteral;
      var right = operator.right as StringLiteral;

      switch (operator.op) {
        case "+":
          return new StringLiteral([]..addAll(left.components)..addAll(right.components));
      }
    } else if (operator.left is StringLiteral && operator.right is NumberLiteral) {
      var left = operator.left as StringLiteral;
      var right = operator.right as NumberLiteral;

      switch (operator.op) {
        case "+":
          return new StringLiteral([]..addAll(left.components)..addAll(right.value.toString().split("")));
      }
    } else if (operator.left is StringLiteral && operator.right is BooleanLiteral) {
      var left = operator.left as StringLiteral;
      var right = operator.right as BooleanLiteral;

      switch (operator.op) {
        case "+":
          return new StringLiteral([]..addAll(left.components)..addAll(right.value.toString().split("")));
      }
    }

    return operator;
  }
}
