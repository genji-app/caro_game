import 'dart:convert';
import 'dart:typed_data';

/// Helper class for Base64 encoding and decoding operations
class Base64Helper {
  /// Decode base64 string to UTF-8 string
  ///
  /// Returns the decoded string, or empty string if decoding fails
  ///
  /// Example:
  /// ```dart
  /// final decoded = Base64Helper.decodeToString('SGVsbG8gV29ybGQ=');
  /// print(decoded); // 'Hello World'
  /// ```
  static String decodeToString(String base64String) {
    try {
      if (base64String.isEmpty) {
        return '';
      }

      // Remove data URI prefix if present (e.g., "data:image/png;base64,")
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      return utf8.decode(bytes);
    } catch (e) {
      return '';
    }
  }

  /// Decode base64 string to bytes (Uint8List)
  ///
  /// Returns the decoded bytes, or empty Uint8List if decoding fails
  ///
  /// Example:
  /// ```dart
  /// final bytes = Base64Helper.decodeToBytes('SGVsbG8gV29ybGQ=');
  /// ```
  static Uint8List decodeToBytes(String base64String) {
    try {
      if (base64String.isEmpty) {
        return Uint8List(0);
      }

      // Remove data URI prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      return base64Decode(cleanBase64);
    } catch (e) {
      return Uint8List(0);
    }
  }

  /// Encode string to base64
  ///
  /// Returns the base64 encoded string
  ///
  /// Example:
  /// ```dart
  /// final encoded = Base64Helper.encode('Hello World');
  /// print(encoded); // 'SGVsbG8gV29ybGQ='
  /// ```
  static String encode(String input) {
    try {
      if (input.isEmpty) {
        return '';
      }
      final bytes = utf8.encode(input);
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  /// Encode bytes to base64
  ///
  /// Returns the base64 encoded string from bytes
  ///
  /// Example:
  /// ```dart
  /// final bytes = utf8.encode('Hello World');
  /// final encoded = Base64Helper.encodeBytes(bytes);
  /// print(encoded); // 'SGVsbG8gV29ybGQ='
  /// ```
  static String encodeBytes(Uint8List bytes) {
    try {
      if (bytes.isEmpty) {
        return '';
      }
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  /// Check if a string is valid base64
  ///
  /// Returns true if the string is valid base64, false otherwise
  static bool isValidBase64(String input) {
    try {
      if (input.isEmpty) {
        return false;
      }

      String cleanBase64 = input;
      if (input.contains(',')) {
        cleanBase64 = input.split(',').last;
      }

      base64Decode(cleanBase64);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Extension methods on String for Base64 operations
extension Base64StringExtension on String {
  /// Decode this base64 string to UTF-8 string
  ///
  /// Example:
  /// ```dart
  /// final decoded = 'SGVsbG8gV29ybGQ='.base64DecodeToString();
  /// print(decoded); // 'Hello World'
  /// ```
  String base64DecodeToString() => Base64Helper.decodeToString(this);

  /// Decode this base64 string to bytes (Uint8List)
  ///
  /// Example:
  /// ```dart
  /// final bytes = 'SGVsbG8gV29ybGQ='.base64DecodeToBytes();
  /// ```
  Uint8List base64DecodeToBytes() => Base64Helper.decodeToBytes(this);

  /// Encode this string to base64
  ///
  /// Example:
  /// ```dart
  /// final encoded = 'Hello World'.base64Encode();
  /// print(encoded); // 'SGVsbG8gV29ybGQ='
  /// ```
  String base64Encode() => Base64Helper.encode(this);

  /// Check if this string is valid base64
  ///
  /// Example:
  /// ```dart
  /// final isValid = 'SGVsbG8gV29ybGQ='.isValidBase64(); // true
  /// ```
  bool isValidBase64() => Base64Helper.isValidBase64(this);
}
