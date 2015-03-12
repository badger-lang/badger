import "dart:async";
import "dart:async" as _A;
import "dart:convert";
import "dart:mirrors";
import "dart:math";
import "dart:io";
import "dart:io" as _B;

const String DATA = r"""
{"_":{"f":[{"a":"z",")":["badger:io"],"d":null}],"g":[{"a":"l","c":"print","k":[{"a":"q","j":["DirectCode Repositories:"]}]},{"a":"p","c":"url","e":{"a":"q","j":["https://api.github.com/users/DirectMyFile/repos?type=owner&sort=full_name&direction=asc"]},"b":true,"h":true,"(":false},{"a":"p","c":"http","e":{"a":"l","c":"make","k":[{"a":"t","d":"HttpClient"}]},"b":true,"h":true,"(":false},{"a":"p","c":"response","e":{"a":"m","c":{"a":"t","d":"http"},"?":[{"a":"l","c":"get","k":[{"a":"t","d":"url"}]}]},"b":true,"h":true,"(":false},{"a":"p","c":"json","e":{"a":"m","c":{"a":"t","d":"JSON"},"?":[{"a":"l","c":"parse","k":[{"a":"m","c":{"a":"t","d":"response"},"?":["body"]}]}]},"b":false,"h":true,"(":false},{"a":"p","c":"json","e":{"a":"m","c":{"a":"t","d":"json"},"?":[{"a":"l","c":"where","k":[{"a":"y","k":["a"],"n":[{"a":"p","c":"stars","e":{"a":"m","c":{"a":"t","d":"a"},"?":["stargazers_count"]},"b":true,"h":true,"(":false},{"a":"p","c":"include","e":{"a":"o","r":{"a":"t","d":"stars"},"s":{"a":"+","e":0},"i":">"},"b":true,"h":true,"(":false},{"a":"*","e":{"a":"t","d":"include"}}]}]}]},"b":false,"h":false,"(":null},{"a":"p","c":"json","e":{"a":"m","c":{"a":"t","d":"json"},"?":[{"a":"l","c":"sort","k":[{"a":"y","k":["a","b"],"n":[{"a":"p","c":"x","e":{"a":"m","c":{"a":"t","d":"a"},"?":["stargazers_count"]},"b":true,"h":true,"(":false},{"a":"p","c":"y","e":{"a":"m","c":{"a":"t","d":"b"},"?":["stargazers_count"]},"b":true,"h":true,"(":false},{"a":"*","e":{"a":"m","c":{"a":"t","d":"y"},"?":[{"a":"l","c":"compareTo","k":[{"a":"t","d":"x"}]}]}}]}]}]},"b":false,"h":false,"(":null},{"a":"u","d":"repo","e":{"a":"t","d":"json"},"n":[{"a":"p","c":"name","e":{"a":"m","c":{"a":"t","d":"repo"},"?":["name"]},"b":true,"h":true,"(":false},{"a":"p","c":"stars","e":{"a":"m","c":{"a":"t","d":"repo"},"?":["stargazers_count"]},"b":true,"h":true,"(":false},{"a":"l","c":"print","k":[{"a":"q","j":["- ",{"a":"t","d":"name"},": ",{"a":"t","d":"stars"}," stars"]}]}]}]}}
""";
main(List<String> args) async {
  var file_A = await IOUtils.createTempFile("badger-exec");
  await file_A.writeAsString(DATA);
  var env = new FileEnvironment(file_A);
  var ctx = new Context(env);
  ctx.setVariable("args", args);
  CoreLibrary.import_A(ctx);
  await env.eval_A(ctx);
  await IOUtils.deleteTemporaryFiles();
}
abstract class Environment {
  Future import_E(String location_A, Evaluator evaluator, Context context_A,
      Program source_A);
  Future<Map<String, dynamic>> getProperties();
}
class ImportMapEnvironment extends Environment {
  final Map<String, Program> programs;
  Environment _c;
  ImportMapEnvironment(this.programs, [this._c]);
  Future import_E(String location_A, Evaluator evaluator, Context context_A,
      Program source_A) async {
    if (_c != null && !programs.containsKey(location_A)) {
      return _c.import_E(location_A, evaluator, context_A, source_A);
    }
    var program = programs[location_A];
    await evaluator.evaluateProgram(program, context_A);
  }
  Future<Map<String, dynamic>> getProperties() async => properties;
  Map<String, dynamic> properties = {};
}
abstract class BaseEnvironment extends Environment {
  final BadgerParser _parser = new BadgerParser();
  Environment _e;
  eval_A(Context context_A) async {
    var program = _parse_A(await readScriptContent());
    return await new Evaluator(program, _e != null ? _e : this)
        .evaluate(context_A);
  }
  Future<Program> parse_B([String content]) async {
    return _parse_A(content != null ? content : await readScriptContent());
  }
  Future<String> readScriptContent();
  Program _parse_A(String content) {
    try {
      var json = JSON.decode(content);
      if (json.containsKey("_")) {
        var p = new BadgerSnapshotParser(json);
        var m = p.parse_B();
        _e = new ImportMapEnvironment(m, this)..properties = properties;
        return (_e as ImportMapEnvironment).programs["_"];
      }
      return new BadgerJsonParser().build(json);
    } on FormatException catch (e) {}
    _e = this;
    return _parser.parse_B(content).value;
  }
  Future<Map<String, dynamic>> getProperties() async => properties;
  Map<String, dynamic> properties = {};
}
typedef dynamic BadgerFunction(List _0);
abstract class BadgerObject {
  bool asBoolean_A() => true;
  dynamic getProperty_A(String name_A) {
    return BadgerUtils.getProperty(name_A, this);
  }
  void setProperty_A(String name_A, dynamic value_A) {
    BadgerUtils.setProperty(name_A, value_A, this);
  }
}
typedef dynamic InterceptionHandler(List _0);
class _Unspecified {
  const _Unspecified();
}
class Reference {
  final Context _ctx;
  final String _name_A;
  Reference(this._ctx, this._name_A);
}
class MergeSorter {
  Future<List> sort(List input_A, [compare_A]) async {
    if (input_A.length <= 1) return new List.from(input_A);
    if (compare_A == null) {
      compare_A = (a, b) => a.compareTo(b);
    }
    var left_A = [];
    var right_A = [];
    var middle = (input_A.length / 2).round();
    int x_A;
    for (x_A = 0; x_A < middle; x_A++) {
      left_A.add(input_A[x_A]);
    }
    for (; x_A >= middle && x_A < input_A.length; x_A++) {
      right_A.add(input_A[x_A]);
    }
    left_A = await sort(left_A, compare_A);
    right_A = await sort(right_A, compare_A);
    return await merge(left_A, right_A, compare_A);
  }
  Future<List> merge(List left_A, List right_A, compare_A) async {
    var result_A = [];
    while (left_A.isNotEmpty && right_A.isNotEmpty) {
      var a = await compare_A(left_A.first, right_A.first);
      var b = await compare_A(right_A.first, left_A.first);
      if (a <= b) {
        result_A.add(left_A.first);
        left_A.removeAt(0);
      } else {
        result_A.add(right_A.first);
        right_A.removeAt(0);
      }
    }
    while (left_A.isNotEmpty) {
      result_A.add(left_A.first);
      left_A.removeAt(0);
    }
    while (right_A.isNotEmpty) {
      result_A.add(right_A.first);
      right_A.removeAt(0);
    }
    return result_A;
  }
}
const _Unspecified _UNSPECIFIED = const _Unspecified();
class Interceptor {
  final InterceptionHandler handler;
  Interceptor(this.handler);
  dynamic call([a = _UNSPECIFIED, b = _UNSPECIFIED, c = _UNSPECIFIED,
      d = _UNSPECIFIED, e = _UNSPECIFIED, f = _UNSPECIFIED, g = _UNSPECIFIED,
      h = _UNSPECIFIED, i = _UNSPECIFIED, j = _UNSPECIFIED, k = _UNSPECIFIED,
      l = _UNSPECIFIED, m = _UNSPECIFIED, n = _UNSPECIFIED, o = _UNSPECIFIED,
      p = _UNSPECIFIED, q = _UNSPECIFIED, r = _UNSPECIFIED, s = _UNSPECIFIED,
      t = _UNSPECIFIED, u = _UNSPECIFIED, v = _UNSPECIFIED, w_A = _UNSPECIFIED,
      x_A = _UNSPECIFIED, y_A = _UNSPECIFIED, z_A = _UNSPECIFIED]) {
    var list_A = [
      a,
      b,
      c,
      d,
      e,
      f,
      g,
      h,
      i,
      j,
      k,
      l,
      m,
      n,
      o,
      p,
      q,
      r,
      s,
      t,
      u,
      v,
      w_A,
      x_A,
      y_A,
      z_A
    ];
    var args = list_A.takeWhile((it) => it != _UNSPECIFIED).toList();
    return handler(args);
  }
}
class Immutable extends BadgerObject {
  final dynamic value;
  Immutable(this.value);
}
class Nullable extends BadgerObject {
  final dynamic value;
  Nullable(this.value);
}
class BadgerUtils {
  static dynamic getProperty(String name_A, obj, [bool isFromContext = false]) {
    if (obj is ReturnValue) {
      obj = obj.value;
    }
    if (obj is Immutable) {
      obj = obj.value;
    }
    if (obj is Map) {
      return obj[name_A];
    }
    if (obj is Context && !isFromContext) {
      var prop = obj.getProperty_A(name_A);
      if (prop is Function) {
        var n = prop;
        prop = new Interceptor((x_A) {
          return n(x_A);
        });
      }
      return prop;
    }
    if (obj is Iterable) {
      if (name_A == "where") {
        return (x_A) async {
          var result_A = [];
          for (var e in obj) {
            if (asBoolean(await x_A(e))) {
              result_A.add(e);
            }
          }
          return result_A;
        };
      } else if (name_A == "map") {
        return (x_A) async {
          var result_A = [];
          for (var e in obj) {
            result_A.add(await x_A(e));
          }
          return result_A;
        };
      } else if (name_A == "sort") {
        return ([comparator]) async {
          return await new MergeSorter().sort(obj, comparator);
        };
      } else if (name_A == "each" || name_A == "forEach") {
        return (function_A) async {
          for (var e in obj) {
            await function_A(e);
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
    var field = f.getField(MirrorSystem.getSymbol(name_A));
    return field.reflectee;
  }
  static void setProperty(String name_A, value_A, obj) {
    if (obj is Map) {
      obj[name_A] = value_A;
      return;
    }
    var mirror = reflect(obj);
    mirror.setField(MirrorSystem.getSymbol(name_A), value_A);
  }
  static bool asBoolean(value_A) {
    if (value_A == null) {
      return false;
    } else if (value_A == VOID) {
      return false;
    } else if (value_A is int) {
      return value_A != 0;
    } else if (value_A is double) {
      return value_A != 0.0;
    } else if (value_A is String) {
      return value_A.isNotEmpty;
    } else if (value_A is bool) {
      return value_A;
    } else if (value_A is BadgerObject) {
      return value_A.asBoolean_A();
    } else {
      return true;
    }
  }
}
typedef dynamic TypeCreator(List _0);
class Context extends BadgerObject {
  final Context parent;
  final Environment env;
  Context(this.env, [this.parent]);
  String typeName;
  Map<String, BadgerFunction> functions = {};
  Map<String, dynamic> variables = {};
  Map<String, dynamic> meta = {};
  Map<String, dynamic> namespaces = {};
  Map<String, TypeCreator> types = {};
  dynamic getMetadata(String name_A) {
    return meta[name_A];
  }
  bool hasMetadata(String name_A) {
    return meta.containsKey(name_A);
  }
  void setMetadata(String name_A, dynamic value_A) {
    meta[name_A] = value_A;
  }
  void defineNamespace(String name_A, Context context_A) {
    namespaces[name_A] = context_A;
  }
  void defineType(String name_A, TypeCreator creator) {
    types[name_A] = creator;
  }
  Reference getReference(String name_A) {
    return new Reference(this, name_A);
  }
  dynamic getVariable(String name_A) {
    if (variables.containsKey(name_A)) {
      var x_A = variables[name_A];
      if (x_A is Nullable) {
        x_A = x_A.value;
      }
      if (x_A is Immutable) {
        x_A = x_A.value;
      }
      return x_A;
    } else if (hasFunction(name_A)) {
      return getFunction(name_A);
    } else if (parent != null && parent.hasVariable(name_A)) {
      return parent.getVariable(name_A);
    } else {
      throw new Exception("Variable ${name_A} is not defined.");
    }
  }
  void define(String name_A, Function function_A, {bool wrap: true}) {
    functions[name_A] = wrap
        ? ((args) {
      return Function.apply(function_A, args);
    })
        : function_A;
  }
  void alias(String from_A, String to) {
    if (functions.containsKey(from_A)) {
      functions[to] = functions[from_A];
    } else if (variables.containsKey(from_A)) {
      variables[to] = variables[from_A];
    } else {
      throw new Exception(
          "Failed to alias ${from_A} to ${to}, ${from_A} is not defined.");
    }
  }
  void proxy(String name_A, dynamic value_A) {
    if (value_A is Function) {
      functions[name_A] = (args) {
        return Function.apply(value_A, args);
      };
    } else {
      variables[name_A] = value_A;
    }
  }
  void merge(Context ctx) {
    ctx.variables.keys.where((it) => !it.startsWith("_")).forEach((x_A) {
      variables[x_A] = ctx.variables[x_A];
    });
    ctx.functions.keys.where((it) => !it.startsWith("_")).forEach((x_A) {
      functions[x_A] = ctx.functions[x_A];
    });
    ctx.namespaces.keys.where((it) => !it.startsWith("_")).forEach((x_A) {
      namespaces[x_A] = ctx.namespaces[x_A];
    });
    ctx.types.keys.where((it) => !it.startsWith("_")).forEach((x_A) {
      types[x_A] = ctx.types[x_A];
    });
  }
  Context fork() {
    return new Context(env, this);
  }
  bool hasFunction(String name_A) {
    if (functions.containsKey(name_A)) {
      return true;
    } else if (variables.containsKey(name_A) && variables[name_A] is Function) {
      return true;
    } else if (parent != null && parent.hasFunction(name_A)) {
      return true;
    } else {
      return false;
    }
  }
  dynamic invoke(String name_A, List<dynamic> args) {
    if (functions.containsKey(name_A)) {
      return functions[name_A](args);
    } else if (hasType(name_A)) {
      if (types.containsKey(name_A)) {
        return types[name_A](args);
      } else {
        return parent.invoke(name_A, args);
      }
    } else if (variables.containsKey(name_A) && variables[name_A] is Function) {
      return variables[name_A](args);
    } else if (variables.containsKey(name_A) && variables[name_A] is Type) {
      var c = reflectClass(variables[name_A]);
      return c.newInstance(MirrorSystem.getSymbol(""), args).reflectee;
    } else if (parent != null && parent.hasFunction(name_A)) {
      return parent.invoke(name_A, args);
    } else {
      throw new Exception("Method ${name_A} is not defined.");
    }
  }
  Function getFunction(String name_A) {
    if (functions.containsKey(name_A)) {
      return functions[name_A];
    } else if (variables.containsKey(name_A) && variables[name_A] is Function) {
      return variables[name_A];
    } else if (parent != null && parent.hasFunction(name_A)) {
      return parent.getFunction(name_A);
    } else {
      throw new Exception("Method ${name_A} is not defined.");
    }
  }
  bool hasVariable(String name_A) {
    return variables.containsKey(name_A) ||
        (parent != null && parent.hasVariable(name_A));
  }
  bool hasNamespace(String name_A) {
    return namespaces.containsKey(name_A) ||
        (parent != null && parent.hasNamespace(name_A));
  }
  bool hasType(String name_A) {
    return types.containsKey(name_A) ||
        (parent != null && parent.hasType(name_A));
  }
  dynamic setVariable(String name_A, dynamic value_A,
      [bool checkExists = false]) {
    if (checkExists && hasVariable(name_A)) {
      throw new Exception("Unable to set ${name_A}, it is already defined.");
    }
    if (parent != null && parent.hasVariable(name_A)) {
      return parent.setVariable(name_A, value_A);
    } else {
      if (variables.containsKey(name_A)) {
        var v = variables[name_A];
        if (value_A == null && v is! Nullable) {
          throw new Exception(
              "Unable to set ${name_A} to null, it is not nullable.");
        } else if (v is Nullable) {
          v = v.value;
        }
        if (v is Immutable) {
          throw new Exception("Unable to set ${name_A}, it is immutable.");
        }
      }
      return variables[name_A] = value_A;
    }
  }
  dynamic run(void c()) {
    return Zone.ROOT.fork(zoneValues: {"context": this}).run(c);
  }
  static Context get current_A => Zone.current["context"];
  Context getNamespace(String name_A) {
    if (hasNamespace(name_A)) {
      if (namespaces.containsKey(name_A)) {
        return namespaces[name_A];
      } else {
        return parent.getNamespace(name_A);
      }
    } else {
      throw new Exception("Undefined Namespace: ${name_A}");
    }
  }
  void inherit(Context context_A) {
    merge(context_A);
  }
  TypeCreator getType(String name_A) {
    if (hasType(name_A)) {
      if (types.containsKey(name_A)) {
        return types[name_A];
      } else {
        return parent.getType(name_A);
      }
    } else {
      throw new Exception("Undefined Type: ${name_A}");
    }
  }
  dynamic getProperty_A(String name_A) {
    if (hasVariable(name_A)) {
      return getVariable(name_A);
    } else if (hasFunction(name_A)) {
      return getFunction(name_A);
    } else if (hasNamespace(name_A)) {
      return getNamespace(name_A);
    } else if (hasType(name_A)) {
      return getType(name_A);
    } else if (["inherit", "merge"].contains(name_A)) {
      var x_A = reflect(this).getField(new Symbol(name_A)).reflectee;
      if (x_A is Function) {
        return (args) {
          return Function.apply(x_A, args);
        };
      }
      return x_A;
    } else {
      throw new Exception("Failed to get property ${name_A} on context.");
    }
  }
  void setProperty_A(String name_A, dynamic value_A) {
    setVariable(name_A, value_A);
  }
  dynamic createChild(void handler_A()) {
    var ctx = fork();
    return Zone.current.fork(zoneValues: {"context": ctx}).run(() {
      return handler_A();
    });
  }
  String toString() {
    if (typeName != null) {
      return "Instance of '${typeName}'";
    } else {
      return super.toString();
    }
  }
}
final Object VOID = new Object();
final Object _BREAK_NOW = new Object();
class Evaluator {
  static const List<String> SUPPORTED_FEATURES = const [];
  final Program mainProgram;
  final Environment environment_A;
  final Set<String> features = new Set<String>();
  Evaluator(this.mainProgram, this.environment_A);
  evaluate(Context ctx) async {
    var props = await environment_A.getProperties();
    props.addAll(
        {"runtime.name": "badger", "runtime.features": SUPPORTED_FEATURES});
    return await evaluateProgram(mainProgram, ctx);
  }
  evaluateProgram(Program program, Context ctx) async {
    return ctx.run(() async {
      await _processDeclarations(program.declarations, ctx, program);
      var result_A = await _evaluateBlock(program.statements);
      if (result_A is ReturnValue) {
        result_A = result_A.value;
      }
      if (result_A is Immutable) {
        result_A = result_A.value;
      }
      return result_A;
    });
  }
  _processDeclarations(
      List<Declaration> declarations_A, Context ctx, Program program) async {
    for (var decl in declarations_A) {
      if (decl is FeatureDeclaration) {
        if (decl.feature.components.any((it) => it is! String)) {
          throw new Exception(
              "String Interpolation is not allowed in a feature declaration.");
        }
        var f = decl.feature.components.join();
        if (!SUPPORTED_FEATURES.contains(f)) {
          throw new Exception("Unsupported Feature: ${f}");
        }
        features.add(f);
      } else if (decl is ImportDeclaration) {
        await _import(decl.location.components.join(), decl.id, ctx, program);
      } else {
        throw new Exception("Unable to Process Declaration");
      }
    }
  }
  _import(String location_A, String id_A, Context ctx, Program source_A) async {
    var c = await ctx.createChild(() async {
      await environment_A.import_E(
          location_A, this, Context.current_A, source_A);
      return Context.current_A;
    });
    if (id_A == null) {
      ctx.merge(c);
    } else {
      ctx.setVariable(id_A, c);
    }
  }
  _evaluateBlock(List<dynamic> statements, [bool allowBreak = false]) async {
    var retval = VOID;
    for (var statement in statements) {
      if (statement is Statement) {
        var value_A = await _evaluateStatement(statement, allowBreak);
        if (value_A != null) {
          if (value_A is ReturnValue) {
            retval = value_A;
            break;
          } else if (value_A == _BREAK_NOW) {
            if (allowBreak) {
              retval = _BREAK_NOW;
              break;
            }
          } else {
            if (value_A is ReturnValue) {
              value_A = value_A.value;
            }
            if (value_A is Immutable) {
              value_A = value_A.value;
            }
            retval = value_A;
          }
        }
      } else if (statement is Expression) {
        retval = await _resolveValue(statement);
      } else {
        throw new Exception("Invalid Block Statement");
      }
    }
    return retval;
  }
  _evaluateStatement(Statement statement, [bool allowBreak = false]) async {
    if (statement is MethodCall) {
      return await _callMethod(statement);
    } else if (statement is Assignment) {
      var value_A = await _resolveValue(statement.value);
      if (statement.immutable) {
        value_A = new Immutable(value_A);
      }
      if (statement.isNullable == true) {
        value_A = new Nullable(value_A);
      }
      var ref = statement.reference;
      if (ref is String) {
        Context.current_A.setVariable(ref, value_A, statement.isInitialDefine);
      } else {
        var n = ref.identifier;
        var x_A = await _resolveValue(ref.reference);
        if (x_A is BadgerObject) {
          x_A.setProperty_A(n, value_A);
        } else {
          BadgerUtils.setProperty(n, value_A, x_A);
        }
      }
      return value_A;
    } else if (statement is MultiAssignment) {
      var r = await _resolveValue(statement.value);
      var ids = statement.ids;
      var i = 0;
      for (var id_A in ids) {
        var v = r is List ? r[i] : r[id_A];
        if (statement.immutable) {
          v = new Immutable(v);
        }
        Context.current_A.setVariable(id_A, v, statement.isInitialDefine);
        i++;
      }
      return r;
    } else if (statement is ReturnStatement) {
      var value_A = null;
      if (statement.expression != null) {
        value_A = await _resolveValue(statement.expression);
      }
      return new ReturnValue(value_A);
    } else if (statement is SwitchStatement) {
      var value_A = await _resolveValue(statement.expression);
      for (var c in statement.cases) {
        var v = await _resolveValue(c.expression);
        if (value_A == v) {
          await _evaluateBlock(c.block.statements, allowBreak);
          break;
        }
      }
    } else if (statement is NamespaceBlock) {
      var ctx = await Context.current_A.createChild(() async {
        await _evaluateBlock(statement.block.statements);
        return Context.current_A;
      });
      Context.current_A.defineNamespace(statement.name, ctx);
    } else if (statement is TypeBlock) {
      var creator;
      creator = (args) async {
        var map_A = {};
        var i = 0;
        for (var n in statement.args) {
          if (i < statement.args.length) {
            map_A[n] = args[i];
          }
          i++;
        }
        for (var n in map_A.keys) {
          Context.current_A.setVariable(n, map_A[n]);
        }
        var x_A = statement.extension != null
            ? await Context.current_A.getType(statement.extension)([])
            : null;
        return await Context.current_A.createChild(() async {
          Context.current_A.typeName = statement.name;
          if (x_A != null) {
            x_A.setVariable("extender", Context.current_A);
            Context.current_A.merge(x_A);
            Context.current_A.setVariable("super", x_A);
          }
          Context.current_A.setVariable("this", Context.current_A);
          await _evaluateBlock(statement.block.statements);
          return Context.current_A;
        });
      };
      Context.current_A.defineType(statement.name, creator);
      return creator;
    } else if (statement is IfStatement) {
      var value_A = await _resolveValue(statement.condition);
      var c = BadgerUtils.asBoolean(value_A);
      var v = await Context.current_A.createChild(() async {
        if (c) {
          return await _evaluateBlock(statement.block.statements, allowBreak);
        } else {
          if (statement.elseBlock != null) {
            return await _evaluateBlock(
                statement.elseBlock.statements, allowBreak);
          }
        }
      });
      return v;
    } else if (statement is TryCatchStatement) {
      var block = statement.tryBlock.statements;
      var catchBlock = statement.catchBlock.statements;
      try {
        await Context.current_A.createChild(() async {
          await _evaluateBlock(block);
        });
      } catch (e) {
        await Context.current_A.createChild(() async {
          Context.current_A.setVariable(statement.identifier, e);
          await _evaluateBlock(catchBlock);
        });
      }
    } else if (statement is WhileStatement) {
      while (BadgerUtils.asBoolean(await _resolveValue(statement.condition))) {
        var value_A = await Context.current_A.createChild(() async {
          return await _evaluateBlock(statement.block.statements, true);
        });
        if (value_A == _BREAK_NOW) {
          break;
        } else if (value_A is ReturnValue) {
          return value_A;
        }
      }
    } else if (statement is ForInStatement) {
      var i = statement.identifier;
      var n = await _resolveValue(statement.value);
      call_A(value_A) async {
        return Context.current_A.createChild(() async {
          Context.current_A.setVariable(i, value_A);
          return await _evaluateBlock(statement.block.statements, allowBreak);
        });
      }
      if (n is Stream) {
        await for (var x_A in n) {
          var result_A = await call_A(x_A);
          if (result_A == _BREAK_NOW) {
            break;
          }
        }
      } else {
        for (var x_A in n) {
          call_A(x_A);
        }
      }
    } else if (statement is FunctionDefinition) {
      var name_A = statement.name;
      var argnames = statement.args;
      var block = statement.block;
      var ctx = Context.current_A;
      ctx.define(name_A, (args) async {
        var i = 0;
        var inputs = {};
        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }
        return ctx.createChild(() async {
          var cmt = Context.current_A;
          for (var n in inputs.keys) {
            cmt.setVariable(n, inputs[n]);
          }
          var result_A = await _evaluateBlock(block.statements, allowBreak);
          if (result_A is ReturnValue) {
            result_A = result_A.value;
          }
          return result_A;
        });
      }, wrap: false);
    } else if (statement is BreakStatement) {
      return _BREAK_NOW;
    } else {
      throw new Exception("Unable to Execute Statement");
    }
    return null;
  }
  _resolveValue(Expression expr) async {
    var v = await __resolveValue(expr);
    if (v is ReturnValue) {
      v = v.value;
    }
    if (v is Immutable) {
      v = v.value;
    }
    return v;
  }
  __resolveValue(Expression expr) async {
    if (expr is StringLiteral) {
      var components = [];
      for (var it in expr.components) {
        if (it is Expression) {
          components.add(await _resolveValue(it));
        } else {
          components.add(it);
        }
      }
      return _unescape(components.join());
    } else if (expr is IntegerLiteral) {
      return expr.value;
    } else if (expr is DoubleLiteral) {
      return expr.value;
    } else if (expr is HexadecimalLiteral) {
      return expr.value;
    } else if (expr is VariableReference) {
      return Context.current_A.getProperty_A(expr.identifier);
    } else if (expr is Parentheses) {
      return await _resolveValue(expr.expression);
    } else if (expr is AnonymousFunction) {
      var argnames = expr.args;
      var block = expr.block;
      var func = (args) async {
        var i = 0;
        var inputs = {};
        for (var n in args) {
          if (i >= argnames.length) {
            break;
          }
          inputs[argnames[i]] = n;
          i++;
        }
        return await Context.current_A.createChild(() async {
          var c = Context.current_A;
          for (var n in inputs.keys) {
            c.setVariable(n, inputs[n]);
          }
          var result_A = await _evaluateBlock(block.statements);
          if (result_A is ReturnValue) {
            result_A = result_A.value;
          }
          if (result_A is Immutable) {
            result_A = result_A.value;
          }
          return result_A;
        });
      };
      return new Interceptor((a) async {
        return await func(a);
      });
    } else if (expr is MethodCall) {
      return await _callMethod(expr);
    } else if (expr is Defined) {
      return Context.current_A.hasVariable(expr.identifier);
    } else if (expr is NativeCode) {
      throw new Exception("Native Code is not supported on the evaluator.");
    } else if (expr is ReferenceCreation) {
      return Context.current_A.getReference(expr.variable.identifier);
    } else if (expr is Access) {
      var value_A = await _resolveValue(expr.reference);
      for (var p in expr.parts) {
        if (p is String) {
          if (value_A is BadgerObject) {
            value_A = await value_A.getProperty_A(p);
          } else {
            value_A = await BadgerUtils.getProperty(p, value_A);
          }
        } else {
          MethodCall c = p;
          value_A = await _callMethod(c, value_A);
        }
      }
      return value_A;
    } else if (expr is Negate) {
      return !(await _resolveValue(expr.expression));
    } else if (expr is RangeLiteral) {
      var step = expr.step != null ? await _resolveValue(expr.step) : 1;
      return _createRange(
          await _resolveValue(expr.left), await _resolveValue(expr.right),
          inclusive: !expr.exclusive, step: step);
    } else if (expr is TernaryOperator) {
      var value_A = await _resolveValue(expr.condition);
      var c = BadgerUtils.asBoolean(value_A);
      if (c) {
        return await _resolveValue(expr.whenTrue);
      } else {
        return await _resolveValue(expr.whenFalse);
      }
    } else if (expr is MapDefinition) {
      var map_A = {};
      for (var e in expr.entries) {
        var key_A = await _resolveValue(e.key);
        var value_A = await _resolveValue(e.value);
        map_A[key_A] = value_A;
      }
      return map_A;
    } else if (expr is NullLiteral) {
      return null;
    } else if (expr is ListDefinition) {
      var x_A = [];
      for (var e in expr.elements) {
        x_A.add(await _resolveValue(e));
      }
      return x_A;
    } else if (expr is BooleanLiteral) {
      return expr.value;
    } else if (expr is BracketAccess) {
      var index_A = await _resolveValue(expr.index);
      return (await _resolveValue(expr.reference))[index_A];
    } else if (expr is Operator) {
      var op = expr.op;
      return await _handleOperation(expr.left, expr.right, op);
    } else {
      throw new Exception("Unable to Resolve Value: ${expr}");
    }
  }
  _handleOperation(Expression left_A, Expression right_A, String op) async {
    var a = () async => await _resolveValue(left_A);
    var b = () async => await _resolveValue(right_A);
    switch (op) {
      case "+":
        return (await a()) + (await b());

      case "-":
        return (await a()) - (await b());

      case "*":
        return (await a()) * (await b());

      case "/":
        return (await a()) / (await b());

      case "~/":
        return (await a()) ~/ (await b());

      case "<":
        return (await a()) < (await b());

      case ">":
        return (await a()) > (await b());

      case "<=":
        return (await a()) <= (await b());

      case ">=":
        return (await a()) >= (await b());

      case "==":
        return (await a()) == (await b());

      case "!=":
        return (await a()) != (await b());

      case "&":
        return (await a()) & (await b());

      case "in":
        var m = await b();
        var c = await a();
        if (m is Map) {
          return m.containsKey(c);
        } else {
          return m.contains(c);
        }
        break;

      case "|":
        return (await a()) | (await b());

      case "||":
        return BadgerUtils.asBoolean((await a())) ||
            BadgerUtils.asBoolean((await b()));

      case "&&":
        return BadgerUtils.asBoolean((await a())) &&
            BadgerUtils.asBoolean((await b()));

      default:
        throw new Exception("Unsupported Operator");
    }
  }
  dynamic _callMethod(MethodCall call_A, [dynamic obj]) async {
    var args = [];
    for (var s in call_A.args) {
      args.add(await _resolveValue(s));
    }
    var ref = call_A.reference;
    if (ref is String && obj == null) {
      return await Context.current_A.invoke(ref, args);
    } else {
      var v = obj == null ? await _resolveValue(ref.reference) : obj;
      var l = call_A.reference;
      if (obj == null) {
        List<String> n = ref.identifiers;
        List<String> ids = new List<String>.from(n);
        ids.removeLast();
        for (var id_A in ids) {
          v = await BadgerUtils.getProperty(id_A, v);
          if (v is ReturnValue) {
            v = v.value;
          }
          if (v is Immutable) {
            v = v.value;
          }
        }
        l = n.last;
      }
      var z_A = await BadgerUtils.getProperty(l, v);
      if (z_A is ReturnValue) {
        z_A = z_A.value;
      }
      if (z_A is Immutable) {
        z_A = z_A.value;
      }
      return await Function.apply(z_A, args);
    }
  }
}
Iterable<int> _createRange(int lower, int upper,
    {bool inclusive: true, int step: 1}) {
  if (step == 1) {
    if (inclusive) {
      return new Iterable<int>.generate(upper - lower + 1, (i) => lower + i)
          .toList();
    } else {
      return new Iterable<int>.generate(upper - lower - 1, (i) => lower + i + 1)
          .toList();
    }
  } else {
    var list_A = [];
    for (var i = inclusive ? lower : lower + step;
        inclusive ? i <= upper : i < upper;
        i += step) {
      list_A.add(i);
    }
    return list_A;
  }
}
class ReturnValue {
  final dynamic value;
  ReturnValue(this.value);
}
const _PRINT = print;
class CoreLibrary {
  static void import_A(Context context_A) {
    context_A.proxy("print", print_A);
    context_A.proxy("π", PI);
    context_A.proxy("Math", BadgerMath);
    context_A.proxy("Random", Random);
    context_A.proxy("getCurrentContext", getCurrentContext);
    context_A.alias("getCurrentContext", "currentContext");
    context_A.proxy("newContext", newContext);
    context_A.proxy("run", run_A);
    context_A.proxy("JSON", JSON_A);
    context_A.proxy("make", make);
    context_A.proxy("sleep", sleep_A);
    context_A.proxy("async", async_A);
    context_A.proxy("waitForLoop", waitForLoop);
    context_A.proxy("later", later);
    context_A.proxy("void", VOID);
    context_A.proxy("eval", eval);
    context_A.proxy("EventBus", EventBus);
    context_A.proxy("inheritContext", inheritContext);
    context_A.proxy("Runtime", BadgerRuntime);
  }
  static dynamic eval(String content) async {
    var parser = new BadgerParser();
    var program = parser.parse_B(content).value;
    var env = new ImportMapEnvironment({});
    var evaluator = new Evaluator(program, env);
    return await evaluator.evaluate(Context.current_A);
  }
  static void inheritContext(Context ctx) {
    Context.current_A.inherit(ctx);
  }
  static Context getCurrentContext() => Context.current_A;
  static Context newContext() => new Context(Context.current_A.env);
  static void print_A(line_A) {
    _PRINT(line_A);
  }
  static dynamic make(Type type_A, [List<dynamic> args = const []]) {
    return reflectClass(type_A).newInstance(
        MirrorSystem.getSymbol(""), args).reflectee;
  }
  static void later(function_A(), int time) {
    new Future.delayed(new Duration(milliseconds: time)).then((__D) {
      function_A();
    });
  }
  static dynamic run_A(function_A()) {
    return function_A();
  }
  static final BadgerJSON JSON_A = new BadgerJSON();
  static Future sleep_A(int time) async {
    await new Future.delayed(new Duration(milliseconds: time));
  }
  static void async_A(function_A(), [bool microtask_A = false]) {
    if (microtask_A) {
      _A.scheduleMicrotask(function_A);
    } else {
      Timer.run(function_A);
    }
  }
  static Future waitForLoop() async {
    var completer = new Completer();
    Timer.run(() {
      completer.complete();
    });
    return completer.future;
  }
}
class ParserLibrary {
  static void import_B(Context context_A) {
    context_A.proxy("BadgerParser", BadgerParser);
    context_A.proxy("BadgerPrinter", BadgerAstPrinter);
    context_A.proxy("BadgerJsonBuilder", BadgerJsonBuilder);
    context_A.proxy("BadgerJsonParser", BadgerJsonParser);
  }
}
class BadgerJSON {
  dynamic parse_B(String input_A) {
    return JSON.decode(input_A);
  }
  String encode(input_A, [bool pretty = false]) {
    return pretty
        ? new JsonEncoder.withIndent("  ").convert(input_A)
        : JSON.encode(input_A);
  }
}
class BadgerRuntime {}
class BadgerMath {}
enum TestResultType { SUCCESS, FAILURE }
class TestResult {
  final String name;
  final TestResultType type;
  final String message;
  final int duration;
  TestResult(this.name, this.type, this.duration, [this.message]);
}
class TestingLibrary {
  static void _defaultResultHandler(TestResult result_A) {
    var status =
        result_A.type == TestResultType.SUCCESS ? "Success" : "Failure";
    print("${result_A.name}: ${status}");
    if (result_A.message != null && result_A.message.isNotEmpty) {
      print(result_A.message);
    }
  }
  static void import_C(Context context_A, {void handleTestStarted(String name),
      void handleTestResult(TestResult result): _defaultResultHandler,
      void handleTestsBegin(), void handleTestsEnd()}) {
    context_A.define("test", (name_A, func) {
      if (!Context.current_A.meta.containsKey("__tests__")) {
        Context.current_A.meta["__tests__"] = [];
      }
      var tests = Context.current_A.meta["__tests__"];
      tests.add([name_A, func]);
    });
    context_A.define("assertEqual", (a, b) {
      var result_A = a == b;
      if (!result_A) {
        throw new Exception("Test failed: ${a} != ${b}");
      }
    });
    context_A.alias("assertEqual", "testEqual");
    context_A.define("assert", (a) {
      if (!BadgerUtils.asBoolean(a)) {
        throw new Exception("Assertion Failed");
      }
    });
    context_A.define("shouldThrow", (func) async {
      var threw = false;
      try {
        await func([]);
      } catch (e) {
        threw = true;
      }
      if (!threw) {
        throw new Exception("Function did not throw an exception.");
      }
    });
    context_A.define("runTests", () async {
      Context.current_A.setMetadata("__tests__", true);
      if (!Context.current_A.hasMetadata("__tests__")) {
        return false;
      } else {
        var tests = Context.current_A.getMetadata("__tests__");
        if (handleTestsBegin != null) {
          handleTestsBegin();
        }
        for (var test_A in tests) {
          var name_A = test_A[0];
          var func = test_A[1];
          if (handleTestStarted != null) {
            handleTestStarted(name_A);
          }
          var stopwatch = new Stopwatch();
          try {
            stopwatch.start();
            await func([]);
          } catch (e) {
            stopwatch.stop();
            handleTestResult(new TestResult(name_A, TestResultType.FAILURE,
                stopwatch.elapsedMilliseconds, e.toString()));
            continue;
          }
          stopwatch.stop();
          handleTestResult(new TestResult(
              name_A, TestResultType.SUCCESS, stopwatch.elapsedMilliseconds));
        }
        if (handleTestsEnd != null) {
          handleTestsEnd();
        }
        return true;
      }
    });
  }
}
class EventBus {}
final RegExp _unicodeEscapeSequence = new RegExp(r"\\u([0-9a-fA-F]{4})");
final Map<String, String> _decodeTable_A = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
String _unescape(String input_A) {
  for (var code in _decodeTable_A.keys) {
    if (input_A.contains("\\${code}")) {
      input_A = input_A.replaceAll("\\${code}", _decodeTable_A[code]);
    }
  }
  if (_unicodeEscapeSequence.hasMatch(input_A)) {
    input_A = input_A.replaceAllMapped(_unicodeEscapeSequence, (match) {
      var value_A = int.parse(match[1], radix: 16);
      if ((value_A >= 0xD800 && value_A <= 0xDFFF) || value_A > 0x10FFFF) {
        throw new Exception("Invalid Escape Code: value(${value_A})");
      }
      return new String.fromCharCode(value_A);
    });
  }
  return input_A;
}
abstract class IOEnvironment extends BaseEnvironment {}
class FileEnvironment extends IOEnvironment {
  final File file_A;
  FileEnvironment(this.file_A);
  Future import_E(String location_A, Evaluator evaluator, Context context_A,
      Program source_A) async {
    try {
      var uri_A = Uri.parse(location_A);
      if (uri_A.scheme == null || uri_A.scheme.isEmpty) {
        throw new FormatException();
      }
      if (uri_A.scheme == "badger") {
        var name_A = uri_A.path;
        if (name_A == "core") {
          CoreLibrary.import_A(context_A);
        } else if (name_A == "io") {
          IOLibrary.import_D(context_A);
        } else if (name_A == "test") {
          TestingLibrary.import_C(context_A);
        } else if (name_A == "parser") {
          ParserLibrary.import_B(context_A);
        } else {
          throw new Exception("Unknown Standard Library: ${name_A}");
        }
        return;
      } else if (uri_A.scheme == "file") {
        var file_A = new File(uri_A.toFilePath());
        var program = await parse_B(await file_A.readAsString());
        program.meta["file.path"] = file_A.path;
        await evaluator.evaluateProgram(program, context_A);
        return;
      } else if (uri_A.scheme == "http" || uri_A.scheme == "https") {
        var client = new HttpClient();
        var request = await client.getUrl(uri_A);
        var response_A = await request.close();
        if (response_A.statusCode != 200) {
          throw new Exception(
              "Failed to fetch import over HTTP: Status Code: ${response_A.statusCode}");
        }
        var content = await response_A.transform(UTF8.decoder).join();
        var program = await parse_B(content);
        await evaluator.evaluateProgram(program, context_A);
        return;
      } else {
        throw new Exception("Unsupported Import URI Scheme: ${uri_A.scheme}");
      }
    } on FormatException catch (e) {}
    String p;
    if (source_A != null && source_A.meta.containsKey("file.path")) {
      p = dirname(source_A.meta["file.path"]);
    } else {
      p = dirname(file_A.path);
    }
    Program program;
    if (isRelative(location_A)) {
      var f = new File("${p}/${location_A}");
      if (!(await f.exists())) {
        throw new Exception(
            "Tried to import file ${f.path}, but it does not exist.");
      }
      program = await parse_B(await f.readAsString());
      program.meta["file.path"] = f.path;
    } else {
      var f = new File(location_A);
      if (!(await f.exists())) {
        throw new Exception(
            "Tried to import file ${f.path}, but it does not exist.");
      }
      program = await parse_B(await f.readAsString());
      program.meta["file.path"] = f.path;
    }
    await evaluator.evaluateProgram(program, context_A);
  }
  Future<String> readScriptContent() async {
    if (_content != null) {
      return _content;
    } else {
      return _content = await file_A.readAsString();
    }
  }
  String _content;
}
abstract class BadgerFileSystemEntity {}
class BadgerFile extends BadgerFileSystemEntity {}
class BadgerDirectory extends BadgerFileSystemEntity {}
class BadgerHttpClient {}
class BadgerWebSocket {}
class IOLibrary {
  static void import_D(Context context_A) {
    context_A.proxy("HttpClient", BadgerHttpClient);
    context_A.proxy("Socket", BadgerSocket);
    context_A.proxy("File", BadgerFile);
    context_A.proxy("Directory", BadgerDirectory);
    context_A.proxy("FileSystemEntity", BadgerFileSystemEntity);
    context_A.proxy("WebSocket", BadgerWebSocket);
    context_A.proxy("HttpServer", BadgerHttpServer);
    context_A.proxy("Process", BadgerProcess);
    context_A.proxy("stdin", new BadgerStdin());
    context_A.proxy("stdout", new BadgerStdout());
    context_A.proxy("stderr", new BadgerStderr());
    context_A.proxy("Platform", Platform);
    context_A.proxy("NetworkInterface", NetworkInterface);
    context_A.proxy("InternetAddress", InternetAddress);
    context_A.proxy("InternetAddressType", InternetAddressType);
    context_A.proxy("exit", exit);
    context_A.proxy("setExitCode", (x_A) => _B.exitCode = x_A);
    context_A.proxy("getExitCode", () => _B.exitCode);
    context_A.proxy("getProcessId", () => _B.pid);
    context_A.proxy("Channel", Channel);
  }
}
class Channel<T_A> {}
class BadgerProcess {}
class BadgerHttpServer {}
class BadgerSocket {}
class BadgerStderr {
  void write(String line_A, [bool nb = false]) {
    if (nb) {
      _B.stderr.nonBlocking.write(line_A);
    } else {
      _B.stderr.write(line_A);
    }
  }
  Future flush([bool nb = false]) async {
    if (nb) {
      await _B.stderr.nonBlocking.flush();
    } else {
      await _B.stderr.flush();
    }
  }
  Future close([bool nb = false]) async {
    if (nb) {
      await _B.stderr.nonBlocking.close();
    } else {
      await _B.stderr.close();
    }
  }
}
class BadgerStdout {
  void write(String line_A, [bool nb = false]) {
    if (nb) {
      _B.stdout.nonBlocking.write(line_A);
    } else {
      _B.stdout.write(line_A);
    }
  }
  Future flush([bool nb = false]) async {
    if (nb) {
      await _B.stdout.nonBlocking.flush();
    } else {
      await _B.stdout.flush();
    }
  }
  Future close([bool nb = false]) async {
    if (nb) {
      await _B.stdout.nonBlocking.close();
    } else {
      await _B.stdout.close();
    }
  }
}
class BadgerStdin {
  Stream _stream_A;
  Stream<String> _utf;
  Stream<String> _lines;
  BadgerStdin() {
    _stream_A = _B.stdin.asBroadcastStream();
  }
}
class IOUtils {
  static List<FileSystemEntity> _tmps = [];
  static Future<File> createTempFile([String prefix_A]) async {
    var dir = await Directory.systemTemp.createTemp(prefix_A);
    var file_A = new File("${dir.path}/tmpfile");
    _tmps.add(dir);
    return file_A;
  }
  static Future deleteTemporaryFiles() async {
    for (var e in _tmps) {
      await e.delete(recursive: true);
    }
    _tmps.clear();
  }
}
abstract class Statement {}
abstract class Expression {}
abstract class Declaration {}
class MethodCall extends Expression with Statement {
  final dynamic reference;
  final List<Expression> args;
  MethodCall(this.reference, this.args);
  String toString() => "MethodCall(reference: ${reference}, args: ${args})";
}
class Block {
  final List<Statement> statements;
  Block(this.statements);
  String toString() => "Block(${statements})";
}
class BooleanLiteral extends Expression {
  final bool value;
  BooleanLiteral(this.value);
}
class NamespaceBlock extends Statement {
  final String name;
  final Block block;
  NamespaceBlock(this.name, this.block);
}
class TypeBlock extends Statement {
  final String name;
  final List<String> args;
  final Block block;
  final String extension;
  TypeBlock(this.name, this.args, this.extension, this.block);
}
class TryCatchStatement extends Statement {
  final Block tryBlock;
  final String identifier;
  final Block catchBlock;
  TryCatchStatement(this.tryBlock, this.identifier, this.catchBlock);
}
class ReferenceCreation extends Expression {
  final VariableReference variable;
  ReferenceCreation(this.variable);
}
class FunctionDefinition extends Statement {
  final String name;
  final List<String> args;
  final Block block;
  FunctionDefinition(this.name, this.args, this.block);
  String toString() =>
      "FunctionDefinition(name: ${name}, args: ${args}, block: ${block})";
}
class AnonymousFunction extends Expression {
  final List<String> args;
  final Block block;
  AnonymousFunction(this.args, this.block);
}
class BreakStatement extends Statement {}
class IfStatement extends Statement {
  final Expression condition;
  final Block block;
  final Block elseBlock;
  IfStatement(this.condition, this.block, this.elseBlock);
}
class TernaryOperator extends Expression {
  final Expression condition;
  final Expression whenTrue;
  final Expression whenFalse;
  TernaryOperator(this.condition, this.whenTrue, this.whenFalse);
}
class RangeLiteral extends Expression {
  final Expression left;
  final Expression right;
  final Expression step;
  final bool exclusive;
  RangeLiteral(this.left, this.right, this.exclusive, this.step);
}
class Negate extends Expression {
  final Expression expression;
  Negate(this.expression);
}
class NullLiteral extends Expression {}
class Operator extends Expression {
  final Expression left;
  final Expression right;
  final String op;
  Operator(this.left, this.right, this.op);
}
class ForInStatement extends Statement {
  final String identifier;
  final Expression value;
  final Block block;
  ForInStatement(this.identifier, this.value, this.block);
}
class WhileStatement extends Statement {
  final Expression condition;
  final Block block;
  WhileStatement(this.condition, this.block);
}
class ReturnStatement extends Statement {
  final Expression expression;
  ReturnStatement(this.expression);
  String toString() => "ReturnStatement(${expression})";
}
class Access extends Expression {
  final Expression reference;
  final List<dynamic> parts;
  Access(this.reference, this.parts);
}
class StringLiteral extends Expression {
  final List<dynamic> components;
  StringLiteral(this.components);
  String toString() => "StringLiteral(${components})";
}
class NativeCode extends Expression {
  final String code;
  NativeCode(this.code);
}
abstract class NumberLiteral<T_A> extends Expression {
  T_A get value;
}
class IntegerLiteral extends NumberLiteral<int> {
  final int value;
  IntegerLiteral(this.value);
  String toString() => "IntegerLiteral(${value})";
}
class DoubleLiteral extends NumberLiteral<double> {
  final double value;
  DoubleLiteral(this.value);
  String toString() => "DoubleLiteral(${value})";
}
class Defined extends Expression {
  final String identifier;
  Defined(this.identifier);
}
class SwitchStatement extends Statement {
  final Expression expression;
  final List<CaseStatement> cases;
  SwitchStatement(this.expression, this.cases);
}
class CaseStatement extends Statement {
  final Expression expression;
  final Block block;
  CaseStatement(this.expression, this.block);
}
class Parentheses extends Expression {
  final Expression expression;
  Parentheses(this.expression);
}
class HexadecimalLiteral extends NumberLiteral<int> {
  final int value;
  HexadecimalLiteral(this.value);
}
class VariableReference extends Expression {
  final String identifier;
  VariableReference(this.identifier);
  String toString() => "VariableReference(${identifier})";
}
class Assignment extends Statement {
  final bool immutable;
  final dynamic reference;
  final Expression value;
  final bool isInitialDefine;
  final bool isNullable;
  Assignment(this.reference, this.value, this.immutable, this.isInitialDefine,
      this.isNullable);
  String toString() => "Assignment(identifier: ${reference}, value: ${value})";
}
class ListDefinition extends Expression {
  final List<Expression> elements;
  ListDefinition(this.elements);
  String toString() => "ListDefinition(${elements.join(", ")})";
}
class BracketAccess extends Expression {
  final VariableReference reference;
  final Expression index;
  BracketAccess(this.reference, this.index);
  String toString() => "BracketAccess(receiver: ${reference}, index: ${index})";
}
class FeatureDeclaration extends Declaration {
  final StringLiteral feature;
  FeatureDeclaration(this.feature);
  String toString() => "FeatureDeclaration(${feature})";
}
class ImportDeclaration extends Declaration {
  final StringLiteral location;
  final String id;
  ImportDeclaration(this.location, this.id);
  String toString() => "ImportDeclaration(${location})";
}
class MapDefinition extends Expression {
  final List<MapEntry> entries;
  MapDefinition(this.entries);
}
class MapEntry extends Expression {
  final Expression key;
  final Expression value;
  MapEntry(this.key, this.value);
}
class MultiAssignment extends Statement {
  final bool immutable;
  final List<String> ids;
  final Expression value;
  final bool isInitialDefine;
  final bool isNullable;
  MultiAssignment(this.ids, this.value, this.immutable, this.isInitialDefine,
      this.isNullable);
}
class Program {
  final List<dynamic> statements;
  final List<Declaration> declarations;
  Map<String, dynamic> meta = {};
  Program(this.declarations, this.statements);
  String toString() =>
      "Program(\n${statements.map((it) => '  ${it.toString()}').join(",\n")}\n)";
}
class BadgerGrammarDefinition extends GrammarDefinition {
  start() => (whitespace().star().optional() &
      ref(declarations).optional() &
      whitespace().star().optional() &
      ref(statement).separatedBy(whitespace().plus() &
          char(";").optional() &
          whitespace().plus().optional(), includeSeparators: false) &
      whitespace().star().optional()).end();
  statement() => ((ref(functionDefinition) |
          ref(multipleAssign) |
          ref(accessAssignment) |
          ref(assignment) |
          ref(methodCall) |
          ref(ifStatement) |
          ref(whileStatement) |
          ref(breakStatement) |
          ref(forInStatement) |
          ref(returnStatement) |
          ref(switchStatement) |
          ref(tryCatchStatement) |
          ref(namespace) |
          ref(type) |
          ref(expression)) &
      char(";").optional()).pick(0);
  breakStatement() => ref(BREAK);
  booleanLiteral() => ref(TRUE) | ref(FALSE);
  nullLiteral() => ref(NULL);
  multipleAssign() => ((string_A("let") | string_A("var")) &
          char("?").optional() &
          whitespace().star()).optional() &
      char("{") &
      whitespace().star() &
      ref(identifier).separatedBy(
          whitespace().star() & char(",") & whitespace().star(),
          includeSeparators: false) &
      whitespace().star() &
      char("}") &
      whitespace().star() &
      char("=") &
      whitespace().star() &
      ref(expression);
  methodCall() => (ref(identifier) | ref(access)) &
      char("(") &
      ref(arguments).optional() &
      char(")");
  simpleMethodCall() =>
      ref(identifier) & char("(") & ref(arguments).optional() & char(")");
  arguments() => ref(expression).separatedBy(
      whitespace().star() & char(",") & whitespace().star(),
      includeSeparators: false);
  forInStatement() => ref(FOR) &
      whitespace().plus() &
      ref(identifier) &
      whitespace().plus() &
      ref(IN) &
      whitespace().plus() &
      ref(expression) &
      ref(block);
  parens() => char("(") & ref(expression) & char(")");
  returnStatement() => ref(RETURN) &
      (whitespace().star() & ref(expression) & whitespace().star());
  listDefinition() => char("[") &
      whitespace().star() &
      ref(arguments) &
      whitespace().star() &
      char("]");
  ternaryOperator() => ref(expressionItem) &
      whitespace().star() &
      char("?") &
      whitespace().star() &
      ref(expression) &
      whitespace().star() &
      char(":") &
      whitespace().star() &
      ref(expression);
  plusOperator() => ref(OPERATOR, "+");
  minusOperator() => ref(OPERATOR, "-");
  divideOperator() => ref(OPERATOR, "/");
  divideIntOperator() => ref(OPERATOR, "~/");
  multiplyOperator() => ref(OPERATOR, "*");
  andOperator() => ref(OPERATOR, "&&");
  orOperator() => ref(OPERATOR, "||");
  bitwiseAndOperator() => ref(OPERATOR, "&");
  bitwiseOrOperator() => ref(OPERATOR, "|");
  lessThanOperator() => ref(OPERATOR, "<");
  greaterThanOperator() => ref(OPERATOR, ">");
  lessThanOrEqualOperator() => ref(OPERATOR, "<=");
  greaterThanOrEqualOperator() => ref(OPERATOR, ">=");
  bitShiftLeft() => ref(OPERATOR, "<<");
  bitShiftRight() => ref(OPERATOR, ">>");
  equalOperator() => ref(OPERATOR, "==");
  notEqualOperator() => ref(OPERATOR, "!=");
  inOperator() => ref(OPERATOR, "in");
  OPERATOR(String x_A) => ref(expressionItem) &
      whitespace().star() &
      string_A(x_A) &
      whitespace().star() &
      ref(expression);
  NEWLINE_A() => pattern_A('\n\r');
  singleLineComment() =>
      string_A('//') & ref(NEWLINE_A).neg().star() & ref(NEWLINE_A).optional();
  declarations() => ref(declaration).separatedBy(char("\n"));
  declaration() => ref(importDeclaration) | ref(featureDeclaration);
  featureDeclaration() =>
      ref(USING_FEATURE) & whitespace().plus() & ref(stringLiteral);
  importDeclaration() => ref(IMPORT) &
      whitespace().star() &
      ref(stringLiteral) &
      (whitespace().plus() &
          string_A("as") &
          whitespace().plus() &
          ref(identifier)).optional();
  bracketAccess() =>
      ref(variableReference) & char("[") & ref(expressionItem) & char("]");
  reference() => char("&") & ref(variableReference);
  tryCatchStatement() => string_A("try") &
      whitespace().star() &
      ref(block) &
      whitespace().star() &
      string_A("catch") &
      whitespace().star() &
      char("(") &
      ref(identifier) &
      char(")") &
      whitespace().star() &
      ref(block);
  block() => whitespace().star() &
      char("{") &
      whitespace().star() &
      ref(statement).separatedBy(whitespace().star()).optional() &
      whitespace().star() &
      char("}");
  functionDefinition() => ref(FUNC).optional() &
      whitespace().star() &
      ref(identifier) &
      char("(") &
      ref(identifier)
          .separatedBy(whitespace().star() & char(",") & whitespace().star())
          .optional() &
      char(")") &
      ref(block);
  emptyListDefinition() => string_A("[]");
  assignment() =>
      (((ref(LET) | ref(VAR)) & char("?").optional()).flatten().optional() &
              whitespace().plus()).optional() &
          ref(identifier) &
          whitespace().star() &
          ref(token, "=") &
          whitespace().star() &
          ref(expression);
  accessAssignment() => ref(access) &
      whitespace().star() &
      string_A("=") &
      whitespace().star() &
      ref(expression);
  variableReference() => ref(identifier);
  expression() => ref(inOperator) |
      ref(definedOperator) |
      ref(ternaryOperator) |
      ref(plusOperator) |
      ref(minusOperator) |
      ref(multiplyOperator) |
      ref(divideIntOperator) |
      ref(divideOperator) |
      ref(andOperator) |
      ref(orOperator) |
      ref(bitwiseAndOperator) |
      ref(bitwiseOrOperator) |
      ref(lessThanOperator) |
      ref(greaterThanOperator) |
      ref(greaterThanOrEqualOperator) |
      ref(lessThanOrEqualOperator) |
      ref(equalOperator) |
      ref(notEqualOperator) |
      ref(bitShiftLeft) |
      ref(bitShiftRight) |
      ref(negate) |
      ref(expressionItem);
  callable() =>
      ref(stringLiteral) | ref(simpleMethodCall) | ref(variableReference);
  access() => ref(callable) &
      char(".") &
      (ref(simpleMethodCall) | ref(identifier))
          .separatedBy(char("."))
          .optional();
  expressionItem() => ((ref(reference) |
          ref(anonymousFunction) |
          ref(simpleAnonymousFunction) |
          ref(methodCall) |
          ref(access) |
          ref(nullLiteral) |
          ref(nativeCode) |
          ref(rangeLiteral) |
          ref(mapDefinition) |
          ref(hexadecimalLiteral) |
          ref(doubleLiteral) |
          ref(integerLiteral) |
          ref(emptyListDefinition) |
          ref(listDefinition) |
          ref(stringLiteral) |
          ref(parens) |
          ref(bracketAccess) |
          ref(booleanLiteral) |
          ref(variableReference)) &
      char(";").optional()).pick(0);
  negate() => char("!") & ref(expressionItem);
  definedOperator() => ref(identifier) & char("?");
  ifStatement() => ref(IF) &
      whitespace().plus() &
      ref(expression) &
      whitespace().plus() &
      ref(block) &
      (whitespace().star() & ref(ELSE) & ref(block)).optional();
  namespace() => ref(token, "namespace") &
      whitespace().plus() &
      ref(identifier) &
      whitespace().star() &
      ref(block);
  type() => ref(token, "type") &
      whitespace().plus() &
      ref(identifier) &
      (char("(") &
          ref(identifier)
              .separatedBy(
                  whitespace().star() & char(",") & whitespace().star())
              .optional() &
          char(")")).pick(1).optional() &
      whitespace().plus() &
      (ref(token, "extends") & whitespace().plus() & ref(identifier))
          .optional() &
      whitespace().star() &
      ref(block);
  switchStatement() => ref(SWITCH) &
      whitespace().plus() &
      ref(expression) &
      whitespace().plus() &
      char("{") &
      whitespace().plus() &
      (ref(caseStatement)).separatedBy(whitespace().star()).optional() &
      whitespace().plus() &
      char("}") &
      whitespace().star();
  caseStatement() => ref(CASE) &
      whitespace().plus() &
      ref(expression) &
      whitespace().star() &
      ref(block);
  simpleAnonymousFunction() => char("(") &
      ref(identifier)
          .separatedBy(whitespace().star() & char(",") & whitespace().star())
          .optional() &
      whitespace().star() &
      string_A(") =>") &
      whitespace().star() &
      ref(expression);
  whileStatement() => ref(WHILE) &
      whitespace().plus() &
      ref(expression) &
      whitespace().plus() &
      ref(block);
  anonymousFunction() => char("(") &
      ref(identifier)
          .separatedBy((whitespace().star() & char(",") & whitespace().star()))
          .optional() &
      whitespace().star() &
      string_A(") ->") &
      whitespace().star() &
      ref(block);
  integerLiteral() => (anyIn(["-", "+"]).optional() & digit().plus()).flatten();
  rangeLiteral() => (ref(integerLiteral) &
      string_A("..") &
      char("<").optional() &
      ref(integerLiteral) &
      (char(":") & ref(integerLiteral)).optional());
  hexadecimalLiteral() =>
      (string_A("0x") & (pattern_A("0-9A-Fa-f").plus().flatten()));
  doubleLiteral() => (anyIn(["-", "+"]).optional() &
      digit().plus() &
      char(".") &
      digit().plus()).flatten();
  stringLiteral() =>
      char('"') & (ref(interpolation) | ref(character)).star() & char('"');
  mapDefinition() => char("{") &
      whitespace().star() &
      ref(mapEntry)
          .separatedBy((char(",") | whitespace().star()).trim(),
              includeSeparators: false)
          .optional() &
      char(",").optional() &
      whitespace().star() &
      char("}");
  nativeCode() =>
      string_A("```") & pattern_A("^```").star().flatten() & string_A("```");
  mapEntry() => ref(expressionItem) &
      whitespace().star() &
      (char(":") | string_A("->")) &
      whitespace().star() &
      ref(expression);
  interpolation() => string_A("\$(") & ref(expression) & char(")");
  character() => ref(unicodeEscape) | ref(characterEscape) | pattern_A('^"\\');
  unicodeEscape() =>
      (string_A("\\u") & pattern_A("A-Fa-f0-9").times(4)).flatten();
  characterEscape() =>
      (string_A("\\") & pattern_A(_decodeTable_B.keys.join())).flatten();
  identifier() => (pattern_A("A-Za-z_") | anyIn(["\$", "\u03A0"])).plus();
  BREAK() => ref(token, "break");
  CASE() => ref(token, "case");
  ELSE() => ref(token, "else");
  TRUE() => ref(token, "true");
  FALSE() => ref(token, "false");
  FOR() => ref(token, "for");
  IF() => ref(token, "if");
  IN() => ref(token, "in");
  NULL() => ref(token, "null");
  SWITCH() => ref(token, "switch");
  VAR() => ref(token, "var");
  LET() => ref(token, "let");
  WHILE() => ref(token, "while");
  FUNC() => ref(token, "func");
  RETURN() => ref(token, "return");
  IMPORT() => ref(token, "import");
  USING_FEATURE() => ref(token, "using feature");
  HIDDEN() => ref(singleLineComment);
  Parser token(input_A) {
    if (input_A is String) {
      input_A = input_A.length == 1 ? char(input_A) : string_A(input_A);
    } else if (input_A is Function) {
      input_A = ref(input_A);
    }
    if (input_A is! Parser && input_A is TrimmingParser) {
      throw new StateError("Invalid token parser: ${input_A}");
    }
    return input_A.token().trim(ref(HIDDEN));
  }
}
class BadgerSnapshotParser {
  final Map input;
  BadgerSnapshotParser(this.input);
  Map<String, Program> parse_B() {
    var progs = {};
    for (var loc in input.keys) {
      progs.addAll(go(loc, input[loc]));
    }
    return progs;
  }
  Map<String, Program> go(String name_A, Map it) {
    if (!it.containsKey("statements") && !it.containsKey("g")) {
      var map_A = {};
      for (var key_A in it.keys) {
        var x_A = go(key_A, it[key_A]);
        map_A[key_A] = x_A;
      }
      var c = null;
      if (map_A["_"].containsKey("_")) {
        c = map_A["_"]["_"];
      } else {
        c = map_A["_"];
      }
      map_A.remove("_");
      map_A[name_A] = c;
      return map_A;
    } else {
      return {(name_A): new BadgerJsonParser().build(it)};
    }
  }
}
class BadgerJsonBuilder {}
class BadgerTinyAst {
  static final Map<String, String> MAPPING = {
    "type": "a",
    "immutable": "b",
    "reference": "c",
    "identifier": "d",
    "value": "e",
    "declarations": "f",
    "statements": "g",
    "isInitialDefine": "h",
    "op": "i",
    "components": "j",
    "args": "k",
    "method call": "l",
    "access": "m",
    "block": "n",
    "operator": "o",
    "assignment": "p",
    "string literal": "q",
    "left": "r",
    "right": "s",
    "variable reference": "t",
    "for in": "u",
    "if": "v",
    "while": "w",
    "function definition": "x",
    "anonymous function": "y",
    "import declaration": "z",
    "integer literal": "+",
    "double literal": "-",
    "hexadecimal literal": "@",
    "ternary operator": ">",
    "boolean literal": "<",
    "range literal": ".",
    "list definition": "|",
    "map definition": "[",
    "map entry": "]",
    "return": "*",
    "ternary": ";",
    "break": "=",
    "defined": "#",
    "condition": "{",
    "whenTrue": "%",
    "whenFalse": "&",
    "elements": "^",
    "parentheses": "%",
    "isNullable": "(",
    "location": ")",
    "parts": "?",
    "extension": "_",
    "multiple assignment": "~",
    "catch": "`",
    "try": ","
  };
  static String demap(String key_A) {
    if (MAPPING.values.contains(key_A)) {
      return MAPPING.keys.firstWhere((it) => MAPPING[it] == key_A);
    } else {
      return key_A;
    }
  }
  static Map expand_A(Map it) {
    return transformMapStrings(it, (key_A) {
      return demap(key_A);
    });
  }
  static dynamic transformMapStrings(it, dynamic transformer(x)) {
    if (it is Map) {
      var r = {};
      for (var x_A in it.keys) {
        var v = it[x_A];
        if (x_A == "type" || x_A == MAPPING["type"]) {
          v = x_A == "type"
              ? (MAPPING.containsKey(v) ? MAPPING[v] : v)
              : demap(v);
        }
        r[transformer(x_A)] = transformMapStrings(v, transformer);
      }
      return r;
    } else if (it is List) {
      var l = [];
      for (var x_A in it) {
        l.add(transformMapStrings(x_A, transformer));
      }
      return l;
    } else {
      return it;
    }
  }
}
class BadgerJsonParser {
  Program build(Map input_A) {
    if (!input_A.containsKey("statements") && input_A.containsKey("g")) {
      input_A = BadgerTinyAst.expand_A(input_A);
    }
    var declarations_A =
        input_A["declarations"].map(_buildDeclaration).toList();
    var statements = input_A["statements"].map(_buildStatement).toList();
    return new Program(declarations_A, statements);
  }
  Declaration _buildDeclaration(Map it) {
    var type_A = it["type"];
    if (type_A == "feature declaration") {
      return new FeatureDeclaration(_buildStringLiteral(it["feature"]));
    } else if (type_A == "import declaration") {
      return new ImportDeclaration(
          _buildStringLiteral(it["location"]), it["identifier"]);
    } else {
      throw new Exception("Invalid Declaration");
    }
  }
  dynamic _buildStatement(Map it) {
    var type_A = it["type"];
    if (type_A == "method call") {
      return _buildMethodCall(it);
    } else if (type_A == "assignment") {
      return new Assignment(it["reference"] is String
              ? it["reference"]
              : _buildExpression(it["reference"]),
          _buildExpression(it["value"]), it["immutable"], it["isInitialDefine"],
          it["isNullable"]);
    } else if (type_A == "function definition") {
      return new FunctionDefinition(it["identifier"], it["args"],
          new Block(it["block"].map(_buildStatement).toList()));
    } else if (type_A == "while") {
      return new WhileStatement(_buildExpression(it["condition"]),
          new Block(it["block"].map(_buildStatement).toList()));
    } else if (type_A == "if") {
      return new IfStatement(_buildExpression(it["condition"]),
          new Block(it["block"].map(_buildStatement).toList()), new Block(
              it["elseBlock"] == null
                  ? []
                  : it["elseBlock"].map(_buildStatement).toList()));
    } else if (type_A == "for in") {
      return new ForInStatement(it["identifier"], _buildExpression(it["value"]),
          new Block(it["block"].map(_buildStatement).toList()));
    } else if (type_A == "multiple assignment") {
      return new MultiAssignment(it["ids"], _buildExpression(it["value"]),
          it["immutable"], it["isInitialDefine"], it["isNullable"]);
    } else if (type_A == "type") {
      return new TypeBlock(it["name"], it["args"], it["extension"],
          new Block(it["block"].map(_buildStatement).toList()));
    } else if (type_A == "namespace") {
      return new NamespaceBlock(
          it["name"], new Block(it["block"].map(_buildStatement).toList()));
    } else if (type_A == "return") {
      return new ReturnStatement(
          it["value"] == null ? null : _buildExpression(it["value"]));
    } else if (type_A == "try") {
      return new TryCatchStatement(
          new Block(it["block"].map(_buildStatement).toList()),
          it["identifier"],
          new Block(it["catch"].map(_buildStatement).toList()));
    } else if (type_A == "break") {
      return new BreakStatement();
    } else if (type_A == "switch") {
      return new SwitchStatement(_buildExpression(it["expression"]),
          it["cases"].map(_buildStatement).toList());
    } else {
      return _buildExpression(it);
    }
  }
  Expression _buildExpression(Map it) {
    var type_A = it["type"];
    if (type_A == "string literal") {
      return _buildStringLiteral(it["components"]);
    } else if (type_A == "variable reference") {
      return new VariableReference(it["identifier"]);
    } else if (type_A == "method call") {
      return _buildMethodCall(it);
    } else if (type_A == "integer literal") {
      return new IntegerLiteral(it["value"]);
    } else if (type_A == "double literal") {
      return new DoubleLiteral(it["value"]);
    } else if (type_A == "operator") {
      return new Operator(_buildExpression(it["left"]),
          _buildExpression(it["right"]), it["op"]);
    } else if (type_A == "negate") {
      return new Negate(_buildExpression(it["value"]));
    } else if (type_A == "null") {
      return new NullLiteral();
    } else if (type_A == "range literal") {
      return new RangeLiteral(_buildExpression(it["left"]),
          _buildExpression(it["right"]), it["exclusive"],
          it["step"] != null ? _buildExpression(it["step"]) : null);
    } else if (type_A == "hexadecimal literal") {
      return new HexadecimalLiteral(it["value"]);
    } else if (type_A == "boolean literal") {
      return new BooleanLiteral(it["value"]);
    } else if (type_A == "ternary") {
      return new TernaryOperator(_buildExpression(it["condition"]),
          _buildExpression(it["whenTrue"]), _buildExpression(it["whenFalse"]));
    } else if (type_A == "reference") {
      return new ReferenceCreation(_buildExpression(it["value"]));
    } else if (type_A == "parentheses") {
      return new Parentheses(_buildExpression(it["expression"]));
    } else if (type_A == "access") {
      return new Access(_buildExpression(it["reference"]), it["parts"]
          .map((it) => it is Map ? _buildExpression(it) : it)
          .toList());
    } else if (type_A == "map definition") {
      return new MapDefinition(it["entries"].map(_buildExpression).toList());
    } else if (type_A == "map entry") {
      return new MapEntry(
          _buildExpression(it["key"]), _buildExpression(it["value"]));
    } else if (type_A == "list definition") {
      return new ListDefinition(it["elements"].map(_buildExpression).toList());
    } else if (type_A == "bracket access") {
      return new BracketAccess(
          _buildExpression(it["reference"]), _buildExpression(it["index"]));
    } else if (type_A == "anonymous function") {
      return new AnonymousFunction(
          it["args"], new Block(it["block"].map(_buildStatement).toList()));
    } else if (type_A == "native code") {
      return new NativeCode(it["code"]);
    } else if (type_A == "defined") {
      return new Defined(it["identifier"]);
    } else {
      throw new Exception("Failed to build expression for ${it}");
    }
  }
  MethodCall _buildMethodCall(Map it) {
    var ref = it["reference"];
    var args = it["args"].map(_buildExpression).toList();
    if (ref is Map) {
      ref = _buildExpression(ref);
    }
    return new MethodCall(ref, args);
  }
  StringLiteral _buildStringLiteral(List components) {
    var c = [];
    for (var m in components) {
      if (m is String) {
        c.add(m);
      } else {
        c.add(_buildExpression(m));
      }
    }
    return new StringLiteral(c);
  }
}
class BadgerParserDefinition extends BadgerGrammarDefinition {
  start() => super.start().map((it) {
    return new Program(it[1] == null
        ? []
        : it[1].where((it) => it is Declaration).toList(), it[3] == null
        ? []
        : it[3].where((it) => it is Statement || it is Expression).toList());
  });
  methodCall() => super.methodCall().map((it) {
    return new MethodCall(it[0], it[2] == null ? [] : it[2]);
  });
  stringLiteral() => super.stringLiteral().map((it) {
    return new StringLiteral(it[1]);
  });
  simpleMethodCall() => super.simpleMethodCall().map((it) {
    return new MethodCall(it[0], it[2] == null ? [] : it[2]);
  });
  type() => super.type().map((it) {
    return new TypeBlock(it[2],
        it[3] == null ? [] : it[3].where((it) => it is String).toList(),
        it[5] != null ? it[5][2] : null, it[7]);
  });
  namespace() => super.namespace().map((it) {
    return new NamespaceBlock(it[2], it[4]);
  });
  switchStatement() => super.switchStatement().map((it) {
    return new SwitchStatement(it[2], (it[6] == null ? [] : it[6])
        .where((it) => it is CaseStatement)
        .toList());
  });
  caseStatement() => super.caseStatement().map((it) {
    return new CaseStatement(it[2], it[4] == null ? new Block([]) : it[4]);
  });
  breakStatement() => super.breakStatement().map((it) {
    return new BreakStatement();
  });
  interpolation() => super.interpolation().map((it) {
    return it[1];
  });
  mapDefinition() => super.mapDefinition().map((it) {
    return new MapDefinition(it[2] == null ? [] : it[2]);
  });
  simpleAnonymousFunction() => super.simpleAnonymousFunction().map((it) {
    return new AnonymousFunction(it[1], new Block([it[5]]));
  });
  mapEntry() => super.mapEntry().map((it) {
    return new MapEntry(it[0], it[4]);
  });
  statement() => super.statement().map((it) {
    return it;
  });
  rangeLiteral() => super.rangeLiteral().map((it) {
    return new RangeLiteral(
        it[0], it[3], it[2] != null, it[4] != null ? it[4][1] : null);
  });
  negate() => super.negate().map((it) {
    return new Negate(it[1]);
  });
  nullLiteral() => super.nullLiteral().map((Token token) {
    return new NullLiteral();
  });
  arguments() => super.arguments().map((it) {
    return it.where((it) => it is Expression).toList();
  });
  returnStatement() => super.returnStatement().map((it) {
    return new ReturnStatement(it[1][1]);
  });
  OPERATOR(String n) => super.OPERATOR(n).map((it) {
    return new Operator(it[0], it[4], it[2]);
  });
  doubleLiteral() => super.doubleLiteral().map((it) {
    return new DoubleLiteral(double.parse(it));
  });
  importDeclaration() => super.importDeclaration().map((it) {
    return new ImportDeclaration(it[2], it[3] != null ? it[3][3] : null);
  });
  hexadecimalLiteral() => super.hexadecimalLiteral().map((it) {
    return new HexadecimalLiteral(int.parse(it[1], radix: 16));
  });
  ternaryOperator() => super.ternaryOperator().map((it) {
    return new TernaryOperator(it[0], it[4], it[8]);
  });
  assignment() => super.assignment().map((it) {
    var isInitialDefine = it[0] != null;
    var isNullable = it[0] == null ? null : it[0][0].endsWith("?");
    var isImmutable = it[0] != null && it[0][0].startsWith("let");
    return new Assignment(
        it[1], it[5], isImmutable, isInitialDefine, isNullable);
  });
  multipleAssign() => super.multipleAssign().map((it) {
    var isInitialDefine = it[0] != null;
    var isNullable = it[0] == null ? null : it[0][0].endsWith("?");
    var isImmutable = it[0] != null && it[0][0].startsWith("let");
    return new MultiAssignment(
        it[3], it[9], isImmutable, isInitialDefine, isNullable);
  });
  accessAssignment() => super.accessAssignment().map((it) {
    return new Assignment(it[0], it[4], false, false, true);
  });
  forInStatement() => super.forInStatement().map((it) {
    return new ForInStatement(it[2], it[6], it[7]);
  });
  access() => super.access().map((it) {
    var ids = it[2].where((it) => it != ".").toList();
    return new Access(it[0], ids);
  });
  integerLiteral() => super.integerLiteral().map((it) {
    return new IntegerLiteral(int.parse(it));
  });
  ifStatement() => super.ifStatement().map((it) {
    return new IfStatement(it[2], it[4], it[5] != null ? it[5][2] : null);
  });
  whileStatement() => super.whileStatement().map((it) {
    return new WhileStatement(it[2], it[4]);
  });
  booleanLiteral() => super.booleanLiteral().map((Token it) {
    return new BooleanLiteral(it.value == "true");
  });
  parens() => super.parens().map((it) {
    return new Parentheses(it[1]);
  });
  listDefinition() => super.listDefinition().map((it) {
    return new ListDefinition(it[2]);
  });
  emptyListDefinition() => super.emptyListDefinition().map((it) {
    return new ListDefinition([]);
  });
  nativeCode() => super.nativeCode().map((it) {
    return new NativeCode(it[1]);
  });
  definedOperator() => super.definedOperator().map((it) {
    return new Defined(it[0]);
  });
  featureDeclaration() => super.featureDeclaration().map((it) {
    return new FeatureDeclaration(it[2]);
  });
  bracketAccess() => super.bracketAccess().map((it) {
    return new BracketAccess(it[0], it[2]);
  });
  anonymousFunction() => super.anonymousFunction().map((it) {
    var x_A = it[1] != null ? it[1].where((it) => it is String).toList() : [];
    return new AnonymousFunction(x_A, it[5]);
  });
  variableReference() => super.variableReference().map((it) {
    return new VariableReference(it);
  });
  functionDefinition() => super.functionDefinition().map((it) {
    var argnames =
        it[4] != null ? it[4].where((it) => it is String).toList() : [];
    return new FunctionDefinition(it[2], argnames, it[6]);
  });
  reference() => super.reference().map((it) {
    return new ReferenceCreation(it[1]);
  });
  tryCatchStatement() => super.tryCatchStatement().map((it) {
    return new TryCatchStatement(it[2], it[7], it[10]);
  });
  block() => super.block().map((it) {
    return new Block(it[3] == null
        ? []
        : it[3].where((it) => it is Statement || it is Expression).toList());
  });
  identifier() => super.identifier().map((it) {
    return it.join();
  });
}
class BadgerParser extends GrammarParser {
  BadgerParser() : super(new BadgerParserDefinition());
}
class BadgerAstPrinter extends AstVisitor {}
final Map<String, String> _decodeTable_B = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
abstract class AstVisitorBase {}
abstract class AstVisitor extends AstVisitorBase {}
final Context_A context = createInternal();
String get current_B {
  var uri_A = Uri.base;
  if (Style.platform == Style.url) {
    return uri_A.resolve('.').toString();
  } else {
    var path_A = uri_A.toFilePath();
    int lastIndex = path_A.length - 1;
    assert(path_A[lastIndex] == '/' || path_A[lastIndex] == '\\');
    return path_A.substring(0, lastIndex);
  }
}
String dirname(String path_A) => context.dirname_A(path_A);
bool isRelative(String path_A) => context.isRelative_A(path_A);
const SLASH_A = 0x2f;
const COLON_A = 0x3a;
const UPPER_A = 0x41;
const UPPER_Z = 0x5a;
const LOWER_A = 0x61;
const LOWER_Z = 0x7a;
const BACKSLASH_A = 0x5c;
Context_A createInternal() => new Context_A._internal_A();
class Context_A {
  Context_A._internal_A()
      : style = Style.platform,
        _current_A = null;
  final InternalStyle style;
  final String _current_A;
  String get current => _current_A != null ? _current_A : current_B;
  String get separator => style.separator;
  String dirname_A(String path_A) {
    var parsed = _parse_B(path_A);
    parsed.removeTrailingSeparators();
    if (parsed.parts.isEmpty) return parsed.root == null ? '.' : parsed.root;
    if (parsed.parts.length == 1) {
      return parsed.root == null ? '.' : parsed.root;
    }
    parsed.parts.removeLast();
    parsed.separators.removeLast();
    parsed.removeTrailingSeparators();
    return parsed.toString();
  }
  String extension(String path_A) => _parse_B(path_A).extension;
  String rootPrefix(String path_A) =>
      path_A.substring(0, style.rootLength(path_A));
  bool isAbsolute(String path_A) => style.rootLength(path_A) > 0;
  bool isRelative_A(String path_A) => !this.isAbsolute(path_A);
  bool isRootRelative(String path_A) => style.isRootRelative(path_A);
  String join(String part1, [String part2, String part3, String part4,
      String part5, String part6, String part7, String part8]) {
    var parts = [part1, part2, part3, part4, part5, part6, part7, part8];
    _validateArgList("join", parts);
    return joinAll(parts.where((part_A) => part_A != null));
  }
  String joinAll(Iterable<String> parts) {
    var buffer_A = new StringBuffer();
    var needsSeparator = false;
    var isAbsoluteAndNotRootRelative = false;
    for (var part_A in parts.where((part_A) => part_A != '')) {
      if (this.isRootRelative(part_A) && isAbsoluteAndNotRootRelative) {
        var parsed = _parse_B(part_A);
        parsed.root = this.rootPrefix(buffer_A.toString());
        if (style.needsSeparator(parsed.root)) {
          parsed.separators[0] = style.separator;
        }
        buffer_A.clear();
        buffer_A.write(parsed.toString());
      } else if (this.isAbsolute(part_A)) {
        isAbsoluteAndNotRootRelative = !this.isRootRelative(part_A);
        buffer_A.clear();
        buffer_A.write(part_A);
      } else {
        if (part_A.length > 0 && style.containsSeparator(part_A[0])) {
        } else if (needsSeparator) {
          buffer_A.write(separator);
        }
        buffer_A.write(part_A);
      }
      needsSeparator = style.needsSeparator(part_A);
    }
    return buffer_A.toString();
  }
  List<String> split(String path_A) {
    var parsed = _parse_B(path_A);
    parsed.parts = parsed.parts.where((part_A) => !part_A.isEmpty).toList();
    if (parsed.root != null) parsed.parts.insert(0, parsed.root);
    return parsed.parts;
  }
  ParsedPath _parse_B(String path_A) => new ParsedPath.parse_A(path_A, style);
}
_validateArgList(String method_A, List<String> args) {
  for (var i = 1; i < args.length; i++) {
    if (args[i] == null || args[i - 1] != null) continue;
    var numArgs;
    for (numArgs = args.length; numArgs >= 1; numArgs--) {
      if (args[numArgs - 1] != null) break;
    }
    var message_A = new StringBuffer();
    message_A.write("${method_A}(");
    message_A.write(args
        .take(numArgs)
        .map((arg) => arg == null ? "null" : '"${arg}"')
        .join(", "));
    message_A.write("): part ${i - 1} was null, but part ${i} was not.");
    throw new ArgumentError(message_A.toString());
  }
}
abstract class InternalStyle extends Style {
  String get separator;
  bool containsSeparator(String path_A);
  bool isSeparator(int codeUnit);
  bool needsSeparator(String path_A);
  int rootLength(String path_A);
  String getRoot(String path_A) {
    var length_A = rootLength(path_A);
    if (length_A > 0) return path_A.substring(0, length_A);
    return isRootRelative(path_A) ? path_A[0] : null;
  }
  bool isRootRelative(String path_A);
}
class ParsedPath {
  InternalStyle style;
  String root;
  bool isRootRelative;
  List<String> parts;
  List<String> separators;
  String get extension => _splitExtension()[1];
  bool get isAbsolute => root != null;
  factory ParsedPath.parse_A(String path_A, InternalStyle style_A) {
    var root_A = style_A.getRoot(path_A);
    var isRootRelative_A = style_A.isRootRelative(path_A);
    if (root_A != null) path_A = path_A.substring(root_A.length);
    var parts_A = [];
    var separators_A = [];
    var start_A = 0;
    if (path_A.isNotEmpty && style_A.isSeparator(path_A.codeUnitAt(0))) {
      separators_A.add(path_A[0]);
      start_A = 1;
    } else {
      separators_A.add('');
    }
    for (var i = start_A; i < path_A.length; i++) {
      if (style_A.isSeparator(path_A.codeUnitAt(i))) {
        parts_A.add(path_A.substring(start_A, i));
        separators_A.add(path_A[i]);
        start_A = i + 1;
      }
    }
    if (start_A < path_A.length) {
      parts_A.add(path_A.substring(start_A));
      separators_A.add('');
    }
    return new ParsedPath.__A(
        style_A, root_A, isRootRelative_A, parts_A, separators_A);
  }
  ParsedPath.__A(
      this.style, this.root, this.isRootRelative, this.parts, this.separators);
  void removeTrailingSeparators() {
    while (!parts.isEmpty && parts.last == '') {
      parts.removeLast();
      separators.removeLast();
    }
    if (separators.length > 0) separators[separators.length - 1] = '';
  }
  String toString() {
    var builder_A = new StringBuffer();
    if (root != null) builder_A.write(root);
    for (var i = 0; i < parts.length; i++) {
      builder_A.write(separators[i]);
      builder_A.write(parts[i]);
    }
    builder_A.write(separators.last);
    return builder_A.toString();
  }
  List<String> _splitExtension() {
    var file_A = parts.lastWhere((p) => p != '', orElse: () => null);
    if (file_A == null) return ['', ''];
    if (file_A == '..') return ['..', ''];
    var lastDot = file_A.lastIndexOf('.');
    if (lastDot <= 0) return [file_A, ''];
    return [file_A.substring(0, lastDot), file_A.substring(lastDot)];
  }
}
abstract class Style {
  static final posix = new PosixStyle();
  static final windows = new WindowsStyle();
  static final url = new UrlStyle();
  static final platform = _getPlatformStyle();
  static Style _getPlatformStyle() {
    if (Uri.base.scheme != 'file') return Style.url;
    if (!Uri.base.path.endsWith('/')) return Style.url;
    if (new Uri(path: 'a/b').toFilePath() == 'a\\b') return Style.windows;
    return Style.posix;
  }
  String get name;
  String get separator;
  String getRoot(String path_A);
  String toString() => name;
}
class PosixStyle extends InternalStyle {
  PosixStyle();
  final name = 'posix';
  final separator = '/';
  final separators = const ['/'];
  final separatorPattern = new RegExp(r'/');
  final needsSeparatorPattern = new RegExp(r'[^/]$');
  final rootPattern = new RegExp(r'^/');
  final relativeRootPattern = null;
  bool containsSeparator(String path_A) => path_A.contains('/');
  bool isSeparator(int codeUnit) => codeUnit == SLASH_A;
  bool needsSeparator(String path_A) =>
      path_A.isNotEmpty && !isSeparator(path_A.codeUnitAt(path_A.length - 1));
  int rootLength(String path_A) {
    if (path_A.isNotEmpty && isSeparator(path_A.codeUnitAt(0))) return 1;
    return 0;
  }
  bool isRootRelative(String path_A) => false;
}
class UrlStyle extends InternalStyle {
  UrlStyle();
  final name = 'url';
  final separator = '/';
  final separators = const ['/'];
  final separatorPattern = new RegExp(r'/');
  final needsSeparatorPattern =
      new RegExp(r"(^[a-zA-Z][-+.a-zA-Z\d]*://|[^/])$");
  final rootPattern = new RegExp(r"[a-zA-Z][-+.a-zA-Z\d]*://[^/]*");
  final relativeRootPattern = new RegExp(r"^/");
  bool containsSeparator(String path_A) => path_A.contains('/');
  bool isSeparator(int codeUnit) => codeUnit == SLASH_A;
  bool needsSeparator(String path_A) {
    if (path_A.isEmpty) return false;
    if (!isSeparator(path_A.codeUnitAt(path_A.length - 1))) return true;
    return path_A.endsWith("://") && rootLength(path_A) == path_A.length;
  }
  int rootLength(String path_A) {
    if (path_A.isEmpty) return 0;
    if (isSeparator(path_A.codeUnitAt(0))) return 1;
    var index_A = path_A.indexOf("/");
    if (index_A > 0 && path_A.startsWith('://', index_A - 1)) {
      index_A = path_A.indexOf('/', index_A + 2);
      if (index_A > 0) return index_A;
      return path_A.length;
    }
    return 0;
  }
  bool isRootRelative(String path_A) =>
      path_A.isNotEmpty && isSeparator(path_A.codeUnitAt(0));
}
class WindowsStyle extends InternalStyle {
  WindowsStyle();
  final name = 'windows';
  final separator = '\\';
  final separators = const ['/', '\\'];
  final separatorPattern = new RegExp(r'[/\\]');
  final needsSeparatorPattern = new RegExp(r'[^/\\]$');
  final rootPattern = new RegExp(r'^(\\\\[^\\]+\\[^\\/]+|[a-zA-Z]:[/\\])');
  final relativeRootPattern = new RegExp(r"^[/\\](?![/\\])");
  bool containsSeparator(String path_A) => path_A.contains('/');
  bool isSeparator(int codeUnit) =>
      codeUnit == SLASH_A || codeUnit == BACKSLASH_A;
  bool needsSeparator(String path_A) {
    if (path_A.isEmpty) return false;
    return !isSeparator(path_A.codeUnitAt(path_A.length - 1));
  }
  int rootLength(String path_A) {
    if (path_A.isEmpty) return 0;
    if (path_A.codeUnitAt(0) == SLASH_A) return 1;
    if (path_A.codeUnitAt(0) == BACKSLASH_A) {
      if (path_A.length < 2 || path_A.codeUnitAt(1) != BACKSLASH_A) return 1;
      var index_A = path_A.indexOf('\\', 2);
      if (index_A > 0) {
        index_A = path_A.indexOf('\\', index_A + 1);
        if (index_A > 0) return index_A;
      }
      return path_A.length;
    }
    if (path_A.length < 3) return 0;
    if (!isAlphabetic(path_A.codeUnitAt(0))) return 0;
    if (path_A.codeUnitAt(1) != COLON_A) return 0;
    if (!isSeparator(path_A.codeUnitAt(2))) return 0;
    return 3;
  }
  bool isRootRelative(String path_A) => rootLength(path_A) == 1;
}
bool isAlphabetic(int char_A) => (char_A >= UPPER_A && char_A <= UPPER_Z) ||
    (char_A >= LOWER_A && char_A <= LOWER_Z);
class ActionParser extends DelegateParser {
  final Function _function;
  ActionParser(parser, this._function) : super(parser);
  Result parseOn(Context_B context_A) {
    var result_A = _delegate_A.parseOn(context_A);
    if (result_A.isSuccess) {
      return result_A.success(_function(result_A.value));
    } else {
      return result_A;
    }
  }
  bool hasEqualProperties(Parser other) {
    return other is ActionParser &&
        super.hasEqualProperties(other) &&
        _function == other._function;
  }
}
class TrimmingParser extends DelegateParser {
  Parser _left;
  Parser _right;
  TrimmingParser(parser, this._left, this._right) : super(parser);
  Result parseOn(Context_B context_A) {
    var current_C = context_A;
    do {
      current_C = _left.parseOn(current_C);
    } while (current_C.isSuccess);
    var result_A = _delegate_A.parseOn(current_C);
    if (result_A.isFailure) {
      return result_A;
    }
    current_C = result_A;
    do {
      current_C = _right.parseOn(current_C);
    } while (current_C.isSuccess);
    return current_C.success(result_A.value);
  }
  List<Parser> get children => [_delegate_A, _left, _right];
  void replace(Parser source_A, Parser target_A) {
    super.replace(source_A, target_A);
    if (_left == source_A) {
      _left = target_A;
    }
    if (_right == source_A) {
      _right = target_A;
    }
  }
}
class FlattenParser extends DelegateParser {
  FlattenParser(parser) : super(parser);
  Result parseOn(Context_B context_A) {
    var result_A = _delegate_A.parseOn(context_A);
    if (result_A.isSuccess) {
      var output = context_A.buffer is String
          ? context_A.buffer.substring(context_A.position, result_A.position)
          : context_A.buffer.sublist(context_A.position, result_A.position);
      return result_A.success(output);
    } else {
      return result_A;
    }
  }
}
class TokenParser extends DelegateParser {
  TokenParser(parser) : super(parser);
  Result parseOn(Context_B context_A) {
    var result_A = _delegate_A.parseOn(context_A);
    if (result_A.isSuccess) {
      var token = new Token(result_A.value, context_A.buffer,
          context_A.position, result_A.position);
      return result_A.success(token);
    } else {
      return result_A;
    }
  }
}
class CharacterParser extends Parser {
  final CharacterPredicate _predicate;
  final String _message;
  CharacterParser(this._predicate, this._message);
  Result parseOn(Context_B context_A) {
    var buffer_A = context_A.buffer;
    var position_A = context_A.position;
    if (position_A < buffer_A.length &&
        _predicate.test(buffer_A.codeUnitAt(position_A))) {
      return context_A.success(buffer_A[position_A], position_A + 1);
    }
    return context_A.failure(_message);
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser other) {
    return other is CharacterParser &&
        super.hasEqualProperties(other) &&
        _predicate == other._predicate &&
        _message == other._message;
  }
}
abstract class CharacterPredicate {
  bool test(int value_A);
}
class _NotCharacterPredicate implements CharacterPredicate {
  final CharacterPredicate predicate_A;
  _NotCharacterPredicate(this.predicate_A);
  bool test(int value_A) => !predicate_A.test(value_A);
}
CharacterPredicate _optimizedRanges(Iterable<_RangeCharPredicate> ranges) {
  var sortedRanges = new List.from(ranges, growable: false);
  sortedRanges.sort((first_A, second_A) {
    return first_A.start != second_A.start
        ? first_A.start - second_A.start
        : first_A.stop - second_A.stop;
  });
  var mergedRanges = new List();
  for (var thisRange in sortedRanges) {
    if (mergedRanges.isEmpty) {
      mergedRanges.add(thisRange);
    } else {
      var lastRange = mergedRanges.last;
      if (lastRange.stop + 1 >= thisRange.start) {
        var characterRange =
            new _RangeCharPredicate(lastRange.start, thisRange.stop);
        mergedRanges[mergedRanges.length - 1] = characterRange;
      } else {
        mergedRanges.add(thisRange);
      }
    }
  }
  if (mergedRanges.length == 1) {
    return mergedRanges[0].start == mergedRanges[0].stop
        ? new _SingleCharPredicate(mergedRanges[0].start)
        : mergedRanges[0];
  } else {
    return new _RangesCharPredicate(mergedRanges.length,
        mergedRanges.map((range_A) => range_A.start).toList(growable: false),
        mergedRanges.map((range_A) => range_A.stop).toList(growable: false));
  }
}
Parser char(element_A, [String message_A]) {
  return new CharacterParser(new _SingleCharPredicate(_toCharCode(element_A)),
      message_A != null ? message_A : '"${element_A}" expected');
}
class _SingleCharPredicate implements CharacterPredicate {
  final int value;
  const _SingleCharPredicate(this.value);
  bool test(int value_A) => identical(this.value, value_A);
}
Parser digit([String message_A]) {
  return new CharacterParser(
      _digitCharPredicate, message_A != null ? message_A : 'digit expected');
}
class _DigitCharPredicate implements CharacterPredicate {
  const _DigitCharPredicate();
  bool test(int value_A) => 48 <= value_A && value_A <= 57;
}
const _digitCharPredicate = const _DigitCharPredicate();
Parser pattern_A(String element_A, [String message_A]) {
  return new CharacterParser(_patternParser.parse_B(element_A).value,
      message_A != null ? message_A : '[${element_A}] expected');
}
Parser _createPatternParser() {
  var single_A = any_A().map(
      (each) => new _RangeCharPredicate(_toCharCode(each), _toCharCode(each)));
  var multiple = any_A().seq(char('-')).seq(any_A()).map((each) =>
      new _RangeCharPredicate(_toCharCode(each[0]), _toCharCode(each[2])));
  var positive =
      multiple.or(single_A).plus().map((each) => _optimizedRanges(each));
  return char('^').optional().seq(positive).map((each) =>
      each[0] == null ? each[1] : new _NotCharacterPredicate(each[1]));
}
final _patternParser = _createPatternParser();
class _RangesCharPredicate implements CharacterPredicate {
  final int length;
  final List<int> starts;
  final List<int> stops;
  _RangesCharPredicate(this.length, this.starts, this.stops);
  bool test(int value_A) {
    var min_A = 0;
    var max_A = length;
    while (min_A < max_A) {
      var mid = min_A + ((max_A - min_A) >> 1);
      var comp = starts[mid] - value_A;
      if (comp == 0) {
        return true;
      } else if (comp < 0) {
        min_A = mid + 1;
      } else {
        max_A = mid;
      }
    }
    return 0 < min_A && value_A <= stops[min_A - 1];
  }
}
class _RangeCharPredicate implements CharacterPredicate {
  final int start;
  final int stop;
  _RangeCharPredicate(this.start, this.stop);
  bool test(int value_A) => start <= value_A && value_A <= stop;
}
Parser whitespace([String message_A]) {
  return new CharacterParser(_whitespaceCharPredicate,
      message_A != null ? message_A : 'whitespace expected');
}
class _WhitespaceCharPredicate implements CharacterPredicate {
  const _WhitespaceCharPredicate();
  bool test(int value_A) {
    if (value_A < 256) {
      return value_A == 0x09 ||
          value_A == 0x0A ||
          value_A == 0x0B ||
          value_A == 0x0C ||
          value_A == 0x0D ||
          value_A == 0x20 ||
          value_A == 0x85 ||
          value_A == 0xA0;
    } else {
      return value_A == 0x1680 ||
          value_A == 0x180E ||
          value_A == 0x2000 ||
          value_A == 0x2001 ||
          value_A == 0x2002 ||
          value_A == 0x2003 ||
          value_A == 0x2004 ||
          value_A == 0x2005 ||
          value_A == 0x2006 ||
          value_A == 0x2007 ||
          value_A == 0x2008 ||
          value_A == 0x2009 ||
          value_A == 0x200A ||
          value_A == 0x2028 ||
          value_A == 0x2029 ||
          value_A == 0x202F ||
          value_A == 0x205F ||
          value_A == 0x3000 ||
          value_A == 0xFEFF;
    }
  }
}
const _whitespaceCharPredicate = const _WhitespaceCharPredicate();
int _toCharCode(element_A) {
  if (element_A is num) {
    return element_A.round();
  }
  var value_A = element_A.toString();
  if (value_A.length != 1) {
    throw new ArgumentError('${value_A} is not a character');
  }
  return value_A.codeUnitAt(0);
}
class DelegateParser extends Parser {
  Parser _delegate_A;
  DelegateParser(this._delegate_A);
  Result parseOn(Context_B context_A) {
    return _delegate_A.parseOn(context_A);
  }
  List<Parser> get children => [_delegate_A];
  void replace(Parser source_A, Parser target_A) {
    super.replace(source_A, target_A);
    if (_delegate_A == source_A) {
      _delegate_A = target_A;
    }
  }
}
class EndOfInputParser extends DelegateParser {
  final String _message;
  EndOfInputParser(parser, this._message) : super(parser);
  Result parseOn(Context_B context_A) {
    var result_A = _delegate_A.parseOn(context_A);
    if (result_A.isFailure || result_A.position == result_A.buffer.length) {
      return result_A;
    }
    return result_A.failure(_message, result_A.position);
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser other) {
    return other is EndOfInputParser &&
        super.hasEqualProperties(other) &&
        _message == other._message;
  }
}
class NotParser extends DelegateParser {
  final String _message;
  NotParser(parser, this._message) : super(parser);
  Result parseOn(Context_B context_A) {
    var result_A = _delegate_A.parseOn(context_A);
    if (result_A.isFailure) {
      return context_A.success(null);
    } else {
      return context_A.failure(_message);
    }
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser other) {
    return other is NotParser &&
        super.hasEqualProperties(other) &&
        _message == other._message;
  }
}
class OptionalParser extends DelegateParser {
  final _otherwise;
  OptionalParser(parser, this._otherwise) : super(parser);
  Result parseOn(Context_B context_A) {
    var result_A = _delegate_A.parseOn(context_A);
    if (result_A.isSuccess) {
      return result_A;
    } else {
      return context_A.success(_otherwise);
    }
  }
  bool hasEqualProperties(Parser other) {
    return other is OptionalParser &&
        super.hasEqualProperties(other) &&
        _otherwise == other._otherwise;
  }
}
abstract class ListParser extends Parser {
  final List<Parser> _parsers;
  ListParser(this._parsers);
  List<Parser> get children => _parsers;
  void replace(Parser source_A, Parser target_A) {
    super.replace(source_A, target_A);
    for (var i = 0; i < _parsers.length; i++) {
      if (_parsers[i] == source_A) {
        _parsers[i] = target_A;
      }
    }
  }
}
class ChoiceParser extends ListParser {
  factory ChoiceParser(Iterable<Parser> parsers) {
    return new ChoiceParser.__B(new List.from(parsers, growable: false));
  }
  ChoiceParser.__B(parsers) : super(parsers);
  Result parseOn(Context_B context_A) {
    var result_A;
    for (var i = 0; i < _parsers.length; i++) {
      result_A = _parsers[i].parseOn(context_A);
      if (result_A.isSuccess) {
        return result_A;
      }
    }
    return result_A;
  }
  Parser or(Parser other) {
    return new ChoiceParser(new List()
      ..addAll(_parsers)
      ..add(other));
  }
}
class SequenceParser extends ListParser {
  factory SequenceParser(Iterable<Parser> parsers) {
    return new SequenceParser.__C(new List.from(parsers, growable: false));
  }
  SequenceParser.__C(parsers) : super(parsers);
  Result parseOn(Context_B context_A) {
    var current_C = context_A;
    var elements = new List(_parsers.length);
    for (var i = 0; i < _parsers.length; i++) {
      var result_A = _parsers[i].parseOn(current_C);
      if (result_A.isFailure) {
        return result_A;
      }
      elements[i] = result_A.value;
      current_C = result_A;
    }
    return current_C.success(elements);
  }
  Parser seq(Parser other) {
    return new SequenceParser(new List()
      ..addAll(_parsers)
      ..add(other));
  }
}
class Context_B {
  const Context_B(this.buffer, this.position);
  final buffer;
  final int position;
  Result success(result_A, [int position_A]) {
    return new Success(
        buffer, position_A == null ? this.position : position_A, result_A);
  }
  Result failure(String message_A, [int position_A]) {
    return new Failure(
        buffer, position_A == null ? this.position : position_A, message_A);
  }
  String toString() => 'Context[${toPositionString()}]';
  String toPositionString() => Token.positionString(buffer, position);
}
abstract class Result extends Context_B {
  const Result(buffer_A, position_A) : super(buffer_A, position_A);
  bool get isSuccess => false;
  bool get isFailure => false;
  get value;
  String get message;
}
class Success extends Result {
  const Success(buffer_A, position_A, this.value) : super(buffer_A, position_A);
  bool get isSuccess => true;
  final value;
  String get message => null;
  String toString() => 'Success[${toPositionString()}]: ${value}';
}
class Failure extends Result {
  const Failure(buffer_A, position_A, this.message)
      : super(buffer_A, position_A);
  bool get isFailure => true;
  get value => throw new ParserError(this);
  final String message;
  String toString() => 'Failure[${toPositionString()}]: ${message}';
}
class ParserError extends Error {
  final Failure failure;
  ParserError(this.failure);
  String toString() => '${failure.message} at ${failure.toPositionString()}';
}
abstract class GrammarDefinition {
  Parser start();
  Parser ref(Function function_A, [arg1, arg2, arg3, arg4, arg5, arg6]) {
    var arguments_A = [
      arg1,
      arg2,
      arg3,
      arg4,
      arg5,
      arg6
    ].takeWhile((each) => each != null).toList(growable: false);
    return new _Reference(function_A, arguments_A);
  }
  Parser build({Function start: null, List arguments: const []}) {
    return _resolve(
        new _Reference(start != null ? start : this.start, arguments));
  }
  Parser _resolve(_Reference reference_A) {
    var mapping = new Map();
    Parser _dereference(_Reference reference_A) {
      var parser = mapping[reference_A];
      if (parser == null) {
        var references = [reference_A];
        parser = reference_A.resolve();
        while (parser is _Reference) {
          if (references.contains(parser)) {
            throw new StateError(
                'Recursive references detected: ${references}');
          }
          references.add(parser);
          parser = parser.resolve();
        }
        for (var each in references) {
          mapping[each] = parser;
        }
      }
      return parser;
    }
    var todo = [_dereference(reference_A)];
    var seen = new Set.from(todo);
    while (todo.isNotEmpty) {
      var parent_A = todo.removeLast();
      for (var child in parent_A.children) {
        if (child is _Reference) {
          var referenced = _dereference(child);
          parent_A.replace(child, referenced);
          child = referenced;
        }
        if (!seen.contains(child)) {
          seen.add(child);
          todo.add(child);
        }
      }
    }
    return mapping[reference_A];
  }
}
class GrammarParser extends DelegateParser {
  GrammarParser(GrammarDefinition definition) : super(definition.build());
}
class _Reference extends Parser {
  final Function function;
  final List arguments;
  _Reference(this.function, this.arguments);
  Parser resolve() => Function.apply(function, arguments);
  bool operator ==(other) {
    if (other is! _Reference ||
        other.function != function ||
        other.arguments.length != arguments.length) {
      return false;
    }
    for (var i = 0; i < arguments.length; i++) {
      var a = arguments[i],
          b = other.arguments[i];
      if (a is Parser && a is! _Reference && b is Parser && b is! _Reference) {
        if (!a.isEqualTo(b)) {
          return false;
        }
      } else {
        if (a != b) {
          return false;
        }
      }
    }
    return true;
  }
  int get hashCode => function.hashCode;
  Result parseOn(Context_B context_A) =>
      throw new UnsupportedError('References cannot be parsed.');
}
abstract class Parser {
  Result parseOn(Context_B context_A);
  Result parse_B(input_A) {
    return parseOn(new Context_B(input_A, 0));
  }
  Iterable matchesSkipping(input_A) {
    var list_A = new List();
    map((each) => list_A.add(each)).or(any_A()).star().parse_B(input_A);
    return list_A;
  }
  Parser optional([otherwise]) => new OptionalParser(this, otherwise);
  Parser star() => repeat(0, unbounded);
  Parser plus() => repeat(1, unbounded);
  Parser repeat(int min_A, int max_A) {
    return new PossessiveRepeatingParser(this, min_A, max_A);
  }
  Parser times(int count) => repeat(count, count);
  Parser seq(Parser other) => new SequenceParser([this, other]);
  Parser operator &(Parser other) => this.seq(other);
  Parser or(Parser other) => new ChoiceParser([this, other]);
  Parser operator |(Parser other) => this.or(other);
  Parser not([String message_A]) => new NotParser(this, message_A);
  Parser neg([String message_A]) => not(message_A).seq(any_A()).pick(1);
  Parser flatten() => new FlattenParser(this);
  Parser token() => new TokenParser(this);
  Parser trim([Parser left_A, Parser right_A]) {
    if (left_A == null) left_A = whitespace();
    if (right_A == null) right_A = left_A;
    return new TrimmingParser(this, left_A, right_A);
  }
  Parser end([String message_A = 'end of input expected']) {
    return new EndOfInputParser(this, message_A);
  }
  Parser map(Function function_A) => new ActionParser(this, function_A);
  Parser pick(int index_A) {
    return this.map((List list_A) {
      return list_A[index_A < 0 ? list_A.length + index_A : index_A];
    });
  }
  Parser separatedBy(Parser separator,
      {bool includeSeparators: true, bool optionalSeparatorAtEnd: false}) {
    var repeater = new SequenceParser([separator, this]).star();
    var parser = new SequenceParser(optionalSeparatorAtEnd
        ? [this, repeater, separator.optional(separator)]
        : [this, repeater]);
    return parser.map((List list_A) {
      var result_A = new List();
      result_A.add(list_A[0]);
      for (var tuple in list_A[1]) {
        if (includeSeparators) {
          result_A.add(tuple[0]);
        }
        result_A.add(tuple[1]);
      }
      if (includeSeparators &&
          optionalSeparatorAtEnd &&
          !identical(list_A[2], separator)) {
        result_A.add(list_A[2]);
      }
      return result_A;
    });
  }
  bool isEqualTo(Parser other, [Set<Parser> seen]) {
    if (seen == null) {
      seen = new Set();
    }
    if (this == other || seen.contains(this)) {
      return true;
    }
    seen.add(this);
    return runtimeType == other.runtimeType &&
        hasEqualProperties(other) &&
        hasEqualChildren(other, seen);
  }
  bool hasEqualProperties(Parser other) => true;
  bool hasEqualChildren(Parser other, Set<Parser> seen) {
    var thisChildren = children,
        otherChildren = other.children;
    if (thisChildren.length != otherChildren.length) {
      return false;
    }
    for (var i = 0; i < thisChildren.length; i++) {
      if (!thisChildren[i].isEqualTo(otherChildren[i], seen)) {
        return false;
      }
    }
    return true;
  }
  List<Parser> get children => const [];
  void replace(Parser source_A, Parser target_A) {}
}
Parser any_A([String message_A = 'input expected']) {
  return new AnyParser(message_A);
}
class AnyParser extends Parser {
  final String _message;
  AnyParser(this._message);
  Result parseOn(Context_B context_A) {
    var position_A = context_A.position;
    var buffer_A = context_A.buffer;
    return position_A < buffer_A.length
        ? context_A.success(buffer_A[position_A], position_A + 1)
        : context_A.failure(_message);
  }
  bool hasEqualProperties(Parser other) {
    return other is AnyParser &&
        super.hasEqualProperties(other) &&
        _message == other._message;
  }
}
Parser anyIn(elements, [String message_A]) {
  return predicate(1, (each) => elements.indexOf(each) >= 0,
      message_A != null ? message_A : 'any of ${elements} expected');
}
Parser string_A(String element_A, [String message_A]) {
  return predicate(element_A.length, (String each) => element_A == each,
      message_A != null ? message_A : '${element_A} expected');
}
typedef bool Predicate(_0);
Parser predicate(int length_A, Predicate predicate_A, String message_A) {
  return new PredicateParser(length_A, predicate_A, message_A);
}
class PredicateParser extends Parser {
  final int _length_A;
  final Predicate _predicate;
  final String _message;
  PredicateParser(this._length_A, this._predicate, this._message);
  Result parseOn(Context_B context_A) {
    final start_A = context_A.position;
    final stop_A = start_A + _length_A;
    if (stop_A <= context_A.buffer.length) {
      var result_A = context_A.buffer is String
          ? context_A.buffer.substring(start_A, stop_A)
          : context_A.buffer.sublist(start_A, stop_A);
      if (_predicate(result_A)) {
        return context_A.success(result_A, stop_A);
      }
    }
    return context_A.failure(_message);
  }
  String toString() => '${super.toString()}[${_message}]';
  bool hasEqualProperties(Parser other) {
    return other is PredicateParser &&
        super.hasEqualProperties(other) &&
        _length_A == other._length_A &&
        _predicate == other._predicate &&
        _message == other._message;
  }
}
const int unbounded = -1;
abstract class RepeatingParser extends DelegateParser {
  final int _min;
  final int _max;
  RepeatingParser(Parser parser, this._min, this._max) : super(parser) {
    assert(0 <= _min);
    assert(_max == unbounded || _min <= _max);
  }
  String toString() {
    var max_A = _max == unbounded ? '*' : _max;
    return '${super.toString()}[${_min}..${max_A}]';
  }
  bool hasEqualProperties(Parser other) {
    return other is RepeatingParser &&
        super.hasEqualProperties(other) &&
        _min == other._min &&
        _max == other._max;
  }
}
class PossessiveRepeatingParser extends RepeatingParser {
  PossessiveRepeatingParser(Parser parser, int min_A, int max_A)
      : super(parser, min_A, max_A);
  Result parseOn(Context_B context_A) {
    var current_C = context_A;
    var elements = new List();
    while (elements.length < _min) {
      var result_A = _delegate_A.parseOn(current_C);
      if (result_A.isFailure) {
        return result_A;
      }
      elements.add(result_A.value);
      current_C = result_A;
    }
    while (_max == unbounded || elements.length < _max) {
      var result_A = _delegate_A.parseOn(current_C);
      if (result_A.isFailure) {
        return current_C.success(elements);
      }
      elements.add(result_A.value);
      current_C = result_A;
    }
    return current_C.success(elements);
  }
}
class Token {
  final value;
  final buffer;
  final int start;
  final int stop;
  const Token(this.value, this.buffer, this.start, this.stop);
  get input => buffer is String
      ? buffer.substring(start, stop)
      : buffer.sublist(start, stop);
  int get length => stop - start;
  String toString() => 'Token[${positionString(buffer, start)}]: ${value}';
  bool operator ==(other) {
    return other is Token &&
        value == other.value &&
        start == other.start &&
        stop == other.stop;
  }
  int get hashCode => value.hashCode + start.hashCode + stop.hashCode;
  static final Parser _NEWLINE_PARSER =
      char('\n').or(char('\r').seq(char('\n').optional()));
  static Parser newlineParser() => _NEWLINE_PARSER;
  static List<int> lineAndColumnOf(String buffer_A, int position_A) {
    var line_A = 1,
        offset_A = 0;
    for (var token in newlineParser().token().matchesSkipping(buffer_A)) {
      if (position_A < token.stop) {
        return [line_A, position_A - offset_A + 1];
      }
      line_A++;
      offset_A = token.stop;
    }
    return [line_A, position_A - offset_A + 1];
  }
  static String positionString(buffer_A, int position_A) {
    if (buffer_A is String) {
      var lineAndColumn = Token.lineAndColumnOf(buffer_A, position_A);
      return '${lineAndColumn[0]}:${lineAndColumn[1]}';
    } else {
      return '${position_A}';
    }
  }
}
