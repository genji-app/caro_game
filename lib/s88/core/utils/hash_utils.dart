import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for MD5 hashing used in authentication
class HashUtils {
  HashUtils._();

  /// Create MD5 hash from input string
  static String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Hash for Register (Web)
  /// Hash = MD5(username + password + displayName + platformID + osVersion + deviceId + HSK)
  static String createRegisterHash({
    required String username,
    required String password,
    required String displayName,
    required int platformId,
    required String osVersion,
    required String deviceId,
    required String hsk,
  }) {
    final input =
        username +
        password +
        displayName +
        platformId.toString() +
        osVersion +
        deviceId +
        hsk;
    return md5Hash(input);
  }

  /// Hash for Login (Native - iOS/Android)
  /// Hash = MD5(username + password + platformID + deviceId + HSK)
  static String createLoginHash({
    required String username,
    required String password,
    required int platformId,
    required String deviceId,
    required String hsk,
  }) {
    final input = username + password + platformId.toString() + deviceId + hsk;
    return md5Hash(input);
  }

  /// Hash for Login (Web) - includes timestamp
  /// Hash = MD5(username + password + platformID + deviceId + timestamp + HSK)
  static String createLoginWebHash({
    required String username,
    required String password,
    required int platformId,
    required String deviceId,
    required String timestamp,
    required String hsk,
  }) {
    final input =
        username +
        password +
        platformId.toString() +
        deviceId +
        timestamp +
        hsk;
    return md5Hash(input);
  }

  /// Hash for OTP verification
  /// Hash = MD5(sessionId + otp + HSK)
  static String createOtpHash({
    required String sessionId,
    required String otp,
    required String hsk,
  }) {
    final input = sessionId + otp + hsk;
    return md5Hash(input);
  }

  /// Hash for checking username availability
  /// Hash = MD5(username + brand + HSK)
  static String createCheckUsernameHash({
    required String username,
    required String brand,
    required String hsk,
  }) {
    final input = username + brand + hsk;
    return md5Hash(input);
  }

  /// Hash for loginHashSS / registerHashSS (unified for web and native)
  /// Hash = MD5(username + password + displayName + platformId + advId + deviceId + osVersion + bundleId + brand + secretKey)
  static String createAuthHashSS({
    required String username,
    required String password,
    required String displayName,
    required int platformId,
    required String advId,
    required String deviceId,
    required String osVersion,
    required String bundleId,
    required String brand,
    required String secretKey,
  }) {
    final input =
        username +
        password +
        displayName +
        platformId.toString() +
        advId +
        deviceId +
        osVersion +
        bundleId +
        brand +
        secretKey;
    return md5Hash(input);
  }
}
