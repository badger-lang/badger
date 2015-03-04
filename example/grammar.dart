import "dart:io";
import "package:badger/parser.dart";

main() {
  var file = new File("example/test.badger");
  var content = file.readAsStringSync();
  var parser = new BadgerGrammar();
  var result = parser.parse(content);

  if (result.isFailure) {
    throw new Exception(result.toString());
  }

  print(result.value);
}
