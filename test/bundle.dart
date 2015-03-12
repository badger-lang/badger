import "package:badger/eval.dart";
import "package:badger/io.dart";

const String DATA = r"""
{{content}}
""";

main(List<String> args) async {
  var file = await IOUtils.createTempFile("badger-exec");
  await file.writeAsString(DATA);
  var env = new FileEnvironment(file);
  var ctx = new Context(env);

  ctx.setVariable("args", args);

  CoreLibrary.import(ctx);

  await env.eval(ctx);
  await IOUtils.deleteTemporaryFiles();
}
