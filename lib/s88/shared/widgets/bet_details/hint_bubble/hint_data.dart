import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Hint Data Model
///
/// Contains all data needed to generate hint content for betting popup.
/// Based on FLUTTER_HINT_BUBBLE_IMPLEMENTATION_GUIDE.md
class HintData {
  // === MARKET INFO ===
  /// ID của market (từ API)
  final int marketId;

  /// Market category enum
  final MarketCategory market;

  /// Period of the bet
  final Period period;

  // === ODDS INFO ===
  /// Điểm chấp (vd: -0.5, 1.0, 2.5)
  final double handicap;

  /// Tỷ lệ cược (vd: 1.95, -0.85)
  final double ratio;

  /// Odds style enum
  final OddsStyle style;

  // === TEAM INFO ===
  /// Team type selected
  final HintTeamType team;

  /// Tên đội nhà
  final String homeName;

  /// Tên đội khách
  final String awayName;

  /// Tên đội/selection đang cược
  final String teamName;

  // === SCORE INFO ===
  /// Điểm đội nhà
  final int homeScore;

  /// Điểm đội khách
  final int awayScore;

  /// Số lần phạt góc đội nhà
  final int homeCorner;

  /// Số lần phạt góc đội khách
  final int awayCorner;

  /// Số thẻ phạt đội nhà (red*2 + yellow)
  final int homeBookings;

  /// Số thẻ phạt đội khách
  final int awayBookings;

  // === BET INFO ===
  /// Số tiền user nhập (đơn vị: VND)
  ///
  /// Example: 1000000.0 = 1,000,000 VND = 1M
  final double stake;

  /// Tổng tiền cược thực tế (cho Malay/Indo âm)
  final int totalCostBet;

  /// Trận đấu đang diễn ra?
  final bool isLive;

  // === OUTRIGHT INFO ===
  /// Event name for outright bets (e.g., "UEFA Champions League 2025/2026 - Winner")
  final String eventName;

  /// Event date for outright bets (e.g., "31/05/2026")
  final String eventDate;

  // === UI COLORS ===
  /// Màu text mô tả thông thường
  final Color simpleColor;

  /// Màu tên đội
  final Color teamColor;

  /// Màu bullet points, TH1, TH2...
  final Color highlightColor;

  /// Màu odds dương (blue)
  final Color positiveColor;

  /// Màu odds âm (red)
  final Color negativeColor;

  const HintData({
    required this.marketId,
    required this.market,
    required this.period,
    required this.handicap,
    required this.ratio,
    required this.style,
    required this.team,
    required this.homeName,
    required this.awayName,
    required this.teamName,
    required this.homeScore,
    required this.awayScore,
    required this.isLive,
    this.homeCorner = 0,
    this.awayCorner = 0,
    this.homeBookings = 0,
    this.awayBookings = 0,
    this.stake = 100000.0,
    this.totalCostBet = 0,
    this.eventName = '',
    this.eventDate = '',
    this.simpleColor = const Color(0xFFFFE991),
    this.teamColor = const Color(0xFFFBB877),
    this.highlightColor = const Color(0xFFFFE991),
    this.positiveColor = const Color(0xFF2E90FA),
    this.negativeColor = const Color(0xFFF63D68),
  });

  /// Create HintData from BettingPopupData
  factory HintData.fromBettingPopup({
    required BettingPopupData popupData,
    required double currentOdds,
    double stake = 100000.0, // Default 100K VND
  }) {
    final marketId = popupData.marketData.marketId;

    // Detect special outright bets: marketId = 0, awayName empty, homeName present
    final isOutright = marketId == 0 &&
        popupData.eventData.awayName.isEmpty &&
        popupData.eventData.homeName.isNotEmpty;

    final market = isOutright
        ? MarketCategory.outright
        : HintData.getMarketCategory(marketId);

    // Build event date for outright bets
    String eventDate = '';
    if (isOutright && popupData.eventData.startTime > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        popupData.eventData.startTime,
      );
      eventDate =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    return HintData(
      marketId: marketId,
      market: market,
      period: HintData.getPeriod(marketId),
      handicap: double.tryParse(popupData.oddsData.points) ?? 0.0,
      ratio: currentOdds,
      style: popupData.oddsStyle,
      team: HintData.mapOddsTypeToTeam(popupData.oddsType),
      homeName: popupData.eventData.homeName,
      awayName: popupData.eventData.awayName,
      teamName: popupData.getTeamName(),
      homeScore: popupData.eventData.homeScore,
      awayScore: popupData.eventData.awayScore,
      homeCorner: popupData.eventData.cornersHome,
      awayCorner: popupData.eventData.cornersAway,
      homeBookings:
          popupData.eventData.redCardsHome * 2 +
          popupData.eventData.yellowCardsHome,
      awayBookings:
          popupData.eventData.redCardsAway * 2 +
          popupData.eventData.yellowCardsAway,
      stake: stake,
      isLive: popupData.isLive,
      eventName: popupData.eventData.eventName ?? '',
      eventDate: eventDate,
    );
  }

  /// Get hint type based on handicap value
  HintType getHintType() {
    final handicapAbs = handicap.abs();
    final decimal = handicapAbs - handicapAbs.floor();

    switch (market) {
      case MarketCategory.asianHandicap:
      case MarketCategory.cornerHandicap:
      case MarketCategory.bookingsHandicap:
        if (_isZero(decimal)) {
          return HintType.asianHandicapRound;
        } else if (_isHalf(decimal)) {
          return HintType.asianHandicapHalf;
        } else if (_isQuarter(decimal)) {
          return handicap < 0
              ? HintType.asianHandicapQuarterOver
              : HintType.asianHandicapQuarterUnder;
        } else if (_isThreeQuarter(decimal)) {
          return handicap < 0
              ? HintType.asianHandicap3QuarterOver
              : HintType.asianHandicap3QuarterUnder;
        }
        return HintType.asianHandicapRound;

      case MarketCategory.overUnder:
      case MarketCategory.cornerOverUnder:
      case MarketCategory.bookingsOverUnder:
        if (_isZero(decimal)) {
          return HintType.overUnderRound;
        } else if (_isHalf(decimal)) {
          return HintType.overUnderHalf;
        } else if (_isQuarter(decimal)) {
          return HintType.overUnderQuarter;
        } else if (_isThreeQuarter(decimal)) {
          return HintType.overUnder3Quarter;
        }
        return HintType.overUnderHalf;

      case MarketCategory.market1X2:
        return HintType.market1X2;
      case MarketCategory.oddEven:
        return HintType.oddEven;
      case MarketCategory.doubleChance:
        return HintType.doubleChance;
      case MarketCategory.correctScore:
        return HintType.correctScore;
      case MarketCategory.drawNoBet:
        return HintType.drawNoBet;
      case MarketCategory.nextGoal:
        return HintType.nextGoal;
      case MarketCategory.moneyLine:
        return HintType.moneyLine;
      case MarketCategory.outright:
        return HintType.outright;
      default:
        return HintType.unknown;
    }
  }

  /// Get number of cases based on hint type
  int getCaseCount() {
    final hintType = getHintType();
    switch (hintType) {
      case HintType.asianHandicapRound:
      case HintType.overUnderRound:
        return 3; // Win, Draw, Lose
      case HintType.asianHandicapHalf:
      case HintType.overUnderHalf:
      case HintType.market1X2:
      case HintType.oddEven:
      case HintType.doubleChance:
      case HintType.moneyLine:
      case HintType.outright:
        return 2; // Win, Lose
      case HintType.asianHandicapQuarterOver:
      case HintType.asianHandicapQuarterUnder:
      case HintType.asianHandicap3QuarterOver:
      case HintType.asianHandicap3QuarterUnder:
      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        return 3; // Win, Half Win/Lose, Lose
      default:
        return 2;
    }
  }

  // Private helper methods

  static bool _isZero(double decimal) => decimal < 0.001;
  static bool _isHalf(double decimal) => (decimal - 0.5).abs() < 0.001;
  static bool _isQuarter(double decimal) => (decimal - 0.25).abs() < 0.001;
  static bool _isThreeQuarter(double decimal) => (decimal - 0.75).abs() < 0.001;

  /// Map market ID to MarketCategory (public for reuse)
  static MarketCategory getMarketCategory(int marketId) {
    // Asian Handicap
    if ([
      5,
      6,
      27,
      28,
      19,
      20,
      33,
      34,
      44,
      45,
      46,
      47,
      48,
      49,
    ].contains(marketId)) {
      return MarketCategory.asianHandicap;
    }
    // Over/Under
    if ([
      3,
      4,
      25,
      26,
      21,
      22,
      31,
      32,
      38,
      39,
      40,
      41,
      42,
      43,
      80,
    ].contains(marketId)) {
      return MarketCategory.overUnder;
    }
    // 1X2
    if ([
      1,
      2,
      23,
      24,
      17,
      18,
      29,
      30,
      50,
      51,
      52,
      53,
      54,
      55,
      89,
    ].contains(marketId)) {
      return MarketCategory.market1X2;
    }
    // Odd/Even
    if ([8, 9, 56, 57, 76, 77, 86].contains(marketId)) {
      return MarketCategory.oddEven;
    }
    // Double Chance
    if ([12, 13].contains(marketId)) {
      return MarketCategory.doubleChance;
    }
    // Correct Score
    if ([10, 11].contains(marketId)) {
      return MarketCategory.correctScore;
    }
    // Draw No Bet
    if ([16].contains(marketId)) {
      return MarketCategory.drawNoBet;
    }
    // Corner markets
    if ([101, 102].contains(marketId)) {
      return MarketCategory.cornerOverUnder;
    }
    if ([103, 104].contains(marketId)) {
      return MarketCategory.cornerHandicap;
    }
    // Money Line (Basketball, Tennis, Volleyball)
    if ([200, 205, 400, 403, 500, 504].contains(marketId)) {
      return MarketCategory.moneyLine;
    }
    // Basketball Handicap
    if ([201, 203].contains(marketId)) {
      return MarketCategory.asianHandicap;
    }
    // Basketball Over/Under
    if ([202, 204].contains(marketId)) {
      return MarketCategory.overUnder;
    }
    // Tennis
    if ([402].contains(marketId)) {
      return MarketCategory.asianHandicap;
    }
    if ([401].contains(marketId)) {
      return MarketCategory.overUnder;
    }
    // Volleyball
    if ([509].contains(marketId)) {
      return MarketCategory.asianHandicap;
    }
    if ([510].contains(marketId)) {
      return MarketCategory.overUnder;
    }

    return MarketCategory.unknown;
  }

  /// Map market ID to Period (public for reuse)
  static Period getPeriod(int marketId) {
    // Half Time markets (HT)
    if ([2, 4, 6, 9, 11, 13, 24, 26, 28, 30, 32, 34].contains(marketId)) {
      return Period.halfTime;
    }
    // Default to Full Time
    return Period.fullTime;
  }

  /// Map OddsType to HintTeamType (public for reuse)
  static HintTeamType mapOddsTypeToTeam(OddsType oddsType) {
    switch (oddsType) {
      case OddsType.home:
        return HintTeamType.home;
      case OddsType.away:
        return HintTeamType.away;
      case OddsType.draw:
        return HintTeamType.draw;
      default:
        return HintTeamType.none;
    }
  }

  /// Check if betting on Over
  bool get isOver =>
      team == HintTeamType.home &&
      (market == MarketCategory.overUnder ||
          market == MarketCategory.cornerOverUnder ||
          market == MarketCategory.bookingsOverUnder);

  /// Check if betting on Under
  bool get isUnder =>
      team == HintTeamType.away &&
      (market == MarketCategory.overUnder ||
          market == MarketCategory.cornerOverUnder ||
          market == MarketCategory.bookingsOverUnder);

  /// Check if betting on Odd
  bool get isOdd =>
      team == HintTeamType.home && market == MarketCategory.oddEven;

  /// Check if betting on Even
  bool get isEven =>
      team == HintTeamType.away && market == MarketCategory.oddEven;

  /// Get selected team name for Over/Under markets
  String get selectionName {
    if (isOver) return 'Tài';
    if (isUnder) return 'Xỉu';
    if (isOdd) return 'Lẻ';
    if (isEven) return 'Chẵn';
    if (team == HintTeamType.draw) return 'Hòa';
    return teamName;
  }
}
