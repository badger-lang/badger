part of badger.compiler;

class JsAstVisitor extends AstVisitor {
  StringBuffer buff;

  JsAstVisitor(this.buff);

  void visitForInStatement(ForInStatement statement) {

  }

  void visitImportDeclaration(ImportDeclaration declaration) {

  }

  void visitFeatureDeclaration(FeatureDeclaration declaration) {

  }

  void visitIfStatement(IfStatement statement) {

  }

  void visitWhileStatement(WhileStatement statement) {

  }

  void visitReturnStatement(ReturnStatement statement) {

  }

  void visitBreakStatement(BreakStatement statement) {

  }

  void visitAssignment(Assignment assignment) {

  }

  void visitFunctionDefinition(FunctionDefinition definition) {

  }

  void visitMethodCall(MethodCall call) {
    if(call.reference is String) {
      this.buff.write("${call.reference}(");
    }

    for(var exp in call.args) {
      this.visitExpression(exp);

      if(call.args.indexOf(exp) != call.args.length - 1) {
        this.buff.write(",");
      }
    }

    this.buff.write(");");
  }

  void visitStringLiteral(StringLiteral literal) {
    this.buff.write("'${literal.components.join()}'");
  }

  void visitIntegerLiteral(IntegerLiteral literal) {

  }

  void visitDoubleLiteral(DoubleLiteral literal) {

  }

  void visitRangeLiteral(RangeLiteral literal) {

  }

  void visitVariableReference(VariableReference reference) {

  }

  void visitListDefinition(ListDefinition definition) {

  }

  void visitMapDefinition(MapDefinition definition) {

  }

  void visitNegate(Negate negate) {

  }

  void visitBooleanLiteral(BooleanLiteral literal) {

  }

  void visitHexadecimalLiteral(HexadecimalLiteral literal) {

  }

  void visitOperator(Operator operator) {

  }

  void visitAccess(Access access) {

  }

  void visitBracketAccess(BracketAccess access) {

  }

  void visitTernaryOperator(TernaryOperator operator) {

  }

  void visitAnonymousFunction(AnonymousFunction function) {
    this.buff.write("function(");

    if(function.args != null)
      this.buff.write(function.args.join(","));

    this.buff.write("){");

    for(var statement in function.block.statements) {
      this.visitStatement(statement);

      if(function.block.statements.indexOf(statement) != function.block.statements.length - 1) {
        this.buff.write(",");
      }
    }

    this.buff.write("}.bind(this)");
  }
}

class JsCompilerTarget extends CompilerTarget<String> {

  StringBuffer buff = new StringBuffer();
  List<String> _names = <String>[];
  List<String> _bodies = <String>[];

  JsCompilerTarget();

  @override
  String compile(Program program) {
    addGlobal("print", "function(obj) { console.log(obj.toString()); }");
    addGlobal("async", "function(cb) { setTimeout(cb, 0); }");

    writePrelude();
    new JsAstVisitor(buff).visit(program);
    writePostlude();

    return buff.toString();
  }

  void addGlobal(String name, String body) {
    _names.add(name);
    _bodies.add(body);
  }

  void writePrelude() {
    buff.write("(function(${_names.join(",")}){");
  }

  void writePostlude() {
    buff.write("})(${_bodies.join(",")});");
  }
}
