part of badger.eval;

typedef BadgerFunction(List<dynamic> args);

abstract class BadgerObject {
  bool asBoolean() => true;
  dynamic getValue() => this;
  dynamic getProperty(String name) {
    return BadgerUtils.getProperty(name, this);
  }
  void setProperty(String name, dynamic value) {
    BadgerUtils.setProperty(name, value, this);
  }
}

typedef InterceptionHandler(List<dynamic> positional);

class _Unspecified {
  const _Unspecified();
}

class MergeSorter {
  Future<List> sort(List input, [compare]) async {
    if (input.length <= 1) return new List.from(input);

    if (compare == null) {
      compare = (a, b) => a.compareTo(b);
    }

    var left = [];
    var right = [];
    var middle = (input.length / 2).round();

    int x;

    for (x = 0; x < middle; x++) {
      left.add(input[x]);
    }

    for (; x >= middle && x < input.length; x++) {
      right.add(input[x]);
    }

    left = await sort(left, compare);
    right = await sort(right, compare);

    return await merge(left, right, compare);
  }

  Future<List> merge(List left, List right, compare) async {
    var result = [];

    while (left.isNotEmpty && right.isNotEmpty) {
      var a = await compare(left.first, right.first);
      var b = await compare(right.first, left.first);
      if (a <= b) {
        result.add(left.first);
        left.removeAt(0);
      } else {
        result.add(right.first);
        right.removeAt(0);
      }
    }

    while (left.isNotEmpty) {
      result.add(left.first);
      left.removeAt(0);
    }

    while (right.isNotEmpty) {
      result.add(right.first);
      right.removeAt(0);
    }

    return result;
  }
}

const _Unspecified _UNSPECIFIED = const _Unspecified();

class Interceptor {
  final InterceptionHandler handler;

  Interceptor(this.handler);

  dynamic call([
               a = _UNSPECIFIED,
               b = _UNSPECIFIED,
               c = _UNSPECIFIED,
               d = _UNSPECIFIED,
               e = _UNSPECIFIED,
               f = _UNSPECIFIED,
               g = _UNSPECIFIED,
               h = _UNSPECIFIED,
               i = _UNSPECIFIED,
               j = _UNSPECIFIED,
               k = _UNSPECIFIED,
               l = _UNSPECIFIED,
               m = _UNSPECIFIED,
               n = _UNSPECIFIED,
               o = _UNSPECIFIED,
               p = _UNSPECIFIED,
               q = _UNSPECIFIED,
               r = _UNSPECIFIED,
               s = _UNSPECIFIED,
               t = _UNSPECIFIED,
               u = _UNSPECIFIED,
               v = _UNSPECIFIED,
               w = _UNSPECIFIED,
               x = _UNSPECIFIED,
               y = _UNSPECIFIED,
               z = _UNSPECIFIED
               ]) {
    var list = [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z];
    var args = list.takeWhile((it) => it != _UNSPECIFIED).toList();

    return handler(args);
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

class Nullable extends BadgerObject {
  final dynamic value;

  Nullable(this.value);

  @override
  dynamic getValue() {
    return value;
  }
}

class BadgerUtils {
  static dynamic getProperty(String name, obj) {
    if (obj is ReturnValue) {
      obj = obj.value;
    }

    if (obj is Immutable) {
      obj = obj.value;
    }

    if (obj is Map) {
      return obj[name];
    }

    if (obj is Iterable) {
      if (name == "where") {
        return (x) async {
          var result = [];

          for (var e in obj) {
            if (asBoolean(await x(e))) {
              result.add(e);
            }
          }

          return result;
        };
      } else if (name == "map") {
        return (x) async {
          var result = [];
          for (var e in obj) {
            result.add(await x(e));
          }
          return result;
        };
      } else if (name == "sort") {
        return ([comparator]) async {
          return await new MergeSorter().sort(obj, comparator);
        };
      } else if (name == "each" || name == "forEach") {
        return (function) async {
          for (var e in obj) {
            await function(e);
          }
        };
      }
    }

    ObjectMirror f;
    if (obj is Type) {
      f = reflectClass(obj);
    } else {
      f = reflect(obj);
    }

    var field = f.getField(MirrorSystem.getSymbol(name));

    return field.reflectee;
  }

  static void setProperty(String name, value, obj) {
    if (obj is Map) {
      obj[name] = value;
      return;
    }

    var mirror = reflect(obj);
    mirror.setField(MirrorSystem.getSymbol(name), value);
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

      if (x is Nullable) {
        x = x.value;
      }

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

  void define(String name, Function function, {bool wrap: true}) {
    functions[name] = wrap ? ((args) {
      return Function.apply(function, args);
    }) : function;
  }

  void proxy(String name, dynamic value) {
    if (value is Function) {
      functions[name] = (args) {
        return Function.apply(value, args);
      };
    } else {
      variables[name] = value;
    }
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
    } else if (variables.containsKey(name) && variables[name] is Type) {
      var c = reflectClass(variables[name]);
      return c.newInstance(MirrorSystem.getSymbol(""), args);
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
      if (variables.containsKey(name)) {
        var v = variables[name];

        if (value == null && v is! Nullable) {
          throw new Exception("Unable to set ${name} to null, it is not nullable.");
        } else if (v is Nullable) {
          v = v.value;
        }

        if (v is Immutable) {
          throw new Exception("Unable to set ${name}, it is immutable.");
        }
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

  @override
  void setProperty(String name, dynamic value) {
    setVariable(name, value);
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
