import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Utility class to check if odds meet "Kèo Rung" (Vibrating Odds) threshold.
///
/// Kèo Rung is triggered when odds reach "dangerous" levels for live football
/// Over/Under markets. This indicates a high probability event based on the odds.
///
/// Conditions (all must be true):
/// 1. Football only (sportId = 1)
/// 2. Live only
/// 3. Over/Under market
/// 4. Single point value (no range)
/// 5. Line matches current score + 0.5
/// 6. Odds value meets format threshold
class VibratingOddsChecker {
  /// Football sport ID
  static const int footballSportId = 1;

  /// All Over/Under markets that support vibrating odds
  static const Set<int> overUnderMarketIds = {
    3, // FT_OVER_UNDER (Goals O/U Full Time)
    4, // HT_OVER_UNDER (Goals O/U Half Time)
    21, // FT_CORNER_OVER_UNDER (Corner O/U Full Time)
    22, // HT_CORNER_OVER_UNDER (Corner O/U Half Time)
    31, // FT_OVER_UNDER_BOOKINGS (Bookings O/U Full Time)
    32, // HT_OVER_UNDER_BOOKINGS (Bookings O/U Half Time)
  };

  /// Corner market IDs — use corner score instead of goal score
  static const Set<int> _cornerMarketIds = {21, 22};

  /// Check all conditions for vibrating odds.
  static bool isVibrating({
    required int sportId,
    required bool isLive,
    required int marketId,
    required String points,
    required double oddsValue,
    required OddsStyle oddsFormat,
    required int homeScore,
    required int awayScore,
    int cornersHome = 0,
    int cornersAway = 0,
  }) {
    // 1. Football only
    if (sportId != footballSportId) return false;

    // 2. Live only
    if (!isLive) return false;

    // 3. Over/Under markets only
    if (!overUnderMarketIds.contains(marketId)) return false;

    // 4. Single point value only (no range)
    if (points.contains('-')) return false;

    // 5. Line must match current score + 0.5
    if (!_isLineMatching(
      marketId, points, homeScore, awayScore, cornersHome, cornersAway,
    )) {
      return false;
    }

    // 6. Check threshold
    return _meetsThreshold(oddsValue, oddsFormat);
  }

  /// Check if line matches current total score + 0.5.
  ///
  /// - Corner markets (21, 22): cornersHome + cornersAway + 0.5
  /// - Other markets (3, 4, 31, 32): homeScore + awayScore + 0.5
  ///   NOTE: Bookings (31, 32) use goal score — matches JS behavior.
  static bool _isLineMatching(
    int marketId,
    String points,
    int homeScore,
    int awayScore,
    int cornersHome,
    int cornersAway,
  ) {
    final parsedLine = double.tryParse(points);
    if (parsedLine == null) return false;

    final double expectedLine;
    if (_cornerMarketIds.contains(marketId)) {
      expectedLine = (cornersHome + cornersAway) + 0.5;
    } else {
      expectedLine = (homeScore + awayScore) + 0.5;
    }

    return parsedLine == expectedLine;
  }

  /// Check if odds value meets the threshold for the given format.
  ///
  /// Thresholds by format:
  /// - Malay: |odds| > 0 AND |odds| <= 0.6 (near-zero = dangerous zone)
  /// - Decimal: odds >= 2.67
  /// - Indo/HK: odds >= 1.67
  static bool _meetsThreshold(double odds, OddsStyle format) {
    return switch (format) {
      OddsStyle.malay => odds.abs() > 0 && odds.abs() <= 0.6,
      OddsStyle.decimal => odds >= 2.67,
      OddsStyle.indo || OddsStyle.hongKong => odds >= 1.67,
    };
  }
}
