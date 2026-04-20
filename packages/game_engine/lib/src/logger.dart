/// {@template game_engine_logger}
/// Defines the logging function used throughout game_engine.
///
/// Parameters:
/// - `level`: The log level (`'info'`, `'warning'`, `'error'`).
/// - `message`: The log message content.
/// - `error`: Optional error object (Exception/Error).
/// - `stackTrace`: Optional stack trace associated with the error.
/// {@endtemplate}
typedef GameEngineLogger = void Function(
  String level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

/// {@template silent_logger}
/// Default logger implementation that performs no action.
/// {@endtemplate}
void silentLogger(
  String level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {}
