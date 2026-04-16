import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Market Layout Helper
///
/// Provides utilities for determining market layouts and grouping odds.
/// Based on SbEventDetail.ts:384-555 and SbEventDrawer.ts:200-224
class MarketLayoutHelper {
  MarketLayoutHelper._();

  // ===== MARKET TYPE CHECKS =====

  /// Check if market is 1X2 type
  static bool is1X2(int id) =>
      [1, 2, 17, 18, 23, 24, 29, 30, 50, 51, 52, 53, 54, 55, 89].contains(id);

  /// Check if market is Handicap type
  static bool isHandicap(int id) => [
        // Soccer
        5, 6, 19, 20, 27, 28, 33, 34, 44, 45, 46, 47, 48, 49, 85,
        // Basketball (FT, HT, Q1-Q4)
        201, 203, 210, 211, 212, 213,
        // Combat
        308, 309, 310,
        // Tennis
        402,
        // Volleyball
        509,
        // Table Tennis
        609,
        // Badminton
        702, 709, 711,
      ].contains(id);

  /// Check if market is Over/Under type
  static bool isOverUnder(int id) => [
        // Soccer
        3, 4, 21, 22, 25, 26, 31, 32, 38, 39, 40, 41, 42, 43, 80,
        // Basketball
        202, 204, 214, 215, 216, 217,
        // Combat
        301, 305, 307,
        // Tennis
        401,
        // Volleyball
        510,
        // Table Tennis
        610,
        // Badminton
        701, 710, 712,
      ].contains(id);

  /// Check if market is Odd/Even type
  static bool isOddEven(int id) => [8, 9, 56, 57, 76, 77, 86].contains(id);

  /// Check if market is Correct Score type
  static bool isCorrectScore(int id) => [10, 11].contains(id);

  /// Check if market is Double Chance type
  static bool isDoubleChance(int id) => [12, 13].contains(id);

  /// Check if market is Total Score type
  static bool isTotalScore(int id) => [14, 15].contains(id);

  /// Check if market is Draw No Bet type
  static bool isDrawNoBet(int id) => [16, 75].contains(id);

  /// Check if market is Corner Range type
  static bool isCornerRange(int id) => [131, 134, 135, 136].contains(id);

  /// Check if market is Second Half type
  static bool isSecondHalf(int id) => [80, 85, 86, 89].contains(id);

  // ===== ALWAYS DECIMAL LOGIC =====

  /// Markets that ALWAYS use Decimal odds, regardless of user setting.
  /// Based on SbOddsItem.ts:135-141 from JS team.
  ///
  /// Returns true if the market should always display Decimal odds.
  static bool isAlwaysDecimal(int marketId) {
    return is1X2(marketId) ||
        isDrawNoBet(marketId) ||
        isCorrectScore(marketId) ||
        isDoubleChance(marketId) ||
        isTotalScore(marketId) ||
        isCornerRange(marketId) ||
        isSecondHalf(marketId) ||
        [
          7, // NextGoal
          97, // LastGoal
          58, // ToQualify
          59, // WhichTeamKickOff
          61, 62, 63, 64, // Corner O/U Home/Away FT/HT
          66, 67, // LastCorner FT/HT
          76, 77, // Home/Away OddEven
          103, // WhichTeamToScore
          101, 102, // Home/Away OverUnder
          35, // Outright
          // Basketball Money Line (FT, HT, Q1-Q4)
          200, 205, 206, 207, 208, 209,
          // Combat Money Line (Boxing, MU, BOX)
          300, 304, 306,
          // Tennis Money Line (FT, Set 1-4)
          400, 404, 405, 406, 407,
          // Volleyball Money Line (FT, Set 1-5)
          500, 504, 505, 506, 507, 508,
          // Table Tennis Money Line (FT, Ván 1-7)
          600, 602, 603, 604, 605, 606, 607, 608,
          // Badminton Money Line (FT, Ván 1)
          700, 705,
        ].contains(marketId);
  }

  /// Get the effective odds style for a market.
  /// Returns Decimal if market requires it, otherwise returns user's selected style.
  static OddsStyle getEffectiveOddsStyle(int marketId, OddsStyle userStyle) {
    if (isAlwaysDecimal(marketId)) {
      return OddsStyle.decimal;
    }
    return userStyle;
  }

  /// Get odds value based on effective style for a market.
  static String getOddsValue(
    OddsValue oddsValue,
    int marketId,
    OddsStyle userStyle,
  ) {
    final effectiveStyle = getEffectiveOddsStyle(marketId, userStyle);

    switch (effectiveStyle) {
      case OddsStyle.malay:
        if (oddsValue.malay == -100) return '-';
        return oddsValue.malay.toStringAsFixed(2);
      case OddsStyle.indo:
        if (oddsValue.indo == -100) return '-';
        return oddsValue.indo.toStringAsFixed(2);
      case OddsStyle.decimal:
        if (oddsValue.decimal <= 0) return '-';
        return oddsValue.decimal.toStringAsFixed(2);
      case OddsStyle.hongKong:
        if (oddsValue.hongKong == -100) return '-';
        return oddsValue.hongKong.toStringAsFixed(2);
    }
  }

  /// Get pool type for a group of market IDs
  ///
  /// Logic based on SbEventDetail.ts pool mapping
  static MarketPoolType getPoolType({
    required List<int> marketIds,
    required bool isLandscape,
  }) {
    final sortedIds = [...marketIds]..sort();

    // Main Match markets (6 columns)
    if (_matchesPattern(sortedIds, [1, 2, 3, 4, 5, 6])) {
      return isLandscape ? MarketPoolType.main6 : MarketPoolType.main;
    }

    // Main Match FT only
    if (_matchesPattern(sortedIds, [1, 3, 5])) {
      return MarketPoolType.main;
    }

    // Corner Main (6 columns)
    if (_matchesPattern(sortedIds, [17, 18, 19, 20, 21, 22])) {
      return isLandscape ? MarketPoolType.main6 : MarketPoolType.main;
    }

    // Booking Main (6 columns)
    if (_matchesPattern(sortedIds, [23, 24, 25, 26, 27, 28])) {
      return isLandscape ? MarketPoolType.main6 : MarketPoolType.main;
    }

    // Correct Score
    if (sortedIds.contains(10) && sortedIds.contains(11)) {
      return isLandscape
          ? MarketPoolType.correctScore6
          : MarketPoolType.correctScore;
    }
    if (sortedIds.contains(10) || sortedIds.contains(11)) {
      return MarketPoolType.correctScore;
    }

    // Odd/Even
    if (_matchesPattern(sortedIds, [8, 9])) {
      return isLandscape ? MarketPoolType.only2x2 : MarketPoolType.only2;
    }
    if (sortedIds.contains(8) || sortedIds.contains(9)) {
      return MarketPoolType.only2;
    }

    // Double Chance
    if (_matchesPattern(sortedIds, [12, 13])) {
      return isLandscape ? MarketPoolType.only3x2 : MarketPoolType.only3;
    }
    if (sortedIds.contains(12) || sortedIds.contains(13)) {
      return MarketPoolType.only3;
    }

    // Draw No Bet
    if (_matchesPattern(sortedIds, [16, 35])) {
      return isLandscape ? MarketPoolType.only2x2 : MarketPoolType.only2;
    }

    // Total Score
    if (_matchesPattern(sortedIds, [14, 15])) {
      return isLandscape ? MarketPoolType.together : MarketPoolType.together;
    }

    // Next Goal / Last Goal
    if (sortedIds.contains(7)) {
      return MarketPoolType.only3;
    }

    // Home/Away O/U
    if (_matchesPattern(sortedIds, [80, 81])) {
      return MarketPoolType.market2;
    }

    // Default
    return MarketPoolType.main;
  }

  /// Check if sorted IDs match a pattern
  static bool _matchesPattern(List<int> sortedIds, List<int> pattern) {
    if (sortedIds.length != pattern.length) return false;
    final sortedPattern = [...pattern]..sort();
    for (var i = 0; i < sortedIds.length; i++) {
      if (sortedIds[i] != sortedPattern[i]) return false;
    }
    return true;
  }
}

/// Correct Score Helper
///
/// Groups and sorts odds for Correct Score markets.
/// Based on SbEventDrawer.ts:200-224
///
/// API returns points in format "X:Y" (with colon separator)
/// Display should show "X-Y" (with dash separator)
/// AOS (Any Other Score) is returned as "9:9"
class CorrectScoreHelper {
  CorrectScoreHelper._();

  /// Check if points represents AOS (Any Other Score)
  /// API returns "9:9" for AOS
  static bool isAOS(String points) => points == '9:9';

  /// Get display text for points
  /// Converts "1:0" → "1-0", "9:9" → "AOS"
  static String getDisplayText(String points) {
    if (points == '9:9') return 'AOS';
    return points.replaceAll(':', '-');
  }

  /// Parse scores from points string
  /// Handles both ":" (API format) and "-" (display format) separators
  static (int homeScore, int awayScore)? parseScores(String points) {
    // Try colon separator first (API format)
    var parts = points.split(':');
    if (parts.length != 2) {
      // Fallback to dash separator
      parts = points.split('-');
    }
    if (parts.length != 2) return null;

    final homeScore = int.tryParse(parts[0]);
    final awayScore = int.tryParse(parts[1]);
    if (homeScore == null || awayScore == null) return null;

    return (homeScore, awayScore);
  }

  /// Group odds into Home wins, Draw, Away wins
  ///
  /// Home wins: home score > away score (1:0, 2:0, 2:1, etc.)
  /// Draw: home score == away score (0:0, 1:1, 2:2, 9:9/AOS, etc.)
  /// Away wins: home score < away score (0:1, 0:2, 1:2, etc.)
  static CorrectScoreGroups groupOdds(List<LeagueOddsData> odds) {
    final home = <LeagueOddsData>[];
    final draw = <LeagueOddsData>[];
    final away = <LeagueOddsData>[];

    for (final o in odds) {
      final scores = parseScores(o.points);
      if (scores == null) continue;

      final (homeScore, awayScore) = scores;

      if (homeScore > awayScore) {
        home.add(o);
      } else if (homeScore < awayScore) {
        away.add(o);
      } else {
        // Draw includes AOS (9:9 where 9 == 9)
        draw.add(o);
      }
    }

    // Sort: Home/Draw by home score first, Away by away score first
    // AOS (9:9) will naturally sort to the end of Draw column
    home.sort(_sortByHomeFirst);
    draw.sort(_sortByHomeFirst);
    away.sort(_sortByAwayFirst);

    return CorrectScoreGroups(home: home, draw: draw, away: away);
  }

  /// Sort by home score first, then away score
  /// Based on SbEventDrawer.ts sorting logic
  static int _sortByHomeFirst(LeagueOddsData a, LeagueOddsData b) {
    final scoresA = parseScores(a.points);
    final scoresB = parseScores(b.points);
    if (scoresA == null || scoresB == null) return 0;

    final (ah, aa) = scoresA;
    final (bh, ba) = scoresB;

    if (ah != bh) return ah - bh;
    return aa - ba;
  }

  /// Sort by away score first, then home score
  /// Based on SbEventDrawer.ts sorting logic
  static int _sortByAwayFirst(LeagueOddsData a, LeagueOddsData b) {
    final scoresA = parseScores(a.points);
    final scoresB = parseScores(b.points);
    if (scoresA == null || scoresB == null) return 0;

    final (ah, aa) = scoresA;
    final (bh, ba) = scoresB;

    if (aa != ba) return aa - ba;
    return ah - bh;
  }
}

/// Correct Score Grouped Data
class CorrectScoreGroups {
  final List<LeagueOddsData> home;
  final List<LeagueOddsData> draw;
  final List<LeagueOddsData> away;

  const CorrectScoreGroups({
    required this.home,
    required this.draw,
    required this.away,
  });

  /// Get max rows needed (longest column)
  int get maxRows {
    final lengths = [home.length, draw.length, away.length];
    return lengths.reduce((a, b) => a > b ? a : b);
  }

  /// Check if has any valid data
  bool get hasData => home.isNotEmpty || draw.isNotEmpty || away.isNotEmpty;
}

/// Market Headers Helper
///
/// Provides header labels for different market layouts
class MarketHeadersHelper {
  MarketHeadersHelper._();

  /// Get headers for Main6 layout
  static List<String> getMain6Headers() => [
    'Kèo',
    'Tài/Xỉu',
    '1X2',
    'Kèo H1',
    'T/X H1',
    '1X2 H1',
  ];

  /// Get headers for Main3 layout
  static List<String> getMain3Headers() => ['Kèo', 'Tài/Xỉu', '1X2'];

  /// Get headers for Correct Score 6 layout
  static List<String> getCorrectScore6Headers() => [
    'Đội Nhà',
    'Hoà',
    'Đội Khách',
    'Nhà H1',
    'Hoà H1',
    'Khách H1',
  ];

  /// Get headers for Correct Score 3 layout
  static List<String> getCorrectScore3Headers() => [
    'Đội Nhà',
    'Hoà',
    'Đội Khách',
  ];

  /// Get headers for Only2x2 (Odd/Even) layout
  static List<String> getOddEvenHeaders() => ['Lẻ', 'Chẵn', 'Lẻ H1', 'Chẵn H1'];

  /// Get headers for Only3x2 (Double Chance) layout
  static List<String> getDoubleChance6Headers() => [
    '1X',
    'X2',
    '12',
    '1X H1',
    'X2 H1',
    '12 H1',
  ];

  /// Get headers for Only3 (Double Chance) layout
  static List<String> getDoubleChance3Headers() => ['1X', 'X2', '12'];

  /// Get headers for Only2 layout (Draw No Bet, To Qualify, etc.)
  static List<String> getOnly2Headers() => ['Nhà', 'Khách'];

  /// Get headers for Together layout (Total Score)
  static List<String> getTogetherHeaders() => ['FT', 'H1'];

  /// Get headers for Market2 layout (Home/Away O/U)
  static List<String> getMarket2Headers() => ['Over', 'Under'];

  /// Get headers for Next Goal / Last Goal
  static List<String> getNextGoalHeaders() => ['Nhà', 'Hoà', 'Khách'];

  /// Get headers for Only4 layout (Which Team To Score)
  static List<String> getOnly4Headers() => [
    'Không ai',
    'Nhà',
    'Khách',
    'Cả hai',
  ];
}
