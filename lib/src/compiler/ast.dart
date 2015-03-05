part of badger.compiler;

class AstCompilerTarget extends CompilerTarget<String> {
  @override
  String compile(Program program) {
    var ast = new BadgerJsonBuilder(program);
    var encoder = new JsonEncoder.withIndent("  ");

    return encoder.convert(ast.build());
  }
}
