// ignore_for_file: unused_element
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

/// Dio Interceptor for logging HTTP requests and responses.
///
/// Uses [LoggerMixin] for consistent logging format.
/// Only logs in debug mode to avoid performance overhead in production.
///
/// Usage:
/// ```dart
/// dio.interceptors.add(DioLoggerInterceptor());
/// ```
class DioLoggerInterceptor extends Interceptor with LoggerMixin {
  DioLoggerInterceptor({
    this.enableRequestLogging = true,
    this.enableResponseLogging = true,
    this.enableErrorLogging = true,
    this.logRequestHeaders = false,
    this.logResponseHeaders = false,
    this.maxResponseBodyLength = 1000,
  });

  /// Whether to log request details
  final bool enableRequestLogging;

  /// Whether to log response details
  final bool enableResponseLogging;

  /// Whether to log error details
  final bool enableErrorLogging;

  /// Whether to log request headers
  final bool logRequestHeaders;

  /// Whether to log response headers
  final bool logResponseHeaders;

  /// Maximum length of response body to log (to avoid huge logs)
  final int maxResponseBodyLength;

  @override
  String get logTag => 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode && enableRequestLogging) {
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode && enableResponseLogging) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && enableErrorLogging) {
      _logDioError(err);
    }
    super.onError(err, handler);
  }

  // ============================================================
  // Request Logging
  // ============================================================

  void _logRequest(RequestOptions options) {
    // final buffer = StringBuffer();
    // buffer.writeln('');
    // buffer.writeln(
    //   '┌──────────────────────────────────────────────────────────────',
    // );
    // buffer.writeln('│ 📤 REQUEST');
    // buffer.writeln(
    //   '├──────────────────────────────────────────────────────────────',
    // );
    // buffer.writeln('│ ${options.method.toUpperCase()} ${options.uri}');
    // buffer.writeln('│');

    // // Headers
    // if (logRequestHeaders && options.headers.isNotEmpty) {
    //   buffer.writeln('│ 📋 Headers:');
    //   options.headers.forEach((key, value) {
    //     // Mask sensitive headers
    //     final displayValue = _maskSensitiveHeader(key, value.toString());
    //     buffer.writeln('│   $key: $displayValue');
    //   });
    //   buffer.writeln('│');
    // }

    // // Query Parameters
    // if (options.queryParameters.isNotEmpty) {
    //   buffer.writeln('│ 🔍 Query Params:');
    //   options.queryParameters.forEach((key, value) {
    //     buffer.writeln('│   $key: $value');
    //   });
    //   buffer.writeln('│');
    // }

    // // Body
    // if (options.data != null) {
    //   buffer.writeln('│ 📦 Body:');
    //   final bodyStr = _formatBody(options.data);
    //   for (final line in bodyStr.split('\n')) {
    //     buffer.writeln('│   $line');
    //   }
    // }

    // buffer.writeln(
    //   '└──────────────────────────────────────────────────────────────',
    // );

    // logInfo(buffer.toString());
  }

  // ============================================================
  // Response Logging
  // ============================================================

  void _logResponse(Response<dynamic> response) {
    // final buffer = StringBuffer();
    // final statusEmoji = _getStatusEmoji(response.statusCode ?? 0);
    // final duration = _calculateDuration(response.requestOptions);

    // buffer.writeln('');
    // buffer.writeln(
    //   '┌──────────────────────────────────────────────────────────────',
    // );
    // buffer.writeln('│ 📥 RESPONSE $statusEmoji');
    // buffer.writeln(
    //   '├──────────────────────────────────────────────────────────────',
    // );
    // buffer.writeln(
    //   '│ ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}',
    // );
    // buffer.writeln(
    //   '│ Status: ${response.statusCode} ${response.statusMessage ?? ''}',
    // );
    // if (duration != null) {
    //   buffer.writeln('│ Duration: ${duration}ms');
    // }
    // buffer.writeln('│');

    // // Headers
    // if (logResponseHeaders && response.headers.map.isNotEmpty) {
    //   buffer.writeln('│ 📋 Headers:');
    //   response.headers.forEach((name, values) {
    //     buffer.writeln('│   $name: ${values.join(', ')}');
    //   });
    //   buffer.writeln('│');
    // }

    // // Body
    // if (response.data != null) {
    //   buffer.writeln('│ 📦 Body:');
    //   final bodyStr = _formatBody(response.data, truncate: true);
    //   for (final line in bodyStr.split('\n')) {
    //     buffer.writeln('│   $line');
    //   }
    // }

    // buffer.writeln(
    //   '└──────────────────────────────────────────────────────────────',
    // );

    // // Use appropriate log level based on status
    // if (response.statusCode != null && response.statusCode! >= 400) {
    //   logWarning(buffer.toString());
    // } else {
    //   logInfo(buffer.toString());
    // }
  }

  // ============================================================
  // Error Logging
  // ============================================================

  void _logDioError(DioException err) {
    final buffer = StringBuffer();

    buffer.writeln('');
    buffer.writeln(
      '┌──────────────────────────────────────────────────────────────',
    );
    buffer.writeln('│ ❌ ERROR');
    buffer.writeln(
      '├──────────────────────────────────────────────────────────────',
    );
    buffer.writeln(
      '│ ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}',
    );
    buffer.writeln('│ Type: ${err.type.name}');
    buffer.writeln('│ Message: ${err.message ?? 'No message'}');
    buffer.writeln('│');

    // Response info if available
    if (err.response != null) {
      buffer.writeln('│ 📥 Response:');
      buffer.writeln(
        '│   Status: ${err.response?.statusCode} ${err.response?.statusMessage ?? ''}',
      );
      if (err.response?.data != null) {
        buffer.writeln('│   Body:');
        final bodyStr = _formatBody(err.response?.data, truncate: true);
        for (final line in bodyStr.split('\n')) {
          buffer.writeln('│     $line');
        }
      }
    }

    buffer.writeln(
      '└──────────────────────────────────────────────────────────────',
    );

    super.logError(buffer.toString());
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Format body for display (supports JSON, String, Map, List)
  String _formatBody(dynamic data, {bool truncate = false}) {
    if (data == null) return 'null';

    try {
      String result;

      if (data is String) {
        // Try to parse as JSON for pretty printing
        try {
          final parsed = jsonDecode(data);
          result = const JsonEncoder.withIndent('  ').convert(parsed);
        } catch (_) {
          result = data;
        }
      } else if (data is Map || data is List) {
        result = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        result = data.toString();
      }

      // Truncate if needed
      if (truncate && result.length > maxResponseBodyLength) {
        return '${result.substring(0, maxResponseBodyLength)}\n... [truncated ${result.length - maxResponseBodyLength} chars]';
      }

      return result;
    } catch (e) {
      return data.toString();
    }
  }

  /// Mask sensitive header values
  String _maskSensitiveHeader(String key, String value) {
    final sensitiveHeaders = [
      'authorization',
      'token',
      'x-token',
      'cookie',
      'set-cookie',
    ];

    if (sensitiveHeaders.contains(key.toLowerCase())) {
      if (value.length > 10) {
        return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
      }
      return '****';
    }
    return value;
  }

  /// Get emoji based on HTTP status code
  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '↪️';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '🔥';
    return '❓';
  }

  /// Calculate request duration
  int? _calculateDuration(RequestOptions options) {
    final startTime = options.extra['_startTime'] as DateTime?;
    if (startTime != null) {
      return DateTime.now().difference(startTime).inMilliseconds;
    }
    return null;
  }
}

/// Interceptor to add request start time for duration calculation
class RequestTimingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startTime'] = DateTime.now();
    super.onRequest(options, handler);
  }
}
