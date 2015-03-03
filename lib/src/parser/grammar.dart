part of badger.parser;

class BadgerGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(declarations).optional() & whitespace().star() & ref(statement).separatedBy(whitespace().star());

  statement() => ref(methodCall) | ref(assignment) | ref(functionDefinition) | ref(returnStatement);

  methodCall() => ref(identifier) &
    char("(") &
    ref(arguments).optional() &
    char(")");

  arguments() => ref(expression).separatedBy(
    whitespace().star() &
    char(",") &
    whitespace().star()
  );

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

  declarations() => ref(declaration).separatedBy(char("\n"));
  declaration() => ref(featureDeclaration);

  featureDeclaration() => string("using feature ") & ref(stringLiteral);

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

  assignment() => ref(identifier) &
    whitespace().star() &
    char("=") &
    whitespace().star() &
    ref(expression);

  variableReference() => ref(identifier);
  expression() =>
    ref(emptyListDefinition) |
    ref(listDefinition) |
    ref(stringLiteral) |
    ref(integerLiteral) |
    ref(methodCall) |
    ref(parens) |
    ref(bracketAccess) |
    ref(variableReference);

  integerLiteral() => digit().plus().flatten();

  stringLiteral() => char('"') &
    (
      ref(interpolation) |
      ref(character)
    ).star() &
    char('"');

  interpolation() => string("\\(") &
    ref(expression) &
    char(")");

  character() => pattern("A-Za-z0-9{}[] ");
  identifier() => pattern("A-Za-z_+-").plus();
}

class BadgerGrammar extends GrammarParser {
  BadgerGrammar() : super(new BadgerGrammarDefinition());
}
