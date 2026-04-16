/// Hint Bubble Enums
///
/// Defines enums for market categories, periods, and hint types.
/// Based on FLUTTER_HINT_BUBBLE_IMPLEMENTATION_GUIDE.md

/// Market Category Enum
///
/// Represents different types of betting markets
enum MarketCategory {
  unknown,
  asianHandicap, // Kèo Châu Á
  overUnder, // Tài Xỉu
  market1X2, // Kèo Châu Âu 1X2
  oddEven, // Chẵn Lẻ
  correctScore, // Tỷ số chính xác
  totalScore, // Tổng bàn thắng
  totalGoalsExactly, // Tổng số bàn thắng chính xác
  doubleChance, // Cơ hội kép
  cornerHandicap, // Phạt góc chấp
  cornerOverUnder, // Phạt góc Tài Xỉu
  corner1X2, // Phạt góc 1X2
  cornerOddEven, // Phạt góc Chẵn Lẻ
  cornerRange, // Tổng phạt góc khoảng
  nextCorner, // Phạt góc tiếp theo
  europeanHandicapCorner, // Chấp phạt góc châu Âu
  cornerOverExactlyUnder, // Phạt góc Tài/Chính xác/Xỉu
  bookingsHandicap, // Thẻ phạt chấp
  bookingsOverUnder, // Thẻ phạt Tài Xỉu
  bookings1X2, // Thẻ phạt 1X2
  yellowCards1X2, // Thẻ vàng 1X2
  yellowCardsOverUnder, // Thẻ vàng Tài/Xỉu
  yellowCardsDoubleChance, // Thẻ vàng cơ hội kép
  toQualify, // Đội vào vòng trong
  penaltyWinner, // Đội thắng Penalty
  penaltyTotal, // Tài/Xỉu Penalty
  nextGoal, // Bàn thắng kế tiếp
  lastGoal, // Bàn thắng cuối cùng
  drawNoBet, // Hòa được hoàn tiền
  lastCorner, // Phạt góc cuối cùng
  homeOddEven, // Đội nhà Chẵn Lẻ
  awayOddEven, // Đội khách Chẵn Lẻ
  homeCleanSheet, // Đội nhà giữ sạch lưới
  awayCleanSheet, // Đội khách giữ sạch lưới
  homeOverUnder, // Tài/Xỉu Đội nhà
  awayOverUnder, // Tài/Xỉu Đội khách
  whichTeamKickOff, // Đội giao bóng trước
  whichTeamToScore, // Đội ghi bàn
  outright, // Cược vô địch giải đấu
  moneyLine, // Money Line (Basketball, Tennis)
}

/// Period Enum
///
/// Represents match periods/halves
enum Period {
  fullTime, // Toàn trận / 2 hiệp chính
  halfTime, // Hiệp 1
  secondHalf, // Hiệp 2
  extraFT, // 2 hiệp phụ
  extraHT, // Hiệp phụ 1
  penalty, // Loạt đá luân lưu
}

/// Team Type Enum for hint
///
/// Represents which team/selection the hint is for
enum HintTeamType { none, home, away, draw, over, under, odd, even }

/// Hint Type Enum
///
/// Represents specific hint types for different handicap variants
enum HintType {
  // Asian Handicap variants
  asianHandicapRound, // Chấp tròn (0, 1, 2...)
  asianHandicapHalf, // Chấp rưỡi (0.5, 1.5...)
  asianHandicapQuarterOver, // Chấp 1/4 trên (-0.25, -1.25...)
  asianHandicapQuarterUnder, // Chấp 1/4 dưới (0.25, 1.25...)
  asianHandicap3QuarterOver, // Chấp 3/4 trên (-0.75, -1.75...)
  asianHandicap3QuarterUnder, // Chấp 3/4 dưới (0.75, 1.75...)
  // Over/Under variants
  overUnderRound,
  overUnderHalf,
  overUnderQuarter,
  overUnder3Quarter,

  // Corner variants
  cornerHandicapRound,
  cornerHandicapHalf,
  cornerHandicapQuarter,
  cornerHandicap3Quarter,
  cornerOverUnderRound,
  cornerOverUnderHalf,
  cornerOverUnderQuarter,
  cornerOverUnder3Quarter,

  // Bookings variants
  bookingsHandicapRound,
  bookingsHandicapHalf,
  bookingsOverUnderRound,
  bookingsOverUnderHalf,

  // Simple markets (no variants)
  market1X2,
  oddEven,
  doubleChance,
  correctScore,
  totalScore,
  drawNoBet,
  nextGoal,
  lastGoal,
  moneyLine,
  outright,

  unknown,
}

/// Extension methods for Period
extension PeriodExtension on Period {
  /// Get Vietnamese text for period
  String get text {
    switch (this) {
      case Period.fullTime:
        return 'toàn trận';
      case Period.halfTime:
        return 'hiệp 1';
      case Period.secondHalf:
        return 'hiệp 2';
      case Period.extraFT:
        return '2 hiệp phụ';
      case Period.extraHT:
        return 'hiệp phụ 1';
      case Period.penalty:
        return 'loạt đá luân lưu';
    }
  }

  /// Get period code for display
  String get code {
    switch (this) {
      case Period.fullTime:
        return 'FT';
      case Period.halfTime:
        return 'HT';
      case Period.secondHalf:
        return '2H';
      case Period.extraFT:
        return 'ET';
      case Period.extraHT:
        return 'ET1';
      case Period.penalty:
        return 'PEN';
    }
  }
}

/// Extension methods for MarketCategory
extension MarketCategoryExtension on MarketCategory {
  /// Get Vietnamese name for market category
  String get name {
    switch (this) {
      case MarketCategory.asianHandicap:
        return 'Kèo Châu Á';
      case MarketCategory.overUnder:
        return 'Tài Xỉu';
      case MarketCategory.market1X2:
        return 'Kèo 1X2';
      case MarketCategory.oddEven:
        return 'Chẵn Lẻ';
      case MarketCategory.correctScore:
        return 'Tỷ số chính xác';
      case MarketCategory.totalScore:
        return 'Tổng bàn thắng';
      case MarketCategory.totalGoalsExactly:
        return 'Tổng bàn thắng chính xác';
      case MarketCategory.doubleChance:
        return 'Cơ hội kép';
      case MarketCategory.cornerHandicap:
        return 'Phạt góc chấp';
      case MarketCategory.cornerOverUnder:
        return 'Phạt góc Tài Xỉu';
      case MarketCategory.corner1X2:
        return 'Phạt góc 1X2';
      case MarketCategory.cornerOddEven:
        return 'Phạt góc Chẵn Lẻ';
      case MarketCategory.cornerRange:
        return 'Tổng phạt góc';
      case MarketCategory.nextCorner:
        return 'Phạt góc tiếp theo';
      case MarketCategory.europeanHandicapCorner:
        return 'Chấp phạt góc châu Âu';
      case MarketCategory.cornerOverExactlyUnder:
        return 'Phạt góc Tài/Chính xác/Xỉu';
      case MarketCategory.bookingsHandicap:
        return 'Thẻ phạt chấp';
      case MarketCategory.bookingsOverUnder:
        return 'Thẻ phạt Tài Xỉu';
      case MarketCategory.bookings1X2:
        return 'Thẻ phạt 1X2';
      case MarketCategory.yellowCards1X2:
        return 'Thẻ vàng 1X2';
      case MarketCategory.yellowCardsOverUnder:
        return 'Thẻ vàng Tài Xỉu';
      case MarketCategory.yellowCardsDoubleChance:
        return 'Thẻ vàng cơ hội kép';
      case MarketCategory.toQualify:
        return 'Đội vào vòng trong';
      case MarketCategory.penaltyWinner:
        return 'Đội thắng Penalty';
      case MarketCategory.penaltyTotal:
        return 'Tài Xỉu Penalty';
      case MarketCategory.drawNoBet:
        return 'Hòa hoàn tiền';
      case MarketCategory.nextGoal:
        return 'Bàn thắng kế tiếp';
      case MarketCategory.lastGoal:
        return 'Bàn thắng cuối';
      case MarketCategory.lastCorner:
        return 'Phạt góc cuối cùng';
      case MarketCategory.homeOddEven:
        return 'Đội nhà Chẵn Lẻ';
      case MarketCategory.awayOddEven:
        return 'Đội khách Chẵn Lẻ';
      case MarketCategory.homeCleanSheet:
        return 'Đội nhà giữ sạch lưới';
      case MarketCategory.awayCleanSheet:
        return 'Đội khách giữ sạch lưới';
      case MarketCategory.homeOverUnder:
        return 'Tài Xỉu Đội nhà';
      case MarketCategory.awayOverUnder:
        return 'Tài Xỉu Đội khách';
      case MarketCategory.whichTeamKickOff:
        return 'Đội giao bóng trước';
      case MarketCategory.whichTeamToScore:
        return 'Đội ghi bàn';
      case MarketCategory.outright:
        return 'Vô địch giải đấu';
      case MarketCategory.moneyLine:
        return 'Money Line';
      case MarketCategory.unknown:
        return 'Unknown';
    }
  }
}
