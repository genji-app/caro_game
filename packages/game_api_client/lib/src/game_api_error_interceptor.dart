import 'package:dio/dio.dart';

import 'game_api_exception.dart';
import 'models/game_api_response.dart';

/// Interceptor to handle Game API business errors
///
/// This interceptor checks for business errors in successful HTTP responses
/// where the Game API returns HTTP 200 but includes error codes in the response body.
///
/// All Game API responses follow the pattern:
/// - code: 0 = success, non-zero = business error
/// - status: 0 = success, non-zero = business error
class GameApiErrorInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // Only process JSON responses
    if (response.data is! Map<String, dynamic>) {
      return handler.next(response);
    }

    final json = response.data as Map<String, dynamic>;
    final code = json['code'] ?? 0;
    final status = json['status'] ?? 0;

    // Check for business errors (code != 0 or status != 0)
    if (code != 0 || status != 0) {
      // Create GameApiException with code/status directly
      final gameException = GameApiException(
        message: json['message']?.toString() ?? 'Business error',
        code: code as int,
        status: status as int,
        data: json['data'],
        originalError: response,
      );

      // Wrap in DioException for interceptor compatibility
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: gameException,
          message: gameException.message,
        ),
      );
    }

    // Success - continue with the response
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If error already contains GameApiException, pass it through
    if (err.error is GameApiException) {
      return handler.next(err);
    }

    // Try to parse error response body safely without try-catch
    GameApiFailureResponse<dynamic>? errorBody;
    if (err.response?.data is Map<String, dynamic>) {
      errorBody = _safeParseFailureResponse(
        err.response!.data as Map<String, dynamic>,
      );
    }

    final gameException = GameApiException(
      message: err.message ?? 'Unexpected error',
      code: errorBody?.code,
      status: errorBody?.status,
      data: errorBody?.data,
      originalError: err,
      stackTrace: err.stackTrace,
    );

    // Wrap in DioException for consistency
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: gameException,
        message: gameException.message,
      ),
    );
  }

  /// Safely parse failure response without using try-catch
  ///
  /// Validates each field manually to avoid exceptions during parsing.
  GameApiFailureResponse<dynamic>? _safeParseFailureResponse(
    Map<String, dynamic> json,
  ) {
    // Extract and validate fields manually
    final message = json['message'] is String ? json['message'] as String : 'Unknown error';

    final code = json['code'] is int
        ? json['code'] as int
        : (json['code'] is String ? int.tryParse(json['code'] as String) ?? -1 : -1);

    final status = json['status'] is int
        ? json['status'] as int
        : (json['status'] is String ? int.tryParse(json['status'] as String) ?? -1 : -1);

    final data = json['data'];

    // Create GameApiFailureResponse with validated fields
    return GameApiFailureResponse(
      message: message,
      code: code,
      status: status,
      data: data,
    );
  }
}
