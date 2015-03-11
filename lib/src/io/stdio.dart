part of badger.io;

class BadgerStderr {
  void writeLine(String line, [bool nb = false]) {
    if (nb) {
      stderr.nonBlocking.writeln(line);
    } else {
      stderr.writeln(line);
    }
  }

  void write(String line, [bool nb = false]) {
    if (nb) {
      stderr.nonBlocking.write(line);
    } else {
      stderr.write(line);
    }
  }

  void writeBytes(List<int> bytes, [bool nb = false]) {
    if (nb) {
      stderr.nonBlocking.add(bytes);
    } else {
      stderr.add(bytes);
    }
  }

  Future flush([bool nb = false]) async {
    if (nb) {
      await stderr.nonBlocking.flush();
    } else {
      await stderr.flush();
    }
  }

  Future close([bool nb = false]) async {
    if (nb) {
      await stderr.nonBlocking.close();
    } else {
      await stderr.close();
    }
  }
}

class BadgerStdout {
  void writeLine(String line, [bool nb = false]) {
    if (nb) {
      stdout.nonBlocking.writeln(line);
    } else {
      stdout.writeln(line);
    }
  }

  void write(String line, [bool nb = false]) {
    if (nb) {
      stdout.nonBlocking.write(line);
    } else {
      stdout.write(line);
    }
  }

  void writeBytes(List<int> bytes, [bool nb = false]) {
    if (nb) {
      stdout.nonBlocking.add(bytes);
    } else {
      stdout.add(bytes);
    }
  }

  Future flush([bool nb = false]) async {
    if (nb) {
      await stdout.nonBlocking.flush();
    } else {
      await stdout.flush();
    }
  }

  Future close([bool nb = false]) async {
    if (nb) {
      await stdout.nonBlocking.close();
    } else {
      await stdout.close();
    }
  }
}

class BadgerStdin {
  Stream _stream;
  Stream<String> _utf;
  Stream<String> _lines;

  BadgerStdin() {
    _stream = stdin.asBroadcastStream();
  }

  Future<List<int>> readBytes([int timeout, onTimeout()]) async {
    var f  = _stream.first;
    if (timeout != null) {
      f = f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    }
    return f;
  }

  Future<String> readLine([int timeout, onTimeout()]) async {
    if (_utf == null) {
      _utf = _stream.transform(UTF8.decoder);
    }

    if (_lines == null) {
      _lines = _stream.transform(new LineSplitter());
    }

    var f  = _lines.first;
    if (timeout != null) {
      f = f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    }
    return f;
  }

  Future<String> readString([int timeout, onTimeout()]) async {
    if (_utf == null) {
      _utf = _stream.transform(UTF8.decoder);
    }

    var f  = _utf.first;
    if (timeout != null) {
      f = f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    }
    return f;
  }

  bool get echoMode => stdin.echoMode;
  set echoMode(bool echo) => stdin.echoMode = echo;

  bool get lineMode => stdin.lineMode;
  set lineMode(bool line) => stdin.lineMode = line;

  HandlerSubscription handleBytes(handler(List<int> bytes)) {
    return new HandlerSubscription(_stream.listen(handler));
  }

  HandlerSubscription handleString(handler(String str)) {
    if (_utf == null) {
      _utf = _stream.transform(UTF8.decoder);
    }

    return new HandlerSubscription(_utf.listen(handler));
  }

  HandlerSubscription handleLine(handler(String line)) {
    if (_utf == null) {
      _utf = _stream.transform(UTF8.decoder);
    }

    if (_lines == null) {
      _lines = _utf.transform(new LineSplitter());
    }

    return new HandlerSubscription(_lines.listen(handler));
  }
}
