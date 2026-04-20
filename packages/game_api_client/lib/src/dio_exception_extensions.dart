import 'package:dio/dio.dart';

import 'game_api_exception.dart';

/// Extension methods for DioException to extract GameApiException
///
/// Provides convenient methods to work with wrapped GameApiException.
extension DioExceptionGameApiX on DioException {
  /// Check if this DioException wraps a GameApiException
  bool get isGameApiException => error is GameApiException;

  /// Get the wrapped GameApiException if available
  GameApiException? get gameApiException =>
      error is GameApiException ? error as GameApiException : null;

  /// Get the wrapped GameApiException or throw if not available
  GameApiException get gameApiExceptionOrThrow {
    final ex = gameApiException;
    if (ex == null) {
      throw StateError('DioException does not wrap a GameApiException');
    }
    return ex;
  }
}
