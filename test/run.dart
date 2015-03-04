import "dart:io";
import "package:badger/parser.dart";
import "package:badger/eval.dart";

void main() {
  var dir = new Directory("test/scripts");

  for (File file in dir.listSync(recursive: true).where((it) => it is File && it.path.endsWith(".badger"))) {
    var content = file.readAsStringSync();
    var name = file.path.replaceAll(dir.path, "");
    print("== Script ${name} ==");
    var parser = new BadgerParser();
    var result = parser.parse(content);

    if (result.isFailure) {
      print("FAILED TO PARSE: ${result}");
      exit(1);
    }

    var program = result.value;
    var evaluator = new Evaluator(program);
    var context = new Context();
    StandardLibrary.import(context);
    IOLibrary.import(context);
    evaluator.eval(context);
  }
}
