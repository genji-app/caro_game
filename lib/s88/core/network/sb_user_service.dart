import 'package:co_caro_flame/s88/core/network/api_endpoints.dart';

/// User service for Sportbook.
///
/// Handles user data parsing and account-related operations.
/// Storage remains in SbHttpManager - this class only handles logic.
class SbUserService {
  SbUserService._();

  // ===== USER DATA PARSING =====

  /// Parse user info from API response.
  ///
  /// Handles two response formats:
  /// 1. Named keys: {"displayName":"user","cust_login":"user",...}
  /// 2. Numeric keys: {"0":"username","1":"VND","2":"500.000","3":"Active"}
  ///
  /// Handles balance parsing: "450.000" -> 450.0 (in 1K units).
  ///
  /// Returns a map with normalized user data:
  /// - uid, displayName, cust_login, cust_id
  /// - balance (double, in 1K units)
  /// - currency, status
  static Map<String, dynamic> parseUserInfo(Map<String, dynamic> info) {
    // Check if response uses numeric keys (legacy format)
    final hasNumericKeys = info.containsKey('0');

    if (hasNumericKeys) {
      // Legacy format: {"0":"username","1":"VND","2":"500.000","3":"Active"}
      final username = info['0'] as String? ?? '';
      return {
        'uid': '',
        'displayName': username,
        'cust_login': username,
        'cust_id': '',
        'balance': parseBalance(info['2'] as String? ?? '0'),
        'currency': info['1'] as String? ?? 'VND',
        'status': info['3'] as String? ?? 'Active',
      };
    }

    // Modern format: named keys
    return {
      'uid': info['uid'] as String? ?? '',
      'displayName': info['displayName'] as String? ?? '',
      'cust_login': info['cust_login'] as String? ?? '',
      'cust_id': info['cust_id'] as String? ?? '',
      'balance': parseBalance(info['balance'] as String? ?? '0'),
      'currency': info['currency'] as String? ?? 'VND',
      'status': info['status'] as String? ?? 'Active',
    };
  }

  /// Parse balance string to double.
  ///
  /// Converts "450.000" -> 450000 -> 450.0 (in 1K units).
  /// Removes thousand separators (dots) and divides by 1000.
  static double parseBalance(String balanceStr) {
    final cleaned = balanceStr.replaceAll('.', '');
    final balanceInt = int.tryParse(cleaned) ?? 0;
    return balanceInt / 1000.0;
  }

  // ===== DEFAULT USER DATA =====

  /// Create empty user data map.
  ///
  /// Used for initialization and reset.
  static Map<String, dynamic> createEmptyUserData() {
    return {
      'uid': '',
      'displayName': '',
      'cust_login': '',
      'cust_id': '',
      'balance': 0.0,
      'currency': '',
      'status': 'Active',
    };
  }

  /// Reset user data to default values.
  ///
  /// Modifies the provided map in place.
  static void resetUserData(Map<String, dynamic> user) {
    user['uid'] = '';
    user['displayName'] = '';
    user['cust_login'] = '';
    user['cust_id'] = '';
    user['balance'] = 0.0;
    user['currency'] = '';
    user['status'] = 'Active';
  }

  // ===== URL BUILDERS - delegate to SbApiEndpoints =====

  /// Build user info URL.
  static String buildUserInfoUrl(String baseUrl) =>
      SbApiEndpoints.buildUserInfoUrl(baseUrl);

  /// Build user balance URL.
  static String buildUserBalanceUrl(String baseUrl) =>
      SbApiEndpoints.buildUserBalanceUrl(baseUrl);

  static String buildNotificationUrl(String baseUrl) =>
      SbApiEndpoints.buildNotificationUrl(baseUrl);

  /// Build transaction history URL.
  static String buildTransactionHistoryUrl(
    String apiDomain, {
    int slipType = 0,
    int skip = 0,
    int limit = 10,
  }) => SbApiEndpoints.buildTransactionHistoryUrl(
    apiDomain,
    slipType: slipType,
    skip: skip,
    limit: limit,
  );

  /// Build fetch bank accounts URL.
  static String buildBankAccountsUrl(String apiDomain) =>
      SbApiEndpoints.buildBankAccountsUrl(apiDomain);

  /// Build play history URL.
  static String buildPlayHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 5,
    String? assetName,
  }) => SbApiEndpoints.buildPlayHistoryUrl(
    apiDomain,
    skip: skip,
    limit: limit,
    assetName: assetName,
  );
}
