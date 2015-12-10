library badger.common;

import "dart:async";
import "dart:collection";
import "dart:convert";
import "dart:math";

import "package:badger/parser.dart";
import "package:badger/compiler.dart";
import "package:badger/eval.dart";

import "package:logging/logging.dart";

part "src/common/environment.dart";
part "src/common/collection.dart";
part "src/common/utils.dart";

Logger _logger;
Logger get logger {
  if (_logger == null) {
    hierarchicalLoggingEnabled = true;
    _logger = new Logger("Badger");
  }
  return _logger;
}

bool _hasEnabledConsoleLogging = false;

void setupConsoleLogging([String level]) {
  updateLogLevel(level);

  if (_hasEnabledConsoleLogging) {
    return;
  }

  logger.onRecord.listen((record) {
    print("[${record.loggerName}][${record.level.name}] ${record.message}");
    if (record.error != null) {
      print(record.error);
    }

    if (record.stackTrace != null) {
      print(record.stackTrace);
    }
  });

  _hasEnabledConsoleLogging = true;
}

/// Updates the log level to the level specified [name].
void updateLogLevel(String name) {
  if (name == null) {
    return;
  }

  name = name.trim().toUpperCase();

  if (name == "DEBUG") {
    name = "ALL";
  }

  Map<String, Level> levels = {};
  for (var l in Level.LEVELS) {
    levels[l.name] = l;
  }

  var l = levels[name];

  if (l != null) {
    logger.level = l;
  }
}
