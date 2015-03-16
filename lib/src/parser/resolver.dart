part of badger.parser;

class BadgerResolvedNode {
  final AstNode source;
  final BadgerResolvedNode parent;

  Map<String, AstNode> variables = {};
  Map<String, NamespaceBlock> namespaces = {};
  Map<String, TypeBlock> types = {};

  List<BadgerResolvedNode> children = [];

  BadgerResolvedNode.root(this.source) : parent = null;
  BadgerResolvedNode(this.source, this.parent);

  List<BadgerResolvedNode> getChildrenRecursive() {
    var c = [];
    for (var child in children) {
      c.add(child);
      c.addAll(child.getChildrenRecursive());
    }
    return c;
  }
}

class BadgerResolver {
  BadgerResolvedNode resolve(Program program) {
    var visitor = new BadgerResolverVisitor();
    visitor.visit(program);
    return visitor.rootNode;
  }
}

class BadgerResolverVisitor extends AstVisitor {
  BadgerResolvedNode rootNode;
  BadgerResolvedNode currentNode;

  @override
  void visit(Program program) {
    rootNode = new BadgerResolvedNode.root(program);
    currentNode = rootNode;
    super.visit(program);
  }

  void enter(AstNode n) {
    var x = new BadgerResolvedNode(n, currentNode);
    currentNode.children.add(x);
    currentNode = x;
  }

  void exit() {
    currentNode = currentNode.parent;
  }

  @override
  void visitAccess(Access access) {
  }

  @override
  void visitAnonymousFunction(AnonymousFunction function) {
    enter(function);
    enter(function.block);
    visitStatements(function.block.statements);
    exit();
    exit();
  }

  @override
  void visitAssignment(Assignment assignment) {
    if (assignment.reference is String) {
      currentNode.variables[assignment.reference] = assignment;
    }
  }

  @override
  void visitBooleanLiteral(BooleanLiteral literal) {
  }

  @override
  void visitBracketAccess(BracketAccess access) {
  }

  @override
  void visitBreakStatement(BreakStatement statement) {
  }

  @override
  void visitDefined(Defined defined) {
  }

  @override
  void visitDoubleLiteral(DoubleLiteral literal) {
  }

  @override
  void visitFeatureDeclaration(FeatureDeclaration declaration) {
  }

  @override
  void visitForInStatement(ForInStatement statement) {
    enter(statement);
    enter(statement.block);
    visitStatements(statement.block.statements);
    exit();
    exit();
  }

  @override
  void visitFunctionDefinition(FunctionDefinition definition) {
  }

  @override
  void visitHexadecimalLiteral(HexadecimalLiteral literal) {
  }

  @override
  void visitIfStatement(IfStatement statement) {
    enter(statement);
    enter(statement.block);
    visitStatements(statement.block.statements);
    exit();
    if (statement.elseBlock != null) {
      enter(statement.elseBlock);
      visitStatements(statement.elseBlock.statements);
      exit();
    }
    exit();
  }

  @override
  void visitImportDeclaration(ImportDeclaration declaration) {
  }

  @override
  void visitIntegerLiteral(IntegerLiteral literal) {
  }

  @override
  void visitListDefinition(ListDefinition definition) {
  }

  @override
  void visitMapDefinition(MapDefinition definition) {
  }

  @override
  void visitMethodCall(MethodCall call) {
  }

  @override
  void visitMultiAssignment(MultiAssignment assignment) {
    for (var id in assignment.ids) {
      currentNode.variables[id] = assignment;
    }
  }

  @override
  void visitNamespaceBlock(NamespaceBlock block) {
    enter(block);
    visitStatements(block.block.statements);
    exit();
  }

  @override
  void visitNativeCode(NativeCode code) {
  }

  @override
  void visitNegate(Negate negate) {
  }

  @override
  void visitNullLiteral(NullLiteral literal) {
  }

  @override
  void visitOperator(Operator operator) {
  }

  @override
  void visitParentheses(Parentheses parens) {
    visitExpression(parens.expression);
  }

  @override
  void visitRangeLiteral(RangeLiteral literal) {
    visitExpression(literal.left);
    visitExpression(literal.right);
  }

  @override
  void visitReferenceCreation(ReferenceCreation creation) {
  }

  @override
  void visitReturnStatement(ReturnStatement statement) {
  }

  @override
  void visitStringLiteral(StringLiteral literal) {
  }

  @override
  void visitSwitchStatement(SwitchStatement statement) {
    enter(statement);
    for (var c in statement.cases) {
      enter(c);
      visitStatements(c.block.statements);
      exit();
    }
    exit();
  }

  @override
  void visitTernaryOperator(TernaryOperator operator) {
  }

  @override
  void visitTryCatchStatement(TryCatchStatement statement) {
    enter(statement);
    enter(statement.tryBlock);
    visitStatements(statement.tryBlock.statements);
    exit();
    enter(statement.catchBlock);
    visitStatements(statement.catchBlock.statements);
    exit();
    exit();
    exit();
  }

  @override
  void visitTypeBlock(TypeBlock block) {
    enter(block);
    visitStatements(block.block.statements);
    exit();
  }

  @override
  void visitVariableReference(VariableReference reference) {
  }

  @override
  void visitWhileStatement(WhileStatement statement) {
    enter(statement);
    visitStatements(statement.block.statements);
    exit();
  }
}
