part of badger.compiler;

abstract class CompilerTarget<T> {
  T compile(Program program);

  Map<String, dynamic> options = {};
}
