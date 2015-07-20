part of badger.parser;

class BadgerSnapshotParser {
  final Map input;

  BadgerSnapshotParser(this.input);

  Map<String, Program> parse() {
    var progs = {};

    for (var loc in input.keys) {
      progs.addAll(go(loc, input[loc]));
    }

    return progs;
  }

  Map<String, Program> go(String name, Map it) {
    if (!it.containsKey("statements") && !it.containsKey("g")) {
      var map = {};
      for (var key in it.keys) {
        var x = go(key, it[key]);
        map[key] = x;
      }
      var c = null;

      if (map["_"].containsKey("_")) {
        c = map["_"]["_"];
      } else {
        c = map["_"];
      }

      map.remove("_");

      map[name] = c;
      return map;
    } else {
      return {
        (name): new BadgerJsonParser().build(it)
      };
    }
  }
}

class BadgerJsonBuilder {
  final AstNode rootNode;

  BadgerJsonBuilder(this.rootNode);

  String encode({bool pretty: false}) {
    var out = build();
    if (pretty) {
      return new JsonEncoder.withIndent("  ").convert(out);
    } else {
      return JSON.encode(out);
    }
  }

  _toEncodable(value) {
    if (value is Identifier) {
      return value.toString();
    }
    return null;
  }

  Map build([AstNode node]) {
    if (node == null) {
      node = rootNode;
    }

    Map doIt() {
      if (node is Program) {
        return buildProgram(node);
      } else if (node is Statement) {
        return _generateStatement(node);
      } else if (node is Expression) {
        return _generateExpression(node);
      } else {
        throw new Exception("Unknown AST Node");
      }
    }

    var map = doIt();

    return JSON.decode(JSON.encode(map, toEncodable: _toEncodable));
  }

  Map buildProgram(Program program) {
    return {
      "declarations": _generateDeclarations(program.declarations),
      "statements": _generateStatements(program.statements)
    };
  }

  List<Map> _generateStatements(List<Statement> input) {
    var statements = [];

    for (var s in input) {
      statements.add(_generateStatement(s));
    }

    return statements;
  }

  List<Map> _generateDeclarations(List<Declaration> declarations) {
    return declarations.map((it) {
      if (it is FeatureDeclaration) {
        return _generateFeatureDeclaration(it);
      } else if (it is ImportDeclaration) {
        return _generateImportDeclaration(it);
      } else {
        throw new Exception("Unable to generate declaration.");
      }
    }).toList();
  }

  Map _generateFeatureDeclaration(FeatureDeclaration decl) {
    return {
      "type": "feature declaration",
      "feature": _generateStringLiteralComponents(decl.feature.components)
    };
  }

  Map _generateImportDeclaration(ImportDeclaration decl) {
    return {
      "type": "import declaration",
      "location": _generateStringLiteralComponents(decl.location.components),
      "identifier": decl.id
    };
  }

  Map _generateStatement(Statement statement) {
    if (statement is ExpressionStatement) {
      return {
        "type": "expression statement",
        "expression": _generateExpression(statement.expression)
      };
    } else if (statement is VariableDeclaration) {
      return {
        "type": "variable declaration",
        "identifier": statement.name.name,
        "value": _generateExpression(statement.value),
        "isImmutable": statement.isImmutable,
        "isNullable": statement.isNullable
      };
    } else if (statement is FlatAssignment) {
      return {
        "type": "flat assignment",
        "identifier": statement.name.name,
        "value": _generateExpression(statement.value)
      };
    } else if (statement is AccessAssignment) {
      return {
        "type": "access assignment",
        "reference": _generateExpression(statement.reference),
        "value": _generateExpression(statement.value)
      };
    } else if (statement is FunctionDefinition) {
      return {
        "type": "function definition",
        "identifier": statement.name.name,
        "block": _generateStatements(statement.block.statements),
        "args": statement.args.map((it) => it.name).toList()
      };
    } else if (statement is SwitchStatement) {
      return {
        "type": "switch",
        "expression": _generateExpression(statement.expression),
        "cases": _generateStatements(statement.cases)
      };
    } else if (statement is CaseStatement) {
      return {
        "type": "case",
        "expression": _generateExpression(statement.expression),
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is WhileStatement) {
      return {
        "type": "while",
        "condition": _generateExpression(statement.condition),
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is IfStatement) {
      return {
        "type": "if",
        "condition": _generateExpression(statement.condition),
        "block": _generateStatements(statement.block.statements),
        "else": statement.elseBlock != null ? _generateStatements(statement.elseBlock.statements) : null
      };
    } else if (statement is ForInStatement) {
      return {
        "type": "for in",
        "identifier": statement.identifier.toString(),
        "value": _generateExpression(statement.value),
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is NamespaceBlock) {
      return {
        "type": "namespace",
        "name": statement.name.name,
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is ClassBlock) {
      return {
        "type": "class",
        "name": statement.name.name,
        "args": statement.args,
        "extension": statement.extension.name,
        "block": _generateStatements(statement.block.statements)
      };
    } else if (statement is ReturnStatement) {
      return {
        "type": "return",
        "value": statement.expression != null ? _generateExpression(statement.expression) : null
      };
    } else if (statement is MultiAssignment) {
      return {
        "type": "multiple assignment",
        "ids": statement.ids,
        "immutable": statement.immutable,
        "isNullable": statement.isNullable,
        "isInitialDefine": statement.isInitialDefine,
        "value": _generateExpression(statement.value)
      };
    } else if (statement is TryCatchStatement) {
      return {
        "type": "try",
        "identifier": statement.identifier.name,
        "block": _generateStatements(statement.tryBlock.statements),
        "catch": _generateStatements(statement.catchBlock.statements)
      };
    } else if (statement is BreakStatement) {
      return {
        "type": "break"
      };
    } else {
      throw new Exception("Unknown Statement: ${statement}");
    }
  }

  List<Map> _generateExpressions(List<Expression> expressions) => expressions.map(_generateExpression).toList();

  Map _generateExpression(Expression expression) {
    if (expression is StringLiteral) {
      return {
        "type": "string literal",
        "components": _generateStringLiteralComponents(expression.components)
      };
    } else if (expression is IntegerLiteral) {
      return {
        "type": "integer literal",
        "value": expression.value
      };
    } else if (expression is DoubleLiteral) {
      return {
        "type": "double literal",
        "value": expression.value
      };
    } else if (expression is HexadecimalLiteral) {
      return {
        "type": "hexadecimal literal",
        "value": expression.value
      };
    } else if (expression is MethodCall) {
      return {
        "type": "method call",
        "reference": expression.reference is Identifier ? expression.reference.name : _generateExpression(expression.reference),
        "args": _generateExpressions(expression.args)
      };
    } else if (expression is Defined) {
      return {
        "type": "defined",
        "identifier": expression.identifier.name
      };
    } else if (expression is Parentheses) {
      return {
        "type": "parentheses",
        "expression": _generateExpression(expression.expression)
      };
    } else if (expression is Operation) {
      return {
        "type": "operator",
        "left": _generateExpression(expression.left),
        "right": _generateExpression(expression.right),
        "op": expression.op
      };
    } else if (expression is Negate) {
      return {
        "type": "negate",
        "value": _generateExpression(expression.expression)
      };
    } else if (expression is NullLiteral) {
      return {
        "type": "null"
      };
    } else if (expression is ListDefinition) {
      return {
        "type": "list definition",
        "elements": _generateExpressions(expression.elements)
      };
    } else if (expression is RangeLiteral) {
      return {
        "type": "range literal",
        "left": _generateExpression(expression.left),
        "right": _generateExpression(expression.right),
        "exclusive": expression.exclusive,
        "step": expression.step != null ? _generateExpression(expression.step) : null
      };
    } else if (expression is VariableReference) {
      return {
        "type": "variable reference",
        "identifier": expression.identifier.name
      };
    } else if (expression is MapDefinition) {
      return {
        "type": "map definition",
        "entries": _generateExpressions(expression.entries)
      };
    } else if (expression is MapEntry) {
      return {
        "type": "map entry",
        "key": _generateExpression(expression.key),
        "value": _generateExpression(expression.value)
      };
    } else if (expression is BracketAccess) {
      return {
        "type": "bracket access",
        "reference": _generateExpression(expression.reference),
        "index": _generateExpression(expression.index)
      };
    } else if (expression is TernaryOperator) {
      return {
        "type": "ternary",
        "condition": _generateExpression(expression.condition),
        "whenTrue": _generateExpression(expression.whenTrue),
        "whenFalse": _generateExpression(expression.whenFalse)
      };
    } else if (expression is ReferenceCreation) {
      return {
        "type": "reference",
        "value": _generateExpression(expression.variable)
      };
    } else if (expression is AnonymousFunction) {
      return {
        "type": "anonymous function",
        "args": expression.args,
        "block": _generateStatements(expression.block.statements)
      };
    } else if (expression is Access) {
      return {
        "type": "access",
        "reference": _generateExpression(expression.reference),
        "parts": expression.parts.map((it) => it is Expression ? _generateExpression(it) : it).toList()
      };
    } else if (expression is BooleanLiteral) {
      return {
        "type": "boolean literal",
        "value": expression.value
      };
    } else if (expression is NativeCode) {
      return {
        "type": "native code",
        "code": expression.code
      };
    } else {
      throw new Exception("Failed to generate expression for ${expression}");
    }
  }

  List<dynamic> _generateStringLiteralComponents(List<dynamic> components) {
    var cm = [];
    var cn = [];
    for (var c in components) {
      if (c is Expression) {
        if (cn.isNotEmpty) {
          cm.add(cn.join());
          cn.clear();
        }

        cm.add(_generateExpression(c));
      } else {
        cn.add(c);
      }
    }

    if (cn.isNotEmpty) {
      cm.add(cn.join());
      cn.clear();
    }
    return cm;
  }
}

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
    "try": ",",
    "expression statement": "ß",
    "class": "∆",
    "expression": "€",
    "entries": "ü",
    "isImmutable": "«",
    "variable declaration": "»"
  };

  static String demap(String key) {
    if (MAPPING.values.contains(key)) {
      return MAPPING.keys.firstWhere((it) => MAPPING[it] == key);
    } else {
      return key;
    }
  }

  static Map expand(Map it) {
    var ma = new Map.from(it);
    ma.remove("@@");
    var result = processor(it, (key) {
      return demap(key);
    }, lookup: it["@@"], decoding: true);

    result.remove("@@");

    return result;
  }

  static Map flip(Map map) {
    var result = {};
    for (var key in map.keys) {
      result[map[key]] = key;
    }
    print(result);
    return result;
  }

  static dynamic processor(it, dynamic transformer(x), {Map<String, dynamic> lookup, bool decoding: false}) {
    if (lookup == null) {
      lookup = {};
    }

    String createLookupKey() {
      var c = 0;
      var len = 1;
      while (true) {
        c++;
        if (c == 200) {
          len += 1;
          c = 0;
        }
        var result = generateBasicId(length: len);
        if (lookup.containsKey(result) || (decoding ? true : MAPPING.values.contains(result))) {
          continue;
        } else {
          return result;
        }
      }
    }

    if (it is Map) {
      var r = {};
      for (var x in it.keys.toList()) {
        var v = it[x];

        if (v == null) {
          continue;
        }

        if (x == "type" || x == MAPPING["type"]) {
          v = x == "type" ? (MAPPING.containsKey(v) ? MAPPING[v] : v) : demap(v);
        } else if (v is String) {
          if (((decoding ? lookup.keys : lookup.values) as Iterable).contains(v)) {
            if (decoding) {
              v = lookup[v];
            } else {
              var rx = lookup.keys.firstWhere((x) => lookup[x] == v);
              v = rx;
            }
          } else {
            var rx = createLookupKey();
            lookup[rx] = v;
            v = rx;
          }
        }

        r[transformer(x)] = processor(v, transformer, lookup: lookup, decoding: decoding);
      }
      return r;
    } else if (it is List) {
      var l = [];
      for (var x in it) {
        l.add(processor(x, transformer, lookup: lookup, decoding: decoding));
      }
      return l;
    } else {
      var v = it;
      if (((decoding ? lookup.keys : lookup.values) as Iterable).contains(v)) {
        if (decoding) {
          v = lookup[v];
        } else {
          var rx = lookup.keys.firstWhere((x) => lookup[x] == v);
          v = rx;
        }
      } else {
        var rx = createLookupKey();
        lookup[rx] = v;
        v = rx;
      }
      return v;
    }
  }
}

class BadgerJsonParser {
  Program build(Map input) {
    if (!input.containsKey("statements") && input.containsKey("@@")) {
      input = BadgerTinyAst.expand(input);
    }

    var declarations = input["declarations"].map(_buildDeclaration).toList();
    var statements = input["statements"].map(_buildStatement).toList();

    return new Program(declarations, statements);
  }

  Declaration _buildDeclaration(Map it) {
    var type = it["type"];

    if (type == "feature declaration") {
      return new FeatureDeclaration(_buildStringLiteral(it["feature"]));
    } else if (type == "import declaration") {
      return new ImportDeclaration(_buildStringLiteral(it["location"]), it["identifier"]);
    } else {
      throw new Exception("Invalid Declaration");
    }
  }

  dynamic _buildStatement(Map it) {
    var type = it["type"];

    if (type == "method call") {
      return _buildMethodCall(it);
    } else if (type == "variable declaration") {
      return new VariableDeclaration(
        new Identifier(it["identifier"]),
        _buildExpression(it["value"]),
        it["isImmutable"],
        it["isNullable"]
      );
    } else if (type == "flat assignment") {
      return new FlatAssignment(
        new Identifier(it["identifier"]),
        _buildExpression(it["value"])
      );
    } else if (type == "function definition") {
      return new FunctionDefinition(it["identifier"], it["args"].map((x) => new Identifier(x)).toList(), new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "while") {
      return new WhileStatement(_buildExpression(it["condition"]), new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "if") {
      return new IfStatement(
        _buildExpression(it["condition"]),
        new Block(it["block"].map(_buildStatement).toList()),
        new Block(it["elseBlock"] == null ? [] : it["elseBlock"].map(_buildStatement).toList())
      );
    } else if (type == "for in") {
      return new ForInStatement(
        it["identifier"],
        _buildExpression(it["value"]),
        new Block(it["block"].map(_buildStatement).toList())
      );
    } else if (type == "multiple assignment") {
      return new MultiAssignment(it["ids"], _buildExpression(it["value"]), it["immutable"], it["isInitialDefine"], it["isNullable"]);
    } else if (type == "class") {
      return new ClassBlock(
        new Identifier(it["name"]),
        it["args"].map((x) => new Identifier(x)).toList(),
        new Identifier(it["extension"]),
        new Block(it["block"].map(_buildStatement).toList())
      );
    } else if (type == "namespace") {
      return new NamespaceBlock(new Identifier(it["name"]), new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "return") {
      return new ReturnStatement(
        it["value"] == null ? null : _buildExpression(it["value"])
      );
    } else if (type == "try") {
      return new TryCatchStatement(
        new Block(it["block"].map(_buildStatement).toList()),
        it["identifier"],
        new Block(it["catch"].map(_buildStatement).toList())
      );
    } else if (type == "break") {
      return new BreakStatement();
    } else if (type == "switch") {
      return new SwitchStatement(_buildExpression(it["expression"]), it["cases"].map(_buildStatement).toList());
    } else if (type == "expression statement") {
      return new ExpressionStatement(_buildExpression(it["expression"]));
    } else {
      throw new Exception("Unknown Statement Type: ${type}");
    }
  }

  Expression _buildExpression(Map it) {
    var type = it["type"];

    if (type == "string literal") {
      return _buildStringLiteral(it["components"]);
    } else if (type == "variable reference") {
      return new VariableReference(it["identifier"]);
    } else if (type == "method call") {
      return _buildMethodCall(it);
    } else if (type == "integer literal") {
      return new IntegerLiteral(it["value"]);
    } else if (type == "double literal") {
      return new DoubleLiteral(it["value"]);
    } else if (type == "operator") {
      return new Operation(_buildExpression(it["left"]), _buildExpression(it["right"]), it["op"]);
    } else if (type == "negate") {
      return new Negate(_buildExpression(it["value"]));
    } else if (type == "null") {
      return new NullLiteral();
    } else if (type == "range literal") {
      return new RangeLiteral(
        _buildExpression(it["left"]),
        _buildExpression(it["right"]),
        it["exclusive"],
        it["step"] != null ? _buildExpression(it["step"]) : null
      );
    } else if (type == "hexadecimal literal") {
      return new HexadecimalLiteral(it["value"]);
    } else if (type == "boolean literal") {
      return new BooleanLiteral(it["value"]);
    } else if (type == "ternary") {
      return new TernaryOperator(
        _buildExpression(it["condition"]),
        _buildExpression(it["whenTrue"]),
        _buildExpression(it["whenFalse"])
      );
    } else if (type == "reference") {
      return new ReferenceCreation(_buildExpression(it["value"]));
    } else if (type == "parentheses") {
      return new Parentheses(_buildExpression(it["expression"]));
    } else if (type == "access") {
      return new Access(_buildExpression(it["reference"]), it["parts"].map((it) => it is Map ? _buildExpression(it) : it).toList());
    } else if (type == "map definition") {
      return new MapDefinition(it["entries"].map(_buildExpression).toList());
    } else if (type == "map entry") {
      return new MapEntry(_buildExpression(it["key"]), _buildExpression(it["value"]));
    } else if (type == "list definition") {
      return new ListDefinition(it["elements"].map(_buildExpression).toList());
    } else if (type == "bracket access") {
      return new BracketAccess(_buildExpression(it["reference"]), _buildExpression(it["index"]));
    } else if (type == "anonymous function") {
      return new AnonymousFunction(it["args"].map((x) => new Identifier(x)).toList(), new Block(it["block"].map(_buildStatement).toList()));
    } else if (type == "native code") {
      return new NativeCode(it["code"]);
    } else if (type == "defined") {
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
    } else {
      ref = new Identifier(ref);
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

const List<String> ALPHABET = const [
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z"
];

Random _random = new Random();

String generateBasicId({int length: 30}) {
  var r = new Random(_random.nextInt(5000));
  var buffer = new StringBuffer();
  for (int i = 1; i <= length; i++) {
    var n = r.nextInt(50);
    if (n >= 0 && n <= 32) {
      String letter = ALPHABET[r.nextInt(ALPHABET.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else if (n > 32 && n <= 43) {
      buffer.write(_NUMBERS[r.nextInt(_NUMBERS.length)]);
    } else if (n > 43) {
      buffer.write(_SPECIALS[r.nextInt(_SPECIALS.length)]);
    }
  }
  return buffer.toString();
}

String generateToken({int length: 50}) {
  var r = new Random(_random.nextInt(5000));
  var buffer = new StringBuffer();
  for (int i = 1; i <= length; i++) {
    if (r.nextBool()) {
      String letter = ALPHABET[r.nextInt(ALPHABET.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else {
      buffer.write(_NUMBERS[r.nextInt(_NUMBERS.length)]);
    }
  }
  return buffer.toString();
}

const List<int> _NUMBERS = const [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9
];

const List<String> _SPECIALS = const [
  "@",
  "=",
  "_",
  "+",
  "-",
  "!",
  "."
];
