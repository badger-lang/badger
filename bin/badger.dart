import "dart:io";
import "package:args/args.dart";

import "package:badger/compiler.dart";
import "package:badger/eval.dart";

main(List<String> args) async {
  var argp = new ArgParser();
  argp.addFlag("test", negatable: false, abbr: "t", help: "Runs the script in a testing environment.");
  argp.addOption("compile", abbr: "c", defaultsTo: "none", allowed: [
    "none",
    "tiny-ast",
    "ast",
    "js",
    "badger",
    "snapshot"
  ], help: "Compiles Badger Code");

  var opts = argp.parse(args);

  if (opts.rest.isEmpty) {
    print("Usage: badger [options] <script> [args]");
    print(argp.usage);
    exit(1);
  }

  var context = new Context();
  StandardLibrary.import(context);
  IOLibrary.import(context);

  if (opts["test"]) {
    TestingLibrary.import(context);
  }

  var argz = opts.rest.skip(1).toList();
  context.setVariable("args", argz);

  var file = new File(opts.rest[0]);

  if (!await file.exists()) {
    print("ERROR: Unable to find script file '${file.path}'");
    exit(1);
  }

  var env = new FileEnvironment(file);

  if (opts["compile"] != null && opts["compile"] != "none") {
    var name = opts["compile"];
    CompilerTarget target;

    if (name == "ast") {
      target = CompilerTarget.AST;
    } else if (name == "js") {
      target = CompilerTarget.JS;
    } else if (name == "badger") {
      target = CompilerTarget.BADGER;
    } else if (name == "tiny-ast") {
      target = CompilerTarget.TINY_AST;
    } else if (name == "snapshot") {
      target = new SnapshotCompilerTarget(env);
    } else {
      print("Unknown Compiler Target: ${name}");
      exit(1);
    }

    var program = await env.parse();
    print(await target.compile(program));
    exit(0);
  }

  await env.eval(context);

  if (opts["test"] && !(context.meta["tests.ran"] == true)) {
    await context.run(() async {
      await context.invoke("runTests", []);
    });
  }
}
