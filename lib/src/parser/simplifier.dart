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
    }

    return operator;
  }
}
