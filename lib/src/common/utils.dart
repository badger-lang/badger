part of badger.common;

const List<String> ALPHABET = const [
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z"
];

Random _random = new Random();

String generateBasicId({int length: 30}) {
  var r = new Random(_random.nextInt(5000));
  var buffer = new StringBuffer();
  for (int i = 1; i <= length; i++) {
    var n = r.nextInt(50);
    if (n >= 0 && n <= 32) {
      String letter = ALPHABET[r.nextInt(ALPHABET.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else if (n > 32 && n <= 43) {
      buffer.write(NUMBERS[r.nextInt(NUMBERS.length)]);
    } else if (n > 43) {
      buffer.write(SPECIALS[r.nextInt(SPECIALS.length)]);
    }
  }
  return buffer.toString();
}

String generateToken({int length: 50}) {
  var r = new Random(_random.nextInt(5000));
  var buffer = new StringBuffer();
  for (int i = 1; i <= length; i++) {
    if (r.nextBool()) {
      String letter = ALPHABET[r.nextInt(ALPHABET.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else {
      buffer.write(NUMBERS[r.nextInt(NUMBERS.length)]);
    }
  }
  return buffer.toString();
}

const List<int> NUMBERS = const [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9
];

const List<String> SPECIALS = const [
  "@",
  "=",
  "_",
  "+",
  "-",
  "!",
  "."
];
