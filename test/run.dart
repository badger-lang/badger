import "dart:io";
import "package:badger/eval.dart";

main() async {
  var dir = new Directory("test/scripts");

  await for (File file in dir.list(recursive: true).where((it) => it is File && it.path.endsWith(".badger"))) {
    var name = file.path.replaceAll(dir.path + "/", "");

    if (name.startsWith("imports/") || name.startsWith("prototype/")) {
      continue;
    }

    var env = new FileEnvironment(file);
    {
      var context = new Context();
      StandardLibrary.import(context);
      IOLibrary.import(context);
      TestingLibrary.import(context);
      await env.eval(context);
      await context.run(() async {
        await context.invoke("runTests", ["Parser AST"]);
      });
    }

    {
      var context = new Context();
      StandardLibrary.import(context);
      IOLibrary.import(context);
      TestingLibrary.import(context);
      await env.buildEvalJSON(context);
      await context.run(() async {
        await context.invoke("runTests", ["JSON AST"]);
      });
    }
  }
}

