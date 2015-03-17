part of badger.parser;

abstract class BadgerHighlighterScheme {
  String keyword();
  String string();
  String end();
  String constant();
  String operator();
}

class ConsoleBadgerHighlighterScheme extends BadgerHighlighterScheme {
  @override
  String keyword() {
    return "\x1b[34m";
  }

  @override
  String constant() {
    return "\x1b[36m";
  }

  @override
  String end() {
    return "\x1b[0m";
  }

  @override
  String string() {
   return "\x1b[32m";
  }

  @override
  String operator() {
    return "\x1b[31m";
  }
}

class HtmlBadgerHighlighterScheme extends BadgerHighlighterScheme {
  @override
  String keyword() {
    return c("blue");
  }

  String c(String color) {
    return '<span style="color: ${color};">';
  }

  @override
  String constant() {
    return c("cyan");
  }

  @override
  String end() {
    return r"</span>";
  }

  @override
  String string() {
    return c("green");
  }

  @override
  String operator() {
    return c("red");
  }
}

class BadgerHighlighter extends BadgerAstPrinter {
  final BadgerHighlighterScheme scheme;

  BadgerHighlighter(this.scheme, Program program) : super(program);

  @override
  String keyword(String word) {
    return "${scheme.keyword()}${word}${scheme.end()}";
  }

  @override
  String constant(String n) {
    return "${scheme.constant()}${n}${scheme.end()}";
  }

  @override
  String string(String n) {
    return "${scheme.string()}${n}${scheme.end()}";
  }

  @override
  String operator(String n) {
    return "${scheme.operator()}${n}${scheme.end()}";
  }
}
