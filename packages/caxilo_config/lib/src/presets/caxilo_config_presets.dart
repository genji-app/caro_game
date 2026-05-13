import 'dart:convert';

part 'urls_presets.dart';
part 'display_presets.dart';
part 'categories_presets.dart';
part 'in_house_presets.dart';
part 'external_presets.dart';
part 'backup_presets.dart';

/// Defines the environment to ensure type safety for configuration lookup.
// Formerly CasinoEnvironment.
enum CaxiloEnvironment { dev, staging, prod }

/// Provides multi-environment safe Presets (default configurations) for Caxilo config.
/// Replaces legacy Mock JSON files, supporting documentation comments and type-safety.
// Formerly CasinoSettingsPresets.
class CaxiloConfigPresets {
  /// Builds the complete configuration Map based on the specified environment.
  static Map<String, dynamic> buildSettings(CaxiloEnvironment env) {
    final urls = _getUrlsForEnv(env);
    return {
      "version": 2,
      "updated_at": DateTime.now().toUtc().toIso8601String(),
      "environments": urls,
      "display": _sharedDisplay,
      "lobby": _sharedLobby,
      "categories": _sharedCategories,
      "in_house": _sharedInHouse,
      "external": _sharedExternal,
    };
  }

  /// Exports the complete config as a JSON string.
  ///
  /// [pretty] = true → 2-space indent, human-readable (for review / git diff).
  /// [pretty] = false → compact, suitable for base64 encoding.
  static String toJsonString(CaxiloEnvironment env, {bool pretty = true}) {
    final map = buildSettings(env);
    return pretty ? const JsonEncoder.withIndent('  ').convert(map) : jsonEncode(map);
  }

  /// Exports config as a base64-encoded JSON string.
  ///
  /// The output is compatible with:
  /// - [CaxiloConfigClient.fetchSettings] (auto-detects and decodes base64)
  /// - `--dart-define CASINO_CONFIG_JSON=...` for local testing
  /// - GitHub raw file hosting (same pattern as SbConfig)
  static String toBase64String(CaxiloEnvironment env) {
    return base64Encode(utf8.encode(toJsonString(env, pretty: false)));
  }

  /// Helper to retrieve the URL map corresponding to the given environment.
  static Map<String, dynamic> _getUrlsForEnv(CaxiloEnvironment env) {
    switch (env) {
      case CaxiloEnvironment.dev:
        return _devUrls;
      case CaxiloEnvironment.staging:
        return _stagingUrls;
      case CaxiloEnvironment.prod:
        return _prodUrls;
    }
  }
}
