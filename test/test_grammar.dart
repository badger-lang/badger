import "package:badger/parser.dart";
import "package:petitparser/debug.dart";

import "dart:convert";
import "package:petitparser/petitparser.dart";

const String input = """
import "badger:io"

stdout.write("> ")

stdin.handleLine((line) -> {
  if line == ":exit" {
    exit(0)
  }

  try {
    eval(line)
  } catch (e) {
    print(e)
  }

  stdout.write("> ")
})
""";

void main() {
  var parser = new BadgerGrammar();
  parser = profile(parser);

  var result = parser.parse(input);

  transformer(o) {
    if (o is Token) {
      return transformer((o as Token).value);
    }
    return o;
  };

  var encoder = new JsonEncoder.withIndent("  ", transformer);
  print(encoder.convert(result.value));
}
