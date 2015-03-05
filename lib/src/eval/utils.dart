part of badger.eval;

final RegExp _unicodeEscapeSequence = new RegExp(r"\\u([0-9a-fA-F]{4})");
final RegExp _escapeSequence = new RegExp(r"\\([bfnrt\\])");
final RegExp _unicodeEscape = new RegExp(r"[^\x20-\x7E]+");

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

final Map<String, String> _encodeTable = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  '\b': 'b',
  '\f': 'f',
  '\n': 'n',
  '\r': 'r',
  '\t': 't'
};

String _escapeUnicode(String input) {
  return input.replaceAllMapped(_unicodeEscape, (match) {
    var escape = match[0];
    var end = "0000" + escape.codeUnitAt(0).toRadixString(16);
    end = end.substring(end.length - 4);
    return "\\u" + end;
  });
}

String _unescape(String input) {
  if (_escapeSequence.hasMatch(input)) {
    input = input.replaceAllMapped(_escapeSequence, (match) => _decodeTable[match[1]]);
  }

  if (_unicodeEscapeSequence.hasMatch(input)) {
    input = input.replaceAllMapped(_unicodeEscapeSequence, (match) {
      var value = int.parse(match[1], radix: 16);

      if ((value >= 0xD800 && value <= 0xDFFF) || value > 0x10FFFF) {
        throw new Exception("Invalid Escape Code: value(${value})");
      }

      return new String.fromCharCode(value);
    });
  }

  return input;
}

String _escape(String input) {
  if (_encodeTable.keys.any((it) => input.contains(it))) {
    for (var it in _encodeTable.keys) {
      input = input.replaceAll(it, "\\" + _encodeTable[it]);
    }
  }

  input = _escapeUnicode(input);

  return input;
}
