part of badger.parser;

abstract class HighlighterScheme {
  String keyword();
  String string();
  String end();
  String constant();
  String operator();
}

class ConsoleHighlighterScheme extends HighlighterScheme {
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

/**
 * Highlighter Scheme for marking highlights of code for easy interpretation.
 *
 * Every highlight being with it's specified beginning and ends with \u0000
 *
 * Constants: \u0001
 * Keyword: \u0002
 * Operator: \u0003
 * String: \u0004
 */
class MarkerHighlighterScheme extends HighlighterScheme {
  @override
  String constant() {
    return "\u0001";
  }

  @override
  String keyword() {
    return "\u0002";
  }

  @override
  String operator() {
    return "\u0003";
  }

  @override
  String string() {
    return "\u0004";
  }

  @override
  String end() {
    return "\u0000";
  }
}

class BadgerHighlighter extends BadgerPrinter {
  final HighlighterScheme scheme;

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
