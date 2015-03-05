part of badger.eval;

class StandardLibrary {
  static void import(Context context) {
    context.proxy("print", print);
    context.proxy("currentContext", () => Context.current);
    context.proxy("newContext", () => new Context());
    context.proxy("run", (func) => func([]));
  }
}

class NativeHelper {
  static LibraryMirror getLibrary(String name) {
    var symbol = new Symbol(name);

    return currentMirrorSystem().findLibrary(symbol);
  }
}

class IOLibrary {
  static void import(Context context) {
    context.define("getUrl", (args) async {
      var url = args[0];
      var client = new HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();
      var text = await response.transform(UTF8.decoder).join();

      client.close();

      return text;
    });
  }
}

class TestingLibrary {
  static void import(Context context) {
    context.define("test", (name, func) {
      if (!Context.current.meta.containsKey("__tests__")) {
        Context.current.meta["__tests__"] = [];
      }

      var tests = Context.current.meta["__tests__"];

      tests.add([name, func]);
    });

    context.define("testEqual", (a, b) {
      var result = a == b;

      if (!result) {
        throw new Exception("Test failed: ${a} != ${b}");
      }
    });

    context.define("shouldThrow", (func) async {
      var threw = false;

      try {
        await func([]);
      } catch (e) {
        threw = true;
      }

      if (!threw) {
        throw new Exception("Function did not throw an exception.");
      }
    });

    context.define("runTests", ([prefix]) async {
      Context.current.meta["tests.ran"] = true;

      if (!Context.current.meta.containsKey("__tests__")) {
        print("${prefix != null ? '[${prefix}] ' : ''}No Tests Defined");
      } else {
        var tests = Context.current.meta["__tests__"];

        for (var test in tests) {
          var name = test[0];
          var func = test[1];

          try {
            await func([]);
          } catch (e) {
            print("${prefix != null ? '[${prefix}] ' : ''}${name}: Failure");
            print(e.toString());
            exit(1);
          }

          print("${prefix != null ? '[${prefix}] ' : ''}${name}: Success");
        }
      }
    });
  }
}
