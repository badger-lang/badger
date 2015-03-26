import "package:badger/parser.dart";

const String INPUT = """
class A {}

class B extends A {}

class C {
  hi() {
    print("Hello")
  }
}

class D extends C {
  hi() {
    print("Goodbye")
  }
}

try {
  print("Try")
} catch (e) {
  print("Catch")
}

while true {
  print("Loop")
}

if true {
  print("Hello")
}

for x in 5..10 {
  print(x)
}

print(5 * 5)
print(5 + 5)
print(5 / 5)
print(5 ~/ 5)
print(5 | 5)
print(5 & 5)
print(true || false)
print(true && false)
""";

void main() {
  var parser = new BadgerParser();
  var program = parser.parse(INPUT).value;
  print(program.toSource(pretty: false));
}
