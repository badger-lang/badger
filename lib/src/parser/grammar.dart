part of badger.parser;

class BadgerGrammarDefinition extends GrammarDefinition {
  @override
  start() => (
    whitespace().star().optional() &
    ref(declarations).optional() &
    whitespace().star().optional() &
    ref(statement).separatedBy(whitespace().plus() & char(";").optional() & whitespace().plus().optional(), includeSeparators: false) &
    whitespace().star().optional()
  ).end();

  statement() => (
    (
      ref(functionDefinition) |
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
      ref(expression)
    ) & char(";").optional()
  ).pick(0);

  breakStatement() => ref(BREAK);
  booleanLiteral() => ref(TRUE) | ref(FALSE);
  nullLiteral() => ref(NULL);

  multipleAssign() => (
    (string("let") | string("var")) & char("?").optional() & whitespace().star()
  ).optional() & char("{") & whitespace().star() &
    ref(identifier).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star(),
      includeSeparators: false
    ) & whitespace().star() & char("}") &
    whitespace().star() &
    char("=") & whitespace().star() &
    ref(expression);

  methodCall() => (ref(identifier) | ref(access)) &
    char("(") &
    ref(arguments).optional() &
    char(")");

  simpleMethodCall() => ref(identifier) &
    char("(") &
    ref(arguments).optional() &
    char(")");

  arguments() => ref(expression).separatedBy(
    whitespace().star() &
    char(",") &
    whitespace().star(),
    includeSeparators: false
  );

  forInStatement() => ref(FOR) &
    whitespace().plus() &
    ref(identifier) &
    whitespace().plus() &
    ref(IN) &
    whitespace().plus() &
    ref(expression) &
    ref(block);

  parens() => char("(") &
    ref(expression) &
    char(")");

  returnStatement() => ref(RETURN) & (
    whitespace().star() &
    ref(expression) &
    whitespace().star()
  );

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

  OPERATOR(String x) => ref(expressionItem) &
    whitespace().star() &
    string(x) &
    whitespace().star() &
    ref(expression);

  NEWLINE() => pattern('\n\r');

  singleLineComment() => string('//')
    & ref(NEWLINE).neg().star()
    & ref(NEWLINE).optional();

  declarations() => ref(declaration).separatedBy(char("\n"));
  declaration() => ref(importDeclaration) | ref(featureDeclaration);

  featureDeclaration() => ref(USING_FEATURE) &
    whitespace().plus()
    & ref(stringLiteral);

  importDeclaration() => ref(IMPORT) &
    whitespace().star() &
    ref(stringLiteral) & (
      whitespace().plus() &
      string("as") &
      whitespace().plus() &
      ref(identifier)
  ).optional();

  bracketAccess() => ref(variableReference) &
    char("[") &
    ref(expressionItem) &
    char("]");

  reference() => char("&") & ref(variableReference);

  tryCatchStatement() => string("try") &
    whitespace().star() &
    ref(block) &
    whitespace().star() &
    string("catch") &
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

  functionDefinition() => ref(FUNC).optional() & whitespace().star() &
    ref(identifier) &
    char("(") &
    ref(identifier).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star()
    ).optional() &
    char(")") &
    ref(block);

  emptyListDefinition() => string("[]");

  assignment() =>
  (
    (
      (ref(LET) | ref(VAR)) & char("?").optional()
    ).flatten().optional() &
    whitespace().plus()
  ).optional() &
    ref(identifier) &
    whitespace().star() &
    ref(token, "=") &
    whitespace().star() &
    ref(expression);

  accessAssignment() =>
    ref(access) &
    whitespace().star() &
    string("=") &
    whitespace().star() &
    ref(expression);

  variableReference() => ref(identifier);
  expression() =>
    ref(inOperator) |
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

  callable() => ref(stringLiteral) | ref(simpleMethodCall) | ref(variableReference);

  access() => ref(callable) & char(".") & (
    ref(simpleMethodCall) | ref(identifier)
  ).separatedBy(char(".")).optional();

  expressionItem() => (
    (
      ref(reference) |
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
      ref(variableReference)
    ) & char(";").optional()
  ).pick(0);

  negate() => char("!") & ref(expressionItem);
  definedOperator() => ref(identifier) & char("?");

  ifStatement() => ref(IF) &
    whitespace().plus() &
    ref(expression) &
    whitespace().plus() &
    ref(block) & (
    whitespace().star() &
    ref(ELSE) &
    ref(block)
  ).optional();

  namespace() => ref(token, "namespace") &
    whitespace().plus() &
    ref(identifier) &
    whitespace().star() &
    ref(block);

  type() => ref(token, "type") &
    whitespace().plus() &
    ref(identifier) &
    (
      char("(") &
      ref(identifier).separatedBy(
        whitespace().star() &
        char(",") &
        whitespace().star()
      ).optional() &
      char(")")
    ).pick(1).optional() &
    whitespace().plus() &
    (
      ref(token, "extends") &
      whitespace().plus() &
      ref(identifier)
    ).optional() &
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

  defaultStatement() => ref(DEFAULT) &
    whitespace().plus() &
    ref(block);

  simpleAnonymousFunction() => char("(") &
    ref(identifier).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star()
    ).optional() & whitespace().star() & string(") =>") &
    whitespace().star() &
    ref(expression);

  whileStatement() => ref(WHILE) &
    whitespace().plus() &
    ref(expression) &
    whitespace().plus() &
    ref(block);

  anonymousFunction() => char("(") &
    ref(identifier).separatedBy(
      (
        whitespace().star() &
        char(",") &
        whitespace().star()
      )
    ).optional() & whitespace().star() & string(") ->") &
    whitespace().star() &
    ref(block);

  integerLiteral() => (
    anyIn(["-", "+"]).optional() &
    digit().plus()
  ).flatten();

  rangeLiteral() => (
    ref(integerLiteral) &
    string("..") &
    char("<").optional() &
    ref(integerLiteral) &
    (
      char(":") & ref(integerLiteral)
    ).optional()
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
    ref(mapEntry).separatedBy((char(",") | whitespace().star()).trim(), includeSeparators: false).optional() &
    char(",").optional() &
    whitespace().star() &
    char("}");

  nativeCode() => string("```") &
    pattern("^```").star().flatten() &
    string("```");

  mapEntry() => ref(expressionItem) &
    whitespace().star() &
    (char(":") | string("->")) &
    whitespace().star() &
    ref(expression);

  interpolation() => string("\$(") &
    ref(expression) &
    char(")");

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
    pattern("A-Za-z_") | anyIn([
      "\$",
      "\u03A0", // Pi
    ])
  ).plus();

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
  DEFAULT() => ref(token, "default");
  FUNC() => ref(token, "func");
  RETURN() => ref(token, "return");
  IMPORT() => ref(token, "import");
  USING_FEATURE() => ref(token, "using feature");

  HIDDEN() => ref(singleLineComment);

  Parser token(input) {
    if (input is String) {
      input = input.length == 1 ? char(input) : string(input);
    } else if (input is Function) {
      input = ref(input);
    }

    if (input is! Parser && input is TrimmingParser) {
      throw new StateError("Invalid token parser: ${input}");
    }

    return input.token().trim(ref(HIDDEN));
  }
}

class BadgerGrammar extends GrammarParser {
  BadgerGrammar() : super(new BadgerGrammarDefinition());
}
