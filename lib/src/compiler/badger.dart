part of badger.compiler;

class BadgerCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    if (getBooleanOption("simplify")) {
      program = new BadgerSimplifier().modify(program);
    }

    return (new BadgerPrinter(program)..visit(program)).buff.toString();
  }
}
