part of badger.parser;

class BadgerBuilder {
  final Program program;

  BadgerBuilder() : program = new Program([], []);

  void addStatement(Statement statement) {
    program.statements.add(statement);
  }

  void addDeclaration(Declaration decl) {
    program.declarations.add(decl);
  }

  void callMethod(ref, List<Expression> args) {
    if (ref is String) {
      ref = new Identifier(ref);
    }

    addStatement(new ExpressionStatement(new MethodCall(ref, args)));
  }

  void function(String name, List<String> args, List<Statement> statements) {
    addStatement(
      new FunctionDefinition(
        new Identifier(name),
        args.map((it) => new Identifier(it)).toList(),
        new Block(statements)
      )
    );
  }
}
