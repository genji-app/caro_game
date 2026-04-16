import 'package:co_caro_flame/s88/core/services/models/api_v2/game_part_constants.dart';

class LiveMatchPeriodResolver {
  /// Resolve game part to Vietnamese display string.
  ///
  /// [sportId] — sport ID (2=basketball, 4=tennis, 5=volleyball, 6=table tennis, 7=badminton)
  /// [gamePart] — from EventResponse.game_part (json key "30")
  /// [currentSet] — from score model (volleyball field 506, badminton field 706, table tennis field 606)
  ///
  /// Returns empty string if unknown or not applicable.
  static String resolve({
    required int sportId,
    required int gamePart,
    int? currentSet,
  }) {
    switch (sportId) {
      case 2:
        return _basketball(gamePart);
      case 4:
        return _tennis(gamePart);
      case 5:
        return _volleyball(gamePart, currentSet);
      case 6:
        return _tableTennis(gamePart);
      case 7:
        return _badminton(currentSet);
      default:
        return '';
    }
  }

  static String _basketball(int gamePart) {
    return switch (gamePart) {
      BasketballGamePart.firstQuarter => 'Hiệp 1',
      BasketballGamePart.secondQuarter => 'Hiệp 2',
      BasketballGamePart.thirdQuarter => 'Hiệp 3',
      BasketballGamePart.fourthQuarter => 'Hiệp 4',
      BasketballGamePart.overtime => 'Hiệp phụ',
      BasketballGamePart.overtimeBreak => 'Nghỉ hiệp phụ',
      BasketballGamePart.rtPause => 'Nghỉ giữa hiệp',
      BasketballGamePart.halfTimeBreak => 'Nghỉ giữa hiệp',
      BasketballGamePart.quarterBreak => 'Thời gian nghỉ',
      BasketballGamePart.secondHalf => 'Giữa hiệp 2',
      BasketballGamePart.finished => 'Kết thúc',
      BasketballGamePart.finishRt => 'Finish RT',
      BasketballGamePart.timeout => 'Hết giờ',
      _ => '',
    };
  }

  static String _tennis(int gamePart) {
    return switch (gamePart) {
      TennisGamePart.set1 => 'Set 1',
      TennisGamePart.set2 => 'Set 2',
      TennisGamePart.set3 => 'Set 3',
      TennisGamePart.set4 => 'Set 4',
      TennisGamePart.set5 => 'Set 5',
      TennisGamePart.set6 => 'Set 6',
      TennisGamePart.set7 => 'Set 7',
      TennisGamePart.game => 'Toàn trận',
      TennisGamePart.tieBreak => 'Tie-break',
      TennisGamePart.breakTime => 'Nghỉ',
      TennisGamePart.fullTime => 'Hết trận',
      _ => '',
    };
  }

  static String _volleyball(int gamePart, int? currentSet) {
    // Priority order: golden set → full time → empty cases → currentSet
    if (gamePart == VolleyballGamePart.goldenSet) return 'Set vàng';
    if (gamePart == VolleyballGamePart.fullTime) return 'Hết trận';
    if (gamePart == VolleyballGamePart.scoreBoard ||
        gamePart == VolleyballGamePart.totalPoints) {
      return '';
    }
    // gamePart 1-5 or any other → use currentSet from score model
    if (currentSet != null && currentSet > 0) return 'Set $currentSet';
    return '';
  }

  static String _tableTennis(int gamePart) {
    return switch (gamePart) {
      TableTennisGamePart.set1 => 'Set 1',
      TableTennisGamePart.set2 => 'Set 2',
      TableTennisGamePart.set3 => 'Set 3',
      TableTennisGamePart.set4 => 'Set 4',
      TableTennisGamePart.set5 => 'Set 5',
      TableTennisGamePart.set6 => 'Set 6',
      TableTennisGamePart.set7 => 'Set 7',
      TableTennisGamePart.fullTime => 'Hết trận',
      _ => '',
    };
  }

  static String _badminton(int? currentSet) {
    if (currentSet != null && currentSet > 0) return 'Game $currentSet';
    return '';
  }
}
