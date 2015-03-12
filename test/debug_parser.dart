import "package:badger/parser.dart";
import "package:petitparser/debug.dart";

const String input = """
let bus = EventBus()

bus.on("hello", () -> {
  print("Hello World!")
})

bus.emit("hello")

async(() => bus.emit("test", "This is a test."))

let event = bus.nextEvent("test")

print(event)
""";

void main() {
  var parser = new BadgerParser();
  parser = profile(parser);

  var result = parser.parse(input);
  print(result.value);
}
