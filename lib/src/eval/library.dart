part of badger.eval;

const _PRINT = print;

class CoreLibrary {
  /**
   * Imports the Core Library into the specified [context].
   */
  static void import(Context context) {
    context.proxy("print", print);
    context.proxy("getCurrentContext", getCurrentContext);
    context.alias("getCurrentContext", "currentContext");
    context.proxy("newContext", newContext);
    context.proxy("run", run);
    context.proxy("JSON", JSON);
    context.proxy("make", make);
    context.proxy("sleep", sleep);
    context.proxy("async", async);
    context.proxy("waitForLoop", waitForLoop);
    context.proxy("later", later);
    context.proxy("void", VOID);
    context.proxy("eval", eval);
    context.proxy("EventBus", EventBus);
  }

  static dynamic eval(String content) async {
    var parser = new BadgerParser();
    var program = parser.parse(content).value;
    var env = new ImportMapEnvironment({});
    var evaluator = new Evaluator(program, env);
    return await evaluator.evaluate(Context.current);
  }

  /**
   * Gets the Current Context.
   */
  static Context getCurrentContext() => Context.current;

  /**
   * Gets the Current Context.
   */
  static Context currentContext() => getCurrentContext();

  /**
   * Creates a new empty context.
   */
  static Context newContext() => new Context();

  /**
   * Prints [line] to the console.
   */
  static void print(line) {
    _PRINT(line);
  }

  /**
   * Creates a new instance of the specified [type] with the specified [args].
   */
  static dynamic make(Type type, [List<dynamic> args = const []]) {
    return reflectClass(type).newInstance(MirrorSystem.getSymbol(""), args).reflectee;
  }

  /**
   * Runs the given [function] later given the milliseconds specified by [time].
   */
  static void later(function(), int time) {
    new Future.delayed(new Duration(milliseconds: time)).then((_) {
      function();
    });
  }

  /**
   * Execute the given [function]
   */
  static dynamic run(function()) {
    return function();
  }

  /**
   * Badger JSON APIs
   */
  static final BadgerJSON JSON = new BadgerJSON();

  /**
   * Waits x amount of milliseconds specified by [time] to resume execution.
   */
  static Future sleep(int time) async {
    await new Future.delayed(new Duration(milliseconds: time));
  }

  /**
   * Schedules the given [function] to run in the next event loop.
   *
   * If [microtask] is specified, it will run in the microtask queue instead.
   */
  static void async(function(), [bool microtask = false]) {
    if (microtask) {
      scheduleMicrotask(function);
    } else {
      Timer.run(function);
    }
  }

  /**
   * Waits for the next event loop iteration.
   *
   * This is a semi-asynchronous operation.
   */
  static Future waitForLoop() async {
    var completer = new Completer();
    Timer.run(() {
      completer.complete();
    });
    return completer.future;
  }
}

class BadgerJSON {
  dynamic parse(String input) {
    return JSON.decode(input);
  }

  String encode(input, [bool pretty = false]) {
    return pretty ? new JsonEncoder.withIndent("  ").convert(input) : JSON.encode(input);
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

class EventBus {
  static EventBus create() {
    return new EventBus();
  }

  final StreamController<Event> _controller = new StreamController<Event>.broadcast();

  void post(String name, [dynamic value]) {
    _controller.add(new Event(name, value));
  }

  void emit(String name, [dynamic value]) {
    _controller.add(new Event(name, value));
  }

  HandlerSubscription on(String name, handler(object)) {
    return new HandlerSubscription(_controller.stream.where((it) => it.name == name).listen(handler));
  }

  HandlerSubscription onEvent(handler(event)) {
    return new HandlerSubscription(_controller.stream.listen(handler));
  }

  Future<dynamic> nextEvent(String name, [int timeout, onTimeout()]) async {
    var f = _controller.stream.where((it) => it.name == name).map((it) => it.value).first;

    if (timeout != null) {
      f = f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    }

    return f;
  }

  Future<Event> wait([int timeout, onTimeout()]) async {
    var f = _controller.stream.first;

    if (timeout != null) {
      f = f.timeout(new Duration(milliseconds: timeout), onTimeout: onTimeout);
    }

    return f;
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

class Event {
  final String name;
  final dynamic value;

  Event(this.name, this.value);
}

class EventLoop {
}
