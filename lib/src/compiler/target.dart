part of badger.compiler;

abstract class Target<T> {
  static Target<String> JS_TARGET = new JsTarget();
  static Target<String> AST_TARGET = new AstTarget();

  T compile(Program program);
}
