import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_model.freezed.dart';
part 'market_model.g.dart';

/// Market Model
///
/// Represents a betting market (e.g., Match Winner, Asian Handicap).
@freezed
sealed class MarketModel with _$MarketModel {
  const factory MarketModel({
    required String id,
    required String name,
    @JsonKey(name: 'cls') required String cls,
    @Default([]) List<SelectionModel> odds,
    @Default(true) bool isActive,
    String? description,
  }) = _MarketModel;

  factory MarketModel.fromJson(Map<String, dynamic> json) =>
      _$MarketModelFromJson(json);
}

/// Selection Model (Odds)
///
/// Represents a betting selection with odds.
@freezed
sealed class SelectionModel with _$SelectionModel {
  const factory SelectionModel({
    @JsonKey(name: 'selectionId') required String selectionId,
    required String name,
    @JsonKey(name: 'displayOdds') required String displayOdds,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'trueOdds') double? trueOdds,
    @Default(true) bool isActive,
    @JsonKey(name: 'handicap') double? handicap,
    @JsonKey(name: 'line') double? line,
  }) = _SelectionModel;

  factory SelectionModel.fromJson(Map<String, dynamic> json) =>
      _$SelectionModelFromJson(json);
}

/// Market Classes (Bet Types)
abstract class MarketClasses {
  static const String matchWinner = '1x2';
  static const String asianHandicap = 'asian_handicap';
  static const String overUnder = 'over_under';
  static const String bothTeamsToScore = 'both_teams_to_score';
  static const String correctScore = 'correct_score';
  static const String doubleChance = 'double_chance';
  static const String drawNoBet = 'draw_no_bet';
  static const String halfTimeFullTime = 'half_time_full_time';
  static const String firstHalf = 'first_half';
  static const String secondHalf = 'second_half';
}

/// Selection Extensions
extension SelectionModelX on SelectionModel {
  /// Parse odds to double
  double get oddsValue {
    return double.tryParse(displayOdds) ?? 0.0;
  }

  /// Calculate potential winnings for a stake
  double calculateWinnings(double stake) {
    return stake * oddsValue;
  }

  /// Get formatted odds string
  String get formattedOdds {
    final value = oddsValue;
    if (value == 0) return '-';
    return value.toStringAsFixed(2);
  }
}

/// Market Extensions
extension MarketModelX on MarketModel {
  /// Get home selection (for 1x2 markets)
  SelectionModel? get homeSelection {
    try {
      return odds.firstWhere(
        (o) => o.selectionId == '1' || o.name.toLowerCase().contains('home'),
      );
    } catch (e) {
      return odds.isNotEmpty ? odds.first : null;
    }
  }

  /// Get draw selection (for 1x2 markets)
  SelectionModel? get drawSelection {
    try {
      return odds.firstWhere(
        (o) => o.selectionId == 'X' || o.name.toLowerCase().contains('draw'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get away selection (for 1x2 markets)
  SelectionModel? get awaySelection {
    try {
      return odds.firstWhere(
        (o) => o.selectionId == '2' || o.name.toLowerCase().contains('away'),
      );
    } catch (e) {
      return odds.length > 1 ? odds.last : null;
    }
  }

  /// Check if this is an Asian Handicap market
  bool get isAsianHandicap => cls == MarketClasses.asianHandicap;

  /// Check if this is an Over/Under market
  bool get isOverUnder => cls == MarketClasses.overUnder;

  /// Check if this is a 1x2 market
  bool get isMatchWinner => cls == MarketClasses.matchWinner;
}
