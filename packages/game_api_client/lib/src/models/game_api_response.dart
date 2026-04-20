import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_api_response.freezed.dart';

/// Generic response wrapper for all Game API endpoints
///
/// Uses union type pattern to distinguish between success and failure responses.
/// All Game API responses follow the same structure:
/// ```json
/// {
///   "message": "Success",
///   "code": 0,
///   "status": 0,
///   "data": <T>  // Type varies by endpoint
/// }
/// ```
///
/// **Success**: `code == 0 && status == 0`
/// **Failure**: `code != 0 || status != 0`
///
/// ## Usage
///
/// ```dart
/// final response = await client.getGames();
///
/// response.map(
///   success: (s) {
///     // Handle success - type-safe access to data
///     for (final provider in s.data) {
///       print(provider.providerName);
///     }
///   },
///   failure: (f) {
///     // Handle failure - access error details
///     print('Error ${f.code}: ${f.message}');
///   },
/// );
///
/// // Or use extensions
/// if (response.isSuccess) {
///   final data = response.dataOrNull;
/// }
/// ```
@Freezed(genericArgumentFactories: true)
sealed class GameApiResponse<T> with _$GameApiResponse<T> {
  /// Success response with data
  ///
  /// Returned when `code == 0 && status == 0`
  const factory GameApiResponse.success({
    required String message,
    required int code,
    required int status,
    required T data,
  }) = GameApiSuccessResponse<T>;

  /// Failure/error response
  ///
  /// Returned when `code != 0 || status != 0`
  const factory GameApiResponse.failure({
    required String message,
    required int code,
    required int status,
    Object? data,
  }) = GameApiFailureResponse<T>;

  /// Parse JSON response and determine success/failure
  ///
  /// Automatically routes to success or failure variant based on code/status.
  factory GameApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final code = json['code'] as int? ?? 0;
    final status = json['status'] as int? ?? 0;
    final message = json['message']?.toString() ?? '';
    final rawData = json['data'];

    // Success: code == 0 && status == 0
    if (code == 0 && status == 0) {
      return GameApiSuccessResponse<T>(
        message: message,
        code: code,
        status: status,
        data: fromJsonT(rawData),
      );
    }

    // Failure: code != 0 || status != 0
    return GameApiFailureResponse<T>(
      message: message,
      code: code,
      status: status,
      data: rawData,
    );
  }
}

/// Extension methods for GameApiResponse
extension GameApiResponseX<T> on GameApiResponse<T> {
  /// Check if response is successful
  bool get isSuccess => map(success: (_) => true, failure: (_) => false);

  /// Check if response is a failure
  bool get isFailure => !isSuccess;

  /// Get status code (works for both success and failure)
  int get statusCode => map(success: (s) => s.status, failure: (f) => f.status);

  /// Get error code (works for both success and failure)
  int get errorCode => map(success: (s) => s.code, failure: (f) => f.code);

  /// Get message (works for both success and failure)
  String get responseMessage => map(success: (s) => s.message, failure: (f) => f.message);

  /// Get data if success, null if failure
  T? get dataOrNull => map(success: (s) => s.data, failure: (_) => null);
}
