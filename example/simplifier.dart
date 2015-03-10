import "package:badger/parser.dart";

void main() {
  var parser = new BadgerParser();

  var program = parser.parse("""
  import "badger:io"

  print(1 + 2)
  print(1.5 + 1.5)
  print(2 * 2)
  print(3 * 5)
  print(10 / 5)
  print(10 ~/ 5)
  print(5 / 5)
  print(5 << 5)
  print(5 >> 5)
  print(5 | 5)
  print(5 & 5)
  print("Hello" + " " + "World")
  print("Boolean: " + true)
  """).value;

  var simplifier = new BadgerSimplifier();
  program = simplifier.modify(program);
  var printer = new BadgerAstPrinter(program);
  print(printer.print());
}
