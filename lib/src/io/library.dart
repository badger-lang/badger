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
  }
}
