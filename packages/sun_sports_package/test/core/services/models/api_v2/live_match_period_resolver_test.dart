import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/core/services/models/api_v2/live_match_period_resolver.dart';

void main() {
  group('LiveMatchPeriodResolver', () {
    // ─── Basketball (sportId = 2) ──────────────────────────────────

    group('Basketball', () {
      String resolve(int gamePart) =>
          LiveMatchPeriodResolver.resolve(sportId: 2, gamePart: gamePart);

      test('firstQuarter (2001) → Hiệp 1', () {
        expect(resolve(2001), 'Hiệp 1');
      });

      test('secondQuarter (2002) → Hiệp 2', () {
        expect(resolve(2002), 'Hiệp 2');
      });

      test('thirdQuarter (2003) → Hiệp 3', () {
        expect(resolve(2003), 'Hiệp 3');
      });

      test('fourthQuarter (2004) → Hiệp 4', () {
        expect(resolve(2004), 'Hiệp 4');
      });

      test('overtime (2005) → Hiệp phụ', () {
        expect(resolve(2005), 'Hiệp phụ');
      });

      test('overtimeBreak (2006) → Nghỉ hiệp phụ', () {
        expect(resolve(2006), 'Nghỉ hiệp phụ');
      });

      test('rtPause (4) → Nghỉ giữa hiệp', () {
        expect(resolve(4), 'Nghỉ giữa hiệp');
      });

      test('halfTimeBreak (2008) → Nghỉ giữa hiệp', () {
        expect(resolve(2008), 'Nghỉ giữa hiệp');
      });

      test('quarterBreak (2000) → Thời gian nghỉ', () {
        expect(resolve(2000), 'Thời gian nghỉ');
      });

      test('secondHalf (8) → Giữa hiệp 2', () {
        expect(resolve(8), 'Giữa hiệp 2');
      });

      test('finished (16) → Kết thúc', () {
        expect(resolve(16), 'Kết thúc');
      });

      test('finishRt (32) → Finish RT', () {
        expect(resolve(32), 'Finish RT');
      });

      test('timeout (157) → Hết giờ', () {
        expect(resolve(157), 'Hết giờ');
      });

      test('unknown value → empty', () {
        expect(resolve(0), '');
        expect(resolve(9999), '');
      });
    });

    // ─── Tennis (sportId = 4) ──────────────────────────────────────

    group('Tennis', () {
      String resolve(int gamePart) =>
          LiveMatchPeriodResolver.resolve(sportId: 4, gamePart: gamePart);

      test('set 1-7', () {
        expect(resolve(1), 'Set 1');
        expect(resolve(2), 'Set 2');
        expect(resolve(3), 'Set 3');
        expect(resolve(4), 'Set 4');
        expect(resolve(5), 'Set 5');
        expect(resolve(6), 'Set 6');
        expect(resolve(7), 'Set 7');
      });

      test('game (60) → Toàn trận', () {
        expect(resolve(60), 'Toàn trận');
      });

      test('tieBreak (61) → Tie-break', () {
        expect(resolve(61), 'Tie-break');
      });

      test('breakTime (80) → Nghỉ', () {
        expect(resolve(80), 'Nghỉ');
      });

      test('fullTime (100) → Hết trận', () {
        expect(resolve(100), 'Hết trận');
      });

      test('scoreBoard (0) → empty', () {
        expect(resolve(0), '');
      });

      test('stat values → empty', () {
        expect(resolve(8), '');
        expect(resolve(20), '');
        expect(resolve(55), '');
        expect(resolve(2013), '');
      });

      test('unknown values in gaps → empty', () {
        expect(resolve(10), '');
        expect(resolve(59), '');
        expect(resolve(62), '');
        expect(resolve(79), '');
        expect(resolve(81), '');
        expect(resolve(99), '');
        expect(resolve(101), '');
      });
    });

    // ─── Volleyball (sportId = 5) ──────────────────────────────────

    group('Volleyball', () {
      String resolve(int gamePart, {int? currentSet}) =>
          LiveMatchPeriodResolver.resolve(
            sportId: 5,
            gamePart: gamePart,
            currentSet: currentSet,
          );

      test('goldenSet (50) → Set vàng', () {
        expect(resolve(50, currentSet: 1), 'Set vàng');
        expect(resolve(50), 'Set vàng');
      });

      test('fullTime (100) → Hết trận', () {
        expect(resolve(100), 'Hết trận');
        expect(resolve(100, currentSet: 3), 'Hết trận');
      });

      test('scoreBoard (0) → empty', () {
        expect(resolve(0), '');
        expect(resolve(0, currentSet: 2), '');
      });

      test('totalPoints (8) → empty', () {
        expect(resolve(8), '');
        expect(resolve(8, currentSet: 3), '');
      });

      test('gamePart 1-5 with currentSet → Set N', () {
        expect(resolve(1, currentSet: 1), 'Set 1');
        expect(resolve(2, currentSet: 2), 'Set 2');
        expect(resolve(3, currentSet: 3), 'Set 3');
        expect(resolve(5, currentSet: 5), 'Set 5');
      });

      test('gamePart with currentSet=null → empty', () {
        expect(resolve(2), '');
        expect(resolve(2, currentSet: null), '');
      });

      test('gamePart with currentSet=0 → empty', () {
        expect(resolve(2, currentSet: 0), '');
      });
    });

    // ─── Table Tennis (sportId = 6) ────────────────────────────────

    group('Table Tennis', () {
      String resolve(int gamePart) =>
          LiveMatchPeriodResolver.resolve(sportId: 6, gamePart: gamePart);

      test('set 1-7', () {
        expect(resolve(1), 'Set 1');
        expect(resolve(2), 'Set 2');
        expect(resolve(3), 'Set 3');
        expect(resolve(4), 'Set 4');
        expect(resolve(5), 'Set 5');
        expect(resolve(6), 'Set 6');
        expect(resolve(7), 'Set 7');
      });

      test('fullTime (100) → Hết trận', () {
        expect(resolve(100), 'Hết trận');
      });

      test('scoreBoard (0) → empty', () {
        expect(resolve(0), '');
      });

      test('totalPoints (9) → empty', () {
        expect(resolve(9), '');
      });

      test('unknown → empty', () {
        expect(resolve(8), '');
        expect(resolve(50), '');
      });
    });

    // ─── Badminton (sportId = 7) ──────────────────────────────────

    group('Badminton', () {
      String resolve({int? currentSet}) =>
          LiveMatchPeriodResolver.resolve(
            sportId: 7,
            gamePart: 0,
            currentSet: currentSet,
          );

      test('currentSet=1 → Game 1', () {
        expect(resolve(currentSet: 1), 'Game 1');
      });

      test('currentSet=2 → Game 2', () {
        expect(resolve(currentSet: 2), 'Game 2');
      });

      test('currentSet=3 → Game 3', () {
        expect(resolve(currentSet: 3), 'Game 3');
      });

      test('currentSet=0 → empty', () {
        expect(resolve(currentSet: 0), '');
      });

      test('currentSet=null → empty', () {
        expect(resolve(currentSet: null), '');
        expect(resolve(), '');
      });
    });

    // ─── Unknown sport ────────────────────────────────────────────

    group('Unknown sport', () {
      test('unknown sportId → empty', () {
        expect(
          LiveMatchPeriodResolver.resolve(sportId: 0, gamePart: 1),
          '',
        );
        expect(
          LiveMatchPeriodResolver.resolve(sportId: 99, gamePart: 2001),
          '',
        );
      });
    });
  });
}
