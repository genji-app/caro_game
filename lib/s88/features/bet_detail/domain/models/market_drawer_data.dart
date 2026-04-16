import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';

/// Market Drawer Data Model
///
/// Represents a group of markets displayed together in a drawer.
/// Example: "Trận đấu" drawer contains Handicap FT, O/U FT, 1X2 FT (+ HT versions)
class MarketDrawerData {
  /// Drawer display name (e.g., "Trận đấu", "Phạt góc")
  final String name;

  /// Filter category this drawer belongs to
  final MarketFilter filter;

  /// Layout type for rendering
  final MarketPoolType poolType;

  /// List of markets in this drawer
  final List<LeagueMarketData> markets;

  /// Whether drawer is expanded
  final bool isExpanded;

  const MarketDrawerData({
    required this.name,
    required this.filter,
    required this.poolType,
    required this.markets,
    this.isExpanded = true,
  });

  /// Check if drawer has any valid markets with odds
  bool get hasValidMarkets => markets.any((m) => m.odds.isNotEmpty);

  /// Check if drawer is empty
  bool get isEmpty => markets.isEmpty || !hasValidMarkets;

  /// Get total odds count across all markets
  int get totalOddsCount => markets.fold(0, (sum, m) => sum + m.odds.length);

  /// Copy with new values
  MarketDrawerData copyWith({
    String? name,
    MarketFilter? filter,
    MarketPoolType? poolType,
    List<LeagueMarketData>? markets,
    bool? isExpanded,
  }) {
    return MarketDrawerData(
      name: name ?? this.name,
      filter: filter ?? this.filter,
      poolType: poolType ?? this.poolType,
      markets: markets ?? this.markets,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Market Pool Type - Layout type for different market groups
///
/// Based on SbEventDrawer.ts pool types
enum MarketPoolType {
  /// Main 3 columns: Handicap, O/U, 1X2
  main,

  /// Main 6 columns: FT + HT
  main6,

  /// Vertical list (Together)
  together,

  /// 4 columns vertical
  together4,

  /// Correct Score grid (3 columns: Home/Draw/Away)
  correctScore,

  /// Correct Score 6 columns
  correctScore6,

  /// 2 options (Odd/Even, Yes/No)
  only2,

  /// 2x2 grid
  only2x2,

  /// 3 options (Double Chance)
  only3,

  /// 3x2 grid
  only3x2,

  /// 4 options
  only4,

  /// 2 markets vertical
  market2,
}

/// Market Drawer Builder
///
/// Builds drawer data from event markets
class MarketDrawerBuilder {
  MarketDrawerBuilder._();

  /// Build all drawers from event markets
  ///
  /// Groups markets into logical drawers based on market type.
  /// Layout types based on FLUTTER_MARKET_LAYOUT_GUIDE.md
  ///
  /// [isDesktop] - When true, uses landscape layouts (6 columns, merged drawers)
  ///               When false, uses portrait layouts (3 columns, separate drawers)
  static List<MarketDrawerData> buildDrawers(
    List<LeagueMarketData> markets, {
    bool isDesktop = true,
  }) {
    final drawers = <MarketDrawerData>[];

    // ===== MATCH CATEGORY =====

    // Group 1: Main Match (FT + HT) - poolMain6
    final mainFT = _findMarkets(markets, [5, 3, 1]); // Handicap, O/U, 1X2 FT
    final mainHT = _findMarkets(markets, [6, 4, 2]); // Handicap, O/U, 1X2 HT
    if (mainFT.isNotEmpty || mainHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Trận đấu',
          filter: MarketFilter.match,
          poolType: MarketPoolType.main6,
          markets: [...mainFT, ...mainHT],
        ),
      );
    }

    // Group 2: Odd/Even (FT + HT) - poolOnly2x2
    final oddEven = _findMarkets(markets, [8, 9]);
    if (oddEven.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Chẵn/Lẻ',
          filter: MarketFilter.match,
          poolType: oddEven.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: oddEven,
        ),
      );
    }

    // Group 3: Double Chance (FT + HT) - poolOnly3x2
    final doubleChance = _findMarkets(markets, [12, 13]);
    if (doubleChance.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Cơ hội kép',
          filter: MarketFilter.match,
          poolType: doubleChance.length >= 2
              ? MarketPoolType.only3x2
              : MarketPoolType.only3,
          markets: doubleChance,
        ),
      );
    }

    // Group 4: Draw No Bet (FT + HT) - poolOnly2x2
    // Market IDs: 16 (DrawNoBetFT), 75 (DrawNoBetHT) - NOT 16, 17!
    // Note: 17 is Corner1X2FT
    final drawNoBet = _findMarkets(markets, [16, 75]);
    if (drawNoBet.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Hòa hoàn tiền',
          filter: MarketFilter.match,
          poolType: drawNoBet.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: drawNoBet,
        ),
      );
    }

    // Group 5: Second Half (SH) - poolMain
    // Market IDs: 85 (Handicap SH), 80 (O/U SH), 89 (1X2 SH)
    final secondHalf = _findMarkets(markets, [85, 80, 89]);
    if (secondHalf.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Hiệp 2',
          filter: MarketFilter.match,
          poolType: MarketPoolType.main,
          markets: secondHalf,
        ),
      );
    }

    // Group 6: Extra Time FT+HT - poolMain6
    // Market IDs: [27, 25, 23] FT, [28, 26, 24] HT
    final extraTimeFT = _findMarkets(markets, [27, 25, 23]);
    final extraTimeHT = _findMarkets(markets, [28, 26, 24]);
    if (extraTimeFT.isNotEmpty || extraTimeHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Hiệp phụ',
          filter: MarketFilter.match,
          poolType: MarketPoolType.main6,
          markets: [...extraTimeFT, ...extraTimeHT],
        ),
      );
    }

    // Group 7-12: Time Ranges (0-15, 15-30, 30-45, 45-60, 60-75, 75-90)
    _addTimeRangeDrawers(markets, drawers);

    // Group 13: Next Goal - poolOnly3
    final nextGoal = _findMarkets(markets, [7]);
    if (nextGoal.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Bàn tiếp theo',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only3,
          markets: nextGoal,
        ),
      );
    }

    // Group 14: Last Goal - poolOnly3
    // Market ID: 97 (NOT 63!)
    final lastGoal = _findMarkets(markets, [97]);
    if (lastGoal.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Bàn cuối cùng',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only3,
          markets: lastGoal,
        ),
      );
    }

    // Group 15: Which Team To Score - poolOnly4
    // Market ID: 103 (NOT 60!)
    final whichTeamToScore = _findMarkets(markets, [103]);
    if (whichTeamToScore.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội ghi bàn',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only4,
          markets: whichTeamToScore,
        ),
      );
    }

    // Group 16: To Qualify - poolOnly2
    // Market ID: 58 (NOT 61! - 61 is CornerOverUnderHomeFT)
    final toQualify = _findMarkets(markets, [58]);
    if (toQualify.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội vào vòng trong',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2,
          markets: toQualify,
        ),
      );
    }

    // Group 17: Which Team Kick Off - poolOnly2
    // Market ID: 59
    final whichTeamKickOff = _findMarkets(markets, [59]);
    if (whichTeamKickOff.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội giao bóng trước',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2,
          markets: whichTeamKickOff,
        ),
      );
    }

    // Group 18: Home O/U - poolMarket2
    // Market ID: 101
    final homeOU = _findMarkets(markets, [101]);
    if (homeOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tài/Xỉu Đội nhà',
          filter: MarketFilter.match,
          poolType: MarketPoolType.market2,
          markets: homeOU,
        ),
      );
    }

    // Group 19: Away O/U - poolMarket2
    // Market ID: 102
    final awayOU = _findMarkets(markets, [102]);
    if (awayOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tài/Xỉu Đội khách',
          filter: MarketFilter.match,
          poolType: MarketPoolType.market2,
          markets: awayOU,
        ),
      );
    }

    // Group 20: Home/Away Odd/Even - poolOnly2x2
    // Market IDs: 76 (Home), 77 (Away) - NOT 50, 51!
    final homeAwayOddEven = _findMarkets(markets, [76, 77]);
    if (homeAwayOddEven.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Chẵn/Lẻ theo đội',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2x2,
          markets: homeAwayOddEven,
        ),
      );
    }

    // Group 21: Penalty Shootout Winner - poolOnly2
    // Market ID: 129
    final penaltyShootoutWinner = _findMarkets(markets, [129]);
    if (penaltyShootoutWinner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Đội thắng Penalty',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2,
          markets: penaltyShootoutWinner,
        ),
      );
    }

    // Group 22: Penalty Shootout Total - poolMarket2
    // Market ID: 130
    final penaltyShootoutTotal = _findMarkets(markets, [130]);
    if (penaltyShootoutTotal.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tài/Xỉu Penalty',
          filter: MarketFilter.match,
          poolType: MarketPoolType.market2,
          markets: penaltyShootoutTotal,
        ),
      );
    }

    // Group 11: Clean Sheet - poolOnly2x2
    // Market IDs: 83 (HomeCleanSheet), 84 (AwayCleanSheet)
    final cleanSheet = _findMarkets(markets, [83, 84]);
    if (cleanSheet.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Giữ sạch lưới',
          filter: MarketFilter.match,
          poolType: MarketPoolType.only2x2,
          markets: cleanSheet,
        ),
      );
    }

    // ===== SCORE CATEGORY =====

    // Group 12 & 13: Correct Score
    // Desktop (landscape): Merge FT + HT into 1 drawer with 6 columns (poolCorrect6)
    // Mobile (portrait): Separate drawers with 3 columns each (poolCorrect)
    final correctScoreFT = _findMarkets(markets, [10]);
    final correctScoreHT = _findMarkets(markets, [11]);

    if (isDesktop) {
      // Desktop: Merge FT + HT into one drawer
      if (correctScoreFT.isNotEmpty || correctScoreHT.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: 'Tỷ số chính xác',
            filter: MarketFilter.score,
            poolType: MarketPoolType.correctScore6,
            markets: [...correctScoreFT, ...correctScoreHT],
          ),
        );
      }
    } else {
      // Mobile: Separate drawers
      if (correctScoreFT.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: 'Tỷ số chính xác',
            filter: MarketFilter.score,
            poolType: MarketPoolType.correctScore,
            markets: correctScoreFT,
          ),
        );
      }
      if (correctScoreHT.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: 'Tỷ số chính xác H1',
            filter: MarketFilter.score,
            poolType: MarketPoolType.correctScore,
            markets: correctScoreHT,
          ),
        );
      }
    }

    // Group 14: Total Score - poolTogether
    final totalScore = _findMarkets(markets, [14, 15]);
    if (totalScore.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tổng bàn thắng',
          filter: MarketFilter.score,
          poolType: MarketPoolType.together,
          markets: totalScore,
        ),
      );
    }

    // Group 14b: Total Goals Exactly - poolTogether
    // Market ID: 145
    final totalGoalsExactly = _findMarkets(markets, [145]);
    if (totalGoalsExactly.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Tổng bàn thắng chính xác',
          filter: MarketFilter.score,
          poolType: MarketPoolType.together,
          markets: totalGoalsExactly,
        ),
      );
    }

    // ===== CORNER CATEGORY =====

    // Group 15: Corner Main (FT + HT) - poolMain6
    // FT: 19 (Handicap), 21 (O/U), 17 (1X2)
    // HT: 20 (Handicap), 22 (O/U), 18 (1X2)
    final cornerFT = _findMarkets(markets, [19, 21, 17]); // H, O/U, 1X2 FT
    final cornerHT = _findMarkets(markets, [20, 22, 18]); // H, O/U, 1X2 HT
    if (cornerFT.isNotEmpty || cornerHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.main6,
          markets: [...cornerFT, ...cornerHT],
        ),
      );
    }

    // Group 16: Corner Odd/Even - poolOnly2x2
    // Market IDs: 56 (CornerOddEvenFT), 57 (CornerOddEvenHT)
    final cornerOddEven = _findMarkets(markets, [56, 57]);
    if (cornerOddEven.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc Chẵn/Lẻ',
          filter: MarketFilter.corner,
          poolType: cornerOddEven.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: cornerOddEven,
        ),
      );
    }

    // Group 17: Last Corner - poolOnly2x2
    // Market IDs: 66 (LastCornerFT), 67 (LastCornerHT) - NOT 54, 55!
    final lastCorner = _findMarkets(markets, [66, 67]);
    if (lastCorner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc cuối cùng',
          filter: MarketFilter.corner,
          poolType: lastCorner.length >= 2
              ? MarketPoolType.only2x2
              : MarketPoolType.only2,
          markets: lastCorner,
        ),
      );
    }

    // Group 18: Corner O/U by Team - poolTogether4
    // Market IDs: 61 (HomeFT), 63 (AwayFT), 62 (HomeHT), 64 (AwayHT)
    // NOT 41, 42, 43, 44!
    final cornerOUByTeam = _findMarkets(markets, [61, 63, 62, 64]);
    if (cornerOUByTeam.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc Tài/Xỉu theo đội',
          filter: MarketFilter.corner,
          poolType: cornerOUByTeam.length >= 4
              ? MarketPoolType.together4
              : MarketPoolType.together,
          markets: cornerOUByTeam,
        ),
      );
    }

    // Group 19: Corner Range - poolTogether4
    // Market IDs: 131, 136, 134, 135 - NOT 45, 46, 47, 48!
    final cornerRange = _findMarkets(markets, [131, 136, 134, 135]);
    if (cornerRange.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc khoảng',
          filter: MarketFilter.corner,
          poolType: cornerRange.length >= 4
              ? MarketPoolType.together4
              : MarketPoolType.together,
          markets: cornerRange,
        ),
      );
    }

    // Group 20: Next Corner - poolOnly3
    // Market ID: 137
    final nextCorner = _findMarkets(markets, [137]);
    if (nextCorner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc tiếp theo',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.only3,
          markets: nextCorner,
        ),
      );
    }

    // Group 21: Corner Time-based by 15min - poolTogether
    // Market IDs: 92-96
    _addCornerTimeRangeDrawers(markets, drawers);

    // Group 22: Extra Time Corner - poolMarket2
    // Market IDs: 142 (ExtraTimeCornerOverUnder)
    final extraTimeCornerOU = _findMarkets(markets, [142]);
    if (extraTimeCornerOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Phạt góc hiệp phụ Tài/Xỉu',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.market2,
          markets: extraTimeCornerOU,
        ),
      );
    }

    // Group 23: European Handicap Corner - poolMarket2
    // Market ID: 144
    final europeanHandicapCorner = _findMarkets(markets, [144]);
    if (europeanHandicapCorner.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Chấp phạt góc châu Âu',
          filter: MarketFilter.corner,
          poolType: MarketPoolType.market2,
          markets: europeanHandicapCorner,
        ),
      );
    }

    // ===== BOOKING CATEGORY =====

    // Group 24: Bookings Main (FT + HT) - poolMain6
    // Based on SbMarketItem.ts:1327-1332 and SbEventDetail.ts:450
    // Order: [Handicap, O/U, 1X2]
    // FT: 33 (Handicap), 31 (O/U), 29 (1X2)
    // HT: 34 (Handicap), 32 (O/U), 30 (1X2)
    final bookingFT = _findMarkets(markets, [
      33,
      31,
      29,
    ]); // Handicap, O/U, 1X2 FT
    final bookingHT = _findMarkets(markets, [
      34,
      32,
      30,
    ]); // Handicap, O/U, 1X2 HT
    if (bookingFT.isNotEmpty || bookingHT.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ phạt',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.main6,
          markets: [...bookingFT, ...bookingHT],
        ),
      );
    }

    // Group 25: Yellow Cards 1X2 - poolOnly3
    // Market ID: 138
    final yellowCards1X2 = _findMarkets(markets, [138]);
    if (yellowCards1X2.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ vàng 1X2',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.only3,
          markets: yellowCards1X2,
        ),
      );
    }

    // Group 26: Yellow Cards Over/Under - poolMarket2
    // Market ID: 139
    final yellowCardsOU = _findMarkets(markets, [139]);
    if (yellowCardsOU.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ vàng Tài/Xỉu',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.market2,
          markets: yellowCardsOU,
        ),
      );
    }

    // Group 27: Yellow Cards Double Chance - poolOnly3
    // Market ID: 143
    final yellowCardsDC = _findMarkets(markets, [143]);
    if (yellowCardsDC.isNotEmpty) {
      drawers.add(
        MarketDrawerData(
          name: 'Thẻ vàng cơ hội kép',
          filter: MarketFilter.booking,
          poolType: MarketPoolType.only3,
          markets: yellowCardsDC,
        ),
      );
    }

    return drawers;
  }

  /// Add Time Range drawers (0-15, 15-30, 30-45, 45-60, 60-75, 75-90)
  ///
  /// Each time range has 3 markets: [Handicap, O/U, 1X2]
  /// Based on FLUTTER_MARKET_LAYOUT_GUIDE.md section 0.19
  static void _addTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerData> drawers,
  ) {
    // Time Range Market IDs: [Handicap, O/U, 1X2]
    const timeRanges = [
      {
        'name': '0-15 phút',
        'ids': [44, 38, 50],
      },
      {
        'name': '15-30 phút',
        'ids': [45, 39, 51],
      },
      {
        'name': '30-45 phút',
        'ids': [46, 40, 52],
      },
      {
        'name': '45-60 phút',
        'ids': [47, 41, 53],
      },
      {
        'name': '60-75 phút',
        'ids': [48, 42, 54],
      },
      {
        'name': '75-90 phút',
        'ids': [49, 43, 55],
      },
    ];

    for (final range in timeRanges) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.match,
            poolType: MarketPoolType.main,
            markets: rangeMarkets,
          ),
        );
      }
    }
  }

  /// Add Corner Time Range drawers
  ///
  /// Corner markets by time intervals:
  /// - 15min intervals: 92-96
  /// - 10min intervals: 104-111
  /// - 5min intervals: 112-128
  static void _addCornerTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerData> drawers,
  ) {
    // Corner by 15min intervals
    const corner15min = [
      {
        'name': 'Phạt góc 0-15\'',
        'ids': [92],
      },
      {
        'name': 'Phạt góc 15-30\'',
        'ids': [93],
      },
      {
        'name': 'Phạt góc 30-45\'',
        'ids': [94],
      },
      {
        'name': 'Phạt góc 45-60\'',
        'ids': [95],
      },
      {
        'name': 'Phạt góc 60-75\'',
        'ids': [96],
      },
    ];

    // Corner by 10min intervals
    const corner10min = [
      {
        'name': 'Phạt góc 0-10\'',
        'ids': [104],
      },
      {
        'name': 'Phạt góc 10-20\'',
        'ids': [105],
      },
      {
        'name': 'Phạt góc 20-30\'',
        'ids': [106],
      },
      {
        'name': 'Phạt góc 30-40\'',
        'ids': [107],
      },
      {
        'name': 'Phạt góc 40-50\'',
        'ids': [108],
      },
      {
        'name': 'Phạt góc 50-60\'',
        'ids': [109],
      },
      {
        'name': 'Phạt góc 60-70\'',
        'ids': [110],
      },
      {
        'name': 'Phạt góc 70-80\'',
        'ids': [111],
      },
    ];

    // Corner by 5min intervals
    const corner5min = [
      {
        'name': 'Phạt góc 0-5\'',
        'ids': [112],
      },
      {
        'name': 'Phạt góc 5-10\'',
        'ids': [113],
      },
      {
        'name': 'Phạt góc 10-15\'',
        'ids': [114],
      },
      {
        'name': 'Phạt góc 15-20\'',
        'ids': [115],
      },
      {
        'name': 'Phạt góc 20-25\'',
        'ids': [116],
      },
      {
        'name': 'Phạt góc 25-30\'',
        'ids': [117],
      },
      {
        'name': 'Phạt góc 30-35\'',
        'ids': [118],
      },
      {
        'name': 'Phạt góc 35-40\'',
        'ids': [119],
      },
      {
        'name': 'Phạt góc 40-45\'',
        'ids': [120],
      },
      {
        'name': 'Phạt góc 45-50\'',
        'ids': [121],
      },
      {
        'name': 'Phạt góc 50-55\'',
        'ids': [122],
      },
      {
        'name': 'Phạt góc 55-60\'',
        'ids': [123],
      },
      {
        'name': 'Phạt góc 60-65\'',
        'ids': [124],
      },
      {
        'name': 'Phạt góc 65-70\'',
        'ids': [125],
      },
      {
        'name': 'Phạt góc 70-75\'',
        'ids': [126],
      },
      {
        'name': 'Phạt góc 75-80\'',
        'ids': [127],
      },
      {
        'name': 'Phạt góc 80-85\'',
        'ids': [128],
      },
    ];

    // Add 15min intervals first (most common)
    for (final range in corner15min) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.corner,
            poolType: MarketPoolType.market2,
            markets: rangeMarkets,
          ),
        );
      }
    }

    // Add 10min intervals
    for (final range in corner10min) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.corner,
            poolType: MarketPoolType.market2,
            markets: rangeMarkets,
          ),
        );
      }
    }

    // Add 5min intervals
    for (final range in corner5min) {
      final rangeMarkets = _findMarkets(markets, (range['ids'] as List<int>));
      if (rangeMarkets.isNotEmpty) {
        drawers.add(
          MarketDrawerData(
            name: range['name'] as String,
            filter: MarketFilter.corner,
            poolType: MarketPoolType.market2,
            markets: rangeMarkets,
          ),
        );
      }
    }
  }

  /// Find markets by IDs, maintaining order
  static List<LeagueMarketData> _findMarkets(
    List<LeagueMarketData> markets,
    List<int> marketIds,
  ) {
    final result = <LeagueMarketData>[];
    for (final id in marketIds) {
      final market = markets.where((m) => m.marketId == id).firstOrNull;
      if (market != null && market.odds.isNotEmpty) {
        result.add(market);
      }
    }
    return result;
  }
}
