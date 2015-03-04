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
  var jb = new BadgerJsonBuilder(program);
  var asJson = jb.build();
  var jp = new BadgerJsonParser(asJson);
  print(new JsonEncoder.withIndent("  ").convert(asJson));
  print(jp.build());
}
