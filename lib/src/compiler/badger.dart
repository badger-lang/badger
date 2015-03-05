part of badger.compiler;

class BadgerCompilerTarget extends CompilerTarget<String> {
  @override
  String compile(Program program) {
    return new BadgerAstPrinter().generate(program);
  }
}
