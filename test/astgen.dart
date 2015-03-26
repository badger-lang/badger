import "package:badger/parser.dart";

void main() {
  var b = new BadgerBuilder();
  b.function("hello", [], [
    new ExpressionStatement.forMethodCall("print", [
      new StringLiteral.forString("Hello World")
    ])
  ]);
  b.callMethod("hello", []);
  print(new BadgerPrinter(b.program).print());
}
