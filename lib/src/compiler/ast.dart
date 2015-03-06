part of badger.compiler;

class AstCompilerTarget extends CompilerTarget<String> {
  @override
  String compile(Program program) {
    var ast = new BadgerJsonBuilder(program);
    var encoder = new JsonEncoder.withIndent("  ");

    return encoder.convert(ast.build());
  }
}

class SnapshotCompilerTarget extends CompilerTarget<Future<String>> {
  final Environment env;

  SnapshotCompilerTarget(this.env);

  @override
  Future<String> compile(Program program) async {
    var out = {};
    var locations = [];

    for (ImportDeclaration import in program.declarations.where((it) => it is ImportDeclaration)) {
      locations.add(import.location.components.join());
    }

    for (var location in locations) {
      var p = await env.import(location);
      var m = JSON.decode(await compile(p));
      out[location] = m;
    }

    out["_"] = JSON.decode(new AstCompilerTarget().compile(program));

    return JSON.encode(out);
  }
}

class TinyAstCompilerTarget extends CompilerTarget<String> {
  static final Map<String, String> MAPPING = {
    "type": "t",
    "immutable": "im",
    "reference": "r",
    "identifier": "i",
    "value": "v",
    "declarations": "d",
    "statements": "s",
    "isInitialDefine": "ind",
    "op": "o",
    "components": "c",
    "args": "a",
    "method call": "m",
    "access": "ac",
    "block": "b",
    "operator": "op",
    "assignment": "as",
    "string literal": "st",
    "left": "l",
    "right": "r",
    "variable reference": "va",
    "for in": "f",
    "if": "if",
    "while": "w",
    "function definition": "fd",
    "anonymous function": "af"
  };

  static String demap(String key) {
    if (MAPPING.values.contains(key)) {
      return MAPPING.keys.firstWhere((it) => MAPPING[it] == key);
    } else {
      return key;
    }
  }

  static Map expand(Map it) {
    return transformMapStrings(it, (key) {
      return demap(key);
    });
  }

  @override
  String compile(Program program) {
    var ast = new BadgerJsonBuilder(program);
    var result = ast.build();
    return JSON.encode(transformMapStrings(result, (x) {
      if (MAPPING.containsKey(x)) {
        return MAPPING[x];
      } else {
        return x;
      }
    }));
  }

  static dynamic transformMapStrings(it, dynamic transformer(x)) {
    if (it is Map) {
      var r = {};
      for (var x in it.keys) {
        var v = it[x];
        if (x == "type") {
          v = MAPPING.containsKey(v) ? MAPPING[v] : v;
        }
        r[transformer(x)] = transformMapStrings(v, transformer);
      }
      return r;
    } else if (it is List) {
      var l = [];
      for (var x in it) {
        l.add(transformMapStrings(x, transformer));
      }
      return l;
    } else {
      return it;
    }
  }
}
