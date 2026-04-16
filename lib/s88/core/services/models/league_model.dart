import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/event_status.dart';

part 'league_model.freezed.dart';
part 'league_model.g.dart';

// ===== MAIN DATA MODELS =====

/// League Data Model
///
/// Represents a league/competition with events.
/// Maps to API response format: { li, ln, lg, lpo, e, eo }
///
/// Hierarchy: League → Event → Market → Odds
@freezed
sealed class LeagueData with _$LeagueData {
  const factory LeagueData({
    /// League ID (API: li)
    @JsonKey(name: 'li') @Default(0) int leagueId,

    /// League Name (API: ln)
    @JsonKey(name: 'ln') @Default('') String leagueName,

    /// League Logo URL (API: lg)
    @JsonKey(name: 'lg') @Default('') String leagueLogo,

    /// Priority Order (API: lpo)
    @JsonKey(name: 'lpo') int? priorityOrder,

    /// Events list (API: e)
    @JsonKey(name: 'e') @Default([]) List<LeagueEventData> events,

    /// Outright events (API: eo) - for championship bets
    @JsonKey(name: 'eo') List<OutrightData>? outrightEvents,
  }) = _LeagueData;

  factory LeagueData.fromJson(Map<String, dynamic> json) =>
      _$LeagueDataFromJson(json);
}

/// Event Data Model (for League API)
///
/// Represents a sports event/match within a league.
/// Maps to API response format from EventDataHtml (Flutter_Event_Market_Odds_Guide.md)
///
/// Logo fields follow Web logic (SbEventItem.ts:1606, 1609):
/// - homeLogo = hf || hl || ''
/// - awayLogo = af || al || ''
@freezed
sealed class LeagueEventData with _$LeagueEventData {
  const factory LeagueEventData({
    /// Event ID (API: ei) - required
    @JsonKey(name: 'ei') @Default(0) int eventId,

    /// Event Name - optional (API: en)
    @JsonKey(name: 'en') String? eventName,

    /// Home Team ID (API: hi)
    @JsonKey(name: 'hi') @Default(0) int homeId,

    /// Home Team Name (API: hn) - required
    @JsonKey(name: 'hn') @Default('') String homeName,

    /// Away Team ID (API: ai)
    @JsonKey(name: 'ai') @Default(0) int awayId,

    /// Away Team Name (API: an) - required
    @JsonKey(name: 'an') @Default('') String awayName,

    /// Home Team Logo Primary (API: hf)
    @JsonKey(name: 'hf') String? homeLogoFirst,

    /// Home Team Logo Fallback (API: hl)
    @JsonKey(name: 'hl') String? homeLogoLast,

    /// Away Team Logo Primary (API: af)
    @JsonKey(name: 'af') String? awayLogoFirst,

    /// Away Team Logo Fallback (API: al)
    @JsonKey(name: 'al') String? awayLogoLast,

    /// Start Time - timestamp in milliseconds or datetime string (API: et or st)
    @JsonKey(name: 'st', fromJson: _parseStartTime, readValue: _readStartTime)
    @Default(0)
    int startTime,

    /// Home Score (API: hs)
    @JsonKey(name: 'hs') @Default(0) int homeScore,

    /// Away Score (API: as)
    @JsonKey(name: 'as') @Default(0) int awayScore,

    /// Is Live match (API: l)
    @JsonKey(name: 'l') @Default(false) bool isLive,

    /// Is Going Live (API: gl)
    @JsonKey(name: 'gl') @Default(false) bool isGoingLive,

    /// Is Livestream available (API: ls)
    @JsonKey(name: 'ls') @Default(false) bool isLivestream,

    /// Is Suspended (API: s)
    @JsonKey(name: 's') @Default(false) bool isSuspended,

    /// Event Status (API: es)
    @JsonKey(name: 'es') String? eventStatus,

    /// Event Stats ID for Tracker (API: esi)
    /// Used to build tracker URL: route=8&m={eventStatsId}
    @JsonKey(name: 'esi') @Default(0) int eventStatsId,

    /// Game Time in milliseconds (API: gt)
    /// According to FLUTTER_LIVE_MATCH_STATS_GUIDE.md: gt is in milliseconds
    @JsonKey(name: 'gt') @Default(0) int gameTime,

    /// Game Part/Period (API: gp)
    @JsonKey(name: 'gp') @Default(0) int gamePart,

    /// Stoppage Time in milliseconds (API: stm)
    /// Time added for stoppages/injuries (bù giờ)
    @JsonKey(name: 'stm') @Default(0) int stoppageTime,

    /// Home Corners (API: hc)
    @JsonKey(name: 'hc') @Default(0) int cornersHome,

    /// Away Corners (API: ac)
    @JsonKey(name: 'ac') @Default(0) int cornersAway,

    /// Home Red Cards (API: rch)
    @JsonKey(name: 'rch') @Default(0) int redCardsHome,

    /// Away Red Cards (API: rca)
    @JsonKey(name: 'rca') @Default(0) int redCardsAway,

    /// Home Yellow Cards (API: ych)
    @JsonKey(name: 'ych') @Default(0) int yellowCardsHome,

    /// Away Yellow Cards (API: yca)
    @JsonKey(name: 'yca') @Default(0) int yellowCardsAway,

    /// Total Markets Count (API: mc)
    @JsonKey(name: 'mc') @Default(0) int totalMarketsCount,

    /// Is Parlay enabled (API: ip)
    @JsonKey(name: 'ip') @Default(false) bool isParlay,

    /// Match minute for live - legacy field (API: min)
    @JsonKey(name: 'min') int? minute,

    /// Markets list (API: m)
    @JsonKey(name: 'm') @Default([]) List<LeagueMarketData> markets,
  }) = _LeagueEventData;

  factory LeagueEventData.fromJson(Map<String, dynamic> json) =>
      _$LeagueEventDataFromJson(json);
}

/// Helper to read startTime from either 'st' or 'et' field
Object? _readStartTime(Map<dynamic, dynamic> json, String key) {
  return json['st'] ?? json['et'];
}

/// Parse startTime from various formats (int timestamp, String ISO 8601)
int _parseStartTime(dynamic value) {
  if (value == null) return 0;

  // Already an int (timestamp in milliseconds)
  if (value is int) return value;

  // Number type (could be double from JSON)
  if (value is num) return value.toInt();

  // String format - could be ISO 8601 or numeric string
  if (value is String) {
    // Try parsing as number first
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt;

    // Try parsing as ISO 8601 datetime
    final dateTime = DateTime.tryParse(value);
    if (dateTime != null) return dateTime.millisecondsSinceEpoch;
  }

  return 0;
}

/// Market Data Model (for League API)
///
/// Represents a betting market type (Handicap, Over/Under, 1x2).
/// Maps to API response format: { mi, mn, ip, o }
@freezed
sealed class LeagueMarketData with _$LeagueMarketData {
  const factory LeagueMarketData({
    /// Market ID (API: mi) - required
    @JsonKey(name: 'mi') @Default(0) int marketId,

    /// Market Name (API: mn)
    @JsonKey(name: 'mn') @Default('') String marketName,

    /// Market Type/Class (API: mt) - e.g., 'ah' for Asian Handicap
    @JsonKey(name: 'mt') String? marketType,

    /// Is Parlay enabled (API: ip)
    @JsonKey(name: 'ip') @Default(false) bool isParlay,

    /// Odds list (API: o)
    @JsonKey(name: 'o') @Default([]) List<LeagueOddsData> odds,
  }) = _LeagueMarketData;

  factory LeagueMarketData.fromJson(Map<String, dynamic> json) =>
      _$LeagueMarketDataFromJson(json);
}

/// Odds Data Model (for League API)
///
/// Represents betting odds for a selection.
/// Maps to API response format: { p, ml, shi, sai, sdi, soi, oh, oa, od }
///
/// Supports both legacy format (ho, ao, do) and new format (oh, oa, od with multi-style)
@freezed
sealed class LeagueOddsData with _$LeagueOddsData {
  const factory LeagueOddsData({
    /// Points/Handicap value (API: p) - e.g., "-0.5", "2.5"
    @JsonKey(name: 'p') @Default('') String points,

    /// Is Main Line (API: ml)
    @JsonKey(name: 'ml') @Default(false) bool isMainLine,

    /// Selection Home ID (API: shi)
    @JsonKey(name: 'shi') String? selectionHomeId,

    /// Selection Away ID (API: sai)
    @JsonKey(name: 'sai') String? selectionAwayId,

    /// Selection Draw ID (API: sdi)
    @JsonKey(name: 'sdi') String? selectionDrawId,

    /// Offer ID (API: soi) - used for placing bets
    @JsonKey(name: 'soi') String? offerId,

    /// Home Odds Object (API: oh) - contains {ma, in, de, hk}
    @JsonKey(
      name: 'oh',
      fromJson: OddsValue.fromJson,
      toJson: OddsValue.toJsonStatic,
    )
    @Default(OddsValue())
    OddsValue oddsHome,

    /// Away Odds Object (API: oa) - contains {ma, in, de, hk}
    @JsonKey(
      name: 'oa',
      fromJson: OddsValue.fromJson,
      toJson: OddsValue.toJsonStatic,
    )
    @Default(OddsValue())
    OddsValue oddsAway,

    /// Draw Odds Object (API: od) - contains {ma, in, de, hk}
    @JsonKey(
      name: 'od',
      fromJson: OddsValue.fromJson,
      toJson: OddsValue.toJsonStatic,
    )
    @Default(OddsValue())
    OddsValue oddsDraw,

    // === Legacy fields for backward compatibility ===

    /// Legacy Home Odds (API: ho)
    @JsonKey(name: 'ho') double? homeOddsLegacy,

    /// Legacy Away Odds (API: ao)
    @JsonKey(name: 'ao') double? awayOddsLegacy,

    /// Legacy Draw Odds (API: do)
    @JsonKey(name: 'do') double? drawOddsLegacy,

    /// Legacy Offer ID (API: oi)
    @JsonKey(name: 'oi') String? offerIdLegacy,

    /// Legacy Selection ID (API: si)
    @JsonKey(name: 'si') String? selectionIdLegacy,
  }) = _LeagueOddsData;

  factory LeagueOddsData.fromJson(Map<String, dynamic> json) =>
      _$LeagueOddsDataFromJson(json);
}

/// Odds Value Object
///
/// Contains odds in multiple formats: Malay, Indo, Decimal, Hong Kong
/// Maps to API: { ma, in, de, hk }
class OddsValue {
  final double malay;
  final double indo;
  final double decimal;
  final double hongKong;

  const OddsValue({
    this.malay = -100,
    this.indo = -100,
    this.decimal = -100,
    this.hongKong = -100,
  });

  /// Create from JSON map
  factory OddsValue.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OddsValue();
    return OddsValue(
      malay: _parseOdds(json['ma']),
      indo: _parseOdds(json['in']),
      decimal: _parseOdds(json['de']),
      hongKong: _parseOdds(json['hk']),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
    'ma': malay.toString(),
    'in': indo.toString(),
    'de': decimal.toString(),
    'hk': hongKong.toString(),
  };

  /// Static method for Freezed toJson
  static Map<String, dynamic>? toJsonStatic(OddsValue value) => value.toJson();

  /// Parse odds from various types
  static double _parseOdds(dynamic value) {
    if (value == null) return -100;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? -100;
    return -100;
  }

  /// Get odds by style
  double getByStyle(OddsStyle style) {
    switch (style) {
      case OddsStyle.malay:
        return malay;
      case OddsStyle.indo:
        return indo;
      case OddsStyle.decimal:
        return decimal;
      case OddsStyle.hongKong:
        return hongKong;
    }
  }

  /// Check if odds value is valid
  bool get isValid => decimal > 0 && decimal != -100;

  /// Format odds for display
  String format({int decimals = 2}) {
    if (!isValid) return '-';
    return decimal.toStringAsFixed(decimals);
  }

  @override
  String toString() =>
      'OddsValue(ma: $malay, in: $indo, de: $decimal, hk: $hongKong)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OddsValue &&
          runtimeType == other.runtimeType &&
          malay == other.malay &&
          indo == other.indo &&
          decimal == other.decimal &&
          hongKong == other.hongKong;

  @override
  int get hashCode => Object.hash(malay, indo, decimal, hongKong);
}

/// Outright Data Model
///
/// Represents outright/futures bets (e.g., League Winner).
@freezed
sealed class OutrightData with _$OutrightData {
  const factory OutrightData({
    /// Outright ID
    @JsonKey(name: 'oi') @Default(0) int outrightId,

    /// Outright Name
    @JsonKey(name: 'on') @Default('') String outrightName,

    /// Selections/Odds
    @JsonKey(name: 'os') @Default([]) List<OutrightSelection> selections,
  }) = _OutrightData;

  factory OutrightData.fromJson(Map<String, dynamic> json) =>
      _$OutrightDataFromJson(json);
}

/// Outright Selection
@freezed
sealed class OutrightSelection with _$OutrightSelection {
  const factory OutrightSelection({
    /// Selection ID
    @JsonKey(name: 'si') @Default('') String selectionId,

    /// Selection Name (Team/Player)
    @JsonKey(name: 'sn') @Default('') String selectionName,

    /// Odds value
    @JsonKey(name: 'od') @Default(0.0) double odds,

    /// Offer ID
    @JsonKey(name: 'oi') String? offerId,
  }) = _OutrightSelection;

  factory OutrightSelection.fromJson(Map<String, dynamic> json) =>
      _$OutrightSelectionFromJson(json);
}

// ===== EXTENSIONS =====

/// LeagueData Extensions
extension LeagueDataX on LeagueData {
  /// Check if this is an outright-only league
  bool get isOutrightOnly =>
      outrightEvents != null && outrightEvents!.isNotEmpty && events.isEmpty;

  /// Get total events count
  int get totalEvents => events.length;

  /// Get live events
  List<LeagueEventData> get liveEvents =>
      events.where((e) => e.isLive).toList();

  /// Get upcoming events
  List<LeagueEventData> get upcomingEvents =>
      events.where((e) => !e.isLive).toList();

  /// Get events sorted by start time
  List<LeagueEventData> get eventsSortedByTime =>
      List.from(events)..sort((a, b) => a.startTime.compareTo(b.startTime));
}

/// LeagueEventData Extensions
extension LeagueEventDataX on LeagueEventData {
  /// Get full match name
  String get fullName => '$homeName vs $awayName';

  /// Get display name (use eventName if available, otherwise fullName)
  String get displayName => eventName ?? fullName;

  /// Get score string
  String get scoreString => '$homeScore - $awayScore';

  /// Get start time as DateTime
  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(startTime);

  /// Get formatted time (dd/MM/yyyy | HH:mm)
  String get formattedTime {
    final dt = startDateTime;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year | $hour:$minute';
  }

  /// Get formatted date (dd/MM)
  String get formattedDate {
    final dt = startDateTime;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  /// Get formatted date time (dd/MM HH:mm)
  String get formattedDateTime => '$formattedDate $formattedTime';

  /// Check if match has started
  bool get hasStarted => DateTime.now().millisecondsSinceEpoch > startTime;

  /// Get match minute string for live matches
  /// Converts gameTime from milliseconds to minutes
  /// Handles stoppage time (bù giờ) according to FLUTTER_LIVE_MATCH_STATS_GUIDE.md
  String get minuteString {
    if (!isLive) return '';

    // Convert gameTime from milliseconds to minutes
    final minutes = gameTime > 0 ? (gameTime / 1000 / 60).ceil() : 0;
    final stoppageMinutes = stoppageTime > 0
        ? (stoppageTime / 1000 / 60).ceil()
        : 0;

    // If we have valid gameTime, use it
    if (minutes > 0) {
      // Handle stoppage time (bù giờ)
      if (stoppageMinutes > 0) {
        // Check if we're in first half or second half
        final part = gamePartEnum;
        if (part == GamePart.firstHalf) {
          return "45+$stoppageMinutes'";
        } else if (part == GamePart.secondHalf) {
          return "90+$stoppageMinutes'";
        }
        // For other periods, show minutes + stoppage
        return "$minutes+$stoppageMinutes'";
      }
      return "$minutes'";
    }

    // Fallback to legacy minute field if available
    if (minute != null && minute! > 0) return "$minute'";
    return 'LIVE';
  }

  /// Get game part display
  GamePart get gamePartEnum => GamePart.fromInt(gamePart);

  /// Get live status display (e.g., "45' | Hiệp 1" or "LIVE")
  String get liveStatusDisplay {
    if (!isLive) return '';
    final min = minuteString;
    final part = gamePartEnum.displayName;
    if (min.isNotEmpty && part != 'Not Started') {
      return '$min | $part';
    }
    return min.isNotEmpty ? min : 'LIVE';
  }

  /// Get event status enum
  EventStatus get status => EventStatusX.fromString(eventStatus);

  /// Check if event can be bet on
  bool get canBet => !isSuspended && status == EventStatus.active;

  /// Get home team logo with fallback logic
  /// Priority: hf (homeLogoFirst) → hl (homeLogoLast) → ''
  /// Matches Web logic: instance._homeLogo = hf || hl || '';
  String get homeLogo {
    if (homeLogoFirst != null && homeLogoFirst!.isNotEmpty) {
      return homeLogoFirst!;
    }
    if (homeLogoLast != null && homeLogoLast!.isNotEmpty) {
      return homeLogoLast!;
    }
    return '';
  }

  /// Get away team logo with fallback logic
  /// Priority: af (awayLogoFirst) → al (awayLogoLast) → ''
  /// Matches Web logic: instance._awayLogo = af || al || '';
  String get awayLogo {
    if (awayLogoFirst != null && awayLogoFirst!.isNotEmpty) {
      return awayLogoFirst!;
    }
    if (awayLogoLast != null && awayLogoLast!.isNotEmpty) {
      return awayLogoLast!;
    }
    return '';
  }

  /// Get market by ID
  LeagueMarketData? getMarketById(int marketId) {
    try {
      return markets.firstWhere((m) => m.marketId == marketId);
    } catch (e) {
      return null;
    }
  }

  /// Get main markets for display (Handicap, O/U, 1X2)
  List<LeagueMarketData> getMainMarkets(int sportId) {
    final mainIds = MarketHelper.getMainMarketIds(sportId);
    return markets.where((m) => mainIds.contains(m.marketId)).toList();
  }

  /// Check if has any valid markets
  bool get hasMarkets => markets.isNotEmpty;

  /// Get total cards (red + yellow)
  int get totalCardsHome => redCardsHome + yellowCardsHome;
  int get totalCardsAway => redCardsAway + yellowCardsAway;
}

/// LeagueMarketData Extensions
extension LeagueMarketDataX on LeagueMarketData {
  /// Get market name (use helper if empty)
  String get displayName =>
      marketName.isNotEmpty ? marketName : MarketHelper.getMarketName(marketId);

  /// Check market types
  bool get isHandicap => MarketHelper.isHandicap(marketId);
  bool get isOverUnder => MarketHelper.isOverUnder(marketId);
  bool get is1X2 => MarketHelper.is1X2(marketId);
  bool get isMoneyLine => MarketHelper.isMoneyLine(marketId);
  bool get isOddEven => MarketHelper.isOddEven(marketId);
  bool get isCorrectScore => MarketHelper.isCorrectScore(marketId);

  /// Check if should always show decimal odds
  bool get isAlwaysDecimal => MarketHelper.isAlwaysDecimal(marketId);

  /// Get odds types for this market
  List<OddsType> get oddsTypes => MarketHelper.getOddsTypes(marketId);

  /// Get visible odds (filtered)
  List<LeagueOddsData> get visibleOdds =>
      odds.where((o) => o.points.isNotEmpty || is1X2).toList();

  /// Get main line odds
  LeagueOddsData? get mainLineOdds {
    try {
      return odds.firstWhere((o) => o.isMainLine);
    } catch (e) {
      return odds.isNotEmpty ? odds.first : null;
    }
  }
}

/// LeagueOddsData Extensions
extension LeagueOddsDataX on LeagueOddsData {
  /// Get points as double
  double get pointsValue => double.tryParse(points) ?? 0.0;

  /// Get home odds value (supports both new and legacy format)
  double getHomeOdds(OddsStyle style) {
    if (oddsHome.isValid) {
      return oddsHome.getByStyle(style);
    }
    return homeOddsLegacy ?? -100;
  }

  /// Get away odds value (supports both new and legacy format)
  double getAwayOdds(OddsStyle style) {
    if (oddsAway.isValid) {
      return oddsAway.getByStyle(style);
    }
    return awayOddsLegacy ?? -100;
  }

  /// Get draw odds value (supports both new and legacy format)
  double? getDrawOdds(OddsStyle style) {
    if (oddsDraw.isValid) {
      return oddsDraw.getByStyle(style);
    }
    return drawOddsLegacy;
  }

  /// Format home odds for display
  /// Returns '-' for invalid values (-100, 0, or too small for decimal style)
  String formattedHomeOdds(OddsStyle style, {int decimals = 2}) {
    final value = getHomeOdds(style);
    if (!_isValidOddsValue(value, style)) return '-';
    return value.toStringAsFixed(decimals);
  }

  /// Format away odds for display
  /// Returns '-' for invalid values (-100, 0, or too small for decimal style)
  String formattedAwayOdds(OddsStyle style, {int decimals = 2}) {
    final value = getAwayOdds(style);
    if (!_isValidOddsValue(value, style)) return '-';
    return value.toStringAsFixed(decimals);
  }

  /// Format draw odds for display
  /// Returns null for invalid values
  String? formattedDrawOdds(OddsStyle style, {int decimals = 2}) {
    final value = getDrawOdds(style);
    if (value == null || !_isValidOddsValue(value, style)) return null;
    return value.toStringAsFixed(decimals);
  }

  /// Check if odds value is valid for the given style
  /// - -100 is our sentinel for "no data"
  /// - 0 is never a valid odds value
  /// - For Decimal style, valid odds must be >= 1.00
  /// - For HK style, valid odds must be > 0
  /// - For Malay/Indo, can be negative but not 0
  bool _isValidOddsValue(double value, OddsStyle style) {
    if (value == -100 || value == 0) return false;
    if (style == OddsStyle.decimal && value < 1.0) return false;
    if (style == OddsStyle.hongKong && value <= 0) return false;
    return true;
  }

  /// Check if this is a 3-way market (has draw)
  bool get hasDrawOdds =>
      oddsDraw.isValid || (drawOddsLegacy != null && drawOddsLegacy! > 0);

  /// Get effective offer ID (new or legacy)
  String? get effectiveOfferId => offerId ?? offerIdLegacy;

  /// Get effective selection ID for home (new or legacy)
  String? get effectiveHomeSelectionId => selectionHomeId ?? selectionIdLegacy;

  /// Get effective selection ID for away
  String? get effectiveAwaySelectionId => selectionAwayId;

  /// Get effective selection ID for draw
  String? get effectiveDrawSelectionId => selectionDrawId;

  /// Check if odds are valid for betting
  bool get isValid => oddsHome.isValid || homeOddsLegacy != null;
}

// ===== MARKET HELPER =====

/// Market Helper Class
///
/// Utility class for market type checking and naming.
/// Based on Flutter_Event_Market_Odds_Guide.md
class MarketHelper {
  MarketHelper._();

  // Football main market IDs
  static const footballMainMarkets = [5, 3, 1]; // Handicap, O/U, 1X2

  // Basketball main market IDs
  static const basketballMainMarkets = [200, 201, 202]; // ML, Handicap, O/U

  // Tennis main market IDs
  static const tennisMainMarkets = [400, 402, 401]; // ML, Handicap, O/U

  // Volleyball main market IDs
  static const volleyballMainMarkets = [500, 509, 510]; // ML, Handicap, O/U

  /// Get main market IDs for a sport
  static List<int> getMainMarketIds(int sportId) {
    switch (sportId) {
      case 1:
        return footballMainMarkets;
      case 2:
        return basketballMainMarkets;
      case 4:
        return tennisMainMarkets;
      case 5:
        return volleyballMainMarkets;
      default:
        return footballMainMarkets;
    }
  }

  /// Check if market is Handicap type
  static bool isHandicap(int marketId) {
    return [
      // Soccer Handicap
      5, 6, // AsianHandicapFT/HT
      85, // AsianHandicapSH
      27, 28, // AsianHandicapExtraFT/HT
      19, 20, // CornerHandicapFT/HT
      33, 34, // BookingsHandicapFT/HT
      44, 45, 46, 47, 48, 49, // TimeHandicap 0015-7590
      144, // EuropeanHandicapCorner
      // Other Sports
      201, 203, // Basketball
      402, // Tennis
      509, // Volleyball
    ].contains(marketId);
  }

  /// Check if market is Over/Under type
  static bool isOverUnder(int marketId) {
    return [
      // Soccer Over/Under
      3, 4, 80, // OverUnderFT/HT/SH
      25, 26, // OverUnderExtraFT/HT
      21, 22, // CornerOverUnderFT/HT
      31, 32, // BookingsOverUnderFT/HT
      38, 39, 40, 41, 42, 43, // TimeOverUnder 0015-7590
      101, 102, // HomeOverUnder, AwayOverUnder
      61, 62, 63, 64, // CornerOverUnder Home/Away FT/HT
      // Corner time-based by 15min
      92, 93, 94, 95, 96,
      // Corner time-based by 10min
      104, 105, 106, 107, 108, 109, 110, 111,
      // Corner time-based by 5min
      112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
      122, 123, 124, 125, 126, 127, 128,
      139, // FTYellowCardsOverUnder
      142, // ExtraTimeCornerOverUnder
      // Other Sports
      202, 204, // Basketball
      401, // Tennis
      510, // Volleyball
    ].contains(marketId);
  }

  /// Check if market is 1X2 type
  static bool is1X2(int marketId) {
    return [
      // Soccer 1X2
      1, 2, 89, // Market1X2FT/HT/SH
      23, 24, // Market1X2ExtraFT/HT
      17, 18, // Corner1X2FT/HT
      29, 30, // Bookings1X2FT/HT
      50, 51, 52, 53, 54, 55, // Time1X2 0015-7590
      138, // FTYellowCards1X2
    ].contains(marketId);
  }

  /// Check if market is Money Line type (Basketball, Tennis, Volleyball)
  static bool isMoneyLine(int marketId) {
    return [
      200, 205, // Basketball FT/H1
      400, 403, 404, 405, 406, 407, // Tennis
      500, 504, 505, 506, 507, 508, // Volleyball
      700, 704, 705, // Badminton
    ].contains(marketId);
  }

  /// Check if market is Odd/Even type
  static bool isOddEven(int marketId) {
    return [8, 9, 86, 56, 57, 76, 77].contains(marketId);
  }

  /// Check if market is Correct Score type
  static bool isCorrectScore(int marketId) {
    return [10, 11].contains(marketId);
  }

  /// Check if market is Corner type (all corner markets)
  static bool isCornerMarket(int marketId) {
    return [
      17, 18, 19, 20, 21, 22, // Main Corner
      56, 57, // Corner Odd/Even
      61, 62, 63, 64, // Corner O/U by team
      66, 67, // Last Corner
      92, 93, 94, 95, 96, // Corner by 15min
      104, 105, 106, 107, 108, 109, 110, 111, // Corner by 10min
      112,
      113,
      114,
      115,
      116,
      117,
      118,
      119,
      120,
      121,
      122,
      123,
      124,
      125,
      126,
      127,
      128, // Corner by 5min
      131, 134, 135, 136, // Corner Range
      137, // NextCorner
      140, 141, 142, 144, // New Corner Markets
    ].contains(marketId);
  }

  /// Check if market is Yellow Card type
  static bool isYellowCardMarket(int marketId) {
    return [138, 139, 143].contains(marketId);
  }

  /// Check if market should always show Decimal odds
  static bool isAlwaysDecimal(int marketId) {
    return is1X2(marketId) ||
        isMoneyLine(marketId) ||
        isCorrectScore(marketId) ||
        [
          12, 13, // DoubleChance
          14, 15, // TotalScore
          16, 75, // DrawNoBet
          58, 59, // ToQualify, WhichTeamKickOff
          35, // Outright
          7, 97, // NextGoal, LastGoal
          103, // WhichTeamToScore
          129, 130, // PenaltyShootout
          131, 134, 135, 136, // CornerRange
          137, // NextCorner
          140, 141, // CornerOverExactlyUnder
          143, // FTYellowCardsDoubleChance
          145, // TotalGoalsExactly
          66, 67, // LastCorner
          83, 84, // CleanSheet
          101, 102, // Home/Away O/U
        ].contains(marketId);
  }

  /// Get odds types for a market
  static List<OddsType> getOddsTypes(int marketId) {
    if (is1X2(marketId) || [12, 13].contains(marketId)) {
      return [OddsType.home, OddsType.draw, OddsType.away];
    }
    if (isCorrectScore(marketId) || [14, 15].contains(marketId)) {
      return [OddsType.home]; // Single column
    }
    return [OddsType.home, OddsType.away];
  }

  /// Get market name by ID
  static String getMarketName(int marketId) {
    switch (marketId) {
      // Football
      case 1:
        return '1X2 FT';
      case 2:
        return '1X2 HT';
      case 3:
        return 'Over/Under FT';
      case 4:
        return 'Over/Under HT';
      case 5:
        return 'Handicap FT';
      case 6:
        return 'Handicap HT';
      case 7:
        return 'Next Goal';
      case 8:
        return 'Odd/Even FT';
      case 10:
        return 'Correct Score';
      case 12:
        return 'Double Chance';
      case 14:
        return 'Total Goals';
      case 16:
        return 'Draw No Bet';
      // Basketball
      case 200:
        return 'Money Line FT';
      case 201:
        return 'Handicap FT';
      case 202:
        return 'Over/Under FT';
      case 205:
        return 'Money Line H1';
      // Tennis
      case 400:
        return 'Match Winner';
      case 401:
        return 'Over/Under Games';
      case 402:
        return 'Handicap Games';
      // Volleyball
      case 500:
        return 'Match Winner';
      case 509:
        return 'Handicap Points';
      case 510:
        return 'Over/Under Points';
      default:
        return 'Market #$marketId';
    }
  }

  /// Get market name by ID in Vietnamese
  static String getMarketNameVi(int marketId) {
    switch (marketId) {
      // Football - Full Time
      case 1:
        return '1X2';
      case 2:
        return '1X2 H1';
      case 3:
        return 'Tài xỉu';
      case 4:
        return 'Tài xỉu H1';
      case 5:
        return 'Kèo chấp';
      case 6:
        return 'Kèo chấp H1';
      case 7:
        return 'Bàn tiếp theo';
      case 8:
        return 'Chẵn/Lẻ';
      case 9:
        return 'Chẵn/Lẻ H1';
      case 10:
        return 'Tỷ số chính xác';
      case 11:
        return 'Tỷ số chính xác H1';
      case 12:
        return 'Cơ hội kép';
      case 13:
        return 'Cơ hội kép H1';
      case 14:
        return 'Tổng bàn thắng';
      case 15:
        return 'Tổng bàn thắng H1';
      case 16:
        return 'Hòa hoàn tiền';
      case 75:
        return 'Hòa hoàn tiền H1';

      // Corner - Phạt góc
      case 17:
        return '1X2 Phạt góc';
      case 18:
        return '1X2 Phạt góc H1';
      case 19:
        return 'Kèo chấp Phạt góc';
      case 20:
        return 'Kèo chấp Phạt góc H1';
      case 21:
        return 'Tài xỉu Phạt góc';
      case 22:
        return 'Tài xỉu Phạt góc H1';
      case 56:
        return 'Chẵn/Lẻ Phạt góc';
      case 57:
        return 'Chẵn/Lẻ Phạt góc H1';
      case 66:
        return 'Phạt góc cuối';
      case 67:
        return 'Phạt góc cuối H1';

      // Extra Time - Hiệp phụ
      case 23:
        return '1X2 Hiệp phụ';
      case 24:
        return '1X2 Hiệp phụ H1';
      case 25:
        return 'Tài xỉu Hiệp phụ';
      case 26:
        return 'Tài xỉu Hiệp phụ H1';
      case 27:
        return 'Kèo chấp Hiệp phụ';
      case 28:
        return 'Kèo chấp Hiệp phụ H1';

      // Booking - Thẻ phạt
      case 29:
        return '1X2 Thẻ phạt';
      case 30:
        return '1X2 Thẻ phạt H1';
      case 31:
        return 'Tài xỉu Thẻ phạt';
      case 32:
        return 'Tài xỉu Thẻ phạt H1';
      case 33:
        return 'Kèo chấp Thẻ phạt';
      case 34:
        return 'Kèo chấp Thẻ phạt H1';

      // Time range - Theo phút
      case 38:
        return 'Tài xỉu 0-15\'';
      case 39:
        return 'Tài xỉu 15-30\'';
      case 40:
        return 'Tài xỉu 30-45\'';
      case 41:
        return 'Tài xỉu 45-60\'';
      case 42:
        return 'Tài xỉu 60-75\'';
      case 43:
        return 'Tài xỉu 75-90\'';
      case 44:
        return 'Kèo chấp 0-15\'';
      case 45:
        return 'Kèo chấp 15-30\'';
      case 46:
        return 'Kèo chấp 30-45\'';
      case 47:
        return 'Kèo chấp 45-60\'';
      case 48:
        return 'Kèo chấp 60-75\'';
      case 49:
        return 'Kèo chấp 75-90\'';
      case 50:
        return '1X2 0-15\'';
      case 51:
        return '1X2 15-30\'';
      case 52:
        return '1X2 30-45\'';
      case 53:
        return '1X2 45-60\'';
      case 54:
        return '1X2 60-75\'';
      case 55:
        return '1X2 75-90\'';

      // Other Match markets
      case 58:
        return 'Đội đi tiếp';
      case 59:
        return 'Đội giao bóng';
      case 76:
        return 'Chẵn/Lẻ Đội nhà';
      case 77:
        return 'Chẵn/Lẻ Đội khách';
      case 80:
        return 'Tài xỉu Hiệp 2';
      case 83:
        return 'Giữ sạch lưới Đội nhà';
      case 84:
        return 'Giữ sạch lưới Đội khách';
      case 85:
        return 'Kèo chấp Hiệp 2';
      case 86:
        return 'Chẵn/Lẻ Hiệp 2';
      case 89:
        return '1X2 Hiệp 2';
      case 97:
        return 'Bàn cuối cùng';
      case 101:
        return 'Tài xỉu Đội nhà';
      case 102:
        return 'Tài xỉu Đội khách';
      case 103:
        return 'Đội ghi bàn';
      case 129:
        return 'Thắng Penalty';
      case 130:
        return 'Tài xỉu Penalty';

      // Basketball
      case 200:
        return 'Thắng/Thua';
      case 201:
        return 'Kèo chấp';
      case 202:
        return 'Tài xỉu';
      case 203:
        return 'Kèo chấp H1';
      case 204:
        return 'Tài xỉu H1';
      case 205:
        return 'Thắng/Thua H1';

      // Tennis
      case 400:
        return 'Thắng trận';
      case 401:
        return 'Tài xỉu Game';
      case 402:
        return 'Kèo chấp Game';

      // Volleyball
      case 500:
        return 'Thắng trận';
      case 509:
        return 'Kèo chấp Điểm';
      case 510:
        return 'Tài xỉu Điểm';

      // New Soccer Markets (137-145)
      case 137:
        return 'Phạt góc tiếp theo';
      case 138:
        return '1X2 Thẻ vàng';
      case 139:
        return 'Tài xỉu Thẻ vàng';
      case 140:
        return 'Phạt góc H1 T/CX/X';
      case 141:
        return 'Phạt góc HP T/CX/X';
      case 142:
        return 'Tài xỉu Phạt góc HP';
      case 143:
        return 'Cơ hội kép Thẻ vàng';
      case 144:
        return 'Chấp Phạt góc Châu Âu';
      case 145:
        return 'Tổng bàn thắng chính xác';

      // Corner Over/Under by Team
      case 61:
        return 'Tài xỉu PG Đội nhà';
      case 62:
        return 'Tài xỉu PG Đội nhà H1';
      case 63:
        return 'Tài xỉu PG Đội khách';
      case 64:
        return 'Tài xỉu PG Đội khách H1';

      // Corner Range
      case 131:
        return 'Tổng phạt góc';
      case 134:
        return 'Tổng PG Đội nhà';
      case 135:
        return 'Tổng PG Đội khách';
      case 136:
        return 'Tổng phạt góc H1';

      // Corner time-based by 15min (92-96)
      case 92:
        return 'PG Tài xỉu 0-15\'';
      case 93:
        return 'PG Tài xỉu 15-30\'';
      case 94:
        return 'PG Tài xỉu 30-45\'';
      case 95:
        return 'PG Tài xỉu 45-60\'';
      case 96:
        return 'PG Tài xỉu 60-75\'';

      default:
        // Fallback: convert English name to Vietnamese
        final englishName = getMarketName(marketId);
        return _convertToVietnamese(englishName);
    }
  }

  /// Convert English market name to Vietnamese (fallback)
  static String _convertToVietnamese(String name) {
    return name
        .replaceAll(RegExp(r'Over/Under', caseSensitive: false), 'Tài xỉu')
        .replaceAll(RegExp(r'Handicap', caseSensitive: false), 'Kèo chấp')
        .replaceAll(RegExp(r'Odd/Even', caseSensitive: false), 'Chẵn/Lẻ')
        .replaceAll(
          RegExp(r'Correct Score', caseSensitive: false),
          'Tỷ số chính xác',
        )
        .replaceAll(
          RegExp(r'Double Chance', caseSensitive: false),
          'Cơ hội kép',
        )
        .replaceAll(
          RegExp(r'Draw No Bet', caseSensitive: false),
          'Hòa hoàn tiền',
        )
        .replaceAll(
          RegExp(r'Total Goals', caseSensitive: false),
          'Tổng bàn thắng',
        )
        .replaceAll(RegExp(r'Next Goal', caseSensitive: false), 'Bàn tiếp theo')
        .replaceAll(RegExp(r'Last Goal', caseSensitive: false), 'Bàn cuối cùng')
        .replaceAll(RegExp(r'Corner', caseSensitive: false), 'Phạt góc')
        .replaceAll(RegExp(r'Booking', caseSensitive: false), 'Thẻ phạt')
        .replaceAll(RegExp(r'Money Line', caseSensitive: false), 'Thắng/Thua')
        .replaceAll(RegExp(r'Match Winner', caseSensitive: false), 'Thắng trận')
        .replaceAll(
          RegExp(r'Clean Sheet', caseSensitive: false),
          'Giữ sạch lưới',
        )
        .replaceAll(RegExp(r'\bFT\b'), '')
        .replaceAll(RegExp(r'\bHT\b'), 'H1')
        .trim();
  }

  /// Get market name with period prefix in Vietnamese
  /// Format: "Period - Market Type" (e.g., "Toàn trận - Kèo chấp")
  static String getMarketNameViDisplay(int marketId) {
    final period = _getPeriodName(marketId);
    final marketType = _getBaseMarketTypeVi(marketId);

    if (period.isEmpty) {
      return marketType;
    }
    return '$period - $marketType';
  }

  /// Get period name from marketId
  static String _getPeriodName(int marketId) {
    // First Half markets (H1)
    const firstHalfMarkets = [
      2,
      4,
      6,
      9,
      11,
      13,
      15,
      18,
      20,
      22,
      24,
      26,
      28,
      30,
      32,
      34,
      57,
      67,
      75,
      203,
      204,
      205,
    ];
    if (firstHalfMarkets.contains(marketId)) {
      return 'Hiệp 1';
    }

    // Second Half markets (H2)
    const secondHalfMarkets = [80, 85, 86, 89];
    if (secondHalfMarkets.contains(marketId)) {
      return 'Hiệp 2';
    }

    // Extra Time markets
    const extraTimeMarkets = [23, 25, 27];
    if (extraTimeMarkets.contains(marketId)) {
      return 'Hiệp phụ';
    }

    // Extra Time First Half markets
    const extraTimeH1Markets = [24, 26, 28];
    if (extraTimeH1Markets.contains(marketId)) {
      return 'Hiệp phụ H1';
    }

    // Time range markets (don't need period prefix)
    const timeRangeMarkets = [
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      54,
      55,
    ];
    if (timeRangeMarkets.contains(marketId)) {
      return '';
    }

    // Corner markets
    const cornerMarkets = [17, 19, 21, 56, 66];
    if (cornerMarkets.contains(marketId)) {
      return 'Toàn trận';
    }

    // Booking/Card markets
    const bookingMarkets = [29, 31, 33];
    if (bookingMarkets.contains(marketId)) {
      return 'Toàn trận';
    }

    // Full Time markets (default for most markets)
    const fullTimeMarkets = [
      1,
      3,
      5,
      7,
      8,
      10,
      12,
      14,
      16,
      58,
      59,
      76,
      77,
      83,
      84,
      97,
      101,
      102,
      103,
      129,
      130,
      200,
      201,
      202,
      400,
      401,
      402,
      500,
      509,
      510,
    ];
    if (fullTimeMarkets.contains(marketId)) {
      return 'Toàn trận';
    }

    // Default to Toàn trận for unknown markets
    return 'Toàn trận';
  }

  /// Get base market type name in Vietnamese (without period info)
  static String _getBaseMarketTypeVi(int marketId) {
    switch (marketId) {
      // 1X2
      case 1:
      case 2:
      case 89:
        return '1X2';

      // Over/Under - Tài xỉu
      case 3:
      case 4:
      case 80:
      case 38:
      case 39:
      case 40:
      case 41:
      case 42:
      case 43:
        return 'Tài xỉu';

      // Handicap - Kèo chấp
      case 5:
      case 6:
      case 85:
      case 44:
      case 45:
      case 46:
      case 47:
      case 48:
      case 49:
        return 'Kèo chấp';

      // Odd/Even - Chẵn/Lẻ
      case 8:
      case 9:
      case 86:
      case 76:
      case 77:
        return 'Chẵn/Lẻ';

      // Next Goal
      case 7:
        return 'Bàn tiếp theo';

      // Correct Score
      case 10:
      case 11:
        return 'Tỷ số chính xác';

      // Double Chance
      case 12:
      case 13:
        return 'Cơ hội kép';

      // Total Goals
      case 14:
      case 15:
        return 'Tổng bàn thắng';

      // Draw No Bet
      case 16:
      case 75:
        return 'Hòa hoàn tiền';

      // Corner markets
      case 17:
      case 18:
        return '1X2 Phạt góc';
      case 19:
      case 20:
        return 'Kèo chấp Phạt góc';
      case 21:
      case 22:
        return 'Tài xỉu Phạt góc';
      case 56:
      case 57:
        return 'Chẵn/Lẻ Phạt góc';
      case 66:
      case 67:
        return 'Phạt góc cuối';

      // Extra Time markets
      case 23:
      case 24:
        return '1X2';
      case 25:
      case 26:
        return 'Tài xỉu';
      case 27:
      case 28:
        return 'Kèo chấp';

      // Booking/Card markets
      case 29:
      case 30:
        return '1X2 Thẻ phạt';
      case 31:
      case 32:
        return 'Tài xỉu Thẻ phạt';
      case 33:
      case 34:
        return 'Kèo chấp Thẻ phạt';

      // Time range markets
      case 50:
      case 51:
      case 52:
      case 53:
      case 54:
      case 55:
        return '1X2';

      // Other markets
      case 58:
        return 'Đội đi tiếp';
      case 59:
        return 'Đội giao bóng';
      case 83:
        return 'Giữ sạch lưới Đội nhà';
      case 84:
        return 'Giữ sạch lưới Đội khách';
      case 97:
        return 'Bàn cuối cùng';
      case 101:
        return 'Tài xỉu Đội nhà';
      case 102:
        return 'Tài xỉu Đội khách';
      case 103:
        return 'Đội ghi bàn';
      case 129:
        return 'Thắng Penalty';
      case 130:
        return 'Tài xỉu Penalty';

      // Basketball
      case 200:
      case 205:
        return 'Thắng/Thua';
      case 201:
      case 203:
        return 'Kèo chấp';
      case 202:
      case 204:
        return 'Tài xỉu';

      // Tennis
      case 400:
        return 'Thắng trận';
      case 401:
        return 'Tài xỉu Game';
      case 402:
        return 'Kèo chấp Game';

      // Volleyball
      case 500:
        return 'Thắng trận';
      case 509:
        return 'Kèo chấp Điểm';
      case 510:
        return 'Tài xỉu Điểm';

      default:
        return getMarketNameVi(marketId);
    }
  }
}

// ===== ODDS DISPLAY HELPER =====

/// Odds Display Helper
///
/// Utility class for formatting and displaying odds.
class OddsDisplay {
  OddsDisplay._();

  /// Format odds value for display
  static String format(double odds, {int decimals = 2}) {
    if (odds == -100 || odds <= 0) return '-';
    return odds.toStringAsFixed(decimals);
  }

  /// Get style name
  static String getStyleName(OddsStyle style) => style.shortName;

  /// Check if odds value indicates positive odds (green color)
  static bool isPositive(double odds) => odds > 0 && odds != -100;

  /// Check if odds value indicates negative odds (red color)
  static bool isNegative(double odds) => odds < 0 && odds != -100;
}

// ===== POINTS FORMATTER =====

/// Points Formatter (Quarter Ball / Kèo tứ phân)
///
/// Formats handicap/over-under points for display according to Asian Handicap rules.
///
/// Rules:
/// - Quarter ball (0.25 or 0.75): Display as range "X-Y"
///   - 0.25 → "0-0.5"
///   - 0.75 → "0.5-1"
///   - 1.25 → "1-1.5"
///   - 1.75 → "1.5-2"
/// - Half ball (0.5) or Whole ball (0, 1, 2...): Display as-is
///
/// Based on Flutter_Event_Market_Odds_Guide.md Section 12
class PointsFormatter {
  PointsFormatter._();

  /// Format points value for display
  ///
  /// API returns: 0.25, 0.5, 0.75, 1, 1.25, -0.75...
  /// Display: "0-0.5", "0.5", "0.5-1", "1", "1-1.5", "-0.5-1"...
  static String format(dynamic pointsValue) {
    if (pointsValue == null || pointsValue.toString().isEmpty) {
      return '';
    }

    final value = double.tryParse(pointsValue.toString()) ?? 0;
    if (value == 0) return '0';

    final absValue = value.abs();
    final decimal = absValue % 1; // Get decimal part
    final minus = value < 0 ? '-' : '';

    // Quarter ball: 0.25 or 0.75
    if (_isQuarterBall(decimal)) {
      final low = absValue - 0.25;
      final high = absValue + 0.25;
      return '${_formatNumber(low)}-${_formatNumber(high)}';
    }

    // Half ball (0.5) or Whole ball (0, 1, 2...)
    return '${_formatNumber(absValue)}';
  }

  /// Check if decimal part represents a quarter ball
  static bool _isQuarterBall(double decimal) {
    // Use tolerance for floating point comparison
    const tolerance = 0.001;
    return (decimal - 0.25).abs() < tolerance ||
        (decimal - 0.75).abs() < tolerance;
  }

  /// Check if a points value is a quarter ball
  static bool isQuarterBall(dynamic pointsValue) {
    if (pointsValue == null || pointsValue.toString().isEmpty) {
      return false;
    }
    final value = double.tryParse(pointsValue.toString()) ?? 0;
    final decimal = value.abs() % 1;
    return _isQuarterBall(decimal);
  }

  /// Format number: remove .0 if it's a whole number
  static String _formatNumber(double num) {
    if (num == num.toInt()) {
      return num.toInt().toString(); // 1.0 → "1"
    }
    // Format to remove trailing zeros
    final str = num.toString();
    if (str.contains('.')) {
      // Remove trailing zeros but keep at least one decimal if needed
      return str.replaceAll(RegExp(r'\.?0+$'), '');
    }
    return str;
  }
}
