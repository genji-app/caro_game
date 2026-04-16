/// Market Filter Enum for Bet Detail Screen
///
/// Filters markets by category and period.
/// Based on SbEventDetail.ts filter logic
///
/// Tab types:
/// - main: Shows all main markets (Handicap, O/U, 1X2) - fixed tab
/// - fullTime: Full Time markets (Toàn trận)
/// - firstHalf: First Half markets (Hiệp 1)
/// - secondHalf: Second Half markets (Hiệp 2)
/// - extraTime: Extra Time markets (Hiệp phụ/Bù giờ)
/// - corner: Corner markets (Phạt góc)
/// - score: Score markets (Tỷ số)
/// - booking: Booking/Card markets (Thẻ phạt)
enum MarketFilter {
  /// Main tab - shows all main markets (Handicap, O/U, 1X2)
  main,

  /// Full Time (Toàn trận) - FT markets
  fullTime,

  /// First Half (Hiệp 1) - HT markets
  firstHalf,

  /// Second Half (Hiệp 2) - SH markets
  secondHalf,

  /// Extra Time (Hiệp phụ/Bù giờ)
  extraTime,

  /// Corner markets (Phạt góc)
  corner,

  /// Score markets (Tỷ số)
  score,

  /// Booking/Card markets (Thẻ phạt)
  booking,

  /// Set/Quarter 1 (non-soccer: Tennis Set 1, Basketball Q1, Volleyball Set 1, etc.)
  set1,

  /// Set/Quarter 2
  set2,

  /// Set/Quarter 3
  set3,

  /// Set/Quarter 4
  set4,

  /// Set/Quarter 5
  set5,

  /// Legacy: Match category (for backwards compatibility)
  match,

  /// Legacy: All markets
  all,
}

/// Extension for MarketFilter
extension MarketFilterExtension on MarketFilter {
  /// Display name for filter tab
  String get displayName {
    switch (this) {
      case MarketFilter.main:
        return 'Chính';
      case MarketFilter.fullTime:
        return 'Toàn trận';
      case MarketFilter.firstHalf:
        return 'Hiệp 1';
      case MarketFilter.secondHalf:
        return 'Hiệp 2';
      case MarketFilter.extraTime:
        return 'Hiệp phụ';
      case MarketFilter.corner:
        return 'Phạt góc';
      case MarketFilter.score:
        return 'Tỷ số';
      case MarketFilter.booking:
        return 'Thẻ phạt';
      case MarketFilter.set1:
        return 'Set 1';
      case MarketFilter.set2:
        return 'Set 2';
      case MarketFilter.set3:
        return 'Set 3';
      case MarketFilter.set4:
        return 'Set 4';
      case MarketFilter.set5:
        return 'Set 5';
      case MarketFilter.all:
        return 'Tất cả';
      case MarketFilter.match:
        return 'Trận đấu';
    }
  }

  /// Check if this is a main filter (shows all main markets)
  bool get isMainFilter => this == MarketFilter.main;

  /// Check if this is a period-based filter
  bool get isPeriodFilter =>
      this == MarketFilter.fullTime ||
      this == MarketFilter.firstHalf ||
      this == MarketFilter.secondHalf ||
      this == MarketFilter.extraTime ||
      this == MarketFilter.set1 ||
      this == MarketFilter.set2 ||
      this == MarketFilter.set3 ||
      this == MarketFilter.set4 ||
      this == MarketFilter.set5;

  /// Check if this is a category-based filter
  bool get isCategoryFilter =>
      this == MarketFilter.corner ||
      this == MarketFilter.score ||
      this == MarketFilter.booking;

  /// Check if a market ID belongs to this filter
  bool containsMarketId(int marketId) {
    if (this == MarketFilter.all) return true;
    return MarketFilterMapping.getMarketIds(this).contains(marketId);
  }
}

/// Market ID Mapping by Filter
///
/// Maps market IDs to filter categories based on SbEventDetail.ts
class MarketFilterMapping {
  MarketFilterMapping._();

  /// Match filter market IDs
  /// Includes: Handicap, O/U, 1X2, OddEven, DoubleChance, DrawNoBet, etc.
  static const Set<int> matchMarketIds = {
    // Main markets FT
    1, // 1X2 FT
    3, // Over/Under FT
    5, // Asian Handicap FT
    // Main markets HT
    2, // 1X2 HT
    4, // Over/Under HT
    6, // Asian Handicap HT
    // Second Half
    23, 25, 27, // 1X2 SH, O/U SH, Handicap SH
    // Extra Time
    35, 36, 37, 38, 39, 40, // Extra time markets
    // Odd/Even
    8, 9, // Odd/Even FT, HT
    50, 51, // Home/Away Odd/Even
    // Double Chance
    12, 13, // Double Chance FT, HT
    // Draw No Bet
    16, 17, // Draw No Bet FT, HT
    // Goals
    7, // Next Goal
    58, // Last Goal
    59, // To Qualify
    60, // Which Team Kick Off
    // Home/Away O/U
    80, 81, // Home O/U, Away O/U
    // Clean Sheet (HomeCleanSheet = 83, AwayCleanSheet = 84)
    83, 84, // Home/Away Clean Sheet
    // Penalty
    85, 86, // Penalty Winner, Penalty Total
    // Time-based markets (0-15, 15-30, etc.)
    // Note: 50, 51 removed (Home/Away Odd/Even - already listed above)
    41, 42, 43, 44, 45, 46, 47, 48, 49, 52, 53, 54, 55,
  };

  /// Corner filter market IDs
  /// Based on documentation: markets 17-22, 56-57, 61-67, 92-96, 104-128, 131-137, 140-142, 144
  static const Set<int> cornerMarketIds = {
    // Corner main markets FT
    17, // Corner1X2FT - Phạt góc 1X2 toàn trận
    19, // CornerHandicapFT - Phạt góc kèo chấp toàn trận
    21, // CornerOverUnderFT - Phạt góc Tài/Xỉu toàn trận
    // Corner main markets HT
    18, // Corner1X2HT - Phạt góc 1X2 hiệp 1
    20, // CornerHandicapHT - Phạt góc kèo chấp hiệp 1
    22, // CornerOverUnderHT - Phạt góc Tài/Xỉu hiệp 1
    // Corner Odd/Even
    56, // CornerOddEvenFT - Phạt góc Chẵn/Lẻ toàn trận
    57, // CornerOddEvenHT - Phạt góc Chẵn/Lẻ hiệp 1
    // Corner O/U by team
    61, // CornerOverUnderHomeFT - Đội nhà phạt góc Tài/Xỉu
    62, // CornerOverUnderHomeHT - Đội nhà phạt góc Tài/Xỉu H1
    63, // CornerOverUnderAwayFT - Đội khách phạt góc Tài/Xỉu
    64, // CornerOverUnderAwayHT - Đội khách phạt góc Tài/Xỉu H1
    // Last Corner
    66, // LastCornerFT - Phạt góc cuối cùng toàn trận
    67, // LastCornerHT - Phạt góc cuối cùng hiệp 1
    // Corner time-based by 15min (92-96)
    92, // CornerOverUnder0015
    93, // CornerOverUnder1530
    94, // CornerOverUnder3045
    95, // CornerOverUnder4560
    96, // CornerOverUnder6075
    // Corner time-based by 10min (104-111)
    104, // CornerOverUnder0010
    105, // CornerOverUnder1020
    106, // CornerOverUnder2030
    107, // CornerOverUnder3040
    108, // CornerOverUnder4050
    109, // CornerOverUnder5060
    110, // CornerOverUnder6070
    111, // CornerOverUnder7080
    // Corner time-based by 5min (112-128)
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
    122, 123, 124, 125, 126, 127, 128,
    // Corner Range
    131, // CornerRangeFT - Tổng phạt góc trận đấu
    134, // HomeCornerRange - Tổng phạt góc đội nhà
    135, // AwayCornerRange - Tổng phạt góc đội khách
    136, // CornerRangeHT - Tổng phạt góc hiệp 1
    // New Corner Markets
    137, // NextCorner - Phạt góc tiếp theo
    140, // HTCornerOverExactlyUnder - Phạt góc hiệp 1: Tài/Chính xác/Xỉu
    141, // ExtraTimeCornerOverExactlyUnder - Phạt góc hiệp phụ: Tài/Chính xác/Xỉu
    142, // ExtraTimeCornerOverUnder - Phạt góc hiệp phụ: Tài/Xỉu
    144, // EuropeanHandicapCorner - Chấp phạt góc châu Âu
  };

  /// Score filter market IDs
  static const Set<int> scoreMarketIds = {
    10, // Correct Score FT
    11, // Correct Score HT
    14, // Total Score FT
    15, // Total Score HT
    145, // TotalGoalsExactly - Tổng số bàn thắng chính xác
  };

  /// Booking filter market IDs
  /// Based on documentation: markets 29-34, 138-139, 143
  static const Set<int> bookingMarketIds = {
    // Main Booking Markets
    29, // Bookings1X2FT - Thẻ phạt 1X2 toàn trận
    30, // Bookings1X2HT - Thẻ phạt 1X2 hiệp 1
    31, // BookingsOverUnderFT - Thẻ phạt Tài/Xỉu toàn trận
    32, // BookingsOverUnderHT - Thẻ phạt Tài/Xỉu hiệp 1
    33, // BookingsHandicapFT - Thẻ phạt kèo chấp toàn trận
    34, // BookingsHandicapHT - Thẻ phạt kèo chấp hiệp 1
    // Yellow Cards Markets (New)
    138, // FTYellowCards1X2 - Thẻ vàng 1X2
    139, // FTYellowCardsOverUnder - Thẻ vàng Tài/Xỉu
    143, // FTYellowCardsDoubleChance - Thẻ vàng cơ hội kép
  };

  /// Main market IDs (Handicap, O/U, 1X2 for all periods)
  static const Set<int> mainMarketIds = {
    // FT
    1, 3, 5,
    // HT
    2, 4, 6,
    // SH
    80, 85, 89,
    // Extra Time
    23, 24, 25, 26, 27, 28,
  };

  /// Full Time (Toàn trận) market IDs
  static const Set<int> fullTimeMarketIds = {
    1, 3, 5, // Main FT
    8, // Odd/Even FT
    12, // Double Chance FT
    16, // Draw No Bet FT
    7, 97, // Next/Last Goal
    58, 59, // To Qualify, Kick Off
    76, 77, // Home/Away Odd/Even
    83, 84, // Clean Sheet
    101, 102, // Home/Away O/U
    103, // Which Team To Score
    129, 130, // Penalty
    145, // TotalGoalsExactly - Tổng số bàn thắng chính xác
  };

  /// First Half (Hiệp 1) market IDs
  static const Set<int> firstHalfMarketIds = {
    2, 4, 6, // Main HT
    9, // Odd/Even HT
    13, // Double Chance HT
    75, // Draw No Bet HT (note: was 17 but that's corner)
  };

  /// Second Half (Hiệp 2) market IDs
  static const Set<int> secondHalfMarketIds = {
    80, 85, 89, // O/U SH, Handicap SH, 1X2 SH
    86, // Odd/Even SH
  };

  /// Extra Time market IDs
  static const Set<int> extraTimeMarketIds = {
    23, 24, 25, 26, 27, 28, // Extra time FT/HT
  };

  /// Get market IDs for a filter
  static Set<int> getMarketIds(MarketFilter filter) {
    switch (filter) {
      case MarketFilter.main:
        return mainMarketIds;
      case MarketFilter.fullTime:
        return fullTimeMarketIds;
      case MarketFilter.firstHalf:
        return firstHalfMarketIds;
      case MarketFilter.secondHalf:
        return secondHalfMarketIds;
      case MarketFilter.extraTime:
        return extraTimeMarketIds;
      case MarketFilter.corner:
        return cornerMarketIds;
      case MarketFilter.score:
        return scoreMarketIds;
      case MarketFilter.booking:
        return bookingMarketIds;
      case MarketFilter.set1:
      case MarketFilter.set2:
      case MarketFilter.set3:
      case MarketFilter.set4:
      case MarketFilter.set5:
        return const {}; // Set/Quarter filters are assigned directly by builder
      case MarketFilter.all:
        return {
          ...matchMarketIds,
          ...cornerMarketIds,
          ...scoreMarketIds,
          ...bookingMarketIds,
        };
      case MarketFilter.match:
        return matchMarketIds;
    }
  }

  /// Get filter for a market ID
  static MarketFilter getFilterForMarketId(int marketId) {
    if (matchMarketIds.contains(marketId)) return MarketFilter.match;
    if (cornerMarketIds.contains(marketId)) return MarketFilter.corner;
    if (scoreMarketIds.contains(marketId)) return MarketFilter.score;
    if (bookingMarketIds.contains(marketId)) return MarketFilter.booking;
    return MarketFilter.match; // Default to match
  }
}
