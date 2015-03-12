library benchmark;

import "dart:io";
import "package:badger/parser.dart";

int benchmark(Function function, [int warmup = 5, int milliseconds = 1000]) {
  var count = 0;
  var elapsed = 0;
  var watch = new Stopwatch();
  while (warmup-- > 0) {
    function();
  }
  watch.start();
  while (elapsed < milliseconds) {
    function();
    elapsed = watch.elapsedMilliseconds;
    count++;
  }
  return (elapsed / count).round();
}

void main() {
  var parser = new BadgerParser();
  Directory.current
      .list(recursive: true)
      .where((file) => file is File)
      .where((file) => file.path.endsWith('.badger'))
      .forEach((file) {
    var source = file.readAsStringSync();
    var result = parser.parse(source);
    if (result.isSuccess) {
      var time = benchmark(() => parser.parse(source));
      print('${file.path}: ${time.round()}ms');
    } else {
      print('${file.path}: FAILURE');
    }
  });
}
