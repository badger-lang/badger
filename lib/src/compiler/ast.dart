part of badger.compiler;

class AstCompilerTarget extends CompilerTarget<String> {
  @override
  String compile(Program program) {
    var ast = new BadgerJsonBuilder(program);
    var encoder = options["pretty"] == true ? new JsonEncoder.withIndent("  ") : JSON.encoder;

    return encoder.convert(ast.build());
  }
}

/**
 * Compiles a program into JSON that includes compiled versions of all the imports as well.
 */
class SnapshotCompilerTarget extends CompilerTarget<Future<String>> {
  final Environment env;

  SnapshotCompilerTarget(this.env);

  @override
  Future<String> compile(Program program) async {
    var encoder = options["pretty"] == true ? new JsonEncoder.withIndent("  ") : JSON.encoder;
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

    out["_"] = JSON.decode(new TinyAstCompilerTarget().compile(program));

    return encoder.convert(out);
  }
}

/**
 * Compiles a Badger Program into JSON that maps all set AST keys into a single character.
 */
class TinyAstCompilerTarget extends CompilerTarget<String> {
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
    "boolean literal": ">",
    "range literal": ".",
    "identifiers": "?",
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
    "elements": "^"
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
    var encoder = options["pretty"] == true ? new JsonEncoder.withIndent("  ") : JSON.encoder;
    var ast = new BadgerJsonBuilder(program);
    var result = ast.build();
    return encoder.convert(transformMapStrings(result, (x) {
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
        if (x == "type" || x == MAPPING["type"]) {
          v = x == "type" ? (MAPPING.containsKey(v) ? MAPPING[v] : v) : demap(v);
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
