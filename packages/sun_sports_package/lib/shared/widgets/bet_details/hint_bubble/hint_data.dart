import 'package:flutter/material.dart';
import 'package:sun_sports/shared/domain/enums/league_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Hint Data Model
///
/// Contains all data needed to generate hint content for betting popup.
/// Based on FLUTTER_HINT_BUBBLE_IMPLEMENTATION_GUIDE.md
class HintData {
  // === MARKET INFO ===
  /// ID của market (từ API)
  final int marketId;

  /// Sport ID (1: Bóng đá, 2: Bóng rổ, 4: Tennis, 5: Bóng chuyền).
  /// Quyết định đơn vị hiển thị (trái / điểm / game).
  final int sportId;

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
    this.sportId = 1,
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
      sportId: popupData.sportId,
      market: market,
      period: HintData.getPeriod(marketId),
      handicap: HintData.selectedHandicap(
        rawPoints: popupData.oddsData.points,
        market: market,
        oddsType: popupData.oddsType,
      ),
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
      case MarketCategory.homeOverUnder:
      case MarketCategory.awayOverUnder:
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

  /// Map market ID to MarketCategory (public for reuse).
  ///
  /// Soccer IDs follow the canonical odds list. Each market is mapped to its
  /// exact category so the hint renders the correct content (score handicap
  /// vs corner/bookings handicap, etc.).
  static MarketCategory getMarketCategory(int marketId) {
    // ===== Money Line (Basketball / Tennis / Volleyball) =====
    if ([200, 205, 400, 403, 500, 504].contains(marketId)) {
      return MarketCategory.moneyLine;
    }

    // ===== Asian Handicap (score) =====
    // Soccer: FT(5) HT(6) 2H(85) Extra(27,28) time-range(44-49).
    // Basketball(201,203) Tennis(402) Volleyball(509).
    if ([
      5, 6, 85, 27, 28, 44, 45, 46, 47, 48, 49, //
      201, 203, 402, 509,
    ].contains(marketId)) {
      return MarketCategory.asianHandicap;
    }

    // ===== Over/Under (score) =====
    // Soccer: FT(3) HT(4) 2H(80) Extra(25,26) time-range(38-43).
    // Basketball(202,204) Tennis(401) Volleyball(510).
    if ([
      3, 4, 80, 25, 26, 38, 39, 40, 41, 42, 43, //
      202, 204, 401, 510,
    ].contains(marketId)) {
      return MarketCategory.overUnder;
    }

    // ===== Home / Away team Over/Under =====
    if (marketId == 101) return MarketCategory.homeOverUnder;
    if (marketId == 102) return MarketCategory.awayOverUnder;

    // ===== Corner Handicap =====
    if ([19, 20].contains(marketId)) {
      return MarketCategory.cornerHandicap;
    }

    // ===== Corner Over/Under =====
    // FT(21) HT(22) home/away(61-64) 15-min(92-96) 10/5-min(104-128).
    if ([21, 22, 61, 62, 63, 64, 92, 93, 94, 95, 96].contains(marketId) ||
        (marketId >= 104 && marketId <= 128)) {
      return MarketCategory.cornerOverUnder;
    }

    // ===== Bookings Handicap / Over-Under =====
    if ([33, 34].contains(marketId)) {
      return MarketCategory.bookingsHandicap;
    }
    if ([31, 32].contains(marketId)) {
      return MarketCategory.bookingsOverUnder;
    }

    // ===== 1X2 (European) =====
    // FT(1) HT(2) 2H(89) Extra(23,24) time-range(50-55).
    if ([1, 2, 89, 23, 24, 50, 51, 52, 53, 54, 55].contains(marketId)) {
      return MarketCategory.market1X2;
    }

    // ===== Odd/Even =====
    // FT(8) HT(9) 2H(86) home/away team(76,77).
    if ([8, 9, 86, 76, 77].contains(marketId)) {
      return MarketCategory.oddEven;
    }

    // ===== Double Chance =====
    if ([12, 13].contains(marketId)) {
      return MarketCategory.doubleChance;
    }

    // ===== Correct Score / Total Score =====
    if ([10, 11].contains(marketId)) {
      return MarketCategory.correctScore;
    }
    if ([14, 15].contains(marketId)) {
      return MarketCategory.totalScore;
    }

    // ===== Draw No Bet (FT 16 / HT 75) =====
    if ([16, 75].contains(marketId)) {
      return MarketCategory.drawNoBet;
    }

    // ===== Other soccer markets =====
    if (marketId == 7) return MarketCategory.nextGoal;
    if (marketId == 97) return MarketCategory.lastGoal;
    if ([17, 18].contains(marketId)) return MarketCategory.corner1X2;
    if ([56, 57].contains(marketId)) return MarketCategory.cornerOddEven;
    if ([29, 30].contains(marketId)) return MarketCategory.bookings1X2;
    if (marketId == 138) return MarketCategory.yellowCards1X2;
    if (marketId == 139) return MarketCategory.yellowCardsOverUnder;
    if ([66, 67].contains(marketId)) return MarketCategory.lastCorner;
    if (marketId == 137) return MarketCategory.nextCorner;
    if ([131, 134, 135, 136].contains(marketId)) {
      return MarketCategory.cornerRange;
    }
    if (marketId == 58) return MarketCategory.toQualify;
    if (marketId == 59) return MarketCategory.whichTeamKickOff;
    if (marketId == 103) return MarketCategory.whichTeamToScore;
    if (marketId == 129) return MarketCategory.penaltyWinner;
    if (marketId == 130) return MarketCategory.penaltyTotal;
    if (marketId == 83) return MarketCategory.homeCleanSheet;
    if (marketId == 84) return MarketCategory.awayCleanSheet;
    if (marketId == 35) return MarketCategory.outright;

    return MarketCategory.unknown;
  }

  /// Map market ID to Period (public for reuse)
  static Period getPeriod(int marketId) {
    // Half Time markets (HT)
    if ([
      2, 4, 6, 9, 11, 13, 18, 20, 22, 24, 26, 28, 30, 32, 34, 57, 75,
    ].contains(marketId)) {
      return Period.halfTime;
    }
    // Second Half markets
    if ([80, 85, 86, 89].contains(marketId)) {
      return Period.secondHalf;
    }
    // Default to Full Time
    return Period.fullTime;
  }

  /// Resolve a handicap value from the SELECTED team's perspective.
  ///
  /// The API field `points` is always given from the Home team's perspective
  /// (negative = Home gives). When the bet is on the Away team, the sign must
  /// be flipped so that negative always means "selected team gives". This
  /// mirrors `SbOddsItem.point` in the original SbHint project. Over/Under
  /// markets keep the raw value (sign is irrelevant there).
  static double selectedHandicap({
    required String rawPoints,
    required MarketCategory market,
    required OddsType oddsType,
  }) {
    final raw = double.tryParse(rawPoints) ?? 0.0;
    final isHandicap =
        market == MarketCategory.asianHandicap ||
        market == MarketCategory.cornerHandicap ||
        market == MarketCategory.bookingsHandicap;
    if (isHandicap && oddsType == OddsType.away) {
      return -raw;
    }
    return raw;
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

  /// Markets that are bet as Over/Under (Tài/Xỉu).
  static const _overUnderMarkets = {
    MarketCategory.overUnder,
    MarketCategory.cornerOverUnder,
    MarketCategory.bookingsOverUnder,
    MarketCategory.homeOverUnder,
    MarketCategory.awayOverUnder,
  };

  /// Check if betting on Over
  bool get isOver =>
      team == HintTeamType.home && _overUnderMarkets.contains(market);

  /// Check if betting on Under
  bool get isUnder =>
      team == HintTeamType.away && _overUnderMarkets.contains(market);

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
