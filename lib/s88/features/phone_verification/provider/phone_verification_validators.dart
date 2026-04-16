import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/string_helper.dart';

/// Regular expression for validating phone numbers.
///
/// Supports various phone number formats including:
/// - International format with country code
/// - Formats with spaces, dots, or dashes
final RegExp _phoneRegex = RegExp(
  r'^(\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$',
);

/// Regular expression for validating OTP codes.
///
/// Expects exactly 6 digits.
final RegExp _otpRegex = RegExp(r'^\d{6}$');

/// Validates a phone number.
///
/// Returns `null` if valid, otherwise returns an error message.
///
/// Validation rules:
/// - Must not be null or empty
/// - Must be at least 10 characters
/// - Must not exceed 15 characters
/// - Must match phone number pattern
///
/// Example:
/// ```dart
/// final error = validatePhoneNumber('0932123456');
/// if (error != null) {
///   print('Invalid: $error');
/// }
/// ```
String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return I18n.errPhoneRequired;
  }

  if (value.length < 10) {
    return I18n.errPhoneMinLength;
  }

  if (value.length > 15) {
    return I18n.errPhoneMaxLength;
  }

  if (!_phoneRegex.hasMatch(value)) {
    return I18n.errPhoneInvalid;
  }

  return null;
}

/// Validates an OTP code.
///
/// Returns `null` if valid, otherwise returns an error message.
///
/// Validation rules:
/// - Must not be null or empty
/// - Must be exactly 6 digits
///
/// Example:
/// ```dart
/// final error = validateOtpCode('123456');
/// if (error != null) {
///   print('Invalid: $error');
/// }
/// ```
String? validateOtpCode(String? value) {
  if (value == null || value.isEmpty) {
    return I18n.errOTPRequired;
  }

  if (!_otpRegex.hasMatch(value)) {
    return I18n.errOTPInvalid;
  }

  return null;
}

/// Formats a phone number for privacy by masking middle digits.
///
/// Example:
/// ```dart
/// formatPhoneForPrivacy('0932123456'); // Returns: '09******56'
/// ```
String formatPhoneForPrivacy(String phoneNumber) {
  return StringHelper.maskPhone(phoneNumber);
}
