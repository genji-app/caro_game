import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Lưu danh sách game casino đã chơi gần đây (tối đa 5).
/// Mỗi item là key: "providerId|productId|gameCode". Mới nhất ở đầu.
class CasinoRecentGamesStorage {
  CasinoRecentGamesStorage._();

  static const String _boxName = 'casino_recent_games';
  static const String _keyList = 'keys';
  static const int maxItems = 5;

  static Box<String>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _b {
    if (_box == null) {
      throw StateError('CasinoRecentGamesStorage chưa init. Gọi init() trước.');
    }
    return _box!;
  }

  static String _gameKey(String providerId, String productId, String gameCode) {
    return '$providerId|$productId|$gameCode';
  }

  static List<String> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      return list
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];
    } catch (_) {
      return [];
    }
  }

  static String _encode(List<String> list) => jsonEncode(list);

  /// Lấy danh sách key gần đây (mới nhất trước), tối đa [maxItems].
  static Future<List<String>> getKeys() async {
    final raw = _b.get(_keyList);
    final list = _decode(raw);
    return list.take(maxItems).toList();
  }

  /// Thêm một game. Nếu đã có thì đưa lên đầu. Giữ tối đa [maxItems].
  static Future<void> addGame(
    String providerId,
    String productId,
    String gameCode,
  ) async {
    final key = _gameKey(providerId, productId, gameCode);
    var list = _decode(_b.get(_keyList));
    list.remove(key);
    list.insert(0, key);
    if (list.length > maxItems) list = list.take(maxItems).toList();
    await _b.put(_keyList, _encode(list));
  }
}
