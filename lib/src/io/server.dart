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

  HandlerSubscription handleRequest(handler(BadgerHttpServerRequest request, BadgerHttpServerResponse response)) {
    return new HandlerSubscription(_requests.listen((request) {
      var response = new BadgerHttpServerResponse(request.request.response);
      handler(request, response);
    }));
  }

  HandlerSubscription createVirtualDirectory(String path, [Map<String, dynamic> options = const {}]) {
    var vd = new VirtualDirectory(path, pathPrefix: options.containsKey("prefix") ? options["prefix"] : null);

    if (options.containsKey("allowDirectoryListing")) {
      vd.allowDirectoryListing = options["allowDirectoryListing"];
    }

    if (options.containsKey("jail")) {
      vd.jailRoot = options["jail"];
    }

    if (options.containsKey("handleDirectory")) {
      vd.directoryHandler = (dir, request) {
        var d = new BadgerDirectory(dir);
        var req = new BadgerHttpServerRequest(request);

        options["handleDirectory"](d, req);
      };
    }

    if (options.containsKey("handleErrorPage")) {
      vd.directoryHandler = (request) {
        var req = new BadgerHttpServerRequest(request);

        options["handleErrorPage"](req);
      };
    }

    if (options.containsKey("followLinks")) {
      vd.followLinks = options["followLinks"];
    }

    return new HandlerSubscription(vd.serve(_requests.map((it) => it.request)));
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
  String get method => request.method;

  int get statusCode => request.response.statusCode;
  set statusCode(int code) => request.response.statusCode = code;

  HttpSession get session => request.session;

  String getHeader(String name) => request.headers.value(name);

  Future<HttpBody> getBody() async {
    if (_body == null) {
      _body = await HttpBodyHandler.processRequest(request);
    }

    return _body;
  }

  Future<dynamic> get bodyJson async => JSON.decode((await getBody()).body);
  Future<String> get bodyContent async => (await getBody()).body;
  Future<Map<String, String>> get bodyForm async => (await getBody()).body;

  HttpBody _body;

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
}

class BadgerHttpServerResponse {
  final HttpResponse response;

  BadgerHttpServerResponse(this.response);

  int get statusCode => response.statusCode;
  set statusCode(int code) => response.statusCode = code;

  String getHeader(String name) => response.headers.value(name);
  void setHeader(String name, String value) => response.headers.set(name, value);

  Future write(value) async {
    if (value is Map) {
      var json = JSON.encode(value);
      await write(json);
    } else if (value is String) {
      response.write(value);
    } else if (value is List<int>) {
      response.add(value);
    } else if (value is Stream) {
      await response.addStream(value);
    } else {
      throw new Exception("Invalid Value");
    }
  }

  Future close([value]) async {
    if (value != null) {
      await write(value);
    }

    await response.close();
  }
}
