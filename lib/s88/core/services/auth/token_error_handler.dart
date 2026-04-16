import 'dart:async';
import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';

/// Centralized handler cho token errors
/// Đảm bảo chỉ có 1 refresh request tại 1 thời điểm
class TokenErrorHandler {
  static final TokenErrorHandler _instance = TokenErrorHandler._();
  static TokenErrorHandler get instance => _instance;
  TokenErrorHandler._();

  static final _logger = AppLogger(tag: 'TokenErrorHandler');

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  /// Timeout for refresh token operation
  static const _refreshTimeout = Duration(seconds: 10);

  /// Xử lý lỗi token, trả về true nếu refresh thành công
  /// Nếu đang refresh, sẽ đợi kết quả từ request đang chạy
  Future<bool> handleTokenError() async {
    // Nếu đang refresh, đợi kết quả
    if (_isRefreshing && _refreshCompleter != null) {
      _logger.d('Token refresh already in progress, waiting...');
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      _logger.i('Starting token refresh...');
      // refreshToken() đã bao gồm getSbToken() nên không cần gọi riêng
      // Thêm timeout để tránh hang vô hạn
      await SbLogin.refreshToken().timeout(
        _refreshTimeout,
        onTimeout: () => throw TimeoutException(
          'Token refresh timeout after ${_refreshTimeout.inSeconds}s',
        ),
      );
      _logger.i(
        'Token refresh successful (accessToken + wsToken + userTokenSb)',
      );
      _refreshCompleter!.complete(true);
      return true;
    } catch (e, stackTrace) {
      _logger.e('Token refresh failed', error: e, stackTrace: stackTrace);
      _refreshCompleter!.complete(false);
      // Đóng game khi không thể refresh
      await SbLogin.closeCreatorGame(
        401,
        withPopup: true,
        info: 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
      );
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Kiểm tra message có phải lỗi token không
  /// Sử dụng specific error patterns để tránh false positive
  bool isTokenError(String message) {
    final lowerMsg = message.toLowerCase();

    // Specific error patterns - tránh match "token updated successfully"
    const errorPatterns = [
      'token expired',
      'token invalid',
      'invalid token',
      'token hết hạn',
      'unauthorized',
      'authentication failed',
      'session expired',
      'jwt expired',
    ];

    return errorPatterns.any((p) => lowerMsg.contains(p));
  }

  /// Kiểm tra HTTP status code có phải lỗi auth không
  bool isAuthStatusCode(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  /// Reset state (dùng khi logout)
  void reset() {
    _isRefreshing = false;
    _refreshCompleter = null;
  }
}
