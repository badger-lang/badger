part of badger.parser;

abstract class AstNode {
  String toSource() {
    return (new BadgerPrinter(this)..visit(this)).buff.toString();
  }
}

abstract class Statement extends AstNode {}
abstract class Expression extends AstNode {}
abstract class Declaration extends AstNode {}

class ExpressionStatement extends Statement {
  final Expression expression;

  ExpressionStatement(this.expression);

  factory ExpressionStatement.forMethodCall(dynamic ref, [List<Expression> args = const []]) {
    return new ExpressionStatement(new MethodCall(ref, args));
  }
}

class MethodCall extends Expression {
  final dynamic reference;
  final List<Expression> args;

  MethodCall(this.reference, this.args);
  MethodCall.withNoArguments(this.reference) : args = [];

  @override
  String toString() => "MethodCall(reference: ${reference}, args: ${args})";
}

class Block extends AstNode {
  final List<Statement> statements;

  Block(this.statements);
  Block.forSingle(Statement statement) : this([statement]);
  Block.forSingleExpression(Expression expr) : this.forSingle(new ExpressionStatement(expr));

  @override
  String toString() => "Block(${statements})";
}

class BooleanLiteral extends Expression {
  final bool value;

  BooleanLiteral(this.value);

  bool get isTrue => value == true;
  bool get isFalse => value == false;

  BooleanLiteral negate() => new BooleanLiteral(!value);
}

class NamespaceBlock extends Statement {
  final Identifier name;
  final Block block;

  NamespaceBlock(this.name, this.block);
}

class ClassBlock extends Statement {
  final Identifier name;
  final List<Identifier> args;
  final Block block;
  final Identifier extension;

  ClassBlock(this.name, this.args, this.extension, this.block);

  String get className => name.name;
}

class TryCatchStatement extends Statement {
  final Block tryBlock;
  final Identifier identifier;
  final Block catchBlock;

  TryCatchStatement(this.tryBlock, this.identifier, this.catchBlock);
}

class ReferenceCreation extends Expression {
  final VariableReference variable;

  ReferenceCreation(this.variable);
}

class FunctionDefinition extends Statement {
  final Identifier name;
  final List<Identifier> args;
  final Block block;

  FunctionDefinition(this.name, this.args, this.block);

  @override
  String toString() => "FunctionDefinition(name: ${name}, args: ${args}, block: ${block})";
}

class AnonymousFunction extends Expression {
  final List<Identifier> args;
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

  RangeLiteral.create(int left, int right, {int step, bool exclusive}) :
    this(
      new IntegerLiteral(left),
      new IntegerLiteral(right),
      exclusive,
      step != null ? new IntegerLiteral(step) : null
    );
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
  final Identifier identifier;
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
  StringLiteral.forString(String input) : components = [input];

  @override
  String toString() => "StringLiteral(${components})";

  bool get isSimpleString => components.every((x) => x is String);
  String asSimpleString() => components.join();

  StringLiteral modify(String modifier(String input)) {
    return new StringLiteral.forString(modifier(asSimpleString()));
  }
}

class NativeCode extends Expression {
  final String code;

  NativeCode(this.code);
}

abstract class NumberLiteral<T extends num> extends Expression {
  static NumberLiteral create(num value) {
    if (value is double) {
      return new DoubleLiteral(value);
    } else if (value is int) {
      return new IntegerLiteral(value);
    } else {
      throw new Exception("Failed to create a numbe literal.");
    }
  }

  T get value;

  NumberLiteral<T> abs() => NumberLiteral.create(value.abs());
}

class IntegerLiteral extends NumberLiteral<int> {
  final int value;

  IntegerLiteral(this.value);

  @override
  String toString() => "IntegerLiteral(${value})";
}

class DoubleLiteral extends NumberLiteral<double> {
  final double value;

  DoubleLiteral(this.value);

  @override
  String toString() => "DoubleLiteral(${value})";
}

class Defined extends Expression {
  final Identifier identifier;

  Defined(this.identifier);
  Defined.forName(String name) : this(new Identifier(name));
}

class SwitchStatement extends Statement {
  final Expression expression;
  final List<CaseStatement> cases;

  SwitchStatement(this.expression, this.cases);
}

class Identifier extends AstNode {
  final String name;

  Identifier(this.name);

  @override
  String toString() => name;
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

class HexadecimalLiteral extends NumberLiteral<int> {
  final int value;

  HexadecimalLiteral(this.value);
  HexadecimalLiteral.forString(String input) : this(int.parse(input, radix: 16));

  String asHex() => "0x${value.toRadixString(16)}";
}

class VariableReference extends Expression {
  final Identifier identifier;

  VariableReference(this.identifier);
  VariableReference.forString(String name) : this(new Identifier(name));

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

  bool get isEmpty => elements.isEmpty;
  bool get isNotEmpty => elements.isNotEmpty;
  int get length => elements.length;
}

class BracketAccess extends Expression {
  final VariableReference reference;
  final Expression index;

  BracketAccess(this.reference, this.index);

  @override
  String toString() => "BracketAccess(receiver: ${reference}, index: ${index})";

  bool get isNumberIndex => index is NumberLiteral;
}

class FeatureDeclaration extends Declaration {
  final StringLiteral feature;

  FeatureDeclaration(this.feature);

  @override
  String toString() => "FeatureDeclaration(${feature})";
}

class ImportDeclaration extends Declaration {
  final StringLiteral location;
  final String id;

  ImportDeclaration(this.location, this.id);

  @override
  String toString() => "ImportDeclaration(${location})";

  Uri asUri() => Uri.parse(location.components.join());
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

class MultiAssignment extends Statement {
  final bool immutable;
  final List<Identifier> ids;
  final Expression value;
  final bool isInitialDefine;
  final bool isNullable;

  MultiAssignment(this.ids, this.value, this.immutable, this.isInitialDefine, this.isNullable);
}

class Program extends AstNode {
  final List<Statement> statements;
  final List<Declaration> declarations;

  /**
   * Metadata Storage for Environment
   */
  Map<String, dynamic> meta = {};

  Program(this.declarations, this.statements);

  @override
  String toString() => "Program(\n${statements.map((it) => '  ${it.toString()}').join(",\n")}\n)";
}
