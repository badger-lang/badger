part of badger.io;

class BadgerSocket {
  final Socket socket;
  Stream<List<int>> _input;
  Stream<String> _utf;

  bool get open => _open;
  bool _open = true;
  Stream<String> _lines;

  static Future<BadgerSocket> connect(String host, int port, [int timeout, onTimeout()]) {
    var f = Socket.connect(host, port).then((c) {
      return new BadgerSocket(c);
    });

    if (timeout != null) {
      return f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    } else {
      return f;
    }
  }

  BadgerSocket(this.socket) {
    _input = socket.asBroadcastStream();
    socket.done.then((_) async {
      _open = false;

      _closeController.add(null);
      await _closeController.close();
    });
  }

  StreamController _closeController = new StreamController.broadcast();

  Future<List<int>> readBytes([int timeout, onTimeout()]) {
    return timeout != null ? _input.first.timeout(new Duration(milliseconds: timeout)) : _input.first;
  }

  Future<String> readString([int timeout, onTimeout()]) {
    if (_utf == null) {
      _utf = _input.transform(const Utf8Decoder()).asBroadcastStream();
    }

    if (timeout != null) {
      return _utf.first.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    } else {
      return _utf.first;
    }
  }

  Future<String> readLine([int timeout, onTimeout()]) {
    if (_utf == null) {
      _utf = _input.transform(const Utf8Decoder()).asBroadcastStream();
    }

    if (_lines == null) {
      _lines = _utf.transform(const LineSplitter()).asBroadcastStream();
    }

    if (timeout != null) {
      return _lines.first.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    } else {
      return _lines.first;
    }
  }

  HandlerSubscription handleBytes(handler(List<int> bytes)) {
    return new HandlerSubscription(_input.listen(handler));
  }

  HandlerSubscription handleClose(handler()) {
    return new HandlerSubscription(_closeController.stream.listen((x) {
      handler();
    }));
  }

  HandlerSubscription handleString(handler(String string)) {
    if (_utf == null) {
      _utf = _input.transform(const Utf8Decoder()).asBroadcastStream();
    }

    return new HandlerSubscription(_utf.listen(handler));
  }

  HandlerSubscription handleLine(handler(String line)) {
    if (_utf == null) {
      _utf = _input.transform(const Utf8Decoder()).asBroadcastStream();
    }

    if (_lines == null) {
      _lines = _utf.transform(const LineSplitter()).asBroadcastStream();
    }

    return new HandlerSubscription(_lines.listen(handler));
  }

  void writeString(String str) {
    socket.write(str);
  }

  void flush() {
    socket.flush();
  }

  Future close() => socket.close();

  void writeLine(String line) => socket.writeln(line);

  void writeBytes(List<int> bytes) {
    socket.add(bytes);
  }
}
