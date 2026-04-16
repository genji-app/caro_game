import 'package:freezed_annotation/freezed_annotation.dart';

import 'event_model_v2.dart';

part 'league_model_v2.freezed.dart';

/// League Model V2
///
/// Represents a league/competition with its events.
/// API returns numeric keys.
@freezed
sealed class LeagueModelV2 with _$LeagueModelV2 {
  const factory LeagueModelV2({
    /// List of events in the league
    @Default([]) List<EventModelV2> events,

    /// Sport ID (1=Soccer, 2=Basketball, etc.)
    @Default(0) int sportId,

    /// League ID - unique identifier
    @Default(0) int leagueId,

    /// Localized league name
    @Default('') String leagueName,

    /// League name in English
    @Default('') String leagueNameEn,

    /// League logo URL
    @Default('') String leagueLogo,

    /// League priority order (lower value = higher priority)
    @Default(0) int priorityOrder,

    /// Indicates if this league is favorited by the user
    @Default(false) bool isFavorited,
  }) = _LeagueModelV2;

  const LeagueModelV2._();

  /// Factory constructor for JSON deserialization
  /// API returns numeric keys.
  /// Supports two formats:
  /// - Standard: "0" = list of events, "1" = sportId, "3" = leagueId, "4" = leagueName, "5" = leagueNameEn, "8" = priorityOrder
  /// - Alternate: "0" = single event object (or list), "1" = leagueId, "2" = leagueName, "4" = priorityOrder (sportId from first event)
  factory LeagueModelV2.fromJson(Map<String, dynamic> json) {
    // Parse events: API may return "0" as List or as single event object
    final events = <EventModelV2>[];
    final rawEvents = json['0'];
    if (rawEvents is List) {
      for (final item in rawEvents) {
        if (item is Map) {
          events.add(EventModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawEvents is Map) {
      events.add(EventModelV2.fromJson(Map<String, dynamic>.from(rawEvents)));
    }

    // Detect alternate format: league has "2" as string (league name) and "4" as number (priority)
    final key2 = json['2'];
    final key4 = json['4'];
    final hasAlternateLeagueKeys = key2 is String && key4 is num;

    int sportId;
    int leagueId;
    String leagueName;
    String leagueNameEn;
    String leagueLogo;
    int priorityOrder;

    if (hasAlternateLeagueKeys) {
      sportId = events.isNotEmpty
          ? events.first.sportId
          : _parseInt(json['1']); // fallback
      leagueId = _parseInt(json['1']);
      leagueName = key2.trim();
      final key5 = json['5']?.toString() ?? '';
      // Hot API: "5" is logo URL; standard alternate: "5" = leagueNameEn, "3" = logo
      if (key5.startsWith('http')) {
        leagueLogo = key5;
        leagueNameEn = leagueName;
      } else {
        leagueLogo = json['3']?.toString() ?? '';
        leagueNameEn = key5.isEmpty ? leagueName : key5;
      }
      priorityOrder = key4.toInt();
    } else {
      sportId = _parseInt(json['1']);
      leagueId = _parseInt(json['3']);
      leagueName = key4?.toString() ?? '';
      leagueNameEn = json['5']?.toString() ?? '';
      leagueLogo = json['6']?.toString() ?? '';
      priorityOrder = _parseInt(json['8']);
    }

    return LeagueModelV2(
      events: events,
      sportId: sportId,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueNameEn: leagueNameEn,
      leagueLogo: leagueLogo,
      priorityOrder: priorityOrder,
    );
  }

  /// Get display name (prefer localized, fallback to English)
  String get displayName => leagueName.isNotEmpty ? leagueName : leagueNameEn;

  /// Total number of events
  int get eventCount => events.length;

  /// Get all live events
  List<EventModelV2> get liveEvents => events.where((e) => e.isLive).toList();

  /// Get all upcoming events
  List<EventModelV2> get upcomingEvents =>
      events.where((e) => !e.isLive && !e.isSuspended).toList();

  /// Check if league has any live events
  bool get hasLiveEvents => events.any((e) => e.isLive);

  /// Get number of live events
  int get liveEventCount => liveEvents.length;

  /// Get events sorted by start time
  List<EventModelV2> get eventsSortedByTime {
    final sorted = List<EventModelV2>.from(events);
    sorted.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sorted;
  }

  /// Get events that are available for betting
  List<EventModelV2> get availableEvents =>
      events.where((e) => e.isAvailable).toList();
}

/// Helper function to safely parse int
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

/// Extension to parse list of leagues from API response
extension LeagueListParserV2 on List<dynamic> {
  List<LeagueModelV2> toLeagueModelsV2() {
    return map((item) {
      if (item is Map<String, dynamic>) {
        return LeagueModelV2.fromJson(item);
      } else if (item is Map) {
        return LeagueModelV2.fromJson(Map<String, dynamic>.from(item));
      }
      throw const FormatException('Invalid league data format');
    }).toList();
  }
}
