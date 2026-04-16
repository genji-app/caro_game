import 'package:freezed_annotation/freezed_annotation.dart';

import 'odds_style_model_v2.dart';

part 'odds_model_v2.freezed.dart';

/// Odds Model V2
///
/// Represents odds information for a specific market line.
/// API returns numeric keys.
@freezed
sealed class OddsModelV2 with _$OddsModelV2 {
  const factory OddsModelV2({
    /// Selection Home ID (e.g., "45422650010000000h")
    @Default('') String selectionHomeId,

    /// Selection Away ID (e.g., "45422650010000000a")
    @Default('') String selectionAwayId,

    /// Selection Draw ID (e.g., "45422650010000000d") - optional for 2-way markets
    @Default('') String selectionDrawId,

    /// Points/Handicap associated with the odds (e.g., "1.0", "-0.5", "0.0")
    @Default('') String points,

    /// Home team odds in different formats
    OddsStyleModelV2? homeOdds,

    /// Away team odds in different formats
    OddsStyleModelV2? awayOdds,

    /// Draw odds in different formats (for 1X2 markets)
    OddsStyleModelV2? drawOdds,

    /// String Offer ID for betting placement
    @Default('') String strOfferId,

    /// Indicates if the odds is for the main line
    @Default(false) bool isMainLine,

    /// Indicates if the odds is suspended (cannot place bet)
    @Default(false) bool isSuspended,

    /// Indicates if the odds is hidden (should not be displayed)
    @Default(false) bool isHidden,
  }) = _OddsModelV2;

  const OddsModelV2._();

  /// Factory constructor for JSON deserialization
  /// API returns numeric keys
  factory OddsModelV2.fromJson(Map<String, dynamic> json) {
    return OddsModelV2(
      selectionHomeId: json['0']?.toString() ?? '',
      selectionAwayId: json['1']?.toString() ?? '',
      selectionDrawId: json['2']?.toString() ?? '',
      points: json['3']?.toString() ?? '',
      homeOdds: json['4'] != null
          ? OddsStyleModelV2.fromJson(
              Map<String, dynamic>.from(json['4'] as Map),
            )
          : null,
      awayOdds: json['5'] != null
          ? OddsStyleModelV2.fromJson(
              Map<String, dynamic>.from(json['5'] as Map),
            )
          : null,
      drawOdds: json['6'] != null
          ? OddsStyleModelV2.fromJson(
              Map<String, dynamic>.from(json['6'] as Map),
            )
          : null,
      strOfferId: json['7']?.toString() ?? '',
      isMainLine: json['8'] == true,
      isSuspended: json['9'] == true,
      isHidden: json['10'] == true,
    );
  }

  /// Parse points to double for calculations
  double get pointsValue => double.tryParse(points) ?? 0.0;

  /// Check if this is a handicap market (has non-zero points)
  bool get isHandicap => points.isNotEmpty && pointsValue != 0.0;

  /// Check if odds are available for betting
  /// Must not be suspended, not hidden, and have valid odds values
  bool get isAvailable =>
      !isSuspended &&
      !isHidden &&
      (homeOdds?.isValid == true || awayOdds?.isValid == true);

  /// Get formatted handicap display string
  String get handicapDisplay {
    if (points.isEmpty) return '';
    final value = pointsValue;
    if (value > 0) return '+$points';
    return points;
  }

  /// Check if this is a three-way market (has draw option)
  bool get isThreeWay => selectionDrawId.isNotEmpty && drawOdds != null;

  /// Get home odds by format
  double getHomeOdds(OddsFormatV2 format) {
    return homeOdds?.getValueByFormat(format) ?? 0.0;
  }

  /// Get away odds by format
  double getAwayOdds(OddsFormatV2 format) {
    return awayOdds?.getValueByFormat(format) ?? 0.0;
  }

  /// Get draw odds by format
  double? getDrawOdds(OddsFormatV2 format) {
    return drawOdds?.getValueByFormat(format);
  }

  /// Format home odds for display
  String formatHomeOdds(OddsFormatV2 format, {int decimals = 2}) {
    final value = getHomeOdds(format);
    if (value == 0) return '-';
    return value.toStringAsFixed(decimals);
  }

  /// Format away odds for display
  String formatAwayOdds(OddsFormatV2 format, {int decimals = 2}) {
    final value = getAwayOdds(format);
    if (value == 0) return '-';
    return value.toStringAsFixed(decimals);
  }

  /// Format draw odds for display
  String? formatDrawOdds(OddsFormatV2 format, {int decimals = 2}) {
    final value = getDrawOdds(format);
    if (value == null || value == 0) return null;
    return value.toStringAsFixed(decimals);
  }
}
