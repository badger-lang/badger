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
}
