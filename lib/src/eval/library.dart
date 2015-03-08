part of badger.eval;

class CoreLibrary {
  static void import(Context context) {
    context.proxy("print", print);
    context.proxy("currentContext", () => Context.current);
    context.proxy("newContext", () => new Context());
    context.proxy("run", (func) => func([]));
    context.proxy("NativeHelper", NativeHelper);
    context.proxy("JSON", BadgerJSON);
    context.proxy("make", (type, [args = const []]) {
      return reflectClass(type).newInstance(MirrorSystem.getSymbol(""), args).reflectee;
    });
  }
}

class BadgerJSON {
  static dynamic parse(String input) {
    return JSON.decode(input);
  }

  static String encode(input, [bool pretty = false]) {
    return pretty ? new JsonEncoder.withIndent("  ").convert(input) : JSON.encode(input);
  }
}

class NativeHelper {
  static LibraryMirror getLibrary(String name) {
    var symbol = new Symbol(name);

    return currentMirrorSystem().findLibrary(symbol);
  }
}

enum TestResultType {
  SUCCESS, FAILURE
}

class TestResult {
  final String name;
  final TestResultType type;
  final String message;
  final int duration;

  TestResult(this.name, this.type, this.duration, [this.message]);
}

class TestingLibrary {
  static void _defaultResultHandler(TestResult result) {
    var status = result.type == TestResultType.SUCCESS ? "Success" : "Failure";
    print("${result.name}: ${status}");
    if (result.message != null && result.message.isNotEmpty) {
      print(result.message);
    }
  }

  static void import(Context context, {
    void handleTestStarted(String name),
    void handleTestResult(TestResult result): _defaultResultHandler,
    void handleTestsBegin(),
    void handleTestsEnd()
  }) {
    context.define("test", (name, func) {
      if (!Context.current.meta.containsKey("__tests__")) {
        Context.current.meta["__tests__"] = [];
      }

      var tests = Context.current.meta["__tests__"];

      tests.add([name, func]);
    });

    context.define("assertEqual", (a, b) {
      var result = a == b;

      if (!result) {
        throw new Exception("Test failed: ${a} != ${b}");
      }
    });

    context.alias("assertEqual", "testEqual");

    context.define("assert", (a) {
      if (!BadgerUtils.asBoolean(a)) {
        throw new Exception("Assertion Failed");
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

    context.define("runTests", () async {
      Context.current.setMetadata("__tests__", true);

      if (!Context.current.hasMetadata("__tests__")) {
        return false;
      } else {
        var tests = Context.current.getMetadata("__tests__");

        if (handleTestsBegin != null) {
          handleTestsBegin();
        }

        for (var test in tests) {
          var name = test[0];
          var func = test[1];

          if (handleTestStarted != null) {
            handleTestStarted(name);
          }

          var stopwatch = new Stopwatch();
          try {
            stopwatch.start();
            await func([]);
          } catch (e) {
            stopwatch.stop();
            handleTestResult(new TestResult(name, TestResultType.FAILURE, stopwatch.elapsedMilliseconds, e.toString()));
            continue;
          }
          stopwatch.stop();

          handleTestResult(new TestResult(name, TestResultType.SUCCESS, stopwatch.elapsedMilliseconds));
        }

        if (handleTestsEnd != null) {
          handleTestsEnd();
        }

        return true;
      }
    });
  }
}
