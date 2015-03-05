part of badger.eval;

typedef BadgerFunction(List<dynamic> args);

abstract class BadgerObject {
  bool asBoolean() => true;
  dynamic getValue() => this;
  dynamic getProperty(String name) {
    return BadgerUtils.getProperty(name, this);
  }
}

class Immutable extends BadgerObject {
  final dynamic value;

  Immutable(this.value);

  @override
  dynamic getValue() {
    return value;
  }
}

class BadgerUtils {
  static dynamic getProperty(String name, obj) {
    var mirror = reflect(obj);
    var field = mirror.getField(MirrorSystem.getSymbol(name));
    return field.reflectee;
  }

  static bool asBoolean(value) {
    if (value == null) {
      return false;
    } else if (value == VOID) {
      return false;
    } else if (value is int) {
      return value != 0;
    } else if (value is double) {
      return value != 0.0;
    } else if (value is String) {
      return value.isNotEmpty;
    } else if (value is bool) {
      return value;
    } else if (value is BadgerObject) {
      return value.asBoolean();
    } else {
      return true;
    }
  }
}

class Context extends BadgerObject {
  final Context parent;

  Context([this.parent]);

  Map<String, BadgerFunction> functions = {};
  Map<String, dynamic> variables = {};
  Map<String, dynamic> meta = {};

  dynamic getVariable(String name) {
    if (variables.containsKey(name)) {
      var x = variables[name];

      if (x is Immutable) {
        x = x.value;
      }

      return x;
    } else if (parent != null && parent.hasVariable(name)) {
      return parent.getVariable(name);
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

  void merge(Context ctx) {
    ctx.variables.keys.where((it) => !it.startsWith("_")).forEach((x) {
      variables[x] = ctx.variables[x];
    });

    ctx.functions.keys.where((it) => !it.startsWith("_")).forEach((x) {
      functions[x] = ctx.functions[x];
    });
  }

  Context fork() {
    return new Context(this);
  }

  bool hasFunction(String name) {
    if (functions.containsKey(name)) {
      return true;
    } else if (variables.containsKey(name) && variables[name] is Function) {
      return true;
    } else if (parent != null && parent.hasFunction(name)) {
      return true;
    } else {
      return false;
    }
  }

  dynamic invoke(String name, List<dynamic> args) {
    if (functions.containsKey(name)) {
      return functions[name](args);
    } else if (variables.containsKey(name) && variables[name] is Function) {
      return variables[name](args);
    } else if (parent != null && parent.hasFunction(name)) {
      return parent.invoke(name, args);
    } else {
      throw new Exception("Method ${name} is not defined.");
    }
  }

  Function getFunction(String name) {
    if (functions.containsKey(name)) {
      return functions[name];
    } else if (variables.containsKey(name) && variables[name] is Function) {
      return variables[name];
    } else if (parent != null && parent.hasFunction(name)) {
      return parent.getFunction(name);
    } else {
      throw new Exception("Method ${name} is not defined.");
    }
  }

  bool hasVariable(String name) {
    return variables.containsKey(name) || (parent != null && parent.hasVariable(name));
  }

  dynamic setVariable(String name, dynamic value, [bool checkExists = false]) {
    if (checkExists && hasVariable(name)) {
      throw new Exception("Unable to set ${name}, it is already defined.");
    }

    if (parent != null && parent.hasVariable(name)) {
      return parent.setVariable(name, value);
    } else {
      if (variables.containsKey(name) && variables[name] is Immutable) {
        throw new Exception("Unable to set ${name}, it is immutable.");
      }

      return variables[name] = value;
    }
  }

   dynamic run(void c()) {
    return Zone.ROOT.fork(zoneValues: {
      "context": this
    }).run(c);
   }

  static Context get current => Zone.current["context"];

  @override
  dynamic getProperty(String name) {
    if (hasVariable(name)) {
      return getVariable(name);
    } else if (hasFunction(name)) {
      return getFunction(name);
    } else {
      throw new Exception("Failed to get property ${name} on context.");
    }
  }

  dynamic createContext(void handler()) {
    var ctx = fork();
    return Zone.current.fork(zoneValues: {
      "context": ctx
    }).run(() {
      return handler();
    });
  }
}
