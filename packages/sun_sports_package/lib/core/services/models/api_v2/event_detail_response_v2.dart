import 'package:freezed_annotation/freezed_annotation.dart';

import 'market_model_v2.dart';

part 'event_detail_response_v2.freezed.dart';

/// Event Detail Response V2
///
/// Response from GET /api/app/events/{eventId}?isMobile=true&onlyParlay=false
/// API returns EventResponse directly (no wrapper).
/// Contains full markets including children (Corner, Extra, Penalty).
@freezed
sealed class EventDetailResponseV2 with _$EventDetailResponseV2 {
  const factory EventDetailResponseV2({
    /// Children events (Corner, Extra Time, Penalty)
    @Default([]) List<EventDetailResponseV2> children,

    /// Full markets array
    @Default([]) List<MarketModelV2> markets,

    /// Sport ID (1=Soccer, 2=Basketball, etc.)
    @Default(0) int sportId,

    /// League ID
    @Default(0) int leagueId,

    /// Event ID - unique identifier
    @Default(0) int eventId,

    /// Event start date in ISO format
    @Default('') String startDate,

    /// Event start time in epoch milliseconds
    @Default(0) int startTime,

    /// Indicates if the event is suspended
    @Default(false) bool isSuspended,

    /// Indicates if the event is hidden
    @Default(false) bool isHidden,

    /// Indicates if the event supports parlay
    @Default(false) bool isParlay,

    /// Indicates if cash out is available
    @Default(false) bool isCashOut,

    /// Event type
    @Default(0) int type,

    /// Event statistics ID for tracker
    @Default(0) int eventStatsId,

    /// Home team ID
    @Default(0) int homeId,

    /// Away team ID
    @Default(0) int awayId,

    /// Home team name
    @Default('') String homeName,

    /// Away team name
    @Default('') String awayName,

    /// Home team logo URL
    @Default('') String homeLogo,

    /// Away team logo URL
    @Default('') String awayLogo,

    /// Total number of markets available
    @Default(0) int marketCount,

    /// Market group IDs for tab filtering
    List<int>? marketGroups,

    /// Indicates if the event is hot/featured
    @Default(false) bool isHot,

    /// Indicates if the event is going live soon
    @Default(false) bool isGoingLive,

    /// Indicates if the event is currently live
    @Default(false) bool isLive,

    /// Indicates if live streaming is available
    @Default(false) bool isLiveStream,

    /// Current part of the game (1=1H, 2=2H, 3=HT, etc.)
    @Default(0) int gamePart,

    /// Current game time in milliseconds
    @Default(0) int gameTime,

    /// Stoppage time in milliseconds
    @Default(0) int stoppageTime,

    /// Raw score data (parse separately based on sportId)
    Map<String, dynamic>? scoreRaw,

    /// Child type (only for child events: 1=Extra, 2=Corner, 3=Penalty)
    int? childType,
  }) = _EventDetailResponseV2;

  const EventDetailResponseV2._();

  /// Factory constructor for JSON deserialization
  /// API returns numeric keys
  factory EventDetailResponseV2.fromJson(Map<String, dynamic> json) {
    // Parse children (key "0") - recursive for child events
    final children = <EventDetailResponseV2>[];
    final rawChildren = json['0'];
    if (rawChildren is List) {
      for (final item in rawChildren) {
        if (item is Map) {
          children.add(
            EventDetailResponseV2.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    // Parse markets (key "1") - reuse existing MarketModelV2
    final markets = <MarketModelV2>[];
    final rawMarkets = json['1'];
    if (rawMarkets is List) {
      for (final item in rawMarkets) {
        if (item is Map) {
          markets.add(MarketModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // Parse market groups (key "24")
    List<int>? marketGroups;
    final rawGroups = json['24'];
    if (rawGroups is List) {
      marketGroups = rawGroups.whereType<int>().toList();
    }

    // Parse score raw (key "33")
    Map<String, dynamic>? scoreRaw;
    final rawScore = json['33'];
    if (rawScore is Map) {
      scoreRaw = Map<String, dynamic>.from(rawScore);
    }

    return EventDetailResponseV2(
      children: children,
      markets: markets,
      sportId: _parseInt(json['2']),
      leagueId: _parseInt(json['3']),
      eventId: _parseInt(json['4']),
      startDate: json['5']?.toString() ?? '',
      startTime: _parseInt(json['6']),
      isSuspended: json['7'] == true,
      isHidden: json['8'] == true,
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
      marketGroups: marketGroups,
      isHot: json['26'] == true,
      isGoingLive: json['27'] == true,
      isLive: json['28'] == true,
      isLiveStream: json['29'] == true,
      gamePart: _parseInt(json['30']),
      gameTime: _parseInt(json['31']),
      stoppageTime: _parseInt(json['32']),
      scoreRaw: scoreRaw,
      childType: json['34'] as int?,
    );
  }

  /// Get all markets including from child events
  List<MarketModelV2> get allMarkets {
    final all = <MarketModelV2>[...markets];
    for (final child in children) {
      all.addAll(child.markets);
    }
    return all;
  }

  /// Get child events by type
  List<EventDetailResponseV2> getChildrenByType(int type) {
    return children.where((c) => c.childType == type).toList();
  }

  /// Get Corner child events (childType = 2)
  List<EventDetailResponseV2> get cornerChildren => getChildrenByType(2);

  /// Get Extra Time child events (childType = 1)
  List<EventDetailResponseV2> get extraTimeChildren => getChildrenByType(1);

  /// Get Penalty child events (childType = 3)
  List<EventDetailResponseV2> get penaltyChildren => getChildrenByType(3);

  /// Get Corner markets from child events
  List<MarketModelV2> get cornerMarkets =>
      cornerChildren.expand((c) => c.markets).toList();

  /// Get Extra Time markets from child events
  List<MarketModelV2> get extraTimeMarkets =>
      extraTimeChildren.expand((c) => c.markets).toList();

  /// Get Penalty markets from child events
  List<MarketModelV2> get penaltyMarkets =>
      penaltyChildren.expand((c) => c.markets).toList();

  /// Full event name
  String get fullName => '$homeName vs $awayName';

  /// Check if event is available for betting
  bool get isAvailable => !isSuspended && !isHidden;
}

/// Child event type enum
enum ChildEventType {
  extraTime(1),
  corner(2),
  penalty(3);

  final int value;
  const ChildEventType(this.value);

  static ChildEventType? fromValue(int? value) {
    if (value == null) return null;
    return ChildEventType.values.cast<ChildEventType?>().firstWhere(
      (e) => e?.value == value,
      orElse: () => null,
    );
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
