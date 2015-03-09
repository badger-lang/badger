part of badger.io;

class BadgerHttpClient {
  Future<BadgerHttpResponse> get(String url, [Map<String, String> headers]) async {
    return await request("GET", url, headers);
  }

  Future<BadgerHttpResponse> post(String url, body, [Map<String, String> headers]) async {
    return await request("POST", url, headers, body);
  }

  Future<BadgerHttpResponse> put(String url, body, [Map<String, String> headers]) async {
    return await request("PUT", url, headers, body);
  }

  Future<BadgerHttpResponse> head(String url, [Map<String, String> headers]) async {
    return await request("HEAD", url, headers);
  }

  Future<BadgerHttpResponse> delete(String url, [Map<String, String> headers]) async {
    return await request("DELETE", url, headers);
  }

  Future<BadgerHttpResponse> request(String method, String url, [Map<String, String> headers, body]) async {
    var client = new HttpClient();
    HttpClientRequest req = await client.getUrl(Uri.parse(url));

    if (body != null) {
      if (body is List<int>) {
        req.add(body);
      } else if (body is Stream) {
        req.addStream(body);
      } else if (body is String) {
        req.write(body);
      } else if (body is Map) {
        var str = "";
        var i = 0;
        for (var x in body.keys) {
          str += Uri.encodeQueryComponent(x);
          str += "=";
          str += Uri.encodeQueryComponent(body[x]);
          if (i != body.length - 1) {
            str += "&";
          }
        }
        req.write(str);
      }
    }

    if (headers != null) {
      for (var key in headers.keys) {
        req.headers.set(key, headers[key]);
      }
    }
    HttpClientResponse res = await req.close();
    var bytes = [];
    await for (var x in res) {
      bytes.addAll(x);
    }
    var heads = {};
    res.headers.forEach((x, y) {
      heads[x] = y.first;
    });
    client.close();
    return new BadgerHttpResponse(res.statusCode, heads, bytes);
  }
}

class BadgerHttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final List<int> bytes;
  String _body;

  String get body {
    if (_body == null) {
      _body = UTF8.decode(bytes);
    }
    return _body;
  }

  BadgerHttpResponse(this.statusCode, this.headers, this.bytes);
}

class BadgerWebSocket {
  final WebSocket _socket;
  Stream _stream;
  bool get open => _open;
  bool _open = true;

  BadgerWebSocket(this._socket) {
    _stream = _socket.asBroadcastStream();
    _socket.done.then((_) {
      if (_onClose != null) {
        _onClose();
      }
    });
  }

  static Future<BadgerWebSocket> connect(String url, [List<String> protocols, Map<String, String> headers]) {
    return WebSocket.connect(url, protocols: protocols, headers: headers).then((x) => new BadgerWebSocket(x));
  }

  void send(dynamic value) {
    _socket.add(value);
  }

  Future<dynamic> read([int timeout, onTimeout]) {
    var f = _stream.first;
    if (timeout != null) {
      return f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    }
    return f;
  }

  void handleData(handler(data)) {
    _stream.listen(handler);
  }

  Function _onClose;

  void handleClose(handler()) {
    _onClose = handler;
  }

  int get pingInterval => _socket.pingInterval != null ? _socket.pingInterval.inMilliseconds : -1;
  set pingInterval(int x) => _socket.pingInterval = new Duration(milliseconds: x);

  Future close([int code, String reason]) {
    return _socket.close(code, reason);
  }

  int get closeCode => _socket.closeCode;
  String get closeReason => _socket.closeReason;
}
