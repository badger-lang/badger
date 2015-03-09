part of badger.parser;

abstract class Statement {}

abstract class Expression {}

abstract class Declaration {}

class MethodCall extends Expression with Statement {
  final dynamic reference;
  final List<Expression> args;

  MethodCall(this.reference, this.args);

  @override
  String toString() => "MethodCall(reference: ${reference}, args: ${args})";
}

class Block {
  final List<Statement> statements;

  Block(this.statements);

  @override
  String toString() => "Block(${statements})";
}

class BooleanLiteral extends Expression {
  final bool value;

  BooleanLiteral(this.value);
}

class NamespaceBlock extends Statement {
  final String name;
  final Block block;

  NamespaceBlock(this.name, this.block);
}

class TypeBlock extends Statement {
  final String name;
  final List<String> args;
  final Block block;
  final String extension;

  TypeBlock(this.name, this.args, this.extension, this.block);
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

class RangeLiteral extends Expression {
  final Expression left;
  final Expression right;
  final Expression step;
  final bool exclusive;

  RangeLiteral(this.left, this.right, this.exclusive, this.step);
}

class Negate extends Expression {
  final Expression expression;

  Negate(this.expression);
}

class NullLiteral extends Expression {
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

class Access extends Expression {
  final Expression reference;
  final List<dynamic> parts;

  Access(this.reference, this.parts);
}

class StringLiteral extends Expression {
  final List<dynamic> components;

  StringLiteral(this.components);

  @override
  String toString() => "StringLiteral(${components})";
}

class NativeCode extends Expression {
  final String code;

  NativeCode(this.code);
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

class Defined extends Expression {
  final String identifier;

  Defined(this.identifier);
}

class SwitchStatement extends Statement {
  final Expression expression;
  final List<CaseStatement> cases;

  SwitchStatement(this.expression, this.cases);
}

class CaseStatement extends Statement {
  final Expression expression;
  final Block block;

  CaseStatement(this.expression, this.block);
}

class Parentheses extends Expression {
  final Expression expression;

  Parentheses(this.expression);
}

class HexadecimalLiteral extends Expression {
  final int value;

  String asHex() => "0x${value.toRadixString(16)}";

  HexadecimalLiteral(this.value);
}

class VariableReference extends Expression {
  final String identifier;

  VariableReference(this.identifier);

  @override
  String toString() => "VariableReference(${identifier})";
}

class Assignment extends Statement {
  final bool immutable;
  final dynamic reference;
  final Expression value;
  final bool isInitialDefine;
  final bool isNullable;

  Assignment(this.reference, this.value, this.immutable, this.isInitialDefine, this.isNullable);

  @override
  String toString() => "Assignment(identifier: ${reference}, value: ${value})";
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

class ImportDeclaration extends Declaration {
  final StringLiteral location;

  ImportDeclaration(this.location);

  @override
  String toString() => "ImportDeclaration(${location})";
}

class RecordDefinition extends Statement {
  final String name;
  final List<RecordEntry> entries;

  RecordDefinition(this.name, this.entries);
}

class MapDefinition extends Expression {
  final List<MapEntry> entries;

  MapDefinition(this.entries);
}

class MapEntry extends Expression {
  final Expression key;
  final Expression value;

  MapEntry(this.key, this.value);
}

class RecordEntry {
  final String type;
  final String name;

  RecordEntry(this.type, this.name);
}

class MultiAssignment extends Statement {
  final bool immutable;
  final List<String> ids;
  final Expression value;
  final bool isInitialDefine;
  final bool isNullable;

  MultiAssignment(this.ids, this.value, this.immutable, this.isInitialDefine, this.isNullable);
}

class Program {
  final List<dynamic> statements;
  final List<Declaration> declarations;

  /**
   * Metadata Storage for Environment
   */
  Map<String, dynamic> meta = {};

  Program(this.declarations, this.statements);

  @override
  String toString() => "Program(\n${statements.map((it) => '  ${it.toString()}').join(",\n")}\n)";
}
