part of badger.parser;

abstract class BadgerHighlighterScheme {
  String keyword();
  String string();
  String end();
  String number();
}

class ConsoleBadgerHighlighterScheme extends BadgerHighlighterScheme {
  @override
  String keyword() {
    return "\x1b[34m";
  }

  @override
  String number() {
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
}

class BadgerHighlighter extends BadgerAstPrinter {
  final BadgerHighlighterScheme scheme;

  BadgerHighlighter(this.scheme, Program program) : super(program);

  @override
  String keyword(String word) {
    return "${scheme.keyword()}${word}${scheme.end()}";
  }

  @override
  String number(String n) {
    return "${scheme.number()}${n}${scheme.end()}";
  }

  @override
  String string(String n) {
    return "${scheme.string()}${n}${scheme.end()}";
  }
}
