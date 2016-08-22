import "package:badger/parser.dart";

const String input = r"""
func ack(m, n) {
  n = n + 1

  var stack = []

  while true {
    if m == 0 {
      if stack.length == 1 {
        return n + 1
      } else {
        m = (stack.removeLast()) - 1
        n = n + 1
      }
    } else {
      if n == 0 {
        m = m - 1
        n = 1
      } else {
        stack.add(m)
        n = n - 1
      }
    }
  }
}

print(ack(3, 4))
""";

void main() {
  var parser = new BadgerParser();
  var program = parser.parse(input).value;
  var highlighter = new BadgerHighlighter(new ConsoleHighlighterScheme(), program: program);
  var out = highlighter.print();
  print(out.trim());
}
