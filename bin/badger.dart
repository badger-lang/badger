import "dart:convert";
import "dart:io";
import "package:args/args.dart";
import "package:badger/eval.dart";

main(List<String> args) async {
  var argp = new ArgParser();
  argp.addFlag("test", negatable: false, abbr: "t", help: "Runs the script in a testing environment.");
  argp.addFlag("generate-json", negatable: false, abbr: "j", help: "Generate JSON from the AST");
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

  if (opts["generate-json"]) {
    var json = await env.generateJSON();
    var encoder = new JsonEncoder.withIndent("  ");

    print(encoder.convert(json));
    exit(0);
  }

  await env.eval(context);

  if (opts["test"] && !(context.meta["tests.ran"] == true)) {
    await context.run(() async {
      await context.invoke("runTests", []);
    });
  }
}
