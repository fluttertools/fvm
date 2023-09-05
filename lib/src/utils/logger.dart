import 'dart:async';
import 'dart:convert';

import 'package:cli_util/cli_logging.dart' as log;
import 'package:io/ansi.dart';

/// Sets default logger mode
log.Logger logger = log.Logger.standard();

/// Logger for FVM
class Logger {
  Logger._();

  /// Sets logger to verbose
  static void setVerbose() {
    logger = log.Logger.verbose();
  }

  /// Prints sucess message
  static void fine(String message) {
    print(cyan.wrap(message));
    consoleController.fine.add(utf8.encode(message));
  }

  /// Prints [message] with warning formatting
  static void warning(String message) {
    print(yellow.wrap(message));
    consoleController.warning.add(utf8.encode(message));
  }

  /// Prints [message] with info formatting
  static void info(String message) {
    print(message);
    consoleController.info.add(utf8.encode(message));
  }

  /// Prints [message] with error formatting
  static void error(String message) {
    print(red.wrap(message));
    consoleController.error.add(utf8.encode(message));
  }

  /// Prints a line space
  static void spacer() {
    print('');
    consoleController.info.add(utf8.encode(''));
  }

  /// Prints a divider
  static void divider() {
    const line = '___________________________________________________\n';

    print(line);
    consoleController.info.add(utf8.encode(line));
  }
}

/// Console controller instance
final consoleController = ConsoleController();

/// Console Controller
class ConsoleController {
  /// stdout stream
  final stdout = StreamController<List<int>>();

  /// sderr stream
  final stderr = StreamController<List<int>>();

  /// warning stream
  final warning = StreamController<List<int>>();

  /// fine stream
  final fine = StreamController<List<int>>();

  /// info streamm
  final info = StreamController<List<int>>();

  /// error stream
  final error = StreamController<List<int>>();
}
