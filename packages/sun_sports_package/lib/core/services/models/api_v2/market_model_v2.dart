import 'package:freezed_annotation/freezed_annotation.dart';

import 'odds_model_v2.dart';

part 'market_model_v2.freezed.dart';

/// Market Model V2
///
/// Represents a betting market with its odds.
/// API returns numeric keys.
@freezed
sealed class MarketModelV2 with _$MarketModelV2 {
  const factory MarketModelV2({
    /// List of odds in the market
    @Default([]) List<OddsModelV2> oddsList,

    /// Sport ID
    @Default(0) int sportId,

    /// League ID
    @Default(0) int leagueId,

    /// Event ID
    @Default(0) int eventId,

    /// Market ID - identifies the market type
    /// SB Native Document mapping:
    /// 1=FT_1X2, 2=HT_1X2, 3=FT_OVER_UNDER, 4=HT_OVER_UNDER, 5=FT_ASIAN_HANDICAP, 6=HT_ASIAN_HANDICAP
    @Default(0) int marketId,

    /// Indicates if the market is suspended
    @Default(false) bool isSuspended,

    /// Indicates if the market supports parlay
    @Default(false) bool isParlay,

    /// Indicates if cash out is available for this market
    @Default(false) bool isCashOut,

    /// Promotion type of the market (0 = normal, 1 = promotion/kèo rung)
    @Default(0) int promotionType,

    /// Group ID - each market belongs to a group
    @Default(0) int groupId,
  }) = _MarketModelV2;

  const MarketModelV2._();

  /// Factory constructor for JSON deserialization
  /// API returns numeric keys
  factory MarketModelV2.fromJson(Map<String, dynamic> json) {
    final oddsList = <OddsModelV2>[];
    final rawOddsList = json['0'];
    if (rawOddsList is List) {
      for (final item in rawOddsList) {
        if (item is Map<String, dynamic>) {
          oddsList.add(OddsModelV2.fromJson(item));
        } else if (item is Map) {
          oddsList.add(OddsModelV2.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return MarketModelV2(
      oddsList: oddsList,
      sportId: _parseInt(json['1']),
      leagueId: _parseInt(json['2']),
      eventId: _parseInt(json['3']),
      marketId: _parseInt(json['4']),
      isSuspended: json['5'] == true,
      isParlay: json['6'] == true,
      isCashOut: json['7'] == true,
      promotionType: _parseInt(json['8']),
      groupId: _parseInt(json['9']),
    );
  }

  /// Get the main line odds (first one that isMainLine = true)
  OddsModelV2? get mainLineOdds {
    try {
      return oddsList.firstWhere((odds) => odds.isMainLine);
    } catch (_) {
      return oddsList.isNotEmpty ? oddsList.first : null;
    }
  }

  /// Check if market is available for betting
  bool get isAvailable => !isSuspended && oddsList.isNotEmpty;

  /// Get market type enum
  MarketTypeV2 get marketType => MarketTypeV2.fromId(marketId);

  /// Get all available odds (not suspended)
  List<OddsModelV2> get availableOdds =>
      oddsList.where((odds) => odds.isAvailable).toList();

  /// Check if this is a handicap market
  /// SB Native: 5=FT_ASIAN_HANDICAP, 6=HT_ASIAN_HANDICAP
  bool get isHandicapMarket => marketId == 5 || marketId == 6;

  /// Check if this is an over/under market
  /// SB Native: 3=FT_OVER_UNDER, 4=HT_OVER_UNDER
  bool get isOverUnderMarket => marketId == 3 || marketId == 4;

  /// Check if this is a 1X2 market
  bool get is1X2Market => marketId == 1 || marketId == 2; // 1X2 or 1X2 FH

  /// Check if is promotion market (kèo rung)
  bool get isPromotion => promotionType == 1;
}

/// Market type enum for better code readability
/// Based on SB Native Document mapping
enum MarketTypeV2 {
  unknown(0, 'Unknown'),
  fullTime1X2(1, '1X2'), // FT_1X2
  firstHalf1X2(2, '1X2 First Half'), // HT_1X2
  overUnder(3, 'Over/Under'), // FT_OVER_UNDER
  overUnderFirstHalf(4, 'Over/Under First Half'), // HT_OVER_UNDER
  handicap(5, 'Handicap'), // FT_ASIAN_HANDICAP
  handicapFirstHalf(6, 'Handicap First Half'); // HT_ASIAN_HANDICAP

  final int id;
  final String displayName;

  const MarketTypeV2(this.id, this.displayName);

  static MarketTypeV2 fromId(int id) {
    return MarketTypeV2.values.firstWhere(
      (type) => type.id == id,
      orElse: () => MarketTypeV2.unknown,
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
