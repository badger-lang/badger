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
  }
}
