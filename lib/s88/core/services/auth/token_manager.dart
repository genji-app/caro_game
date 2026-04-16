import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';

/// Manages authentication tokens storage
class TokenManager {
  TokenManager._();

  /// Save tokens after successful login/register
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String wsToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(SbConfig.userTokenKey, accessToken);
    await prefs.setString(SbConfig.refreshTokenKey, refreshToken);
    await prefs.setString(SbConfig.wsTokenKey, wsToken);

    // Also update SbConfig runtime
    SbConfig.instance.wsToken = wsToken;
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SbConfig.userTokenKey);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SbConfig.refreshTokenKey);
  }

  /// Get WS token (for WebSocket connection)
  static Future<String?> getWsToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SbConfig.wsTokenKey);
  }

  /// Clear all tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SbConfig.userTokenKey);
    await prefs.remove(SbConfig.refreshTokenKey);
    await prefs.remove(SbConfig.wsTokenKey);

    // Also clear SbConfig runtime
    SbConfig.instance.wsToken = '';
  }

  /// Check if user has valid tokens
  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}

/// Manages user credentials for auto-login (Remember Me)
class UserManager {
  UserManager._();

  /// Save credentials for auto-login
  /// NOTE: Password is base64 encoded (not encrypted)
  static Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Strip prefix if exists
    final cleanUsername = username
        .replaceAll('SC_', '')
        .replaceAll('NV_', '')
        .replaceAll('Z8_', '')
        .replaceAll('sc_', '')
        .replaceAll('nv_', '')
        .replaceAll('z8_', '');

    await prefs.setString(
      SbConfig.usernameKey,
      base64.encode(utf8.encode(cleanUsername)),
    );
    await prefs.setString(
      SbConfig.passwordKey,
      base64.encode(utf8.encode(password)),
    );
  }

  /// Get saved credentials
  /// Returns (username, password) or (null, null) if not saved
  static Future<(String?, String?)> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedUsername = prefs.getString(SbConfig.usernameKey);
    final encodedPassword = prefs.getString(SbConfig.passwordKey);

    if (encodedUsername == null || encodedPassword == null) {
      return (null, null);
    }

    try {
      final username = utf8.decode(base64.decode(encodedUsername));
      final password = utf8.decode(base64.decode(encodedPassword));
      return (username, password);
    } catch (e) {
      return (null, null);
    }
  }

  /// Clear saved credentials (logout)
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SbConfig.usernameKey);
    await prefs.remove(SbConfig.passwordKey);
  }

  /// Check if user has saved credentials
  static Future<bool> hasSavedCredentials() async {
    final (username, password) = await getSavedCredentials();
    return username != null && password != null;
  }
}
