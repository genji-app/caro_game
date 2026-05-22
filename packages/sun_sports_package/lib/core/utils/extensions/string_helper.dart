/// Helper class for String operations
class StringHelper {
  StringHelper._();

  /// Mask a phone number for privacy (e.g. 09******56)
  ///
  /// Returns masked string if length >= 4, otherwise returns original string.
  /// If input is null or empty, returns '-'.
  static String maskPhone(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return '-';

    final trimmedPhone = phoneNumber.trim();
    if (trimmedPhone.length < 4) return trimmedPhone;

    return '${trimmedPhone.substring(0, 2)}******${trimmedPhone.substring(trimmedPhone.length - 2)}';
  }
}

/// Extension methods on String for common operations
extension StringExtension on String {
  /// Mask this string as a phone number for privacy
  String maskPhone() => StringHelper.maskPhone(this);
}
