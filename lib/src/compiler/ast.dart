part of badger.compiler;

class AstCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    var ast = new BadgerJsonBuilder(program);
    var encoder = getBooleanOption("pretty") ? new JsonEncoder.withIndent("  ") : JSON.encoder;

    return encoder.convert(ast.build());
  }
}

/**
 * Compiles a program into JSON that includes compiled versions of all the imports as well.
 */
class SnapshotCompilerTarget extends CompilerTarget<String> {
  final Environment env;

  SnapshotCompilerTarget(this.env);

  @override
  Future<String> compile(Program program) async {
    var encoder = getBooleanOption("pretty") ? new JsonEncoder.withIndent("  ") : JSON.encoder;
    var simplify = getBooleanOption("simplify");
    var out = {};
    var locations = [];

    for (ImportDeclaration import in program.declarations.where((it) => it is ImportDeclaration)) {
      locations.add(import.location.components.join());
    }

    for (var location in locations) {
      if (location.startsWith("badger:")) {
        continue;
      }

      var p = await env.resolveProgram(location);

      if (p == null) { // Probably Dynamic
        continue;
      }

      var m = JSON.decode(await compile(p));
      out[location] = m;
    }

    var a = await (new TinyAstCompilerTarget()..options["simplify"] = simplify).compile(program);

    out["_"] = JSON.decode(a);

    return encoder.convert(out);
  }
}

/**
 * Compiles a Badger Program into JSON that maps all set AST keys into a single character.
 */
class TinyAstCompilerTarget extends CompilerTarget<String> {
  @override
  Future<String> compile(Program program) async {
    var encoder = options["pretty"] == true ? new JsonEncoder.withIndent("  ") : JSON.encoder;
    var ast = new BadgerJsonBuilder(program);
    var result = ast.build();
    return encoder.convert(BadgerTinyAst.transformMapStrings(result, (x) {
      if (BadgerTinyAst.MAPPING.containsKey(x)) {
        return BadgerTinyAst.MAPPING[x];
      } else {
        return x;
      }
    }));
  }
}
