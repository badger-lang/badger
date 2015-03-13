import "package:badger/parser.dart";

const String A = """
import "badger:io"

print("Hello World")
""";

const String B = """
import "badger:io"

print("Hello" + " " + "World")
""";

main() async {
  var parser = new BadgerParser();

  var a = parser.parse(A).value;
  var b = parser.parse(B).value;
  var differ = new BadgerDiffer(a, b);
  print("Has Difference: ${differ.hasDifference()}");
}
