part of badger.io;

class IOLibrary {
  static void import(Context context) {
    context.proxy("HttpClient", BadgerHttpClient);
    context.proxy("Socket", BadgerSocket);
    context.proxy("File", BadgerFile);
    context.proxy("Directory", BadgerDirectory);
    context.proxy("FileSystemEntity", BadgerFileSystemEntity);
    context.proxy("WebSocket", BadgerWebSocket);
  }
}
