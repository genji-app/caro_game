import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/services/network/fix_json_content_type_transformer.dart';
import 'package:co_caro_flame/s88/core/services/network/dio_logger_interceptor.dart';
import 'package:co_caro_flame/s88/core/services/auth/token_error_handler.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';

/// HTTP Client singleton for sportbook API calls
///
/// Features:
/// - GET/POST/PUT/DELETE methods
/// - Automatic token injection via headers
/// - 401 handling with token refresh queue
/// - Legacy send() for backward compatibility
class SbApiClient {
  // ===== SINGLETON =====
  static final SbApiClient _instance = SbApiClient._internal();
  static SbApiClient get instance => _instance;
  factory SbApiClient() => _instance;

  SbApiClient._internal() {
    _initDio();
  }

  // ===== DIO =====
  late final Dio _dio;

  // ===== TOKENS =====
  String _userToken = '';
  String _userTokenSb = '';
  String _chatToken = '';

  String get userToken => _userToken;
  String get userTokenSb => _userTokenSb;
  String get chatToken => _chatToken;

  set userToken(String value) => _userToken = value;
  set userTokenSb(String value) => _userTokenSb = value;
  set chatToken(String value) => _chatToken = value;

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        validateStatus: (status) =>
            (status != null && status >= 200 && status < 400) ||
            status == 502 ||
            status == 504,
      ),
    )..transformer = FixJsonContentTypeTransformer();

    // Add interceptors AFTER _dio is initialized
    _dio.interceptors.addAll([
      _RequestTimingInterceptor(),
      DioLoggerInterceptor(
        enableRequestLogging: true,
        enableResponseLogging: true,
        enableErrorLogging: true,
        logRequestHeaders: true,
        logResponseHeaders: false,
        maxResponseBodyLength: 10000,
      ),
      _TokenRefreshInterceptor(
        dio: _dio,
        getToken: () => _userTokenSb,
        getUserToken: () => _userToken,
      ),
    ]);
  }

  // ===== HTTP METHODS =====

  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      url,
      data: data,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      url,
      data: data,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String url, {
    dynamic data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      url,
      data: data,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
  }

  // ===== LEGACY SEND METHOD =====
  /// Backward compatible send() - same signature as SbHttpManager
  Future<dynamic> send(
    String url, {
    bool post = false,
    bool delete = false,
    String? body,
    bool contentJson = false,
    bool headerToken = false,
    bool base64 = false,
    bool json = false,
    bool authorization = false,
    String? token,
    String? lng,
    CancelToken? cancelToken,
  }) async {
    try {
      final headers = <String, String>{};
      if (lng != null) headers['lng'] = lng;
      if (headerToken) headers['token'] = _userTokenSb;
      if (authorization) headers['Authorization'] = token ?? _userTokenSb;
      if (contentJson) headers['Content-Type'] = 'application/json';

      final Response<String> response;
      if (delete) {
        response = await _dio.delete<String>(
          url,
          data: body,
          options: Options(headers: headers, responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
      } else if (post) {
        response = await _dio.post<String>(
          url,
          data: body,
          options: Options(headers: headers, responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
      } else {
        response = await _dio.get<String>(
          url,
          options: Options(headers: headers, responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
      }

      if (response.statusCode == 502 || response.statusCode == 504) {
        return json ? <String, dynamic>{} : '';
      }

      String responseText = response.data ?? '';

      if (base64 && responseText.isNotEmpty) {
        final bytes = base64Decode(responseText);
        responseText = utf8.decode(bytes);
      }

      if (json && responseText.isNotEmpty) {
        return jsonDecode(responseText);
      }

      return responseText;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw HttpException(0, 'Request timeout');
      }
      throw HttpException(
        e.response?.statusCode ?? 0,
        'Network error: ${e.message}',
      );
    }
  }

  /// Clear all tokens (on logout)
  void clearTokens() {
    _userToken = '';
    _userTokenSb = '';
    _chatToken = '';
  }
}

// ===== INTERCEPTOR: Request Timing =====
class _RequestTimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['_startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      AppLogger(tag: 'HTTP').d(
        '${response.requestOptions.method} ${response.requestOptions.uri} - ${duration}ms',
      );
    }
    handler.next(response);
  }
}

// ===== INTERCEPTOR: Token Refresh =====
class _TokenRefreshInterceptor extends QueuedInterceptor {
  _TokenRefreshInterceptor({
    required this.dio,
    required this.getToken,
    required this.getUserToken,
  });

  final Dio dio;
  final String Function() getToken;
  final String Function() getUserToken;

  static final _logger = AppLogger(tag: '_TokenRefreshInterceptor');

  bool _shouldSkipRefresh(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('command=refreshtoken')) return true;
    if (lowerUrl.endsWith('/refreshtoken')) return true;
    return false;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestUrl = err.requestOptions.uri.toString();

    if (_shouldSkipRefresh(requestUrl)) {
      return handler.next(err);
    }

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    _logger.w('Received 401, attempting token refresh...');

    try {
      // Reuse existing TokenErrorHandler
      final refreshed = await TokenErrorHandler.instance.handleTokenError();

      if (refreshed) {
        _logger.i('Token refreshed, retrying request...');

        final opts = err.requestOptions;
        if (opts.headers.containsKey('Authorization')) {
          opts.headers['Authorization'] = getUserToken();
        }
        if (opts.headers.containsKey('token')) {
          opts.headers['token'] = getToken();
        }

        final response = await dio.fetch<dynamic>(opts);
        return handler.resolve(response);
      } else {
        return handler.reject(err);
      }
    } catch (e) {
      _logger.e('Error during token refresh retry: $e');
      return handler.reject(err);
    }
  }
}

// ===== EXCEPTIONS =====
class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException($statusCode): $message';
}
