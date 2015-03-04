import "dart:io";
import "package:badger/eval.dart";

main() async {
  var dir = new Directory("test/scripts");
  var context = new Context();
  StandardLibrary.import(context);
  IOLibrary.import(context);
  TestingLibrary.import(context);

  await for (File file in dir.list(recursive: true).where((it) => it is File && it.path.endsWith(".badger"))) {
    var content = await file.readAsString();
    var name = file.path.replaceAll(dir.path + "/", "");

    if (name.startsWith("imports/") || name.startsWith("prototype/")) {
      continue;
    }

    var env = new FileEnvironment(file);
    await env.eval(context);
  }

  await context.run(() async {
    await context.invoke("runTests", []);
  });
}

