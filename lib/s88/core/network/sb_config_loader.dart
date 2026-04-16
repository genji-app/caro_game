import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/services/models/settings_info.dart';

/// Configuration loader for Sportbook services.
///
/// Handles loading remote config and server settings.
/// Storage remains in SbHttpManager - this class only handles loading logic.
class SbConfigLoader {
  SbConfigLoader._();

  // ===== STATIC CONFIG LOADER =====

  /// Load remote config with cache busting.
  /// Response is base64-encoded JSON.
  ///
  /// Example:
  /// ```dart
  /// final config = await SbConfigLoader.getConfig('https://example.com/config');
  /// print(config['api_domain']);
  /// ```
  static Future<Map<String, dynamic>> getConfig(String url) async {
    try {
      final randomParam = '?r=${Random().nextDouble()}';
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get<String>(
        url + randomParam,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Empty config response');
      }

      // Decode base64 — strip all whitespace first to handle GitHub line wrapping
      final clean = response.data!.replaceAll(RegExp(r'\s+'), '');
      final bytes = base64Decode(clean);
      final decoded = utf8.decode(bytes);

      // Parse JSON
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load config: $e');
    }
  }

  // ===== SETTINGS PARSER =====

  /// Parse settings from API response.
  ///
  /// Returns SettingsInfo model.
  /// Expected input format (numeric keys):
  /// ```json
  /// {
  ///   "0": {"0": "exposeDomain", "1": "bettingDomain", ...},
  ///   "1": {"0": refreshTime, "1": isRefreshAPI},
  ///   "2": {"0": memSize},
  ///   "3": [hiddenLeagueIds]
  /// }
  /// ```
  static SettingsInfo parseSettings(Map<String, dynamic> setting) {
    return SettingsInfo.fromJson(setting);
  }

  /// Parse domains from settings response.
  ///
  /// Returns DomainSettings model.
  static DomainSettings parseDomains(Map<String, dynamic> setting) {
    final domainsData = setting['0'] as Map<String, dynamic>?;
    return DomainSettings.fromJson(domainsData);
  }

  /// Parse balance refresh settings from settings response.
  ///
  /// Returns BalanceSettings model.
  static BalanceSettings parseBalanceSettings(Map<String, dynamic> setting) {
    final balanceData = setting['1'] as Map<String, dynamic>?;
    return BalanceSettings.fromJson(balanceData);
  }

  /// Parse performance settings from settings response.
  ///
  /// Returns PerformanceSettings model.
  static PerformanceSettings parsePerformanceSettings(
    Map<String, dynamic> setting,
  ) {
    final performanceData = setting['2'] as Map<String, dynamic>?;
    return PerformanceSettings.fromJson(performanceData);
  }

  // ===== CONFIG READY CHECKER =====

  /// Wait for a condition to be ready with timeout.
  ///
  /// [isReady] - Function that returns true when ready.
  /// [maxWaitTime] - Maximum time to wait before returning false.
  /// [checkInterval] - Interval between checks.
  ///
  /// Returns true if condition became ready, false if timeout.
  ///
  /// Example:
  /// ```dart
  /// final ready = await SbConfigLoader.waitForReady(
  ///   isReady: () => urlHomeExposeService.isNotEmpty,
  /// );
  /// ```
  static Future<bool> waitForReady({
    required bool Function() isReady,
    Duration maxWaitTime = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    // If already ready, return immediately
    if (isReady()) {
      return true;
    }

    // Wait for condition to be ready (polling with timeout)
    final startTime = DateTime.now();

    while (!isReady()) {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed > maxWaitTime) {
        return false;
      }
      await Future<void>.delayed(checkInterval);
    }

    return true;
  }
}
