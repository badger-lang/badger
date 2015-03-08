part of badger.compiler;

class BadgerCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    return (new BadgerAstPrinter(program)..visit(program)).buff.toString();
  }
}
