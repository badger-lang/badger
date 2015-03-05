part of badger.eval;

class StandardLibrary {
  static void import(Context context) {
    context.define("print", (args) => print(args.join("\n")));
    context.define("withContext", (args) {
      var func = args[0];
      var ctx = args[1];

      return ctx.run(() {
        return func([]);
      });
    });

    context.define("currentContext", (args) {
      return Context.current;
    });

    context.define("newContext", (args) {
      return new Context();
    });

    context.define("keys", (args) {
      var x = args[0];

      if (x is Map) {
        return x.keys.toList();
      } else if (x is List) {
        return new List<int>.generate(x.length, (i) => i);
      } else if (x is Context) {
        return x.variables.keys.toList();
      }
    });

    context.define("parseJSON", (args) {
      var x = args.join();

      return JSON.decode(x);
    });

    context.define("createPeriodicTimer", (args) async {
      var timer = new Timer.periodic(new Duration(milliseconds: args[0]), (t) {
        args[1]([]);
      });

      return timer;
    });

    context.define("async", (args) async {
      Timer.run(() {
        args[0]([]);
      });
    });

    context.define("chars", (args) {
      return args[0].split("");
    });

    context.define("firstWhere", (args) {
      return args[0].firstWhere((it) => args[1]([it]), orElse: () => null);
    });

    context.define("join", (args) {
      return args[0].join(args[1]);
    });

    context.define("substring", (args) {
      return args[0].substring(args[1], args[2]);
    });

    context.define("split", (args) {
      return args[0].split(args[1]);
    });

    context.define("trim", (args) {
      return args[0].trim();
    });

    context.define("lowercase", (args) {
      return args[0].toLowerCase();
    });

    context.define("map", (args) {
      return args[0].map((it) => args[1]([it])).toList();
    });

    context.define("cancelTimer", (args) async {
      return args[0].cancel();
    });

    context.define("isTimerActive", (args) {
      return args[0].isActive;
    });

    context.define("createTimer", (args) {
      var timer = new Timer(new Duration(milliseconds: args[0]), () {
        args[1]([]);
      });

      return timer;
    });

    context.define("encodeJSON", (args) {
      args = [args[0], args.length == 2 ? args[1] : false];
      var input = args[0];
      if (args[1] == true) {
        return new JsonEncoder.withIndent("  ").convert(input);
      } else {
        return JSON.encode(input);
      }
    });

    context.define("run", (args) {
      return args[0](args.skip(1).toList());
    });
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
    context.define("test", (args) {
      var name = args[0];
      var func = args[1];

      if (!Context.current.meta.containsKey("__tests__")) {
        Context.current.meta["__tests__"] = [];
      }

      var tests = Context.current.meta["__tests__"];

      tests.add([name, func]);
    });

    context.define("testEqual", (args) {
      var a = args[0];
      var b = args[1];

      var result = a == b;

      if (!result) {
        throw new Exception("Test failed: ${a} != ${b}");
      }
    });

    context.define("shouldThrow", (args) async {
      var func = args[0];
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

    context.define("runTests", (args) async {
      var prefix = args.length == 0 ? null : args[0];

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
