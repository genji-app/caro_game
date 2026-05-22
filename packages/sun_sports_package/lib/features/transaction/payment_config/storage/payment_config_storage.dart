import 'package:shared_preferences/shared_preferences.dart';

/// Payment Config Storage
///
/// Manages caching of payment configuration data (banks, e-wallets, crypto).
/// Uses SharedPreferences with expiry mechanism to avoid stale data.
class PaymentConfigStorage {
  // ===== STORAGE KEYS =====
  static const String _configKey = 'paymentConfig';
  static const String _timestampKey = 'paymentConfigTimestamp';

  // ===== CACHE SETTINGS =====
  /// Cache expiry duration (1 hour)
  static const Duration cacheExpiry = Duration(hours: 1);

  // ===== SINGLETON PATTERN =====
  static PaymentConfigStorage? _instance;
  static PaymentConfigStorage get instance =>
      _instance ??= PaymentConfigStorage._();
  PaymentConfigStorage._();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences (call once at app startup)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance (lazy init)
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ===== SAVE =====

  /// Save payment config JSON to cache
  Future<void> save(String jsonString) async {
    final prefs = await _preferences;
    await prefs.setString(_configKey, jsonString);
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // ===== GET =====

  /// Get cached payment config JSON
  /// Returns null if not cached or cache expired
  Future<String?> get() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_configKey);
    if (jsonString == null) return null;

    // Check if cache is expired
    if (!await isValid()) {
      await clear();
      return null;
    }

    return jsonString;
  }

  // ===== VALIDATION =====

  /// Check if cache exists and is not expired
  Future<bool> isValid() async {
    final prefs = await _preferences;
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    return now.difference(cachedTime) <= cacheExpiry;
  }

  // ===== CLEAR =====

  /// Clear payment config cache
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_configKey);
    await prefs.remove(_timestampKey);
  }
}
