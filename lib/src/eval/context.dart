part of badger.eval;

typedef BadgerFunction(List<dynamic> args);

class Context {
  static int ctxId = 0;

  final int id;

  Context() : id = ctxId++;

  Map<String, BadgerFunction> functions = {};
  Map<String, dynamic> variables = {};

  dynamic getVariable(String name) {
    if (variables.containsKey(name)) {
      return variables[name];
    } else {
      throw new Exception("Variable ${name} is not defined.");
    }
  }

  void define(String name, BadgerFunction function) {
    functions[name] = function;
  }

  void defun(String name, BadgerFunction function) {
    define(name, function);
  }

  Context fork() {
    var context = new Context();
    context.functions = new Map<String, BadgerFunction>.from(functions);
    context.variables = new Map<String, dynamic>.from(variables);
    return context;
  }

  dynamic invoke(String name, List<dynamic> args) {
    if (functions.containsKey(name)) {
      return functions[name](args);
    } else {
      throw new Exception("Method ${name} is not defined.");
    }
  }

  void setVariable(String name, dynamic value) {
    variables[name] = value;
  }

  @override
  String toString() {
    var buff = new StringBuffer("Context(\n  id: ${id},\n  variables: [\n");
    for (var v in variables.keys) {
      buff.writeln("    ${v}: ${variables[v]}");
    }
    buff.write("  ],\n  functions: [\n");
    for (var m in functions.keys) {
      buff.writeln("    ${m}: ${functions[m]}");
    }
    buff.write("  ]");
    buff.write("\n)");
    return buff.toString();
  }
}
