import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Custom logger
class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      colors: true,
    ),
    level: kReleaseMode ? Level.off : Level.all,
  );

  static void debug(dynamic message) {
    _logger.d(message);
  }

  static void info(dynamic message) {
    _logger.i(message);
  }

  static void warning(dynamic message) {
    _logger.w(message);
  }

  static void error(dynamic message) {
    _logger.e(message);
  }

  static void v(dynamic message) {
    _logger.v(message);
  }
}
