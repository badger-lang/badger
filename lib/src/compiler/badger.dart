part of badger.compiler;

class BadgerCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    if (options.containsKey("simplify") && options["simplify"] == true) {
      program = new BadgerSimplifier().modify(program);
    }

    return (new BadgerPrinter(program)..visit(program)).buff.toString();
  }
}
