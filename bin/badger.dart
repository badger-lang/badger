import "dart:convert";
import "dart:io";
import "package:args/args.dart";

import "package:badger/compiler.dart";
import "package:badger/eval.dart";
import "package:badger/parser.dart";

main(List<String> args) async {
  var argp = new ArgParser();
  argp.addFlag("test", negatable: false, abbr: "t", help: "Runs the script in a testing environment.");
  argp.addOption("compile", abbr: "c", allowed: ["ast", "js"]);
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

  if(opts["compile"] != null) {
    Target<String> target;
    if(opts["compile"] == "ast") {
      target = Target.AST_TARGET;
    } else if(opts["compile"] == "js") {
      target = Target.JS_TARGET;
    }

    var program = await env.parse();
    print(target.compile(program));
    exit(0);
  }

  await env.eval(context);

  if (opts["test"] && !(context.meta["tests.ran"] == true)) {
    await context.run(() async {
      await context.invoke("runTests", []);
    });
  }
}
