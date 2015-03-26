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
  Future<T> compile(Program program);

  /**
   * Compiler Options
   */
  Map<String, dynamic> options = {};

  bool hasOption(String name) {
    return options.containsKey(name);
  }

  dynamic getOption(String name) {
    return options[name];
  }

  bool getBooleanOption(String name, [bool defaultValue = false]) {
    return options.containsKey(name) ? options[name] == true : defaultValue;
  }
}
