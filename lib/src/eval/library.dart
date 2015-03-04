part of badger.eval;

class StandardLibrary {
  static void import(Context context) {
    context.define("print", (args) => print(args.join("\n")));
    context.define("+", (args) {
      return args.reduce((a, b) {
        if (a is List && b is List) {
          return []..addAll(a)..addAll(b);
        } else {
          return a + b;
        }
      });
    });

    context.define("-", (args) {
      return args[0] - args[1];
    });

    context.define(">", (args) {
      return args[0] > args[1];
    });

    context.define("<", (args) {
      return args[0] < args[1];
    });

    context.define("<=", (args) {
      return args[0] <= args[1];
    });

    context.define(">=", (args) {
      return args[0] >= args[1];
    });

    context.define("==", (args) {
      return args[0] == args[1];
    });

    context.define("parseJson", (args) {
      var x = args.join();

      return JSON.decode(x);
    });

    context.define("encodeJson", (args) {
      args = [args[0], args.length == 2 ? args[1] : false];
      var input = args[0];
      if (args[1] == true) {
        return new JsonEncoder.withIndent("  ").convert(input);
      } else {
        return JSON.encode(input);
      }
    });

    context.define("run", (args) {
      return args[0]([]);
    });

    context.define("&&", (args) {
      return args.every((x) => BadgerUtils.asBoolean(x));
    });
  }
}
