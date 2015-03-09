part of badger.io;

class BadgerHttpServer {
  final HttpServer server;
  Stream<BadgerHttpServerRequest> _requests;

  BadgerHttpServer(this.server) {
    _requests = server.asBroadcastStream().map((HttpRequest request) {
      return new BadgerHttpServerRequest(request);
    });
  }

  static Future<BadgerHttpServer> listen(host, int port) async {
    return new BadgerHttpServer(await HttpServer.bind(host, port));
  }

  HandlerSubscription handleRequest(handler(BadgerHttpServerRequest request)) {
    return new HandlerSubscription(_requests.listen(handler));
  }

  Future<BadgerHttpServerRequest> wait([int timeout, onTimeout()]) async {
    if (timeout != null) {
      return _requests.first.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    } else {
      return _requests.first;
    }
  }

  int get port => server.port;

  Future stop([bool force = false]) => server.close(force: force);
}

class BadgerHttpServerRequest {
  final HttpRequest request;

  BadgerHttpServerRequest(this.request);

  Uri get uri => request.uri;
  Uri get requestedUri => request.requestedUri;
  String get path => uri.path;

  Future write(value) async {
    if (value is Map) {
      var json = JSON.encode(value);
      await write(json);
    } else if (value is String) {
      request.response.write(value);
    } else if (value is List<int>) {
      request.response.add(value);
    } else if (value is Stream) {
      await request.response.addStream(value);
    } else {
      throw new Exception("Invalid Value");
    }
  }

  int get statusCode => request.response.statusCode;
  set statusCode(int code) => request.response.statusCode = code;

  HttpSession get session => request.session;

  String getHeader(String name) => request.headers.value(name);
  void setHeader(String name, String value) => request.response.headers.set(name, value);
  Map<String, String> get headers {
    if (_headers != null) {
      return _headers;
    } else {
      var map = {};
      request.headers.forEach((k, v) {
        map[k] = v;
      });
      return _headers = map;
    }
  }

  Map<String, String> _headers;

  Future close([value]) async {
    if (value != null) {
      await write(value);
    }

    await request.response.close();
  }
}
