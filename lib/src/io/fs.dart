part of badger.io;

abstract class BadgerFileSystemEntity {
  bool get isFile => this is BadgerFile;
  bool get isDirectory => this is BadgerDirectory;
}

class BadgerFile extends BadgerFileSystemEntity {
  final File _file;

  BadgerFile(this._file);

  static BadgerFile get(String path) {
    return new BadgerFile(new File(path));
  }

  Future create([bool recursive = false]) => _file.create(recursive: recursive);
  Future<String> read() => _file.readAsString();
  Future write(String content) => _file.writeAsString(content);
  Future writeBytes(List<int> bytes) => _file.writeAsBytes(bytes);
  Future appendBytes(List<int> bytes) => _file.writeAsBytes(bytes, mode: FileMode.APPEND);
  Future append(String content) => _file.writeAsString(content, mode: FileMode.APPEND);
  Future<List<int>> readBytes() => _file.readAsBytes();
  Future<BadgerOpenFile> open([int mode = 0]) async {
    FileMode m = {
      0: FileMode.READ,
      1: FileMode.WRITE,
      2: FileMode.APPEND
    }[mode];

    if (m == null) {
      m = FileMode.READ;
    }

    var of = new BadgerOpenFile(this);
    of._f = await _file.open();
    return of;
  }

  HandlerSubscription handleEvent(handler(FileSystemEvent event)) {
    return new HandlerSubscription(_file.watch().map((it) {
      var e = new BadgerFileSystemEvent(
        it.type,
        it.path,
        dest: it is FileSystemMoveEvent ? it.destination : null,
        contentChanged: it is FileSystemModifyEvent ? it.contentChanged : false
      );

      return e;
    }).listen(handler));
  }

  Future<int> get length => _file.length();

  String get name => path.split(Platform.pathSeparator).last;
  String get extension {
    return pathlib.extension(name);
  }
  String get basename {
    return pathlib.basename(name);
  }
  String get dirname => parent.path;

  Future<int> get size async => (await _file.stat()).size;
  Future<int> get mode async => (await _file.stat()).mode;

  Future<BadgerFile> rename(String name) => _file.rename(name).then((x) => new BadgerFile(x));

  Future<bool> identical(BadgerFile other) => FileSystemEntity.identical(_file.path, other.path);
  BadgerFile parentFile(String name) => parent.file(name);

  Future<bool> get exists => _file.exists();
  String get path => _file.path;
  BadgerDirectory get parent => new BadgerDirectory(_file.parent);
}

class BadgerDirectory extends BadgerFileSystemEntity {
  final Directory _dir;

  BadgerDirectory(this._dir);

  static BadgerDirectory get(String path) {
    return new BadgerDirectory(new Directory(path));
  }

  static BadgerDirectory root() => BadgerDirectory.get("/");
  static BadgerDirectory temp() => new BadgerDirectory(Directory.systemTemp);
  static BadgerDirectory current() => new BadgerDirectory(Directory.current);

  HandlerSubscription handleEvent(handler(FileSystemEvent event)) {
    return new HandlerSubscription(_dir.watch().map((it) {
      var e = new BadgerFileSystemEvent(
        it.type,
        it.path,
        dest: it is FileSystemMoveEvent ? it.destination : null,
        contentChanged: it is FileSystemModifyEvent ? it.contentChanged : false
      );

      return e;
    }).listen(handler));
  }

  Future<bool> get exists => _dir.exists();
  String get path => _dir.path;
  BadgerDirectory get parent => new BadgerDirectory(_dir.parent);
  Future<BadgerDirectory> rename(String name) => _dir.rename(name).then((x) => new BadgerDirectory(x));
  Future delete([bool recursive = false]) => _dir.delete(recursive: recursive);
  bool get isCurrent => Directory.current.absolute.path == _dir.absolute.path;
  void setCurrent() {
    Directory.current = _dir;
  }

  Future<List<BadgerFileSystemEntity>> list([bool recursive = false]) {
    return _dir.list(recursive: recursive).map((it) => it is File ? new BadgerFile(it) : new BadgerDirectory(it)).toList();
  }

  Future walk(handler(BadgerFileSystemEntity entity), [bool recursive = true]) async {
    var sub;
    sub = _dir.list(recursive: recursive).listen((i) async {
      var result = await handler(i is File ? new BadgerFile(i) : new BadgerDirectory(i));

      if (result == false) {
        sub.cancel();
      }
    });

    return sub.asFuture();
  }

  String get name => path.split(Platform.pathSeparator).last;

  Future<bool> identical(BadgerDirectory other) => FileSystemEntity.identical(_dir.path, other.path);

  BadgerFile file(String name) {
    return new BadgerFile(new File("${path}/${name}"));
  }
}

class BadgerOpenFile {
  final BadgerFile file;
  RandomAccessFile _f;

  BadgerOpenFile(this.file);

  Future<int> readByte() async {
    return await _f.readByte();
  }

  Future setPosition(int pos) async {
    await _f.setPosition(pos);
  }

  Future<int> getPosition() async {
    return await _f.position();
  }

  Future flush() async {
    await _f.flush();
  }

  Future<List<int>> read(int count) async {
    return await _f.read(count);
  }

  Future readInto(List<int> buffer, [int start, int end]) async {
    await _f.readInto(buffer, start, end);
  }

  Future writeByte(int byte) async {
    await _f.writeByte(byte);
  }

  Future write(List<int> bytes, [int start, int end]) async {
    await _f.writeFrom(bytes, start, end);
  }

  Future close() async {
    await _f.close();
  }
}

class HandlerSubscription {
  final StreamSubscription sub;

  HandlerSubscription(this.sub);

  Future cancel() async {
    await sub.cancel();
  }

  Future wait() => sub.asFuture();
  void pause([Future until]) => sub.pause(until);
  void resume() => sub.resume();
  bool get isPaused => sub.isPaused;
}

class BadgerFileSystemEvent {
  final String path;
  final String dest;
  final bool contentChanged;
  final int type;

  BadgerFileSystemEvent(this.type, this.path, {this.dest, this.contentChanged});

  BadgerFile getSourceFile() => BadgerFile.get(path);
  BadgerFile getDestinationFile() => BadgerFile.get(dest);
  BadgerDirectory getSourceDirectory() => BadgerDirectory.get(path);
  BadgerDirectory getDestinationDirectory() => BadgerDirectory.get(dest);

  bool get isDeleteEvent => type == FileSystemEvent.DELETE;
  bool get isCreateEvent => type == FileSystemEvent.CREATE;
  bool get isModifyEvent => type == FileSystemEvent.MODIFY;
  bool get isMoveEvent => type == FileSystemEvent.MOVE;

  @override
  String toString() {
    var type = "unknown";

    if (isDeleteEvent) {
      type = "delete";
    } else if (isCreateEvent) {
      type = "create";
    } else if (isModifyEvent) {
      type = "modify";
    } else if (isMoveEvent) {
      type = "move";
    }

    if (isModifyEvent) {
      return "FileSystemEvent(type: ${type}, path: ${path}, content changed: ${contentChanged})";
    } else if (isMoveEvent) {
      return "FileSystemEvent(type: ${type}, path: ${path}, destination: ${dest})";
    } else {
      return "FileSystemEvent(type: ${type}, path: ${path})";
    }
  }
}
