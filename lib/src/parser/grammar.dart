part of badger.parser;

class BadgerGrammarDefinition extends GrammarDefinition {
  @override
  start() => (
    ref(declarations).optional() &
    whitespace().star() &
    ref(statement).separatedBy(whitespace().star()) &
    whitespace().star()
  );

  statement() => (
    (
      ref(functionDefinition) |
      ref(accessAssignment) |
      ref(assignment) |
      ref(methodCall) |
      ref(whileStatement) |
      ref(breakStatement) |
      ref(forInStatement) |
      ref(returnStatement) |
      ref(ifStatement) |
      ref(expression)
    ) & char(";").optional()
  ).pick(0);

  breakStatement() => string("break");
  booleanLiteral() => string("true") | string("false");

  methodCall() => (ref(access) | ref(identifier)) &
    char("(") &
    ref(arguments).optional() &
    char(")");

  arguments() => ref(expression).separatedBy(
    whitespace().star() &
    char(",") &
    whitespace().star()
  );

  forInStatement() => string("for") &
    whitespace().plus() &
    ref(identifier) &
    whitespace().plus() &
    string("in") &
    whitespace().plus() &
    ref(expression) &
    ref(block);

  parens() => char("(") &
    ref(expression) &
    char(")");

  returnStatement() =>  string("return") & (
    whitespace().star() &
    ref(expression) &
    whitespace().star()
  );

  listDefinition() => char("[") &
    ref(arguments) &
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
  equalOperator() => ref(OPERATOR, "==");

  OPERATOR(String x) => ref(expressionItem) &
    whitespace().star() &
    string(x) &
    whitespace().star() &
    ref(expression);

  comment() => char("#") & any() & char("\n");
  declarations() => ref(declaration).separatedBy(char("\n"));
  declaration() => ref(featureDeclaration) |
    ref(importDeclaration);

  featureDeclaration() => string("using feature ")
    & ref(stringLiteral);

  importDeclaration() => string("import ") &
    ref(stringLiteral);

  bracketAccess() => ref(variableReference) &
    char("[") &
    ref(expressionItem) &
    char("]");

  block() => whitespace().star() &
    char("{") &
    whitespace().star() &
    ref(statement).separatedBy(whitespace().star()).optional() &
    whitespace().star() &
    char("}");

  functionDefinition() => string("func ") &
    ref(identifier) &
    char("(") &
    ref(identifier).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star()
    ) &
    char(")") &
    ref(block);

  emptyListDefinition() => string("[]");

  assignment() =>
  (
    (
      string("let") | string("var")
    ).flatten().optional() &
    whitespace().plus()
  ).optional() &
    ref(identifier) &
    whitespace().star() &
    string("=") &
    whitespace().star() &
    ref(expression);

  accessAssignment() =>
    ref(access) &
    whitespace().star() &
    string("=") &
    whitespace().star() &
    ref(expression);

  variableReference() => ref(identifier);
  expression() => ref(ternaryOperator) |
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
    ref(negate) |
    ref(expressionItem);

  accessible() => ref(variableReference);

  access() => ref(accessible) &
    char(".") & ref(identifier);

  expressionItem() => (
    (
      ref(methodCall) |
      ref(access) |
      ref(rangeLiteral) |
      ref(mapDefinition) |
      ref(hexadecimalLiteral) |
      ref(doubleLiteral) |
      ref(integerLiteral) |
      ref(simpleAnonymousFunction) |
      ref(anonymousFunction) |
      ref(emptyListDefinition) |
      ref(listDefinition) |
      ref(stringLiteral) |
      ref(parens) |
      ref(bracketAccess) |
      ref(booleanLiteral) |
      ref(variableReference)
    ) & char(";").optional()
  ).pick(0);

  negate() => char("!") & ref(expressionItem);

  ifStatement() => string("if") &
    whitespace().plus() &
    ref(expression) &
    whitespace().plus() &
    ref(block) & (
    whitespace().star() &
    string("else") &
    ref(block)
  ).optional();

  simpleAnonymousFunction() => char("(") &
    ref(identifier).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star()
    ).optional() & whitespace().star() & string(") =>") &
    whitespace().star() &
    ref(expression);

  whileStatement() => string("while") &
    whitespace().plus() &
    ref(expression) &
    whitespace().plus() &
    ref(block);

  anonymousFunction() => char("(") &
    ref(identifier).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star()
    ).optional() & whitespace().star() & string(") ->") &
    ref(block);

  integerLiteral() => (
    anyIn(["-", "+"]).optional() &
    digit().plus()
  ).flatten();

  rangeLiteral() => (
    ref(integerLiteral) &
    string("..") &
    ref(integerLiteral)
  );

  hexadecimalLiteral() => (
    string("0x") &
    (
      pattern("0-9A-Fa-f").plus().flatten()
    )
  );

  doubleLiteral() => (
    anyIn(["-", "+"]).optional() &
    digit().plus() &
    char(".") &
    digit().plus()
  ).flatten();

  stringLiteral() => char('"') &
    (
      ref(interpolation) |
      ref(character)
    ).star() &
    char('"');

  mapDefinition() => char("{") &
    whitespace().star() &
    ref(mapEntry).separatedBy(char(",").trim()).optional() &
    whitespace().star() &
    char("}");

  mapEntry() => ref(expressionItem) &
    whitespace().star() &
    char(":") &
    whitespace().star() &
    ref(expression);

  interpolation() => string("\$(") &
    ref(expression) &
    char(")");

  record() => string("record") &
    whitespace().star() &
    ref(identifier) &
    ref(recordBlock);

  recordBlock() => whitespace().star() &
    char("{") &
    whitespace().star() &
    ref(recordEntry) &
    whitespace().star() &
    char("}") &
    whitespace().star();

  recordEntry() => (ref(identifier) &
    whitespace().plus()).optional() &
    ref(identifier) &
    char(";").optional();

  character() => ref(unicodeEscape) |
    ref(characterEscape) |
    pattern('^"\\');

  unicodeEscape() => (
    string("\\u") &
    pattern("A-Fa-f0-9").times(4)
  ).flatten();

  characterEscape() => (
    string("\\") &
    pattern(_decodeTable.keys.join())
  ).flatten();

  identifier() => (
    pattern("A-Za-z_") | anyIn(["\$"])
  ).plus();
}

class BadgerGrammar extends GrammarParser {
  BadgerGrammar() : super(new BadgerGrammarDefinition());
}
