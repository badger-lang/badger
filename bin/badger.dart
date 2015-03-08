import "dart:convert";
import "dart:io";

import "package:args/args.dart";

import "package:badger/io.dart";
import "package:badger/compiler.dart";
import "package:badger/eval.dart";

Directory tmpDir;

main(List<String> args) async {
  await loadExternalCompilers();

  var argp = new ArgParser();
  argp.addFlag("test",
      negatable: false,
      abbr: "t",
      help: "Runs the script in a testing environment.");

  argp.addOption("compile",
      abbr: "c",
      allowed: ["tiny-ast", "ast", "js", "badger", "snapshot", "dart"]..addAll(externalCompilers.map((it) => it.name).toList()),
      help: "Compiles Badger Code");

  argp.addOption("compiler-opt",
      abbr: "O", help: "Specifies a Compiler Option", allowMultiple: true);

  var opts = argp.parse(args);

  if (opts.rest.isEmpty) {
    print("Usage: badger [options] <script> [args]");
    print(argp.usage);
    exit(1);
  }

  var context = new Context();
  CoreLibrary.import(context);

  if (opts["test"]) {
    TestingLibrary.import(context);
  }

  var argz = opts.rest.skip(1).toList();
  context.setVariable("args", argz);

  var p = opts.rest[0];

  if (p == "-") {
    var buff = new StringBuffer();
    stdin.lineMode = false;
    await for (var data in stdin) {
      buff.write(UTF8.decode(data));
    }
    stdin.lineMode = true;
    tmpDir = await Directory.systemTemp.createTemp("badger");
    var f = new File("${tmpDir.path}/script");
    await f.writeAsString(buff.toString());
    p = f.path;
  }

  var file = new File(p);

  if (!await file.exists()) {
    print("ERROR: Unable to find script file '${file.path}'");
    exit(1);
  }

  var env = new FileEnvironment(file);

  if (opts["compile"] != null) {
    if (externalCompilers.any((it) => it.name == opts["compile"])) {
      var c = externalCompilers.firstWhere((it) => it.name == opts["compile"]);
      var f = file;
      if (c.provideAst) {
        tmpDir = await Directory.systemTemp.createTemp("badger");
        f = new File("${tmpDir.path}/ast.json");
        await f.writeAsString(JSON.encode(await env.generateJSON()));
      }

      var cmd = c.command.split(" ");

      cmd.addAll(opts["compiler-opt"].map((it) => "-O${it}"));
      cmd.add(f.path);

      var cm = cmd[0];
      var args = cmd.skip(1).toList();
      try {
        var proc = await Process.start(cm, args);
        proc.stdout.listen((x) => stdout.add(x));
        proc.stderr.listen((x) => stderr.add(x));
        stdin.pipe(proc.stdin);
        var code = await proc.exitCode;
        await tmpDir.delete(recursive: true);
        exit(code);
      } catch (e) {
        await tmpDir.delete(recursive: true);
        rethrow;
      }
    } else {
      var name = opts["compile"];
      CompilerTarget target;

      if (name == "ast") {
        target = new AstCompilerTarget();
      } else if (name == "js") {
        target = new JsCompilerTarget();
      } else if (name == "badger") {
        target = new BadgerCompilerTarget();
      } else if (name == "tiny-ast") {
        target = new TinyAstCompilerTarget();
      } else if (name == "snapshot") {
        target = new SnapshotCompilerTarget(env);
      } else if (name == "dart") {
        target = new DartCompilerTarget();
      } else {
        print("Unknown Compiler Target: ${name}");
        exit(1);
      }

      var o = opts["compiler-opt"];
      var optz = {};

      for (var i in o) {
        var split = i.split("=");

        if (split.length == 1) {
          optz[split[0]] = true;
        } else {
          var key = split[0];
          var value = split.skip(1).join("=");

          if (value == "true" || value == "false") {
            optz[key] = value == "true";
            continue;
          }

          try {
            value = num.parse(value);

            optz[key] = value;
          } catch (e) {}

          optz[key] = value;
        }
      }

      target.options = optz;

      target.options.putIfAbsent("isTestSuite", () => opts["test"]);

      var program = await env.parse();
      print(await target.compile(program));
      exit(0);
    }
  }

  await env.eval(context);

  if (opts["test"] && !(context.meta["tests.ran"] == true)) {
    await context.run(() async {
      await context.invoke("runTests", []);
    });
  }

  if (tmpDir != null) {
    await tmpDir.delete(recursive: true);
  }
}

loadExternalCompilers() async {
  var dir = new Directory(
      "${Platform.environment["HOME"]}${Platform.pathSeparator}.badger");
  var compilersDir = new Directory("${dir.path}/compilers");

  if (!(await compilersDir.exists())) {
    return;
  }

  await for (var file in compilersDir
      .list(recursive: true)
      .where((it) => it.path.endsWith(".json"))) {
    var name = file.path.split(Platform.pathSeparator).last;
    name = name.substring(0, name.lastIndexOf(".json"));
    var config = JSON.decode(await file.readAsString());

    if (config is! Map) {
      print(
          "ERROR: External compiler '${name}' provided an invalid configuration. Configuration should be a map.");
      exit(1);
    } else if (!config.containsKey("command")) {
      print(
        "ERROR: External compiler '${name}' provided an invalid configuration. Configuration should provide a command.");
      exit(1);
    } else if (config["command"] is! String) {
      print(
        "ERROR: External compiler '${name}' provided an invalid configuration. Configuration should provide a command that is a string.");
      exit(1);
    } else if (config.containsKey("ast") && config["ast"] is! bool) {
      print(
          "ERROR: External compiler '${name}' provided an invalid configuration. Configuration entry 'ast' should be a boolean.");
      exit(1);
    }

    var c = new ExternalCompiler();
    c.name = name;
    c.command = config["command"];
    c.provideAst = config.containsKey("ast") ? config["ast"] : false;

    externalCompilers.add(c);
  }
}

List<ExternalCompiler> externalCompilers = [];

class ExternalCompiler {
  String name;
  String command;
  bool provideAst;
}
