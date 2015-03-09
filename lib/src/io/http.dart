part of badger.io;

class BadgerHttpClient {
  Future<BadgerHttpResponse> get(String url, [Map<String, String> headers]) async {
    var client = new HttpClient();
    HttpClientRequest req = await client.getUrl(Uri.parse(url));
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

  BadgerWebSocket(this._socket) {
    _stream = _socket.asBroadcastStream();
  }

  static Future<BadgerWebSocket> connect(String url, [List<String> protocols, Map<String, String> headers]) {
    return WebSocket.connect(url, protocols: protocols, headers: headers).then((x) => new BadgerWebSocket(x));
  }

  void send(dynamic value) {
    _socket.add(value);
  }

  Future<dynamic> read([int timeout]) {
    return _stream.first;
  }
}
