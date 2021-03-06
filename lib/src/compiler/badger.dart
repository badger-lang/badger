part of badger.compiler;

class BadgerCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    if (getBooleanOption("simplify")) {
      program = new BadgerSimplifier().modifyProgram(program);
    }

    return (new BadgerPrinter(program)..visitProgram(program)).buff.toString();
  }
}
