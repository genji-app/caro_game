/// Enum cho tab betting (dùng chung cho mobile và desktop)
enum BettingTab { all, mine, bigWin }

/// Enum cho hướng thay đổi odds (up/down indicator)
enum OddsChangeDirection {
  /// Không thay đổi hoặc lần đầu load
  none,

  /// Odds tăng
  up,

  /// Odds giảm
  down,
}

/// Enum cho loại cột bet
enum BetColumnType {
  handicap,
  overUnder,
  matchResult,
  handicapH1,
  overUnderH1,
  matchResultH1,
}

extension BetColumnTypeX on BetColumnType {
  String get title {
    switch (this) {
      case BetColumnType.handicap:
        return 'Kèo chấp';
      case BetColumnType.overUnder:
        return 'Tài xỉu';
      case BetColumnType.matchResult:
        return '1X2';
      case BetColumnType.handicapH1:
        return 'Kèo chấp H1';
      case BetColumnType.overUnderH1:
        return 'Tài xỉu H1';
      case BetColumnType.matchResultH1:
        return '1X2 H1';
    }
  }
}
