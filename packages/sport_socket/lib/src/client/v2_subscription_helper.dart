import 'dart:convert';
import 'dart:typed_data';

/// Helper class for V2 channel-based subscriptions.
///
/// V2 Channel Patterns:
/// - League: `ln:{lang}:s:{sportId}:l`
/// - Match: `ln:{lang}:s:{sportId}:tr:{timeRange}:e`
/// - Match Detail: `ln:{lang}:e:{eventId}`
/// - Hot Matches: `ln:{lang}:s:{sportId}:e:hot`
/// - Outright: `ln:{lang}:s:{sportId}:e:ort`
/// - Combat Sport Match: `ln:{lang}:s:{sportId}:st:{sportTypeId}:tr:{timeRange}:e`
///
/// Time Range Values:
/// - 0: Live
/// - 1: Today
/// - 2: Early
///
/// IMPORTANT: All messages are sent as BINARY frames (raw UTF-8 bytes).
/// Flow: message → UTF-8 bytes → send as BINARY (NO Base64 encoding)
class V2SubscriptionHelper {
  /// Default language
  static const String defaultLanguage = 'vi';

  /// Build league channel string
  static String leagueChannel(int sportId, {String lang = defaultLanguage}) {
    return 'ln:$lang:s:$sportId:l';
  }

  /// Build match channel string
  static String matchChannel(
    int sportId,
    int timeRange, {
    String lang = defaultLanguage,
    int? sportTypeId,
  }) {
    if (sportTypeId != null) {
      // Combat sport format
      return 'ln:$lang:s:$sportId:st:$sportTypeId:tr:$timeRange:e';
    }
    return 'ln:$lang:s:$sportId:tr:$timeRange:e';
  }

  /// Build match detail channel string
  static String matchDetailChannel(int eventId,
      {String lang = defaultLanguage}) {
    return 'ln:$lang:e:$eventId';
  }

  /// Build hot matches channel string
  static String hotChannel(int sportId, {String lang = defaultLanguage}) {
    return 'ln:$lang:s:$sportId:e:hot';
  }

  /// Build outright channel string
  static String outrightChannel(int sportId, {String lang = defaultLanguage}) {
    return 'ln:$lang:s:$sportId:e:ort';
  }

  /// Build SUBSCRIBE message as binary (raw UTF-8 bytes)
  ///
  /// Server expects BINARY frame with raw message (NO Base64 encoding)
  /// Flow: "SUBSCRIBE:channel" → UTF-8 bytes → send as BINARY
  static Uint8List subscribeMessage(String channel) {
    final message = 'SUBSCRIBE:$channel';
    return Uint8List.fromList(utf8.encode(message));
  }

  /// Build UNSUBSCRIBE message as binary (raw UTF-8 bytes)
  ///
  /// Server expects BINARY frame with raw message (NO Base64 encoding)
  /// Flow: "UNSUBSCRIBE:channel" → UTF-8 bytes → send as BINARY
  static Uint8List unsubscribeMessage(String channel) {
    final message = 'UNSUBSCRIBE:$channel';
    return Uint8List.fromList(utf8.encode(message));
  }

  /// Build ping message as binary (raw UTF-8 bytes)
  ///
  /// Server expects BINARY frame with raw ping_<number> (NOT Base64 encoded)
  static Uint8List pingMessage(int pingNumber) {
    final message = 'ping_$pingNumber';
    return Uint8List.fromList(utf8.encode(message));
  }

  /// Parse sportId from channel string
  /// Returns null if channel format is invalid
  static int? parseSportId(String channel) {
    // Pattern: ln:{lang}:s:{sportId}:...
    final parts = channel.split(':');
    final sIndex = parts.indexOf('s');
    if (sIndex >= 0 && sIndex < parts.length - 1) {
      return int.tryParse(parts[sIndex + 1]);
    }
    return null;
  }

  /// Parse timeRange from channel string
  /// Returns null if channel doesn't contain timeRange
  static int? parseTimeRange(String channel) {
    // Pattern: ...tr:{timeRange}:e
    final parts = channel.split(':');
    final trIndex = parts.indexOf('tr');
    if (trIndex >= 0 && trIndex < parts.length - 1) {
      return int.tryParse(parts[trIndex + 1]);
    }
    return null;
  }

  /// Parse eventId from match detail channel
  /// Returns null if channel format is invalid
  static int? parseEventId(String channel) {
    // Pattern: ln:{lang}:e:{eventId}
    final parts = channel.split(':');
    final eIndex = parts.indexOf('e');
    if (eIndex >= 0 && eIndex < parts.length - 1) {
      return int.tryParse(parts[eIndex + 1]);
    }
    return null;
  }

  /// Check if channel is a league channel
  static bool isLeagueChannel(String channel) {
    return channel.endsWith(':l') && channel.contains(':s:');
  }

  /// Check if channel is a match channel
  static bool isMatchChannel(String channel) {
    return channel.endsWith(':e') && channel.contains(':tr:');
  }

  /// Check if channel is a match detail channel
  static bool isMatchDetailChannel(String channel) {
    // Pattern: ln:{lang}:e:{eventId} - ends with digits
    final parts = channel.split(':');
    if (parts.length < 3) return false;
    final eIndex = parts.indexOf('e');
    if (eIndex < 0 || eIndex >= parts.length - 1) return false;
    return int.tryParse(parts[eIndex + 1]) != null;
  }

  /// Check if channel is a hot matches channel
  static bool isHotChannel(String channel) {
    return channel.endsWith(':e:hot');
  }

  /// Check if channel is an outright channel
  static bool isOutrightChannel(String channel) {
    return channel.endsWith(':e:ort');
  }
}

/// Time range constants for V2 subscriptions
class V2TimeRange {
  static const int live = 0;
  static const int today = 1;
  static const int early = 2;

  /// Convert string time range to int
  static int fromString(String timeRange) {
    switch (timeRange.toUpperCase()) {
      case 'LIVE':
        return live;
      case 'TODAY':
        return today;
      case 'EARLY':
        return early;
      default:
        return live;
    }
  }

  /// Convert int time range to string
  static String toStringValue(int timeRange) {
    switch (timeRange) {
      case live:
        return 'LIVE';
      case today:
        return 'TODAY';
      case early:
        return 'EARLY';
      default:
        return 'LIVE';
    }
  }
}

/// Combat sport type IDs
class CombatSportType {
  static const int muayThai = 1;
  static const int mma = 2;
  static const int boxing = 3;
}
