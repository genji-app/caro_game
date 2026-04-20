import 'message_key.dart';
import '../utils/constants.dart';

/// Fast key extractor for WebSocket messages.
///
/// This is Layer 1 of the processing pipeline.
/// Extracts deduplication key and message type WITHOUT full JSON parsing.
/// Uses indexOf for O(1) extraction per field.
class KeyExtractor {
  /// Extract key from raw message - O(1) per field using indexOf
  /// Returns null if message is invalid or cannot be parsed
  ExtractedKey? extract(String raw) {
    // Quick validation - must start with {
    if (raw.isEmpty || raw[0] != '{') return null;

    // Extract type first (required)
    final type = _extractStringValue(raw, JsonField.type);
    if (type == null) return null;

    // Extract sportId (for filtering)
    final sportId = _extractIntValue(raw, JsonField.sportId);

    // Handle based on type
    switch (type) {
      case MessageType.leagueInsert:
        return _extractLeagueKey(raw, type, sportId);

      case MessageType.eventInsert:
      case MessageType.eventUpdate:
      case MessageType.eventRemove:
      case MessageType.scoreUpdate:
        return _extractEventKey(raw, type, sportId);

      case MessageType.marketUpdate:
        return _extractMarketKey(raw, type, sportId);

      case MessageType.oddsUpdate:
      case MessageType.oddsInsert:
        return _extractOddsKey(raw, type, sportId);

      case MessageType.oddsRemove:
        return _extractOddsRemoveKey(raw, type, sportId);

      case MessageType.balanceUpdate:
        // Balance updates are user-specific, use unique key
        return ExtractedKey(
          key: 'balance_${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          raw: raw,
          sportId: sportId,
        );

      default:
        // Unknown type - create unique key to not lose message
        return ExtractedKey(
          key: '${type}_${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          raw: raw,
          sportId: sportId,
        );
    }
  }

  /// Extract league key: "league_ins_{leagueId}"
  ExtractedKey? _extractLeagueKey(String raw, String type, int? sportId) {
    final leagueId = _extractIntValue(raw, JsonField.leagueId);
    if (leagueId == null) return null;

    return ExtractedKey(
      key: '${type}_$leagueId',
      type: type,
      raw: raw,
      sportId: sportId,
      leagueId: leagueId,
    );
  }

  /// Extract event key: "event_*_{eventId}"
  ExtractedKey? _extractEventKey(String raw, String type, int? sportId) {
    final eventId = _extractIntValue(raw, JsonField.eventId);
    if (eventId == null) return null;

    final leagueId = _extractIntValue(raw, JsonField.leagueId);

    return ExtractedKey(
      key: '${type}_$eventId',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      leagueId: leagueId,
    );
  }

  /// Extract market key: "market_up_{eventId}_{marketId}"
  ExtractedKey? _extractMarketKey(String raw, String type, int? sportId) {
    // Try domainEventId first (used in some messages)
    var eventId = _extractIntValue(raw, JsonField.domainEventId);
    eventId ??= _extractIntValue(raw, JsonField.eventId);

    // Try domainMarketId first
    var marketId = _extractIntValue(raw, JsonField.domainMarketId);
    marketId ??= _extractIntValue(raw, JsonField.marketId);

    if (eventId == null || marketId == null) return null;

    return ExtractedKey(
      key: '${type}_${eventId}_$marketId',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      marketId: marketId,
    );
  }

  /// Extract odds key with special handling for arrays
  ExtractedKey? _extractOddsKey(String raw, String type, int? sportId) {
    // Check if kafkaOddsList has multiple items
    if (_hasMultipleOddsItems(raw)) {
      // DON'T dedup batch messages - use unique key
      return ExtractedKey(
        key: 'odds_batch_${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        raw: raw,
        sportId: sportId,
        isBatch: true,
      );
    }

    // Single odds item - extract for deduplication
    final eventId = _extractIntValue(raw, JsonField.eventId);
    final marketId = _extractIntValue(raw, JsonField.marketId);
    final timeRange =
        _extractStringValue(raw, JsonField.timeRange) ?? TimeRange.live;

    if (eventId == null) return null;

    return ExtractedKey(
      key: '${type}_${eventId}_${marketId ?? 0}_$timeRange',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      marketId: marketId,
    );
  }

  /// Extract odds remove key
  ExtractedKey? _extractOddsRemoveKey(String raw, String type, int? sportId) {
    final eventId = _extractIntValue(raw, JsonField.eventId);
    final marketId = _extractIntValue(raw, JsonField.marketId);

    if (eventId == null) return null;

    return ExtractedKey(
      key: '${type}_${eventId}_${marketId ?? 0}',
      type: type,
      raw: raw,
      sportId: sportId,
      eventId: eventId,
      marketId: marketId,
    );
  }

  /// Check if kafkaOddsList has multiple items
  /// Uses simple heuristic: count commas after "[" before first "}"
  bool _hasMultipleOddsItems(String raw) {
    final listStart = raw.indexOf(JsonField.kafkaOddsList);
    if (listStart == -1) return false;

    // Find first occurrence of "},{"  which indicates multiple items
    final multiIndicator = raw.indexOf('},{', listStart);
    if (multiIndicator == -1) return false;

    // Make sure it's within kafkaOddsList (before closing "]")
    final listEnd = raw.indexOf(']', listStart);
    return listEnd > multiIndicator;
  }

  /// Extract string value after prefix - O(n) where n is prefix + value length
  /// Example: '"t":"odds_up"' with prefix '"t":"' returns 'odds_up'
  String? _extractStringValue(String raw, String prefix) {
    final start = raw.indexOf(prefix);
    if (start == -1) return null;

    final valueStart = start + prefix.length;
    if (valueStart >= raw.length) return null;

    // Find closing quote
    final valueEnd = raw.indexOf('"', valueStart);
    if (valueEnd == -1) return null;

    return raw.substring(valueStart, valueEnd);
  }

  /// Extract int value after prefix - O(n) where n is prefix + digits length
  /// Example: '"eventId":123,' with prefix '"eventId":' returns 123
  int? _extractIntValue(String raw, String prefix) {
    final start = raw.indexOf(prefix);
    if (start == -1) return null;

    final valueStart = start + prefix.length;
    if (valueStart >= raw.length) return null;

    // Read digits (and optional negative sign)
    var valueEnd = valueStart;
    if (valueEnd < raw.length && raw.codeUnitAt(valueEnd) == 45) {
      // '-' sign
      valueEnd++;
    }

    while (valueEnd < raw.length) {
      final c = raw.codeUnitAt(valueEnd);
      if (c < 48 || c > 57) break; // Not a digit (0-9 are 48-57)
      valueEnd++;
    }

    if (valueEnd == valueStart) return null;

    return int.tryParse(raw.substring(valueStart, valueEnd));
  }
}
