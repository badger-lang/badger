import "dart:convert";
import "dart:io";
import "package:badger/parser.dart";
import "package:badger/eval.dart";

main() {
  var file = new File("example/test.badger");
  var content = file.readAsStringSync();
  var parser = new BadgerParser();
  var result = parser.parse(content);

  if (result.isFailure) {
    throw new Exception(result.toString());
  }

  var program = result.value;
  var j = new BadgerJsonBuilder(program);
  print(new JsonEncoder.withIndent("  ").convert(j.build()));
}
