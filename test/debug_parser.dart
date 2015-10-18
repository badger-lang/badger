import "package:badger/parser.dart";
import "package:petitparser/debug.dart";

const String input = """
print("Hello World")
""";

void main() {
  var parser = new BadgerParser();
  parser = trace(parser);

  var result = parser.parse(input);
  print(result.value);
}
