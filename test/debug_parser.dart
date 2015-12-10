import "package:badger/parser.dart";
import "package:petitparser/debug.dart";

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
  var parser = new BadgerParser();
  //parser = profile(parser);

  var result = parser.parse(input);
  print(result.value);
}
