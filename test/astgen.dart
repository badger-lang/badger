import "package:badger/parser.dart";

void main() {
  var b = new BadgerBuilder();
  b.function("hello", [], [
    new ExpressionStatement(
      new MethodCall(
        new Identifier("print"),
        [
          new StringLiteral.fromString("Hello World")
        ]
      )
    )
  ]);
  b.callMethod("hello", []);
  print(new BadgerPrinter(b.program).print());
}
