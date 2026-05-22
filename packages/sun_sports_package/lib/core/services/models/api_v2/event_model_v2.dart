import 'package:freezed_annotation/freezed_annotation.dart';

import 'market_model_v2.dart';
import 'score_model_v2.dart';

part 'event_model_v2.freezed.dart';

/// Event Model V2
///
/// Represents a sporting event (match/game).
/// API returns numeric keys.
@freezed
sealed class EventModelV2 with _$EventModelV2 {
  const factory EventModelV2({
    /// List of markets available for this event
    @Default([]) List<MarketModelV2> markets,

    /// Sport ID (1=Soccer, 2=Basketball, etc.)
    @Default(0) int sportId,

    /// League ID
    @Default(0) int leagueId,

    /// Event ID - unique identifier
    @Default(0) int eventId,

    /// Event start date in ISO format (e.g., "2026-01-22T07:30:00Z")
    @Default('') String startDate,

    /// Event start time in epoch milliseconds
    @Default(0) int startTime,

    /// Indicates if the event is suspended
    @Default(false) bool isSuspended,

    /// Indicates if the event supports parlay
    @Default(false) bool isParlay,

    /// Indicates if cash out is available
    @Default(false) bool isCashOut,

    /// Event type (e.g., 2=pre-match, 3=live, 8=live/running)
    @Default(0) int type,

    /// Event statistics ID
    @Default(0) int eventStatsId,

    /// Home team ID
    @Default(0) int homeId,

    /// Away team ID
    @Default(0) int awayId,

    /// Home team name
    @Default('') String homeName,

    /// Away team name
    @Default('') String awayName,

    /// URL of the home team logo
    @Default('') String homeLogo,

    /// URL of the away team logo
    @Default('') String awayLogo,

    /// Total number of markets available
    @Default(0) int marketCount,

    /// Indicates if the event is going live soon
    @Default(false) bool isGoingLive,

    /// Indicates if the event is currently live
    @Default(false) bool isLive,

    /// Indicates if live streaming is available
    @Default(false) bool isLiveStream,

    /// Current part of the game (e.g., 1=first half, 2=second half)
    @Default(0) int gamePart,

    /// Current game time in milliseconds
    @Default(0) int gameTime,

    /// Score information (polymorphic based on sportId)
    ScoreModelV2? score,

    /// Indicates if this event is favorited by the user
    @Default(false) bool isFavorited,
  }) = _EventModelV2;

  const EventModelV2._();

  /// Factory constructor for JSON deserialization
  /// API returns numeric keys
  factory EventModelV2.fromJson(Map<String, dynamic> json) {
    // Parse markets
    final markets = <MarketModelV2>[];
    final rawMarkets = json['1'];
    if (rawMarkets is List) {
      for (final item in rawMarkets) {
        if (item is Map) {
          markets.add(MarketModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // Parse score
    ScoreModelV2? score;
    final rawScore = json['33'];
    if (rawScore is Map) {
      score = ScoreModelV2.fromJson(Map<String, dynamic>.from(rawScore));
    }

    return EventModelV2(
      markets: markets,
      sportId: _parseInt(json['2']),
      leagueId: _parseInt(json['3']),
      eventId: _parseInt(json['4']),
      startDate: json['5']?.toString() ?? '',
      startTime: _parseInt(json['6']),
      isSuspended: json['7'] == true,
      isParlay: json['9'] == true,
      isCashOut: json['10'] == true,
      type: _parseInt(json['11']),
      eventStatsId: _parseInt(json['14']),
      homeId: _parseInt(json['17']),
      awayId: _parseInt(json['18']),
      homeName: json['19']?.toString() ?? '',
      awayName: json['20']?.toString() ?? '',
      homeLogo: json['21']?.toString() ?? '',
      awayLogo: json['22']?.toString() ?? '',
      marketCount: _parseInt(json['23']),
      isGoingLive: json['27'] == true,
      isLive: json['28'] == true,
      isLiveStream: json['29'] == true,
      gamePart: _parseInt(json['30']),
      gameTime: _parseInt(json['31']),
      score: score,
    );
  }

  /// Get start time as DateTime
  DateTime get startDateTime {
    // Try parsing ISO string first
    if (startDate.isNotEmpty) {
      final parsed = DateTime.tryParse(startDate);
      if (parsed != null) return parsed;
    }
    // Fallback to epoch milliseconds
    if (startTime > 0) {
      return DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true);
    }
    return DateTime.now();
  }

  /// Get game time in minutes
  int get gameTimeMinutes => (gameTime / 60000).floor();

  /// Get formatted game time display (e.g., "45'")
  String get gameTimeDisplay {
    if (!isLive || gameTime == 0) return '';
    final minutes = gameTimeMinutes;
    return "$minutes'";
  }

  /// Check if event is available for betting
  bool get isAvailable => !isSuspended;

  /// Get event status
  EventStatusV2 get status {
    if (isSuspended) return EventStatusV2.suspended;
    if (isLive) return EventStatusV2.live;
    if (isGoingLive) return EventStatusV2.goingLive;
    return EventStatusV2.prematch;
  }

  /// Get game part display name
  String get gamePartDisplay {
    switch (gamePart) {
      case 1:
        return '1H';
      case 2:
        return '2H';
      case 3:
        return 'HT';
      case 4:
        return 'ET1';
      case 5:
        return 'ET2';
      case 6:
        return 'PEN';
      case 7:
        return 'FT';
      case 8:
        return 'Running';
      default:
        return '';
    }
  }

  /// Get market by market ID
  MarketModelV2? getMarketById(int marketId) {
    try {
      return markets.firstWhere((m) => m.marketId == marketId);
    } catch (_) {
      return null;
    }
  }

  /// Get 1X2 full time market
  MarketModelV2? get fullTime1X2Market => getMarketById(1);

  /// Get handicap full time market
  MarketModelV2? get handicapMarket => getMarketById(3);

  /// Get over/under full time market
  MarketModelV2? get overUnderMarket => getMarketById(4);

  /// Get 1X2 first half market
  MarketModelV2? get firstHalf1X2Market => getMarketById(2);

  /// Get handicap first half market
  MarketModelV2? get handicapFirstHalfMarket => getMarketById(5);

  /// Get over/under first half market
  MarketModelV2? get overUnderFirstHalfMarket => getMarketById(6);

  /// Get score display string
  String get scoreDisplay {
    final s = score;
    if (s == null) return '- : -';
    return '${s.homeScore} - ${s.awayScore}';
  }

  /// Check if match has started
  bool get hasStarted => isLive || gameTime > 0;

  /// Full event name
  String get fullName => '$homeName vs $awayName';

  /// Get live status display (e.g., "45' | 1H")
  String get liveStatusDisplay {
    if (!isLive) return '';
    final time = gameTimeDisplay;
    final part = gamePartDisplay;
    if (time.isNotEmpty && part.isNotEmpty) {
      return '$time | $part';
    }
    return time.isNotEmpty ? time : 'LIVE';
  }
}

/// Event status enum
enum EventStatusV2 {
  prematch,
  goingLive,
  live,
  suspended;

  String get displayName {
    switch (this) {
      case EventStatusV2.prematch:
        return 'Pre-match';
      case EventStatusV2.goingLive:
        return 'Going Live';
      case EventStatusV2.live:
        return 'Live';
      case EventStatusV2.suspended:
        return 'Suspended';
    }
  }
}

/// Helper function to safely parse int
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}
