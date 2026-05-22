import 'package:shared_preferences/shared_preferences.dart';

/// Sport Storage
///
/// Manages sport-related preferences using SharedPreferences.
/// Follows the same pattern as the Web implementation (localStorage).
///
/// Keys:
/// - sbSportID: Current selected sport ID (default: 1 = Football)
/// - sbOddsStyle: Current odds display style (default: decimal)
class SportStorage {
  // ===== STORAGE KEYS =====
  static const String _sportIdKey = 'sbSportID';
  static const String _oddsStyleKey = 'sbOddsStyle';
  static const String _lastLeagueIdKey = 'sbLastLeagueId';

  // ===== DEFAULT VALUES =====
  static const int defaultSportId = 1; // Football
  // IMPORTANT: Must use shortName format ('MY', 'ID', 'DE', 'HK') to match OddsStyle.fromShortName()
  static const String defaultOddsStyle = 'DE'; // Decimal

  // ===== SINGLETON PATTERN =====
  static SportStorage? _instance;
  static SportStorage get instance => _instance ??= SportStorage._();
  SportStorage._();

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

  // ===== SPORT ID =====

  /// Save sportId to SharedPreferences
  ///
  /// Called when user changes sport in settings.
  /// Flow: User selects sport → saveSportId() → SbHttpManager.sportTypeId = sportId
  Future<void> saveSportId(int sportId) async {
    final prefs = await _preferences;
    await prefs.setInt(_sportIdKey, sportId);
  }

  /// Get sportId from SharedPreferences
  ///
  /// Called at app startup to restore last selected sport.
  /// Returns Football (1) as default if not set.
  Future<int> getSportId() async {
    final prefs = await _preferences;
    return prefs.getInt(_sportIdKey) ?? defaultSportId;
  }

  /// Get sportId synchronously (requires init() first)
  ///
  /// Use this for synchronous access after init().
  int getSportIdSync() {
    return _prefs?.getInt(_sportIdKey) ?? defaultSportId;
  }

  // ===== ODDS STYLE =====

  /// Save odds display style
  ///
  /// Uses OddsStyle.shortName format: 'MY' (malay), 'ID' (indo), 'DE' (decimal), 'HK' (hongKong)
  Future<void> saveOddsStyle(String style) async {
    final prefs = await _preferences;
    await prefs.setString(_oddsStyleKey, style);
  }

  /// Get odds display style
  Future<String> getOddsStyle() async {
    final prefs = await _preferences;
    return prefs.getString(_oddsStyleKey) ?? defaultOddsStyle;
  }

  /// Get odds style synchronously
  String getOddsStyleSync() {
    return _prefs?.getString(_oddsStyleKey) ?? defaultOddsStyle;
  }

  // ===== LAST LEAGUE ID =====

  /// Save last viewed league ID (for navigation restore)
  Future<void> saveLastLeagueId(int leagueId) async {
    final prefs = await _preferences;
    await prefs.setInt(_lastLeagueIdKey, leagueId);
  }

  /// Get last viewed league ID
  Future<int?> getLastLeagueId() async {
    final prefs = await _preferences;
    return prefs.getInt(_lastLeagueIdKey);
  }

  // ===== CLEAR =====

  /// Clear all sport-related storage (logout)
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_sportIdKey);
    await prefs.remove(_oddsStyleKey);
    await prefs.remove(_lastLeagueIdKey);
  }

  @override
  String toString() {
    return 'SportStorage(sportId: ${getSportIdSync()}, oddsStyle: ${getOddsStyleSync()})';
  }
}
