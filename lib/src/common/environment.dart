part of badger.common;

abstract class Environment {
  Future import(String location, Evaluator evaluator, Context context, Program source);
  Future<Program> resolveProgram(String location);
  Future<Map<String, dynamic>> getProperties();
}

class ImportMapEnvironment extends Environment {
  final Map<String, Program> programs;
  Environment _c;

  ImportMapEnvironment(this.programs, [this._c]);

  @override
  Future import(String location, Evaluator evaluator, Context context, Program source) async {
    if (_c != null && !programs.containsKey(location)) {
      return _c.import(location, evaluator, context, source);
    }

    var program = programs[location];
    await evaluator.evaluateProgram(program, context);
  }

  @override
  Future<Program> resolveProgram(String location) async {
    if (_c != null && !programs.containsKey(location)) {
      return _c.resolveProgram(location);
    }

    return programs[location];
  }

  @override
  Future<Map<String, dynamic>> getProperties() async => properties;

  Map<String, dynamic> properties = {};
}

abstract class BaseEnvironment extends Environment {
  final BadgerParser _parser = new BadgerParser();
  Environment _e;

  Future compile(CompilerTarget target) async {
    return target.compile(await parse());
  }

  eval(Context context) async {
    var program = _parse(await readScriptContent());
    return await new Evaluator(program, _e != null ? _e : this).evaluate(context);
  }

  Future<Program> parse([String content]) async {
    return _parse(content != null ? content : await readScriptContent());
  }

  Future<String> readScriptContent();

  Future<Map> generateJSON() async {
    return new BadgerJsonBuilder(await parse()).build();
  }

  Future<Program> parseJSON([String content]) async {
    return new BadgerJsonParser().build(JSON.decode(content != null ? content : await readScriptContent()));
  }

  buildEvalJSON(Context ctx) async {
    return await new Evaluator(await parseJSON(JSON.encode(await generateJSON())), _e != null ? _e : this).evaluate(ctx);
  }

  Program _parse(String content) {
    try {
      var json = JSON.decode(content);

      if (json.containsKey("_")) {
        var p = new BadgerSnapshotParser(json);
        var m = p.parse();
        _e = new ImportMapEnvironment(m, this)..properties = properties;
        return (_e as ImportMapEnvironment).programs["_"];
      }

      return new BadgerJsonParser().build(json);
    } on FormatException catch (e) {
    }

    _e = this;

    return _parser.parse(content).value;
  }

  @override
  Future<Map<String, dynamic>> getProperties() async => properties;

  Map<String, dynamic> properties = {};
}

