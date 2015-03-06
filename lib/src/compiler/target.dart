part of badger.compiler;

abstract class CompilerTarget<T> {
  T compile(Program program);

  bool isTestSuite = false;
}
