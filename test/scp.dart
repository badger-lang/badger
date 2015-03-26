import "package:badger/parser.dart";

const String INPUT = """
print(5 + 5)
""";

void main() {
  var parser = new BadgerParser();
  Program program = parser.parse(INPUT).value;
  var call = (program.statements.first as ExpressionStatement).expression as MethodCall;
  print(call.token);
}
