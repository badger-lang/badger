import "package:badger/parser.dart";

const String input = r"""
func greet(name) {
  return "Hello $(name)"
}

let names = ["Kenneth", "Logan", "Sam", "Mike"]

for name in names {
  print(greet(name))
}
""";

void main() {
  var parser = new BadgerParser();
  var program = parser.parse(input).value;
  var resolver = new BadgerResolver();
  var node = resolver.resolve(program);
  var allNodes = node.getChildrenRecursive();
  for (var node in allNodes) {
    var vars = node.variables;
    print(vars);
  }
}
