part of badger.io;

class IOUtils {
  static List<FileSystemEntity> _tmps = [];

  static Future<String> readStdin() async {
    var buff = new StringBuffer();
    stdin.lineMode = false;
    await for (var data in stdin) {
      buff.write(UTF8.decode(data));
    }
    stdin.lineMode = true;
    return buff.toString();
  }

  static Future<int> inheritIO(Process process) async {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    stdin.pipe(process.stdin);

    return await process.exitCode;
  }

  static Future<File> createTempFile([String prefix]) async {
    var dir = await Directory.systemTemp.createTemp(prefix);
    var file = new File("${dir.path}/tmpfile");
    _tmps.add(dir);
    return file;
  }

  static Future deleteTemporaryFiles() async {
    for (var e in _tmps) {
      await e.delete(recursive: true);
    }
    _tmps.clear();
  }
}
