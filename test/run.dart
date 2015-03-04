import "dart:io";
import "package:badger/parser.dart";
import "package:badger/eval.dart";

void main() {
  var dir = new Directory("test/scripts");

  for (File file in dir.listSync(recursive: true).where((it) => it is File && it.path.endsWith(".badger"))) {
    var content = file.readAsStringSync();
    var name = file.path.replaceAll(dir.path + "/", "");

    if (name.startsWith("imports/")) {
      continue;
    }

    print("== Script ${name} ==");

    var env = new FileEnvironment(file);
    var context = new Context();
    StandardLibrary.import(context);
    IOLibrary.import(context);
    TestingLibrary.import(context);
    env.eval(context);
  }
}
