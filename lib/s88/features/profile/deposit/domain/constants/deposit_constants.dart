/// Constants for deposit feature
///
/// This file contains all magic numbers and strings used in the deposit feature
/// to improve maintainability and avoid hardcoded values.

/// Bank type constants
class BankType {
  static const int eWallet = 2;
}

/// Animation durations
class DepositAnimationDurations {
  /// Delay for navigation after dialog pop
  static const Duration navigationDelay = Duration(milliseconds: 300);

  /// Delay for dialog pop animation
  static const Duration dialogPopDelay = Duration(milliseconds: 400);
}

/// UI constants
class DepositUIConstants {
  /// Default spacing between form fields
  static const double defaultSpacing = 24.0;

  /// Bottom spacing for form
  static const double bottomSpacing = 32.0;

  /// Form field height
  static const double formFieldHeight = 48.0;

  /// Border radius for form fields
  static const double borderRadius = 12.0;
}

/// Error messages
class DepositErrorMessages {
  static const String invalidDenomination = 'Mệnh giá không hợp lệ';
  static const String pleaseCheckInfo = 'Vui lòng kiểm tra lại thông tin';
  static const String processing =
      'Chúng tôi đang xác nhận. Vui lòng đợi vài phút !';
}
