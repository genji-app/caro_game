import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App Logger Wrapper
///
/// Automatically disables logging in release mode for better performance.
/// In debug mode, shows full logs with colors and stack traces.
class AppLogger {
  final Logger _logger;
  final String? tag;

  AppLogger({this.tag})
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: kDebugMode ? 2 : 0, // Stack trace only in debug
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: kDebugMode, // Timestamp only in debug
        ),
        level: kDebugMode
            ? Level.debug
            : Level.warning, // Less verbose in release
      );

  /// Verbose log (only in debug)
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.t(_formatMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  /// Debug log (only in debug)
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(_formatMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  /// Info log
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Warning log
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Error log
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Fatal log
  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  String _formatMessage(dynamic message) {
    if (tag != null) {
      return '[$tag] $message';
    }
    return message.toString();
  }
}

/// Global logger instances
class AppLoggers {
  static final websocket = AppLogger(tag: 'WebSocket');
  static final api = AppLogger(tag: 'API');
  static final auth = AppLogger(tag: 'Auth');
  static final ui = AppLogger(tag: 'UI');
  static final general = AppLogger();
}
