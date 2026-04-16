import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';

/// Private extension for GameApiClient internal use only
///
/// This extension provides the `dataOrThrow` method which is only used
/// internally by GameApiClient to unwrap response data.
extension SunApiResponseX<T> on SunApiResponse<T> {
  /// Get data or throw if failure
  ///
  /// **Internal use only** - This method is called by GameApiClient after
  /// the ErrorInterceptor has already handled failures. In normal operation,
  /// this never throws because failures are caught by the interceptor first.
  /// This is a safety fallback for edge cases.
  ///
  /// Throws [SunApiException] if response is a failure.
  T get dataOrThrow => map(
    success: (s) => s.data as T,
    failure: (f) => throw SunApiException(
      message: f.error ?? f.messageKey,
      messageKey: f.messageKey,
      status: f.code,
      data: f.data,
    ),
  );
}
