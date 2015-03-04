part of badger.parser;

abstract class Statement {}
abstract class Expression {}
abstract class Declaration {}

class MethodCall extends Expression with Statement {
  final String identifier;
  final List<Expression> args;

  MethodCall(this.identifier, this.args);

  @override
  String toString() => "MethodCall(identifier: ${identifier}, args: ${args})";
}

class Block {
  final List<Statement> statements;

  Block(this.statements);

  @override
  String toString() => "Block(${statements})";
}

class BooleanLiteral extends Expression {
  final bool value;

  BooleanLiteral(String x) : value = x == "true";
}

class FunctionDefinition extends Statement {
  final String name;
  final List<String> args;
  final Block block;

  FunctionDefinition(this.name, this.args, this.block);

  @override
  String toString() => "FunctionDefinition(name: ${name}, args: ${args}, block: ${block})";
}

class AnonymousFunction extends Expression {
  final List<String> args;
  final Block block;

  AnonymousFunction(this.args, this.block);
}

class BreakStatement extends Statement {
}

class IfStatement extends Statement {
  final Expression condition;
  final Block block;
  final Block elseBlock;

  IfStatement(this.condition, this.block, this.elseBlock);
}

class TernaryOperator extends Expression {
  final Expression condition;
  final Expression whenTrue;
  final Expression whenFalse;

  TernaryOperator(this.condition, this.whenTrue, this.whenFalse);
}

class Operator extends Expression {
  final Expression left;
  final Expression right;
  final String op;

  Operator(this.left, this.right, this.op);
}

class ForInStatement extends Statement {
  final String identifier;
  final Expression value;
  final Block block;

  ForInStatement(this.identifier, this.value, this.block);
}

class WhileStatement extends Statement {
  final Expression condition;
  final Block block;

  WhileStatement(this.condition, this.block);
}

class ReturnStatement extends Statement {
  final Expression expression;

  ReturnStatement(this.expression);

  @override
  String toString() => "ReturnStatement(${expression})";
}

class StringLiteral extends Expression {
  final List<dynamic> components;

  StringLiteral(this.components);

  @override
  String toString() => "StringLiteral(${components})";
}

class IntegerLiteral extends Expression {
  final int value;

  IntegerLiteral(this.value);

  @override
  String toString() => "IntegerLiteral(${value})";
}

class DoubleLiteral extends Expression {
  final double value;

  DoubleLiteral(this.value);

  @override
  String toString() => "DoubleLiteral(${value})";
}

class VariableReference extends Expression {
  final String identifier;

  VariableReference(this.identifier);

  @override
  String toString() => "VariableReference(${identifier})";
}

class Assignment extends Statement {
  final bool immutable;
  final String identifier;
  final Expression value;

  Assignment(this.identifier, this.value, this.immutable);

  @override
  String toString() => "Assignment(identifier: ${identifier}, value: ${value})";
}

class ListDefinition extends Expression {
  final List<Expression> elements;

  ListDefinition(this.elements);

  @override
  String toString() => "ListDefinition(${elements.join(", ")})";
}

class BracketAccess extends Expression {
  final VariableReference reference;
  final Expression index;

  BracketAccess(this.reference, this.index);

  @override
  String toString() => "BracketAccess(receiver: ${reference}, index: ${index})";
}

class FeatureDeclaration extends Declaration {
  final StringLiteral feature;

  FeatureDeclaration(this.feature);

  @override
  String toString() => "FeatureDeclaration(${feature})";
}

class PlusOperator extends Expression {
  final Expression left;
  final Expression right;

  PlusOperator(this.left, this.right);
}

class Program {
  final List<Statement> statements;
  final List<Declaration> declarations;

  Program(this.declarations, this.statements);

  @override
  String toString() => "Program(\n${statements.map((it) => '  ${it.toString()}').join(",\n")}\n)";
}
