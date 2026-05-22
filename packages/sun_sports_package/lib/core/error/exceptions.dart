/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// Exception thrown when network connection fails
class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred'});
}

/// Exception thrown when data parsing fails
class ParseException extends AppException {
  const ParseException({super.message = 'Failed to parse data'});
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException({
    super.message = 'Authentication failed',
    super.statusCode = 401,
  });
}

/// Exception thrown when authorization fails
class AuthorizationException extends AppException {
  const AuthorizationException({
    super.message = 'Access denied',
    super.statusCode = 403,
  });
}

/// Exception thrown when resource not found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
  });
}

/// Exception thrown when request timeout
class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timeout'});
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    super.statusCode = 422,
    this.errors,
  });
}
