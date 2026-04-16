import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Lưu danh sách từ khóa tìm kiếm gần đây bằng Hive.
/// Tách riêng Thể thao và Casino: tab nào chỉ hiển thị recent của tab đó.
/// Mới nhất ở đầu, tối đa [maxItems], trùng thì đưa lên đầu.
class SearchRecentStorage {
  SearchRecentStorage._();

  static const String _boxName = 'search_recent';
  static const String _keySport = 'keywords_sport';
  static const String _keyCasino = 'keywords_casino';
  static const int maxItems = 5;

  static Box<String>? _box;

  /// Mở Hive box (gọi một lần khi app khởi động).
  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _b {
    if (_box == null) {
      throw StateError(
        'SearchRecentStorage chưa init. Gọi SearchRecentStorage.init() trước.',
      );
    }
    return _box!;
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

  static List<String> _getList(String key) => _decode(_b.get(key));
  static Future<void> _putList(String key, List<String> list) async =>
      _b.put(key, _encode(list));

  /// Lấy danh sách từ khóa gần đây tab Thể thao (mới nhất trước).
  static Future<List<String>> getRecentSport() async => _getList(_keySport);

  /// Lấy danh sách từ khóa gần đây tab Casino (mới nhất trước).
  static Future<List<String>> getRecentCasino() async => _getList(_keyCasino);

  /// Thêm từ khóa tab Thể thao. Giữ tối đa [maxItems].
  static Future<void> addRecentSport(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    var list = _getList(_keySport);
    list.remove(trimmed);
    list.insert(0, trimmed);
    if (list.length > maxItems) list = list.take(maxItems).toList();
    await _putList(_keySport, list);
  }

  /// Thêm từ khóa tab Casino. Giữ tối đa [maxItems].
  static Future<void> addRecentCasino(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    var list = _getList(_keyCasino);
    list.remove(trimmed);
    list.insert(0, trimmed);
    if (list.length > maxItems) list = list.take(maxItems).toList();
    await _putList(_keyCasino, list);
  }

  /// Xóa một từ khóa tab Thể thao.
  static Future<void> removeRecentSport(String keyword) async {
    final list = _getList(_keySport);
    list.remove(keyword.trim());
    await _putList(_keySport, list);
  }

  /// Xóa một từ khóa tab Casino.
  static Future<void> removeRecentCasino(String keyword) async {
    final list = _getList(_keyCasino);
    list.remove(keyword.trim());
    await _putList(_keyCasino, list);
  }
}
