import "dart:io";
import "package:badger/parser.dart";
import "package:badger/compiler.dart";

main() {
  var file = new File("example/test.badger");
  var content = file.readAsStringSync();
  var parser = new BadgerParser();
  var result = parser.parse(content);

  if (result.isFailure) {
    throw new Exception(result.toString());
  }

  var value = result.value;

  var target = new JsTarget();
  var js = target.compile(value);
  print(js.trim());
}
