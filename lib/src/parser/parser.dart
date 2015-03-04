part of badger.parser;

class BadgerParserDefinition extends BadgerGrammarDefinition {
  @override
  start() => super.start().map((it) {
    return new Program(
      it[0] == null ? [] : it[0].where((it) => it is Declaration).toList(),
      it[2] == null ? [] : it[2].where((it) => it is Statement).toList()
    );
  });

  @override
  methodCall() => super.methodCall().map((it) {
    return new MethodCall(it[0], it[2] == null ? [] : it[2]);
  });

  @override
  stringLiteral() => super.stringLiteral().map((it) {
    return new StringLiteral(it[1]);
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
  statement() => super.statement().map((it) {
    return it;
  });

  @override
  arguments([bool allowAnd = false]) => super.arguments(allowAnd).map((it) {
    return it.where((it) => it is Expression).toList();
  });

  @override
  returnStatement() => super.returnStatement().map((it) {
    return new ReturnStatement(it[1][1]);
  });

  @override
  ternaryOperator() => super.ternaryOperator().map((it) {
    return new TernaryOperator(it[0], it[2], it[4]);
  });

  @override
  assignment() => super.assignment().map((it) {
    return new Assignment(it[1], it[5], it[0] == "let");
  });

  @override
  forInStatement() => super.forInStatement().map((it) {
    return new ForInStatement(it[2], it[6], it[7]);
  });

  @override
  integerLiteral() => super.integerLiteral().map((it) {
    return new IntegerLiteral(int.parse(it[0]));
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
  booleanLiteral() => super.booleanLiteral().map((it) {
    return new BooleanLiteral(it);
  });

  @override
  parens() => super.parens().map((it) {
    return it[1];
  });

  @override
  listDefinition() => super.listDefinition().map((it) {
    return new ListDefinition(it[1]);
  });

  @override
  emptyListDefinition() => super.emptyListDefinition().map((it) {
    return new ListDefinition([]);
  });

  @override
  featureDeclaration() => super.featureDeclaration().map((it) {
    return new FeatureDeclaration(it[1]);
  });

  @override
  bracketAccess() => super.bracketAccess().map((it) {
    return new BracketAccess(it[0], it[2]);
  });

  @override
  anonymousFunction() => super.anonymousFunction().map((it) {
    return new AnonymousFunction(it[1], it[4]);
  });

  @override
  variableReference() => super.variableReference().map((it) {
    return new VariableReference(it);
  });

  @override
  functionDefinition() => super.functionDefinition().map((it) {
    return new FunctionDefinition(it[1], it[3], it[5]);
  });

  @override
  block() => super.block().map((it) {
    return new Block(it[3].where((it) => it is Statement).toList());
  });

  @override
  identifier() => super.identifier().map((it) {
    return it.join();
  });
}

class BadgerParser extends GrammarParser {
  BadgerParser() : super(new BadgerParserDefinition());
}
