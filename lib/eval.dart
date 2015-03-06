library badger.eval;

import "dart:async";
import "dart:io";
import "dart:convert";
import "dart:mirrors";
import "package:badger/parser.dart";
import "package:badger/compiler.dart";

import "package:path/path.dart" as pathlib;

part "src/eval/evaluator.dart";
part "src/eval/context.dart";
part "src/eval/library.dart";
part "src/eval/utils.dart";
