import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';

/// Parlay Storage
///
/// Manages parlay/bet slip data persistence using SharedPreferences.
/// Saves single bets and combo bets to local storage so they persist across app restarts.
class ParlayStorage {
  // ===== STORAGE KEYS =====
  static const String _singleBetsKey = 'parlaySingleBets';
  static const String _lastSavedKey = 'parlayLastSaved';
  static const String _comboBetsKey = 'parlayComboBets';
  static const String _comboLastSavedKey = 'parlayComboLastSaved';

  // ===== SINGLETON PATTERN =====
  static ParlayStorage? _instance;
  static ParlayStorage get instance => _instance ??= ParlayStorage._();
  ParlayStorage._();

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

  // ===== SINGLE BETS =====

  /// Save single bets to SharedPreferences
  Future<void> saveSingleBets(List<SingleBetData> bets) async {
    try {
      final prefs = await _preferences;

      if (bets.isEmpty) {
        // Clear storage if no bets
        await prefs.remove(_singleBetsKey);
        await prefs.remove(_lastSavedKey);
        debugPrint('[ParlayStorage] Cleared single bets from storage');
        return;
      }

      // Convert to JSON list
      final jsonList = bets.map((bet) => bet.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_singleBetsKey, jsonString);
      await prefs.setInt(_lastSavedKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('[ParlayStorage] Saved ${bets.length} single bets to storage');
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error saving single bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
    }
  }

  /// Load single bets from SharedPreferences
  Future<List<SingleBetData>> loadSingleBets() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_singleBetsKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('[ParlayStorage] No single bets found in storage');
        return [];
      }

      // Check if data is too old (older than 24 hours)
      final lastSaved = prefs.getInt(_lastSavedKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const maxAge = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

      if (now - lastSaved > maxAge) {
        debugPrint('[ParlayStorage] Single bets data is too old, clearing');
        await clear();
        return [];
      }

      // Parse JSON
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final bets = jsonList
          .map((json) => SingleBetData.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        '[ParlayStorage] Loaded ${bets.length} single bets from storage',
      );
      return bets;
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error loading single bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
      // Clear corrupted data
      await clear();
      return [];
    }
  }

  /// Get last saved timestamp
  Future<DateTime?> getLastSavedTime() async {
    final prefs = await _preferences;
    final timestamp = prefs.getInt(_lastSavedKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // ===== COMBO BETS (PARLAY) =====

  /// Save combo bets to SharedPreferences
  Future<void> saveComboBets(List<SingleBetData> bets) async {
    try {
      final prefs = await _preferences;

      if (bets.isEmpty) {
        // Clear storage if no bets
        await prefs.remove(_comboBetsKey);
        await prefs.remove(_comboLastSavedKey);
        debugPrint('[ParlayStorage] Cleared combo bets from storage');
        return;
      }

      // Convert to JSON list
      final jsonList = bets.map((bet) => bet.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_comboBetsKey, jsonString);
      await prefs.setInt(
        _comboLastSavedKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('[ParlayStorage] Saved ${bets.length} combo bets to storage');
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error saving combo bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
    }
  }

  /// Load combo bets from SharedPreferences
  Future<List<SingleBetData>> loadComboBets() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_comboBetsKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('[ParlayStorage] No combo bets found in storage');
        return [];
      }

      // Check if data is too old (older than 24 hours)
      final lastSaved = prefs.getInt(_comboLastSavedKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const maxAge = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

      if (now - lastSaved > maxAge) {
        debugPrint('[ParlayStorage] Combo bets data is too old, clearing');
        await clearComboBets();
        return [];
      }

      // Parse JSON
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final bets = jsonList
          .map((json) => SingleBetData.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        '[ParlayStorage] Loaded ${bets.length} combo bets from storage',
      );
      return bets;
    } catch (e, stackTrace) {
      debugPrint('[ParlayStorage] Error loading combo bets: $e');
      debugPrint('[ParlayStorage] StackTrace: $stackTrace');
      // Clear corrupted data
      await clearComboBets();
      return [];
    }
  }

  /// Clear only combo bets from storage
  Future<void> clearComboBets() async {
    final prefs = await _preferences;
    await prefs.remove(_comboBetsKey);
    await prefs.remove(_comboLastSavedKey);
    // debugPrint('[ParlayStorage] Cleared combo bets from storage');
  }

  // ===== CLEAR =====

  /// Clear all parlay storage (logout or reset)
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_singleBetsKey);
    await prefs.remove(_lastSavedKey);
    await prefs.remove(_comboBetsKey);
    await prefs.remove(_comboLastSavedKey);
    // debugPrint('[ParlayStorage] Cleared all parlay storage');
  }

  @override
  String toString() {
    final count = _prefs?.getString(_singleBetsKey) != null
        ? 'has data'
        : 'empty';
    return 'ParlayStorage($count)';
  }
}
