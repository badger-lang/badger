part of badger.parser;

abstract class AstVisitorBase {
  void visitDeclaration(Declaration declaration);
  void visitImportDeclaration(ImportDeclaration declaration);
  void visitFeatureDeclaration(FeatureDeclaration declaration);

  void visitStatement(Statement statement);
  void visitIfStatement(IfStatement statement);
  void visitForInStatement(ForInStatement statement);
  void visitWhileStatement(WhileStatement statement);
  void visitReturnStatement(ReturnStatement statement);
  void visitBreakStatement(BreakStatement statement);
  void visitVariableDeclaration(VariableDeclaration decl);
  void visitFlatAssignment(FlatAssignment assignment);
  void visitAccessAssignment(AccessAssignment assignment);
  void visitClassBlock(ClassBlock block);
  void visitNamespaceBlock(NamespaceBlock block);
  void visitMultiAssignment(MultiAssignment assignment);
  void visitFunctionDefinition(FunctionDefinition definition);

  void visitMethodCall(MethodCall call);

  void visitExpression(Expression expression);
  void visitStringLiteral(StringLiteral literal);
  void visitIntegerLiteral(IntegerLiteral literal);
  void visitDoubleLiteral(DoubleLiteral literal);
  void visitRangeLiteral(RangeLiteral literal);
  void visitNullLiteral(NullLiteral literal);
  void visitVariableReference(VariableReference reference);
  void visitListDefinition(ListDefinition definition);
  void visitMapDefinition(MapDefinition definition);
  void visitNegate(Negate negate);
  void visitBooleanLiteral(BooleanLiteral literal);
  void visitHexadecimalLiteral(HexadecimalLiteral literal);
  void visitOperation(Operation operation);
  void visitDefined(Defined defined);
  void visitReferenceCreation(ReferenceCreation creation);
  void visitAccess(Access access);
  void visitParentheses(Parentheses parens);
  void visitNativeCode(NativeCode code);
  void visitBracketAccess(BracketAccess access);
  void visitTernaryOperator(TernaryOperator operator);
  void visitAnonymousFunction(AnonymousFunction function);
  void visitSwitchStatement(SwitchStatement statement);
  void visitTryCatchStatement(TryCatchStatement statement);
  void visitExpressionStatement(ExpressionStatement statement);
}

abstract class AstVisitor extends AstVisitorBase {
  void visit(AstNode node) {
    if (node is Program) {
      visitProgram(node);
    } else if (node is Statement) {
      visitStatement(node);
    } else if (node is Expression) {
      visitExpression(node);
    } else if (node is Declaration) {
      visitDeclaration(node);
    } else if (node is Block) {
      visitStatements(node.statements);
    } else {
      throw new Exception("Unknown AST Node: ${node.runtimeType}");
    }
  }

  void visitProgram(Program program) {
    for (var declaration in program.declarations) {
      visitDeclaration(declaration);
    }

    visitStatements(program.statements);
  }

  @override
  void visitDeclaration(Declaration declaration) {
    if (declaration is FeatureDeclaration) {
      visitFeatureDeclaration(declaration);
    } else if (declaration is ImportDeclaration) {
      visitImportDeclaration(declaration);
    } else {
      throw new Exception("Unknown Declaration Type: ${declaration}");
    }
  }

  void visitStatements(List<Statement> statements) {
    for (var statement in statements) {
      visitStatement(statement);
    }
  }

  @override
  void visitStatement(statement) {
    if (statement is ExpressionStatement) {
      visitExpressionStatement(statement);
    } else if (statement is IfStatement) {
      visitIfStatement(statement);
    } else if (statement is WhileStatement) {
      visitWhileStatement(statement);
    } else if (statement is ForInStatement) {
      visitForInStatement(statement);
    } else if (statement is ReturnStatement) {
      visitReturnStatement(statement);
    } else if (statement is BreakStatement) {
      visitBreakStatement(statement);
    } else if (statement is FunctionDefinition) {
      visitFunctionDefinition(statement);
    } else if (statement is SwitchStatement) {
      visitSwitchStatement(statement);
    } else if (statement is NamespaceBlock) {
      visitNamespaceBlock(statement);
    } else if (statement is MultiAssignment) {
      visitMultiAssignment(statement);
    } else if (statement is FlatAssignment) {
      visitFlatAssignment(statement);
    } else if (statement is VariableDeclaration) {
      visitVariableDeclaration(statement);
    } else if (statement is AccessAssignment) {
      visitAccessAssignment(statement);
    } else if (statement is MethodCall) {
      visitMethodCall(statement);
    } else if (statement is TryCatchStatement) {
      visitTryCatchStatement(statement);
    } else if (statement is ClassBlock) {
      visitClassBlock(statement);
    } else if (statement is VariableReference) {
      visitVariableReference(statement);
    } else {
      throw new Exception("Unknown Statement Type: ${statement}");
    }
  }

  @override
  void visitExpression(Expression expression) {
    if (expression is StringLiteral) {
      visitStringLiteral(expression);
    } else if (expression is IntegerLiteral) {
      visitIntegerLiteral(expression);
    } else if (expression is DoubleLiteral) {
      visitDoubleLiteral(expression);
    } else if (expression is BooleanLiteral) {
      visitBooleanLiteral(expression);
    } else if (expression is RangeLiteral) {
      visitRangeLiteral(expression);
    } else if (expression is HexadecimalLiteral) {
      visitHexadecimalLiteral(expression);
    } else if (expression is Operation) {
      visitOperation(expression);
    } else if (expression is BracketAccess) {
      visitBracketAccess(expression);
    } else if (expression is AnonymousFunction) {
      visitAnonymousFunction(expression);
    } else if (expression is Access) {
      visitAccess(expression);
    } else if (expression is ListDefinition) {
      visitListDefinition(expression);
    } else if (expression is ReferenceCreation) {
      visitReferenceCreation(expression);
    } else if (expression is MapDefinition) {
      visitMapDefinition(expression);
    } else if (expression is VariableReference) {
      visitVariableReference(expression);
    } else if (expression is Negate) {
      visitNegate(expression);
    } else if (expression is MethodCall) {
      visitMethodCall(expression);
    } else if (expression is TernaryOperator) {
      visitTernaryOperator(expression);
    } else if (expression is NativeCode) {
      visitNativeCode(expression);
    } else if (expression is Defined) {
      visitDefined(expression);
    } else if (expression is Parentheses) {
      visitParentheses(expression);
    } else if (expression is NullLiteral) {
      visitNullLiteral(expression);
    } else {
      throw new Exception("Unknown Expression Type: ${expression}");
    }
  }

  @override
  void visitExpressionStatement(ExpressionStatement statement) {
    visitExpression(statement.expression);
  }
}
