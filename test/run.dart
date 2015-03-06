import "dart:io";
import "package:badger/eval.dart";
import "package:badger/compiler.dart";

main(List<String> args) async {
  var dir = new Directory("test/scripts");

  await for (File file in dir.list(recursive: true).where((it) => it is File && it.path.endsWith(".badger"))) {
    var name = file.path.replaceAll(dir.path + "/", "");

    if (name.startsWith("imports/") || name.startsWith("prototype/")) {
      continue;
    }

    var env = new FileEnvironment(file);

    void importTesting(Context c, String name) {
      if (args.contains("--teamcity")) {
        TestingLibrary.import(c, handleTestStarted: (x) {
          print("##teamcity[testStarted name='${x}' captureStandardOutput='true']");
        }, handleTestResult: (result) {
          if (result.type == TestResultType.FAILURE) {
            print("##teamcity[testFailed name='${result.name}' message='${result.message}' details='${result.message}']");
          }

          print("##teamcity[testFinished name='${result.name}']");
        }, handleTestsBegin: () {
          print("##teamcity[testSuiteStarted name='${name}']");
        }, handleTestsEnd: () {
          print("##teamcity[testSuiteFinished name='${name}']");
        });
      } else {
        print("[${name}]");
        TestingLibrary.import(c);
      }
    }

    var context = new Context();
    StandardLibrary.import(context);
    IOLibrary.import(context);
    importTesting(context, "Evaluation Tests");
    await env.eval(context);

    await context.run(() async {
      await context.invoke("runTests", []);
    });

    context = new Context();
    StandardLibrary.import(context);
    IOLibrary.import(context);
    importTesting(context, "JSON AST");
    await env.buildEvalJSON(context);
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
