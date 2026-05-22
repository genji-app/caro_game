import 'package:freezed_annotation/freezed_annotation.dart';

part 'special_outright_model.freezed.dart';
part 'special_outright_model.g.dart';

/// Parse int safely - API may return String when key layout differs.
int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Parse double safely - API may return String when key layout differs.
double _safeParseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Special Outright Model
///
/// Represents outright/futures bets from the special tab API.
/// Maps to API response format with numeric keys:
/// { "0": selections, "1": outrightId, "2": outrightName, "4": endDate,
///   "5": startTime, "6": leagueId, "7": leagueLogo, "8": leagueName }
@freezed
sealed class SpecialOutrightModel with _$SpecialOutrightModel {
  const factory SpecialOutrightModel({
    /// Selections array (API: "0")
    @JsonKey(name: '0') @Default([]) List<SpecialOutrightSelection> selections,

    /// Outright ID (API: "1")
    @JsonKey(name: '1', fromJson: _safeParseInt) @Default(0) int outrightId,

    /// Outright Name (API: "2")
    /// Example: "UEFA Champions League 2025/2026 - Winner"
    @JsonKey(name: '2') @Default('') String outrightName,

    /// End Date ISO 8601 (API: "4")
    /// Example: "2026-05-30T19:00:00Z"
    @JsonKey(name: '4') @Default('') String endDate,

    /// Start/End timestamp in milliseconds (API: "5")
    @JsonKey(name: '5', fromJson: _safeParseInt) @Default(0) int startTime,

    /// League ID (API: "6")
    @JsonKey(name: '6', fromJson: _safeParseInt) @Default(0) int leagueId,

    /// League Logo URL (API: "7")
    @JsonKey(name: '7') @Default('') String leagueLogo,

    /// League Name (API: "8")
    @JsonKey(name: '8') @Default('') String leagueName,
  }) = _SpecialOutrightModel;

  factory SpecialOutrightModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialOutrightModelFromJson(json);
}

/// Special Outright Selection
///
/// Represents a single selection (team/player) in an outright bet.
/// Maps to API response format with numeric keys: { "0", "1", "2", "3", "4", "5" }
@freezed
sealed class SpecialOutrightSelection with _$SpecialOutrightSelection {
  const factory SpecialOutrightSelection({
    /// Selection ID (API: "0")
    /// Example: "38912720350000155h"
    @JsonKey(name: '0') @Default('') String selectionId,

    /// Selection Name (API: "1")
    /// Example: "Arsenal"
    @JsonKey(name: '1') @Default('') String selectionName,

    /// Logo URL (API: "2")
    @JsonKey(name: '2') @Default('') String logoUrl,

    /// Base ID (API: "3") - ID without suffix, used for offer/bet placement
    /// Example: "38912720350000155"
    @JsonKey(name: '3') @Default('') String offerId,

    /// Odds value (API: "4") - use safe parse in case API returns string
    @JsonKey(name: '4', fromJson: _safeParseDouble) @Default(0.0) double odds,

    /// Selection Code (API: "5")
    /// Example: "155"
    @JsonKey(name: '5') @Default('') String selectionCode,
  }) = _SpecialOutrightSelection;

  factory SpecialOutrightSelection.fromJson(Map<String, dynamic> json) =>
      _$SpecialOutrightSelectionFromJson(json);
}
