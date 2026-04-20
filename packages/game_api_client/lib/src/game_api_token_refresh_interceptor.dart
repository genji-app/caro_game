import 'package:dio/dio.dart';

import 'game_api_exception.dart';

/// Signature for token refresh callback
///
/// This function should handle refreshing the access token and return the new token.
/// Returns `null` if refresh fails.
typedef TokenRefreshCallback = Future<String?> Function();

/// Interceptor to handle Game API token refresh
///
/// This interceptor detects when the access token is invalid or expired
/// (HTTP 200 with code/status 500 and specific error message) and automatically
/// attempts to refresh the token before retrying the original request.
///
/// **Features:**
/// - Automatic token refresh on expiration
/// - Request queuing during refresh
/// - Infinite loop prevention
/// - Memory efficient (reuses Dio instance)
///
/// **Usage:**
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   GameApiTokenRefreshInterceptor(
///     dio: dio,  // Pass original Dio instance
///     onRefreshToken: () async {
///       final newToken = await authService.refreshToken();
///       return newToken;
///     },
///   ),
/// );
/// ```
class GameApiTokenRefreshInterceptor extends Interceptor {
  /// Callback to refresh the access token
  final TokenRefreshCallback onRefreshToken;

  /// Original Dio instance for retrying requests
  final Dio _dio;

  /// Whether a token refresh is currently in progress
  bool _isRefreshing = false;

  /// Queue of pending requests waiting for token refresh
  final List<_RequestRetry> _requestQueue = [];

  /// Key to mark requests as retry to prevent infinite loop
  static const String _retryKey = '_token_refresh_retry';

  GameApiTokenRefreshInterceptor({
    required this.onRefreshToken,
    required Dio dio,
  }) : _dio = dio;

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
    final code = (json['code'] ?? 0) as int;
    final status = (json['status'] ?? 0) as int;
    final message = json['message']?.toString() ?? '';

    // Check if this is a token expiration error
    // Case 1: HTTP 200 but code/status = 500 with specific message
    // Case 2: HTTP 200 but code/status = 1 with Vietnamese error message
    final isTokenExpired = _isTokenExpirationError(code, status, message);

    if (isTokenExpired) {
      // ✅ Prevent infinite loop - don't retry if this is already a retry
      if (response.requestOptions.extra[_retryKey] == true) {
        return handler.next(response);
      }

      // Handle token refresh and retry
      _handleTokenRefresh(response, handler);
      return;
    }

    // Not a token error, continue normally
    handler.next(response);
  }

  /// Checks if the response indicates a token expiration error
  ///
  /// Supports two error formats:
  /// 1. code/status = 500 with English message "access token is invalid or expired"
  /// 2. code/status = 1 with Vietnamese message "access_token đã hết hạn hoặc không hợp lệ"
  bool _isTokenExpirationError(int code, int status, String message) {
    final messageLower = message.toLowerCase();

    // Case 1: code/status = 500 with English error message
    if ((code == 500 || status == 500) &&
        messageLower.contains('access token is invalid or expired')) {
      return true;
    }

    // Case 2: code/status = 1 with Vietnamese error message
    if ((code == 1 || status == 1) &&
        messageLower.contains('access_token đã hết hạn hoặc không hợp lệ')) {
      return true;
    }

    return false;
  }

  /// Handles token refresh and request retry logic
  Future<void> _handleTokenRefresh(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // If already refreshing, queue this request
    if (_isRefreshing) {
      _requestQueue.add(_RequestRetry(response, handler));
      return;
    }

    // Start refresh process
    _isRefreshing = true;

    try {
      // Attempt to refresh token
      final newToken = await onRefreshToken();

      if (newToken == null) {
        // Refresh failed - create failure response
        final gameException = GameApiException(
          message: 'Failed to refresh access token',
          code: 401,
          status: 401,
          data: response.data,
          originalError: response,
        );

        final dioError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: gameException,
          message: gameException.message,
        );

        _rejectAllPendingRequests(dioError);
        handler.reject(dioError);
        return;
      }

      // Token refreshed successfully - retry original request
      final retryResponse = await _retryRequest(
        response.requestOptions,
        newToken,
      );
      handler.resolve(retryResponse);

      // Retry all queued requests
      await _retryAllPendingRequests(newToken);
    } catch (e) {
      // Refresh failed with exception
      final gameException = GameApiException(
        message: 'Token refresh failed: $e',
        originalError: e,
      );

      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.unknown,
        error: gameException,
        message: gameException.message,
      );

      _rejectAllPendingRequests(error);
      handler.reject(error);
    } finally {
      _isRefreshing = false;
      _requestQueue.clear();
    }
  }

  /// Retries a request with the new token using original Dio instance
  ///
  /// ✅ Uses original Dio to reuse connection pool
  /// ✅ Marks request as retry to prevent infinite loop
  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    // Clone request options with new token and retry marker
    final newOptions = requestOptions.copyWith(
      headers: {...requestOptions.headers, 'Authorization': newToken},
      extra: {
        ...requestOptions.extra,
        _retryKey: true, // ✅ Mark as retry to prevent loop
      },
    );

    // ✅ Use original Dio instance (reuses connection pool)
    return _dio.fetch<dynamic>(newOptions);
  }

  /// Retries all pending requests with the new token
  Future<void> _retryAllPendingRequests(String newToken) async {
    for (final retry in _requestQueue) {
      try {
        final retryResponse = await _retryRequest(
          retry.requestOptions,
          newToken,
        );
        retry.handler.resolve(retryResponse);
      } catch (e) {
        final gameException = GameApiException(
          message: 'Retry failed: $e',
          originalError: e,
        );

        retry.handler.reject(
          DioException(
            requestOptions: retry.requestOptions,
            type: DioExceptionType.unknown,
            error: gameException,
            message: gameException.message,
          ),
        );
      }
    }
  }

  /// Rejects all pending requests with the given error
  void _rejectAllPendingRequests(DioException error) {
    for (final retry in _requestQueue) {
      retry.handler.reject(error);
    }
  }
}

/// Internal class to hold pending request retry information
class _RequestRetry {
  final Response<dynamic> response;
  final ResponseInterceptorHandler handler;

  _RequestRetry(this.response, this.handler);

  RequestOptions get requestOptions => response.requestOptions;
}
