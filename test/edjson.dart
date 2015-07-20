import "package:badger/compiler.dart";
import "package:badger/parser.dart";

import "dart:io";

main() async {
  var input = new File("example/greeting.badger").readAsStringSync();
  var parser = new BadgerParser();
  Program program = parser.parse(input).value;
  var bigCompiled = await new AstCompilerTarget().compile(program);
  var tinyCompiled = await new TinyAstCompilerTarget().compile(program);
  print("Big AST: ${bigCompiled.length}");
  print("Tiny AST: ${tinyCompiled.length}");
}
