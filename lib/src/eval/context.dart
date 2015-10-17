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

class Reference {
  final Context _ctx;
  final String _name;

  Reference(this._ctx, this._name);

  void set(value) {
    _ctx.setVariable(_name, value);
  }

  dynamic get() {
    return _ctx.getVariable(_name);
  }
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
  static dynamic getProperty(String name, obj, [bool isFromContext = false]) {
    if (obj is ReturnValue) {
      obj = obj.value;
    }

    if (obj is Immutable) {
      obj = obj.value;
    }

    if (obj is Map) {
      return obj[name];
    }

    if (obj is Context && !isFromContext) {
      var prop = obj.getProperty(name);

      if (prop is Function) {
        var n = prop;
        prop = new Interceptor((x) {
          return n(x);
        });
      }

      return prop;
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

typedef TypeCreator(List<dynamic> args);

class Context extends BadgerObject {
  final Context parent;
  final Environment env;

  Context(this.env, [this.parent]);

  Map<String, dynamic> elements = {};
  Map<String, dynamic> meta = {};

  String typeName;

  dynamic getMetadata(String name) {
    return meta[name];
  }

  bool hasMetadata(String name) {
    return meta.containsKey(name);
  }

  void setMetadata(String name, dynamic value) {
    meta[name] = value;
  }

  void defineNamespace(String name, Context context) {
    elements[name] = context;
  }

  void defineType(String name, TypeCreator creator) {
    elements[name] = creator;
  }

  Reference getReference(String name) {
    return new Reference(this, name);
  }

  dynamic getVariable(String name) {
    if (elements.containsKey(name)) {
      var x = elements[name];

      if (x is Nullable) {
        x = x.value;
      }

      if (x is Immutable) {
        x = x.value;
      }

      return x;
    } else if (hasFunction(name)) {
      return getFunction(name);
    } else if (parent != null && parent.hasVariable(name)) {
      return parent.getVariable(name);
    } else {
      throw new Exception("Variable ${name} is not defined.");
    }
  }

  void define(String name, Function function, {bool wrap: true}) {
    elements[name] = wrap ? ((args) {
      return Function.apply(function, args);
    }) : function;
  }

  void alias(String from, String to) {
    if (elements.containsKey(from)) {
      elements[to] = elements[from];
    } else {
      throw new Exception("Failed to alias ${from} to ${to}, ${from} is not defined.");
    }
  }

  void proxy(String name, dynamic value) {
    if (value is Function) {
      elements[name] = (args) {
        return Function.apply(value, args);
      };
    } else {
      elements[name] = value;
    }
  }

  void merge(Context ctx) {
    ctx.elements.keys.where((it) => !it.startsWith("_")).forEach((x) {
      elements[x] = ctx.elements[x];
    });
  }

  Context fork() {
    return new Context(env, this);
  }

  bool hasFunction(String name) {
    if (elements.containsKey(name) && elements[name] is Function) {
      return true;
    } else if (parent != null && parent.hasFunction(name)) {
      return true;
    } else {
      return false;
    }
  }

  dynamic invoke(String name, List<dynamic> args) {
    if (!hasFunction(name) && !hasType(name)) {
      throw new Exception("Method ${name} is not defined.");
    }

    var v = getProperty(name);

    if (v is Type) {
      var c = reflectClass(v);
      return c.newInstance(MirrorSystem.getSymbol(""), args).reflectee;
    } else {
      return v(args);
    }
  }

  Function getFunction(String name) {
    if (elements.containsKey(name)) {
      return elements[name];
    } else if (parent != null && parent.hasFunction(name)) {
      return parent.getFunction(name);
    } else {
      throw new Exception("Method ${name} is not defined.");
    }
  }

  bool hasVariable(String name) {
    return elements.containsKey(name) || (parent != null && parent.hasVariable(name));
  }

  bool hasNamespace(String name) {
    return elements.containsKey(name) || (parent != null && parent.hasNamespace(name));
  }

  bool hasType(String name) {
    return elements.containsKey(name) || (parent != null && parent.hasType(name));
  }

  dynamic setVariable(String name, dynamic value, [bool checkExists = false]) {
    if (checkExists && hasVariable(name)) {
      throw new Exception("Unable to set ${name}, it is already defined.");
    }

    if (parent != null && parent.hasVariable(name)) {
      return parent.setVariable(name, value);
    } else {
      if (elements.containsKey(name)) {
        var v = elements[name];

        if (value == null && v is! Nullable) {
          throw new Exception("Unable to set ${name} to null, it is not nullable.");
        } else if (v is Nullable) {
          v = v.value;
        }

        if (v is Immutable) {
          throw new Exception("Unable to set ${name}, it is immutable.");
        }
      }

      return elements[name] = value;
    }
  }

   dynamic run(void c()) {
    return Zone.ROOT.fork(zoneValues: {
      "context": this
    }).run(c);
   }

  static Context get current => Zone.current["context"];

  Context getNamespace(String name) {
    if (hasNamespace(name)) {
      if (elements.containsKey(name)) {
        return elements[name];
      } else {
        return parent.getNamespace(name);
      }
    } else {
      throw new Exception("Undefined Namespace: ${name}");
    }
  }

  void inherit(Context context) {
    merge(context);
  }

  TypeCreator getType(String name) {
    if (hasType(name)) {
      if (elements.containsKey(name)) {
        return elements[name];
      } else {
        return parent.getType(name);
      }
    } else {
      throw new Exception("Undefined Type: ${name}");
    }
  }

  @override
  dynamic getProperty(String name) {
    if (hasVariable(name)) {
      return getVariable(name);
    } else if (hasFunction(name)) {
      return getFunction(name);
    } else if (hasNamespace(name)) {
      return getNamespace(name);
    } else if (hasType(name)) {
      return getType(name);
    } else if (["inherit", "merge"].contains(name)) {
      var x = reflect(this).getField(new Symbol(name)).reflectee;

      if (x is Function) {
        return (args) {
          return Function.apply(x, args);
        };
      }

      return x;
    } else {
      throw new Exception("Failed to get property ${name} on context.");
    }
  }

  @override
  void setProperty(String name, dynamic value) {
    setVariable(name, value);
  }

  dynamic createChild(void handler()) {
    var ctx = fork();
    return Zone.current.fork(zoneValues: {
      "context": ctx
    }).run(() {
      return handler();
    });
  }

  @override
  String toString() {
    if (typeName != null) {
      return "Instance of '${typeName}'";
    } else {
      return super.toString();
    }
  }
}
