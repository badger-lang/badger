part of badger.parser;

class IndentedStringBuffer extends StringBuffer {
  final String indent;
  int level = 0;

  IndentedStringBuffer({this.indent: "  "});

  @override
  void writeln([Object obj = ""]) {
    super.writeln(obj);
    if (autoIndent) {
      writeIndent();
    }
  }

  void writeIndent() {
    write(indent * level);
  }

  void increment() {
    level++;
  }

  void decrement() {
    level--;
  }

  bool autoIndent = false;
}

final Map<String, String> _decodeTable = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
