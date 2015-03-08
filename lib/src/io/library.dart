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
    return new BadgerHttpResponse(heads, bytes);
  }
}

class IOLibrary {
  static void import(Context context) {
    context.proxy("HttpClient", BadgerHttpClient);
  }
}

class BadgerHttpResponse {
  final Map<String, String> headers;
  final List<int> bytes;
  String _body;

  String get body {
    if (_body == null) {
      _body = UTF8.decode(bytes);
    }
    return _body;
  }

  BadgerHttpResponse(this.headers, this.bytes);
}
