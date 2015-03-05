part of badger.compiler;

abstract class CompilerTarget<T> {
  static final CompilerTarget<String> JS = new JsCompilerTarget();
  static final CompilerTarget<String> AST = new AstCompilerTarget();
  static final CompilerTarget<String> BADGER = new BadgerCompilerTarget();

  T compile(Program program);
}
