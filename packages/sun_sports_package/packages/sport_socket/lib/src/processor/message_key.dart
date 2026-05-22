import 'package:meta/meta.dart';

/// Extracted key from raw WebSocket message.
///
/// This is the result of Layer 1 (Fast Key Extraction).
/// Contains the deduplication key, message type, and original raw message.
/// The type is extracted so we can sort by priority BEFORE parsing JSON.
@immutable
class ExtractedKey {
  /// Unique key for deduplication
  /// Format varies by message type:
  /// - league_ins: "league_ins_{leagueId}"
  /// - event_ins: "event_ins_{eventId}"
  /// - event_up: "event_up_{eventId}"
  /// - event_rm: "event_rm_{eventId}"
  /// - market_up: "market_up_{eventId}_{marketId}"
  /// - odds_up: "odds_up_{eventId}_{marketId}_{timeRange}"
  /// - odds_up (batch): "odds_up_batch_{timestamp}" (no dedup)
  final String key;

  /// Message type (e.g., "league_ins", "event_up", "odds_up")
  /// Extracted for priority sorting without full JSON parsing
  final String type;

  /// Original raw message string
  /// Kept for Layer 2 (JSON parsing)
  final String raw;

  /// Sport ID if extracted (for filtering)
  final int? sportId;

  /// Event ID if extracted (for quick access)
  final int? eventId;

  /// League ID if extracted (for quick access)
  final int? leagueId;

  /// Market ID if extracted (for quick access)
  final int? marketId;

  /// Whether this message contains multiple items (e.g., kafkaOddsList array)
  final bool isBatch;

  const ExtractedKey({
    required this.key,
    required this.type,
    required this.raw,
    this.sportId,
    this.eventId,
    this.leagueId,
    this.marketId,
    this.isBatch = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedKey &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'ExtractedKey(key: $key, type: $type, sportId: $sportId)';
  }
}

/// Parsed message after JSON decoding
@immutable
class ParsedMessage {
  /// Message type
  final String type;

  /// Sport ID
  final int sportId;

  /// Parsed data payload
  final Map<String, dynamic> data;

  /// Original raw message (for debugging)
  final String raw;

  /// Timestamp when parsed
  final DateTime timestamp;

  const ParsedMessage({
    required this.type,
    required this.sportId,
    required this.data,
    required this.raw,
    required this.timestamp,
  });

  /// Get int value from data
  int? getInt(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Get string value from data
  String? getString(String key) {
    final value = data[key];
    if (value == null) return null;
    return value.toString();
  }

  /// Get bool value from data
  bool getBool(String key, {bool defaultValue = false}) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  /// Get double value from data
  double? getDouble(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  /// Get nested map from data
  Map<String, dynamic>? getMap(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Get list from data
  List<dynamic>? getList(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) return value;
    return null;
  }

  @override
  String toString() {
    return 'ParsedMessage(type: $type, sportId: $sportId)';
  }
}
