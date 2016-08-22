part of badger.parser;

class BadgerParserDefinition extends BadgerGrammarDefinition {
  @override
  start() => super.start().map((it) {
    logger.finest("Parsing 'start'");

    List<Declaration> declarations = it[1] == null ? [] : it[1].where(
      (it) => it is Declaration
    ).toList();
    List<Statement> statements = it[3] == null ? [] : it[3];

    return new Program(
      declarations,
      statements
    );
  });

  @override
  statements() => super.statements().map((List it) {
    logger.finest("Parsing 'statements'");
    return it;
  });

  @override
  operation() => super.operation().map((it) {
    logger.finest("Parsing 'operation'");
    var e = it.value;
    e.token = it;
    return e;
  });

  @override
  expressionItem() => super.expressionItem().map((Token it) {
    logger.finest("Parsing 'expressionItem'");
    var e = it.value;
    e.token = it;
    return e;
  });

  @override
  expressionStatement() => super.expressionStatement().map((it) {
    logger.finest("Parsing 'expressionStatement'");
    return new ExpressionStatement(it);
  });

  @override
  methodCall() => super.methodCall().map((it) {
    logger.finest("Parsing 'methodCall'");
    return new MethodCall(it[0], it[2] == null ? [] : it[2]);
  });

  @override
  stringLiteral() => super.stringLiteral().map((it) {
    logger.finest("Parsing 'stringLiteral'");
    return new StringLiteral(it[1]);
  });

  @override
  simpleMethodCall() => super.simpleMethodCall().map((it) {
    return new MethodCall(it[0], it[2] == null ? [] : it[2]);
  });

  @override
  classBlock() => super.classBlock().map((it) {
    return new ClassBlock(
      it[2],
      it[3] == null ? [] : it[3].where((it) => it is Identifier).toList(),
      it[5] != null ? it[5][2] : null,
      it[7]
    );
  });

  @override
  namespace() => super.namespace().map((it) {
    return new NamespaceBlock(it[2], it[4]);
  });

  @override
  switchStatement() => super.switchStatement().map((it) {
    return new SwitchStatement(it[2], (it[6] == null ? [] : it[6]).where((it) => it is CaseStatement).toList());
  });

  @override
  caseStatement() => super.caseStatement().map((it) {
    return new CaseStatement(it[2], it[4] == null ? new Block([]) : it[4]);
  });

  @override
  breakStatement() => super.breakStatement().map((it) {
    return new BreakStatement();
  });

  @override
  interpolation() => super.interpolation().map((it) {
    return it[1];
  });

  @override
  mapDefinition() => super.mapDefinition().map((it) {
    return new MapDefinition(it[2] == null ? [] : it[2]);
  });

  @override
  simpleAnonymousFunction() => super.simpleAnonymousFunction().map((it) {
    return new AnonymousFunction(it[1], new Block([it[5]]));
  });

  @override
  mapEntry() => super.mapEntry().map((it) {
    return new MapEntry(it[0], it[4]);
  });

  @override
  statement() => super.statement().map((it) {
    var e = it.value;
    e.token = it;
    return e;
  });

  @override
  rangeLiteral() => super.rangeLiteral().map((it) {
    return new RangeLiteral(it[0], it[3], it[2] != null, it[4] != null ? it[4][1] : null);
  });

  @override
  negate() => super.negate().map((it) {
    return new Negate(it[1]);
  });

  @override
  nullLiteral() => super.nullLiteral().map((Token token) {
    return new NullLiteral();
  });

  @override
  arguments() => super.arguments().map((it) {
    return it.where((it) => it is Expression).toList();
  });

  @override
  returnStatement() => super.returnStatement().map((it) {
    return new ReturnStatement(it[1][1]);
  });

  @override
  OPERATION(String n) => super.OPERATION(n).map((it) {
    return new Operation(it[0], it[4], it[2].value);
  });

  @override
  doubleLiteral() => super.doubleLiteral().map((it) {
    return new DoubleLiteral(double.parse(it));
  });

  @override
  declaration() => super.declaration().map((it) {
    var e = it.value;
    e.token = it;
    return e;
  });

  @override
  callable() => super.callable().map((it) {
    var e = it.value;
    e.token = it;
    return e;
  });

  @override
  importDeclaration() => super.importDeclaration().map((it) {
    return new ImportDeclaration(it[2], it[3] != null ? it[3][3] : null);
  });

  @override
  hexadecimalLiteral() => super.hexadecimalLiteral().map((it) {
    return new HexadecimalLiteral(int.parse(it[1], radix: 16));
  });

  @override
  ternaryOperator() => super.ternaryOperator().map((it) {
    return new TernaryOperator(it[0], it[4], it[8]);
  });

  @override
  flatAssignment() => super.flatAssignment().map((it) {
    return new FlatAssignment(it[0], it[4]);
  });

  @override
  variableDeclaration() => super.variableDeclaration().map((it) {
    var isNullable = it[0].endsWith("?");
    var isImmutable = it[0] != null && it[0].startsWith("let");
    return new VariableDeclaration(it[2], it[4], isImmutable, isNullable);
  });

  @override
  multipleAssign() => super.multipleAssign().map((it) {
    var isInitialDefine = it[0] != null;
    var isNullable = it[0] == null ? null : it[0][0].endsWith("?");
    var isImmutable = it[0] != null && it[0][0].startsWith("let");
    return new MultiAssignment(it[3], it[9], isImmutable, isInitialDefine, isNullable);
  });

  @override
  accessAssignment() => super.accessAssignment().map((it) {
    return new AccessAssignment(it[0], it[4]);
  });

  @override
  forInStatement() => super.forInStatement().map((it) {
    return new ForInStatement(it[2], it[6], it[7]);
  });

  @override
  access() => super.access().map((it) {
    var ids = it[2].where((it) => createString(it) != ".").toList();
    return new Access(it[0], ids);
  });

  @override
  integerLiteral() => super.integerLiteral().map((it) {
    return new IntegerLiteral(int.parse(it));
  });

  @override
  ifStatement() => super.ifStatement().map((it) {
    return new IfStatement(it[2], it[4], it[5] != null ? it[5][2] : null);
  });

  @override
  whileStatement() => super.whileStatement().map((it) {
    return new WhileStatement(it[2], it[4]);
  });

  @override
  booleanLiteral() => super.booleanLiteral().map((Token it) {
    return new BooleanLiteral(it.value == "true");
  });

  @override
  parens() => super.parens().map((it) {
    return new Parentheses(it[1]);
  });

  @override
  listDefinition() => super.listDefinition().map((it) {
    return new ListDefinition(it[2]);
  });

  @override
  emptyListDefinition() => super.emptyListDefinition().map((it) {
    return new ListDefinition([]);
  });

  @override
  nativeCode() => super.nativeCode().map((it) {
    return new NativeCode(it[1]);
  });

  @override
  definedOperator() => super.definedOperator().map((it) {
    return new Defined(it[0]);
  });

  @override
  featureDeclaration() => super.featureDeclaration().map((it) {
    return new FeatureDeclaration(it[2]);
  });

  @override
  bracketAccess() => super.bracketAccess().map((it) {
    return new BracketAccess(it[0], it[2]);
  });

  @override
  anonymousFunction() => super.anonymousFunction().map((it) {
    var argumentNames = it[1] != null ?
      it[1].where((e) => e is Identifier).toList(): [];

    return new AnonymousFunction(argumentNames, it[5]);
  });

  @override
  variableReference() => super.variableReference().map((it) {
    return new VariableReference(it);
  });

  @override
  functionDefinition() => super.functionDefinition().map((it) {
    var argnames = it[4] != null ? it[4].where((it) => it is Identifier).toList() : [];
    return new FunctionDefinition(it[2], argnames, it[6]);
  });

  @override
  basicFunctionDefinition() => super.basicFunctionDefinition().map((it) {
    var argnames = it[2] != null ? it[2].where((it) => it is Identifier).toList() : [];
    return new FunctionDefinition(it[0], argnames, new Block.forSingle(new ReturnStatement(it[7])));
  });

  @override
  reference() => super.reference().map((it) {
    logger.finest("Parsing 'reference'");
    return new ReferenceCreation(it[1]);
  });

  @override
  tryCatchStatement() => super.tryCatchStatement().map((it) {
    return new TryCatchStatement(it[2], it[7], it[10]);
  });

  @override
  block() => super.block().map((it) {
    logger.finest("Parsing 'block'");
    return new Block(it[3] == null ? [] : it[3]);
  });

  @override
  identifier() => super.identifier().map((Token it) {
    logger.finest("Parsing 'identifier'");
    var e = createString(it.value);
    return new Identifier(e)..token = it;
  });

  String createString(input) {
    if (input is String) {
      return input;
    } else if (input is List) {
      return input.join();
    } else if (input is Token) {
      return input.value.toString();
    } else {
      return input.toString();
    }
  }
}

class BadgerParser extends GrammarParser {
  BadgerParser() : super(new BadgerParserDefinition());
}
