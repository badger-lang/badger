part of badger.io;

class IOLibrary {
  static void import(Context context) {
    context.proxy("HttpClient", BadgerHttpClient);
    context.proxy("Socket", BadgerSocket);
    context.proxy("File", BadgerFile);
    context.proxy("Directory", BadgerDirectory);
    context.proxy("FileSystemEntity", BadgerFileSystemEntity);
    context.proxy("WebSocket", BadgerWebSocket);
    context.proxy("HttpServer", BadgerHttpServer);
    context.proxy("Process", BadgerProcess);
    context.proxy("stdin", new BadgerStdin());
    context.proxy("stdout", new BadgerStdout());
    context.proxy("stderr", new BadgerStderr());
    context.proxy("Platform", Platform);
    context.proxy("NetworkInterface", NetworkInterface);
    context.proxy("InternetAddress", InternetAddress);
    context.proxy("InternetAddressType", InternetAddressType);
    context.proxy("exit", exit);
    context.proxy("setExitCode", (x) => exitCode = x);
    context.proxy("getExitCode", () => exitCode);
    context.proxy("getProcessId", () => pid);
    context.proxy("Channel", Channel);
  }
}

class Channel<T> {
  final StreamController<T> _controller = new StreamController.broadcast();

  StreamController _closeController = new StreamController.broadcast();

  Channel() {
    _controller.done.then((_) async {
      _closeController.add(null);
      await _closeController.close();
    });
  }

  Future<T> read([int timeout, onTimeout()]) {
    if (timeout != null) {
      return _controller.stream.first.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    } else {
      return _controller.stream.first;
    }
  }

  Future<List<T>> get(int count, [int timeout, onTimeout()]) async {
    var list = [];
    var i = 0;
    while (i < count) {
      var obj = await read(timeout, onTimeout);
      list.add(obj);
    }
    return list;
  }

  void write(T input) {
    _controller.add(input);
  }
  void add(T input) => write(input);
  void put(T input) => write(input);

  HandlerSubscription handleClose(handler()) {
    return new HandlerSubscription(_closeController.stream.listen((x) => handler()));
  }

  HandlerSubscription handle(handler(T obj)) {
    return new HandlerSubscription(_controller.stream.listen(handler));
  }

  Future close() async {
    await _controller.close();
  }
}
