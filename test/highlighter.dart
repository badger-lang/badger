import "package:badger/parser.dart";

const String input = """
let x = 0

for l in [1, 2, 3] {
  print(l)
}

print(x)
print("Done")
""";

void main() {
  var parser = new BadgerParser();
  var program = parser.parse(input).value;
  var highlighter = new BadgerHighlighter(new ConsoleBadgerHighlighterScheme(), program);
  var out = highlighter.print();
  print(out);
}
