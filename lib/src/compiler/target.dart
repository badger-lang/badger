part of badger.compiler;

abstract class Target<T> {
  static final Target<String> JS_TARGET = new JsTarget();
  static final Target<String> AST_TARGET = new AstTarget();

  T compile(Program program);
}
