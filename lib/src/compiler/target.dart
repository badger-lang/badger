part of badger.compiler;

/**
 * Represents a Compiler Target.
 *
 * A compiler target is a language or bytecode that Badger code can be compiled to.
 */
abstract class CompilerTarget<T> {
  /**
   * Compiles the specified [program].
   */
  T compile(Program program);

  /**
   * Compiler Options
   */
  Map<String, dynamic> options = {};
}
