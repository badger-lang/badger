part of badger.parser;

class BadgerSimplifier extends BadgerModifier {
  @override
  modifyOperator(Operator operator) {
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
