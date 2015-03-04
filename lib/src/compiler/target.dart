part of badger.compiler;

abstract class Target<T> {
  T compile(Program program);
}
