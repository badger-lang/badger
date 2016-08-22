import "package:badger/parser.dart";
import "package:petitparser/debug.dart";

const String input = r"""
print()
""";

void main() {
  var parser = new BadgerGrammar();
  parser = trace(parser, (msg) {
    print(msg.toString().trim());
  });

  var result = parser.parse(input);
  print(result.value);
}
