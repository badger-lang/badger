part of badger.io;

class BadgerProcess {
  static Future<ProcessResult> run(String executable, List<String> args, [Map<String, String> env, String cwd]) {
    return Process.run(executable, args, environment: env, workingDirectory: cwd);
  }

  static Future<Process> spawn(String executable, List<String> args, [Map<String, String> env, String cwd]) {
    return Process.start(executable, args, environment: env, workingDirectory: cwd);
  }
}
