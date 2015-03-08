part of badger.io;

abstract class IOEnvironment extends BaseEnvironment {
}

class FileEnvironment extends IOEnvironment {
  final File file;

  FileEnvironment(this.file);

  @override
  Future import(String location, Evaluator evaluator, Context context) async {
    try {
      var uri = Uri.parse(location);

      if (uri.scheme == "badger") {
        var name = uri.path;

        if (name == "core") {
          CoreLibrary.import(context);
        } else if (name == "io") {
          IOLibrary.import(context);
        } else if (name == "test") {
          TestingLibrary.import(context);
        } else {
          throw new Exception("Unknown Standard Library: ${name}");
        }
        return;
      } else if (uri.scheme == "file") {
        var file = new File(uri.toFilePath());
        var program = await parse(await file.readAsString());
        await evaluator.evaluateProgram(program, context);
        return;
      } else if (uri.scheme == "http" || uri.scheme == "https") {
        var client = new HttpClient();
        var request = await client.getUrl(uri);
        var response = await request.close();

        if (response.statusCode != 200) {
          throw new Exception("Failed to fetch import over HTTP: Status Code: ${response.statusCode}");
        }

        var content = await response.transform(UTF8.decoder).join();

        var program = await parse(content);
        await evaluator.evaluateProgram(program, context);
        return;
      } else {
        throw new Exception("Unsupported Import URI Scheme: ${uri.scheme}");
      }
    } on FormatException catch (e) {
    }

    var dir = file.parent;

    Program program;

    if (pathlib.isRelative(location)) {
      var f = new File("${dir.path}/${location}");

      if (!(await f.exists())) {
        throw new Exception("Tried to import file ${f.path}, but it does not exist.");
      }

      program = await parse(await f.readAsString());
    } else {
      var f = new File(location);

      if (!(await f.exists())) {
        throw new Exception("Tried to import file ${f.path}, but it does not exist.");
      }

      program = await parse(await f.readAsString());
    }

    await evaluator.evaluateProgram(program, context);
  }

  @override
  Future<String> readScriptContent() async {
    if (_content != null) {
      return _content;
    } else {
      return _content = await file.readAsString();
    }
  }

  String _content;
}
