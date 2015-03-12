import "package:badger/io.dart";
import "package:badger/compiler.dart";
import "dart:io";

main(List<String> args) async {
  if (args.length != 2) {
    print("Usage: bundler <input> <output>");
    exit(1);
  }

  var f = new File(".tmp");
  var inputFile = new File(args[0]);
  var of = new File(args[1]);
  var env = new FileEnvironment(inputFile);
  var snapshot = await env.compile((new SnapshotCompilerTarget(env))..options["simplify"] = true);
  var templateFile = new File("test/bundle.dart");
  var bundle = await templateFile.readAsString();

  bundle = bundle.replaceAll("{{content}}", snapshot);

  await f.writeAsString(bundle);
  var result = await Process.run("dart2js", ["--output-type=dart", "--categories=Server", "-m", "-o", of.path, f.path]);

  if (result.exitCode != 0) {
    print("Failed to build bundle: Compiler exited with code: ${result.exitCode}");
    print("STDOUT:");
    print(result.stdout);
    print("STDERR:");
    print(result.stderr);
    await f.delete();
    exit(1);
  }

  await f.delete();
  await new File("${of.path}.deps").delete();
}
