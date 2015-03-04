part of badger.parser;

class BadgerGrammarDefinition extends GrammarDefinition {
  @override
  start() => (
    ref(declarations).optional() &
    whitespace().star() &
    ref(statement).separatedBy(whitespace().star()) & whitespace().star()
  );

  statement() => (
    (
      ref(methodCall) |
      ref(assignment) |
      ref(functionDefinition) |
      ref(whileStatement) |
      ref(breakStatement) |
      ref(forInStatement) |
      ref(returnStatement) |
      ref(ifStatement)
    ) & char(";").optional()
  ).pick(0);

  breakStatement() => string("break");
  booleanLiteral() => string("true") | string("false");

  methodCall() => ref(identifier) &
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
    ref(integerLiteral) &
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
    ref(expressionItem);

  expressionItem() => (
    (
      ref(hexadecimalLiteral) |
      ref(doubleLiteral) |
      ref(integerLiteral) |
      ref(anonymousFunction) |
      ref(emptyListDefinition) |
      ref(listDefinition) |
      ref(stringLiteral) |
      ref(methodCall) |
      ref(parens) |
      ref(bracketAccess) |
      ref(booleanLiteral) |
      ref(variableReference)
    ) & char(";").optional()
  ).pick(0);

  ifStatement() => string("if") &
    whitespace().plus() &
    ref(expression) &
    whitespace().plus() &
    ref(block) & (
    whitespace().star() &
    string("else") &
    ref(block)
  ).optional();

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

  interpolation() => string("\$(") &
    ref(expression) &
    char(")");

  character() => pattern("A-Za-z0-9{}[] ") | anyIn([".", "/", ":"]);
  identifier() => (
    pattern("A-Za-z_+-") | anyIn(["\$", "&", "^", "!", "<", ">", "=", "/", "~"])
  ).plus();
}

class BadgerGrammar extends GrammarParser {
  BadgerGrammar() : super(new BadgerGrammarDefinition());
}
