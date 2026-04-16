import 'package:co_caro_flame/s88/core/services/network/sun_api_exception.dart';

/// {@template my_bet_failure}
/// A base failure for the my bet repository failures.
/// {@endtemplate}
abstract class MyBetFailure implements Exception {
  /// {@macro my_bet_failure}
  const MyBetFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  String toString() => 'MyBetFailure(error: $error)';
}

/// {@template get_active_tickets_failure}
/// Thrown when fetching active tickets fails.
/// {@endtemplate}
class GetActiveTicketsFailure extends MyBetFailure {
  /// {@macro get_active_tickets_failure}
  const GetActiveTicketsFailure(super.error);

  @override
  String toString() => 'GetActiveTicketsFailure(error: $error)';
}

/// {@template get_settled_tickets_failure}
/// Thrown when fetching settled tickets fails.
/// {@endtemplate}
class GetSettledTicketsFailure extends MyBetFailure {
  /// {@macro get_settled_tickets_failure}
  const GetSettledTicketsFailure(super.error);

  @override
  String toString() => 'GetSettledTicketsFailure(error: $error)';
}

/// {@template get_ticket_detail_failure}
/// Thrown when fetching ticket detail fails.
/// {@endtemplate}
class GetTicketDetailFailure extends MyBetFailure {
  /// {@macro get_ticket_detail_failure}
  const GetTicketDetailFailure(super.error);

  @override
  String toString() => 'GetTicketDetailFailure(error: $error)';
}

/// {@template get_cashout_failure}
/// Thrown when fetching cashout info fails.
/// {@endtemplate}
class GetCashoutFailure extends MyBetFailure {
  /// {@macro get_cashout_failure}
  const GetCashoutFailure(super.error);

  @override
  String toString() => 'GetCashoutFailure(error: $error)';
}

/// {@template perform_cashout_failure}
/// Thrown when performing cashout fails.
/// {@endtemplate}
class PerformCashoutFailure extends MyBetFailure {
  /// {@macro perform_cashout_failure}
  const PerformCashoutFailure(super.error);

  @override
  String toString() => 'PerformCashoutFailure(error: $error)';
}

/// {@template get_play_history_failure}
/// Thrown when fetching play history fails.
/// {@endtemplate}
class GetPlayHistoryFailure extends MyBetFailure {
  /// {@macro get_play_history_failure}
  const GetPlayHistoryFailure(super.error);

  @override
  String toString() => 'GetPlayHistoryFailure(error: $error)';
}

/// Extension to helpers for [MyBetFailure]
extension MyBetFailureX on MyBetFailure {
  /// Get user friendly error message
  String? get errorMessage {
    final err = error;

    final message = err.toString().toLowerCase();

    if (err is SunApiException) {
      return err.userFriendlyMessage;
    }

    // 1. Data Errors
    if (message.contains('formatexception') || message.contains('typeerror')) {
      return 'Dữ liệu trả về từ máy chủ không hợp lệ.';
    }

    // 2. Not Found
    if (message.contains('not found') || message.contains('404')) {
      return 'Không tìm thấy thông tin yêu cầu.';
    }

    // 3. Cashout specific
    if (message.contains('cash out failed')) {
      if (message.contains('not available')) {
        return 'Cashout is not available';
      }
      if (message.contains('amount changed') ||
          message.contains('odds changed')) {
        return 'Cashout amount has changed';
      }
    }

    // Handle generic Exception
    if (err is Exception) {
      if (err.toString().startsWith('Exception: ')) {
        return err.toString().replaceFirst('Exception: ', '');
      }
      return err.toString();
    }

    // Default message
    return 'Đã xảy ra lỗi không xác định.';
  }

  /// Whether cashout is not available error
  bool get isCashoutNotAvailable {
    final msg = error.toString().toLowerCase();
    return msg.contains('cash out failed') && msg.contains('not available');
  }

  /// Whether cashout amount changed error
  bool get isCashoutAmountChanged {
    final msg = error.toString().toLowerCase();
    return msg.contains('cash out failed') &&
        (msg.contains('amount changed') || msg.contains('odds changed'));
  }
}
