#!/usr/bin/env dart

import "dart:convert";
import "dart:io";

import "package:args/args.dart";

import "package:badger/io.dart";
import "package:badger/compiler.dart";
import "package:badger/eval.dart";

Directory getHomeDirectory([String child]) => new Directory(
  Platform.environment["HOME"] + (
    child != null ? "${Platform.pathSeparator}${child}" : ""
  )
);

main(List<String> args) async {
  await loadExternalCompilers();

  var argp = new ArgParser();
  argp.addFlag("test",
      negatable: false,
      abbr: "t",
      help: "Runs the script in a testing environment.");

  argp.addOption("compile",
      abbr: "c",
      allowed: ["tiny-ast", "ast", "js", "badger", "snapshot", "dart"]
        ..addAll(externalCompilers.map((it) => it.name).toList()),
      help: "Compiles Badger Code");

  argp.addOption("define",
    abbr: "D", help: "Specifies an Runtime Property", allowMultiple: true);

  argp.addOption("compiler-opt",
      abbr: "O", help: "Specifies a Compiler Option", allowMultiple: true);

  var opts = argp.parse(args);

  if (opts.rest.isEmpty) {
    print("Usage: badger [options] <script> [args]");
    print(argp.usage);
    exit(1);
  }

  var p = opts.rest[0];

  if (p == "-") {
    var data = await IOUtils.readStdin();
    var f = await IOUtils.createTempFile("badger-stdin");
    await f.writeAsString(data);
    p = f.path;
  }

  var file = new File(p);

  if (!await file.exists()) {
    print("ERROR: Unable to find script file '${file.path}'");
    exit(1);
  }

  var env = new FileEnvironment(file);

  env.properties = parseDefinitionOptions(opts["define"]);

  var context = new Context(env);
  CoreLibrary.import(context);

  if (opts["test"]) {
    TestingLibrary.import(context);
  }

  var argz = opts.rest.skip(1).toList();
  context.setVariable("args", argz);

  if (opts["compile"] != null) {
    var isExternal = externalCompilers.any((c) => c.name == opts["compile"]);

    if (isExternal) {
      var c = externalCompilers.firstWhere((it) => it.name == opts["compile"]);
      var f = file;

      if (c.shouldProvideAst) {
        f = await IOUtils.createTempFile("badger-ast");
        await f.writeAsString(JSON.encode(await env.generateJSON()));
      }

      var cmd = c.command.split(" ");

      cmd.addAll(opts["compiler-opt"].map((it) => "-O${it}"));
      cmd.add(f.path);

      var cm = cmd[0];
      var args = cmd.skip(1).toList();
      try {
        var code = await IOUtils.inheritIO(await Process.start(cm, args));
        await IOUtils.deleteTemporaryFiles();
        exit(code);
      } catch (e) {
        await IOUtils.deleteTemporaryFiles();
        rethrow;
      }
    } else {
      var name = opts["compile"];

      var compilers = {
        "ast": () => new AstCompilerTarget(),
        "js": () => new JsCompilerTarget(),
        "badger": () => new BadgerCompilerTarget(),
        "tiny-ast": () => new TinyAstCompilerTarget(),
        "snapshot": () => new SnapshotCompilerTarget(env),
        "dart": () => new DartCompilerTarget()
      };

      var target = compilers[name]();

      if (target == null) {
        print("ERROR -> Unknown Compiler Target: ${name}");
        exit(1);
      }

      target
        ..options = parseDefinitionOptions(opts["compiler-opt"])
        ..options.putIfAbsent("isTestSuite", () => opts["test"]);

      var program = await env.parse();
      var output = await target.compile(program);
      print(output);
      exit(0);
    }
  }

  await env.eval(context);

  if (opts["test"] && !(context.meta["tests.ran"] == true)) {
    await context.run(() async {
      await context.invoke("runTests", []);
    });
  }

  await IOUtils.deleteTemporaryFiles();
}

loadExternalCompilers() async {
  var dir = getHomeDirectory(".badger");
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

    void error(String msg) {
      var buff = new StringBuffer()
        ..write("ERROR -> External Compiler '")
        ..write(name)
        ..write("'")
        ..write(" provided an invalid configuration. ")
        ..write(msg);
      print(buff.toString());
      exit(1);
    }

    if (config is! Map) {
      error("Configuration should be a map.");
    } else if (!config.containsKey("command")) {
      error("Configuration should provide a command.");
    } else if (config["command"] is! String) {
      error("Configuration should provide a command that is a string.");
    } else if (config.containsKey("ast") && config["ast"] is! bool) {
      error("Configuration entry 'ast' should be a boolean.");
    }

    externalCompilers.add(new ExternalCompiler()
      ..name = name
      ..command = config["command"]
      ..shouldProvideAst = config.containsKey("ast") ? config["ast"] : false
    );
  }
}

Map<String, dynamic> parseDefinitionOptions(List<String> opts) {
  var out = {};

  for (var part in opts) {
    var split = part.split("=");

    if (split.length == 1) {
      out[split[0]] = true;
    } else {
      var key = split[0];
      var value = split.skip(1).join("=");

      if (value == "true" || value == "false") {
        out[key] = value == "true";
        continue;
      }

      try {
        value = num.parse(value);

        out[key] = value;
      } catch (e) {}

      out[key] = value;
    }
  }

  return out;
}

List<ExternalCompiler> externalCompilers = [];

class ExternalCompiler {
  String name;
  String command;
  bool shouldProvideAst;
}
