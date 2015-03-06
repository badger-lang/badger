import "dart:io";
import "package:badger/eval.dart";
import "package:badger/compiler.dart";

main() async {
  var dir = new Directory("test/scripts");

  await for (File file in dir.list(recursive: true).where((it) => it is File && it.path.endsWith(".badger"))) {
    var name = file.path.replaceAll(dir.path + "/", "");

    if (name.startsWith("imports/") || name.startsWith("prototype/")) {
      continue;
    }

    var env = new FileEnvironment(file);

    var context = new Context();
    StandardLibrary.import(context);
    IOLibrary.import(context);
    TestingLibrary.import(context);
    print("[Parser Tests]");
    await env.eval(context);

    await context.run(() async {
      await context.invoke("runTests", []);
    });

    context = new Context();
    StandardLibrary.import(context);
    IOLibrary.import(context);
    TestingLibrary.import(context);
    await env.buildEvalJSON(context);
    print("[JSON AST Tests]");
    await context.run(() async {
      await context.invoke("runTests", []);
    });

    print("[JS Compiler Tests]");
    var target = new JsCompilerTarget();
    target.isTestSuite = true;
    var js = await env.compile(target);
    var proc = await Process.start("node", ["-e", js]);
    proc.stdout.listen((data) => stdout.add(data));
    proc.stderr.listen((data) => stderr.add(data));
    await proc.exitCode;
  }
}
