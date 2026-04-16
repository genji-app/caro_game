import 'package:freezed_annotation/freezed_annotation.dart';

part 'bet_statistics_entity.freezed.dart';
part 'bet_statistics_entity.g.dart';

/// Bet Statistics Simple Entity
///
/// Represents the simple statistics response from /api/v2/bet/statistics/simple
/// Response structure: {0: eventId, 1: {marketId: [selectionStats...]}}
@freezed
sealed class BetStatisticsSimple with _$BetStatisticsSimple {
  const factory BetStatisticsSimple({
    /// Event ID (API key: "0")
    @JsonKey(name: '0') int? eventId,

    /// Market statistics map (API key: "1")
    /// Key: marketId (string), Value: List of selection statistics
    @JsonKey(name: '1')
    Map<String, List<BetStatisticsSelection>>? marketStatistics,
  }) = _BetStatisticsSimple;

  factory BetStatisticsSimple.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsSimpleFromJson(json);
}

/// Bet Statistics Selection
///
/// Represents a single selection statistic within a market
/// Structure: {1: marketId, 2: points/handicap (can be string or number), 3: selectionName, 4: percentage}
@freezed
sealed class BetStatisticsSelection with _$BetStatisticsSelection {
  const factory BetStatisticsSelection({
    /// Market ID (API key: "1")
    @JsonKey(name: '1') int? marketId,

    /// Points/Handicap value (API key: "2")
    /// Can be string like "0.0", "-0.5", "3.0" or number
    @JsonKey(name: '2', fromJson: _parsePoints) String? points,

    /// Selection name (API key: "3")
    /// Examples: "Home", "Away", "Over", "Under", "Atletico Madrid"
    @JsonKey(name: '3') String? selectionName,

    /// Percentage (API key: "4")
    /// Betting percentage for this selection
    @JsonKey(name: '4') double? percentage,
  }) = _BetStatisticsSelection;

  factory BetStatisticsSelection.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsSelectionFromJson(json);
}

/// Parse points value which can be string or number
String? _parsePoints(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

/// Bet Statistics User Details Entity
///
/// Represents the user details statistics response from /api/v2/bet/statistics/user-details
/// Response structure: {"0": [userBetDetails...], "1": totalCount, "2": [marketTypes...]}
@freezed
sealed class BetStatisticsUserDetails with _$BetStatisticsUserDetails {
  const factory BetStatisticsUserDetails({
    /// List of user bet details (API key: "0")
    @JsonKey(name: '0') @Default([]) List<BetStatisticsUserBetDetail> userBets,

    /// Total count (API key: "1")
    @JsonKey(name: '1') int? totalCount,

    /// Market types filter (API key: "2")
    /// Examples: ["HANDICAP", "OVER_UNDER", "_1X2", "CORRECT_SCORE", "CORNER"]
    @JsonKey(name: '2') @Default([]) List<String> marketTypes,
  }) = _BetStatisticsUserDetails;

  factory BetStatisticsUserDetails.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsUserDetailsFromJson(json);
}

/// Bet Statistics User Bet Detail
///
/// Represents a single user bet detail
/// Structure: {"1": userName, "2": selectionName, "3": opponentName, ...}
@freezed
sealed class BetStatisticsUserBetDetail with _$BetStatisticsUserBetDetail {
  const factory BetStatisticsUserBetDetail({
    /// User name (API key: "1")
    @JsonKey(name: '1') String? userName,

    /// Selection name (API key: "2")
    @JsonKey(name: '2') String? selectionName,

    /// Opponent/Team name (API key: "3")
    @JsonKey(name: '3') String? opponentName,

    /// Event ID (API key: "4")
    @JsonKey(name: '4') int? eventId,

    /// League name (API key: "5")
    @JsonKey(name: '5') String? leagueName,

    /// League ID (API key: "6")
    @JsonKey(name: '6') int? leagueId,

    /// Boolean flag (API key: "7")
    @JsonKey(name: '7') bool? flag,

    /// Market name (API key: "8")
    @JsonKey(name: '8') String? marketName,

    /// ID or timestamp (API key: "9")
    @JsonKey(name: '9') String? idOrTimestamp,

    /// Odds style (API key: "10")
    /// Examples: "ma" (Malay), "de" (Decimal), "in" (Indo), "hk" (Hong Kong)
    @JsonKey(name: '10') String? oddsStyle,

    /// Odds value string (API key: "11")
    @JsonKey(name: '11') String? oddsValueString,

    /// Score (API key: "12")
    @JsonKey(name: '12') String? score,

    /// Selection ID (API key: "13")
    @JsonKey(name: '13') String? selectionId,

    /// Selection name (duplicate) (API key: "14")
    @JsonKey(name: '14') String? selectionName2,

    /// Bet timestamp (API key: "15")
    @JsonKey(name: '15') String? betTimestamp,

    /// Odds value (API key: "16")
    @JsonKey(name: '16') double? oddsValue,

    /// Points/Handicap (API key: "17")
    @JsonKey(name: '17') String? points,

    /// Number (API key: "18")
    @JsonKey(name: '18') int? number,

    /// Market ID (API key: "19")
    @JsonKey(name: '19') int? marketId,

    /// Odds values map (API key: "20")
    /// Structure: {"0": decimal, "1": malay, "2": indo, "3": hk, "4": other}
    @JsonKey(name: '20') Map<String, String>? oddsValues,

    /// ID (API key: "21")
    @JsonKey(name: '21') String? id,

    /// Match time (API key: "22")
    @JsonKey(name: '22') String? matchTime,
  }) = _BetStatisticsUserBetDetail;

  factory BetStatisticsUserBetDetail.fromJson(Map<String, dynamic> json) =>
      _$BetStatisticsUserBetDetailFromJson(json);
}
