import "package:badger/parser.dart";

void main() {
  var f = new ForInStatement(
    new Identifier("test"),
    new RangeLiteral.create(5, 10),
    new Block.forSingle(
      new ExpressionStatement.forMethodCall(
        new Identifier("print"),
        [
          new VariableReference.forString("test")
        ]
      )
    )
  );

  print(f.toSource());

  var o = new Operation.add(NumberLiteral.create(1), NumberLiteral.create(2));
  print(o.simplify());
}
