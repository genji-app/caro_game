import 'package:dio/dio.dart';

/// Type of Game API exception for better error handling and debugging
enum GameApiExceptionType {
  /// Business logic error from API (code != 0 or status != 0)
  ///
  /// **Examples:**
  /// - Invalid game code
  /// - Provider not found
  /// - Game not available
  /// - Invalid parameters
  businessError,

  /// Authentication/authorization error
  ///
  /// **Examples:**
  /// - Token expired
  /// - Invalid token
  /// - Insufficient permissions
  /// - User not authenticated
  authenticationError,

  /// Network connectivity error
  ///
  /// **Examples:**
  /// - No internet connection
  /// - DNS resolution failed
  /// - Connection refused
  /// - Host unreachable
  networkError,

  /// Request timeout (send/receive/connection)
  ///
  /// **Examples:**
  /// - Connection timeout
  /// - Send timeout
  /// - Receive timeout
  /// - Server not responding
  timeout,

  /// Server error (HTTP 5xx)
  ///
  /// **Examples:**
  /// - Internal server error (500)
  /// - Service unavailable (503)
  /// - Gateway timeout (504)
  serverError,

  /// Client error (HTTP 4xx, excluding auth)
  ///
  /// **Examples:**
  /// - Bad request (400)
  /// - Not found (404)
  /// - Method not allowed (405)
  clientError,

  /// JSON parsing/serialization error
  ///
  /// **Examples:**
  /// - Invalid JSON format
  /// - Missing required fields
  /// - Type mismatch
  parsingError,

  /// Token refresh failed
  ///
  /// **Examples:**
  /// - Refresh token expired
  /// - Refresh endpoint unavailable
  /// - Invalid refresh token
  tokenRefreshError,

  /// Unknown/unexpected error
  ///
  /// **Examples:**
  /// - Unhandled exception
  /// - Unexpected null value
  /// - Unknown error type
  unknown,
}

/// Exception thrown when Game API calls fail
///
/// This is a domain-level exception that wraps API failures.
/// It does not extend [DioException] to maintain separation of concerns
/// and allow flexibility in HTTP client implementation.
///
/// **Features:**
/// - Automatic type detection
/// - Rich error context
/// - Helper methods for common checks
/// - Better debugging with types
class GameApiException implements Exception {
  /// Type of exception for categorization and handling
  final GameApiExceptionType type;

  /// Error message
  final String message;

  /// API error code (from response body)
  ///
  /// - `0` = success (should not happen in exception)
  /// - Non-zero = error code from API
  final int? code;

  /// API status code (from response body)
  ///
  /// - `0` = success (should not happen in exception)
  /// - Non-zero = status from API
  final int? status;

  /// Additional error data from API response
  final Object? data;

  /// Original error that caused this exception
  ///
  /// Could be [DioException], [SocketException], or any other error.
  final Object? originalError;

  /// Stack trace from the original error
  final StackTrace? stackTrace;

  /// Creates a [GameApiException]
  ///
  /// The [type] is automatically detected if not provided.
  GameApiException({
    required this.message,
    GameApiExceptionType? type,
    this.code,
    this.status,
    this.data,
    this.originalError,
    this.stackTrace,
  }) : type = type ?? _detectType(code, status, message, originalError);

  /// Automatically detect exception type based on context
  static GameApiExceptionType _detectType(
    int? code,
    int? status,
    String message,
    Object? originalError,
  ) {
    // 1. Check for token refresh error (highest priority)
    if (message.toLowerCase().contains('token refresh failed') ||
        message.toLowerCase().contains('failed to refresh')) {
      return GameApiExceptionType.tokenRefreshError;
    }

    // 2. Check for authentication errors based on code/status
    if (code != null || status != null) {
      final msg = message.toLowerCase();

      // ✅ IMPORTANT: Check token-related messages FIRST before checking code 500
      // Game API returns code/status 500 for BOTH auth errors AND business errors
      // We must check the message to distinguish them

      // Auth errors: Token-related messages (even with code 500!)
      if (msg.contains('token') ||
          msg.contains('access token') ||
          msg.contains('unauthorized') ||
          msg.contains('forbidden') ||
          msg.contains('authentication') ||
          msg.contains('expired')) {
        return GameApiExceptionType.authenticationError;
      }

      // Auth errors: Standard HTTP auth codes
      if (code == 401 || status == 401 || code == 403 || status == 403) {
        return GameApiExceptionType.authenticationError;
      }

      // Business errors: code/status 1 (API-specific business logic errors)
      // Examples: "Unsupported provider Id", "Invalid game code", etc.
      if (code == 1 || status == 1) {
        return GameApiExceptionType.businessError;
      }

      // Business errors: code/status 500 WITHOUT token-related message
      // (We already checked for token messages above)
      if (code == 500 || status == 500) {
        return GameApiExceptionType.businessError;
      }

      // Server errors: code/status > 500
      if ((code != null && code > 500) || (status != null && status > 500)) {
        return GameApiExceptionType.serverError;
      }

      // Client errors: code/status 400-499 (excluding auth)
      if ((code != null && code >= 400 && code < 500) ||
          (status != null && status >= 400 && status < 500)) {
        return GameApiExceptionType.clientError;
      }
    }

    // 3. Check DioException type
    if (originalError is DioException) {
      switch (originalError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return GameApiExceptionType.timeout;

        case DioExceptionType.connectionError:
          return GameApiExceptionType.networkError;

        case DioExceptionType.badResponse:
          final statusCode = originalError.response?.statusCode;
          if (statusCode != null) {
            if (statusCode == 401 || statusCode == 403) {
              return GameApiExceptionType.authenticationError;
            }
            if (statusCode >= 500) {
              return GameApiExceptionType.serverError;
            }
            if (statusCode >= 400) {
              return GameApiExceptionType.clientError;
            }
          }
          return GameApiExceptionType.unknown;

        case DioExceptionType.cancel:
        case DioExceptionType.unknown:
        case DioExceptionType.badCertificate:
          return GameApiExceptionType.unknown;
      }
    }

    // 4. Check for parsing errors
    if (originalError is FormatException ||
        originalError is TypeError ||
        message.toLowerCase().contains('parsing') ||
        message.toLowerCase().contains('json')) {
      return GameApiExceptionType.parsingError;
    }

    // 5. Default to unknown
    return GameApiExceptionType.unknown;
  }

  /// HTTP status code from the original error (if available)
  ///
  /// Extracts status code from [DioException] if the original error is Dio-related.
  int? get httpStatusCode {
    final error = originalError;
    if (error is DioException) {
      return error.response?.statusCode;
    }
    return null;
  }

  /// Check if this exception was caused by a network error
  bool get isNetworkError => type == GameApiExceptionType.networkError;

  /// Check if this exception was caused by a timeout
  bool get isTimeout => type == GameApiExceptionType.timeout;

  /// Check if this is an authentication error
  bool get isAuthError => type == GameApiExceptionType.authenticationError;

  /// Check if this is a business logic error
  bool get isBusinessError => type == GameApiExceptionType.businessError;

  /// Check if this is a server error
  bool get isServerError => type == GameApiExceptionType.serverError;

  /// Check if this is a client error
  bool get isClientError => type == GameApiExceptionType.clientError;

  /// Check if this is a parsing error
  bool get isParsingError => type == GameApiExceptionType.parsingError;

  /// Check if this is a token refresh error
  bool get isTokenRefreshError => type == GameApiExceptionType.tokenRefreshError;

  /// Check if this error is retryable
  ///
  /// Network errors and timeouts are typically retryable.
  /// Auth errors and business errors are not.
  bool get isRetryable =>
      type == GameApiExceptionType.networkError ||
      type == GameApiExceptionType.timeout ||
      type == GameApiExceptionType.serverError;

  @override
  String toString() {
    final buffer = StringBuffer('GameApiException[${type.name}]: ');

    buffer.write(message);

    if (code != null || status != null) {
      buffer.write(' (code: $code, status: $status)');
    }

    if (httpStatusCode != null) {
      buffer.write(' [HTTP $httpStatusCode]');
    }

    return buffer.toString();
  }

  /// Get a user-friendly error message based on exception type
  String get userFriendlyMessage {
    switch (type) {
      case GameApiExceptionType.networkError:
        return 'No internet connection. Please check your network.';
      case GameApiExceptionType.timeout:
        return 'Request timed out. Please try again.';
      case GameApiExceptionType.authenticationError:
        return 'Authentication failed. Please login again.';
      case GameApiExceptionType.serverError:
        return 'Server error. Please try again later.';
      case GameApiExceptionType.businessError:
        return message; // Return actual API message for business errors
      case GameApiExceptionType.tokenRefreshError:
        return 'Session expired. Please login again.';
      case GameApiExceptionType.clientError:
      case GameApiExceptionType.parsingError:
      case GameApiExceptionType.unknown:
        return 'An error occurred. Please try again.';
    }
  }
}
