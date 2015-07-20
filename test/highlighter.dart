import "package:badger/parser.dart";

const String input = r"""
let x = 0

let list = [
  "Hello",
  "World",
  1,
  2,
  3,
  0xDEADBEEF,
  2.0
]

for n in list {
  print(n)
}

if true {
  print("True!")
}

if false {
  print("Wut?")
}

print(x)
print("This is a string: $(x)")
""";

void main() {
  var parser = new BadgerParser();
  var program = parser.parse(input).value;
  var highlighter = new BadgerHighlighter(new ConsoleHighlighterScheme(), program: program);
  var out = highlighter.print();
  print(out);
}
