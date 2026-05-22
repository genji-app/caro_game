import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_enums.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/odds_calculator.dart';

/// Hint Service
///
/// Service for generating hint content based on market type.
/// Ported faithfully from the original `SbHint.ts` (`getHint`) so that the
/// hint bubble matches the source sportbook project 1:1.
class HintService {
  HintService._();

  /// Generate complete hint content
  static HintContent generateHint(HintData data) {
    final simpleText = _buildSimpleText(data);
    final infoText = _buildInfoText(data);
    final ratioText = _buildRatioText(data);
    final resultText = _buildResultText(data);
    final exampleText = _buildExampleText(data);

    return HintContent(
      simpleText: simpleText,
      infoText: infoText,
      ratioText: ratioText,
      resultText: resultText,
      exampleText: exampleText,
      homeName: data.homeName,
      awayName: data.awayName,
    );
  }

  /// Part 1: Giải thích kèo (simpleText)
  static String _buildSimpleText(HintData data) {
    final period = _simplePeriod(data.period, data.sportId);

    switch (data.market) {
      case MarketCategory.asianHandicap:
        return 'Kèo Châu Á với đội chấp phải thắng cách biệt hơn tỷ lệ đưa ra trong thời gian $period.';

      case MarketCategory.overUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số ${_sumWord(data.sportId)} của cả 2 đội, trong thời gian $period.';

      case MarketCategory.homeOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào số ${_sumWord(data.sportId)} của đội nhà, trong thời gian $period.';

      case MarketCategory.awayOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào số ${_sumWord(data.sportId)} của đội khách, trong thời gian $period.';

      case MarketCategory.market1X2:
        return 'Kèo Châu Âu trong thời gian $period.\nCó 3 cửa:\n • 1 : đội nhà thắng.\n • X : hòa.\n • 2 : đội khách thắng.';

      case MarketCategory.oddEven:
        return 'Kèo cược tổng số bàn thắng của hai đội là số chẵn hoặc số lẻ, trong thời gian $period.';

      case MarketCategory.doubleChance:
        return 'Kèo Châu Âu cơ hội kép trong thời gian $period.\nNgười chơi có thể chọn:\n • 1X : đội nhà hoặc hoà.\n • 2X : đội khách hoặc hoà.\n • 12 : đội nhà hoặc khách.';

      case MarketCategory.cornerOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số lần phạt góc của cả 2 đội, trong thời gian $period.';

      case MarketCategory.cornerHandicap:
        return 'Kèo phạt góc Châu Á với đội chấp phải có số lần phạt góc cách biệt hơn tỷ lệ đưa ra trong thời gian $period.';

      case MarketCategory.bookingsOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số thẻ phạt của cả 2 đội, trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.';

      case MarketCategory.bookingsHandicap:
        return 'Kèo thẻ phạt Châu Á với đội chấp phải có số thẻ phạt cách biệt hơn tỷ lệ đưa ra trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.';

      case MarketCategory.drawNoBet:
        return 'Kèo cược đội thắng, trong thời gian $period.\nNgười chơi có thể chọn:\n • Đội nhà thắng.\n • Đội khách thắng.';

      case MarketCategory.moneyLine:
        return 'Kèo đội thắng trong thời gian trận đấu.';

      case MarketCategory.correctScore:
        return 'Kèo cược tỷ số chính xác trong thời gian $period.';

      case MarketCategory.outright:
        return 'Kèo cược đội vô địch giải đấu.';

      default:
        return 'Kèo cược trong thời gian $period.';
    }
  }

  /// Period text used by the Part 1 description.
  ///
  /// Mirrors the `time` variable in `SbHint.ts.simpleText`: the full match is
  /// described as "2 hiệp chính" (football), "trận đấu" (basketball) or
  /// "toàn trận" (tennis/volleyball) — not "toàn trận" everywhere, which the
  /// original only uses for the result-section titles.
  static String _simplePeriod(Period period, int sportId) {
    if (period != Period.fullTime) return period.text;
    return switch (sportId) {
      1 => '2 hiệp chính', // Football
      2 => 'trận đấu', // Basketball
      _ => 'toàn trận', // Tennis / Volleyball
    };
  }

  /// Score unit word — "trái" (football), "điểm" (basketball/volleyball),
  /// "game" (tennis). Port of `subScore` in `SbHint.ts`.
  static String _unitWord(int sportId) {
    return switch (sportId) {
      1 => 'trái',
      2 || 5 => 'điểm',
      _ => 'game',
    };
  }

  /// Aggregate-score word — "bàn thắng" (football), "điểm"
  /// (basketball/volleyball), "game" (tennis). Port of `sumScoreText`.
  static String _sumWord(int sportId) {
    return switch (sportId) {
      1 => 'bàn thắng',
      2 || 5 => 'điểm',
      _ => 'game',
    };
  }

  /// Suffix for the live-score label — "Tỷ số game/điểm hiện tại" for
  /// tennis/volleyball, "Tỷ số hiện tại" otherwise. Port of `sub` in `infoText`.
  static String _scoreSub(int sportId) {
    return switch (sportId) {
      4 => ' game', // Tennis
      5 => ' điểm', // Volleyball
      _ => '',
    };
  }

  /// Part 2: Thông tin trận đấu (infoText)
  static String _buildInfoText(HintData data) {
    final buffer = StringBuffer();

    // Outright bet info: show event name and date
    if (data.market == MarketCategory.outright) {
      if (data.eventName.isNotEmpty) {
        buffer.writeln(data.eventName);
      }
      if (data.eventDate.isNotEmpty) {
        buffer.writeln(data.eventDate);
      }
      return buffer.toString().trim();
    }

    final handicapAbs = data.handicap.abs();

    // Handicap info (Asian Handicap / Corner / Bookings)
    if (data.market == MarketCategory.asianHandicap ||
        data.market == MarketCategory.cornerHandicap ||
        data.market == MarketCategory.bookingsHandicap) {
      if (handicapAbs < 0.001) {
        buffer.writeln(switch (data.market) {
          MarketCategory.cornerHandicap => 'Không chấp phạt góc.',
          MarketCategory.bookingsHandicap => 'Không chấp thẻ phạt.',
          _ => 'Trận đấu đồng banh.',
        });
      } else {
        // The giving (over) team: when the selected team gives (handicap < 0)
        // it is the selected team itself, otherwise it is the opponent.
        final selectedIsGiving = data.handicap < 0;
        final isHomeBet = data.team == HintTeamType.home;
        final String overTeamName;
        if (selectedIsGiving) {
          overTeamName = isHomeBet ? data.homeName : data.awayName;
        } else {
          overTeamName = isHomeBet ? data.awayName : data.homeName;
        }
        final unit = switch (data.market) {
          MarketCategory.cornerHandicap => 'lần phạt góc',
          MarketCategory.bookingsHandicap => 'thẻ phạt',
          _ => _unitWord(data.sportId),
        };
        // Tennis/Volleyball omit the "Đội" prefix in the original.
        final teamPrefix = (data.sportId == 4 || data.sportId == 5)
            ? ''
            : 'Đội ';
        buffer.writeln(
          '$teamPrefix$overTeamName chấp ${_fmtNum(handicapAbs)} $unit'
          '${_handicapDetail(handicapAbs)}.',
        );
      }
    }

    // Over/Under info
    if (data.market == MarketCategory.overUnder ||
        data.market == MarketCategory.cornerOverUnder ||
        data.market == MarketCategory.bookingsOverUnder) {
      final unit = switch (data.market) {
        MarketCategory.cornerOverUnder => 'lần phạt góc',
        MarketCategory.bookingsOverUnder => 'thẻ phạt',
        _ => _unitWord(data.sportId),
      };
      buffer.writeln(
        'Kèo Tài Xỉu ${_fmtNum(handicapAbs)} $unit'
        '${_handicapDetail(handicapAbs)}.',
      );
    }

    // Score / corner / bookings status line
    if (!data.isLive) {
      buffer.writeln('Trận đấu chưa bắt đầu.');
    } else {
      if (data.market == MarketCategory.cornerOverUnder ||
          data.market == MarketCategory.cornerHandicap) {
        buffer.writeln(
          'Số lần phạt góc hiện tại: ${data.homeName} ${data.homeCorner}-${data.awayCorner} ${data.awayName}.',
        );
      } else if (data.market == MarketCategory.bookingsOverUnder ||
          data.market == MarketCategory.bookingsHandicap) {
        buffer.writeln(
          'Số thẻ phạt hiện tại: ${data.homeName} ${data.homeBookings}-${data.awayBookings} ${data.awayName}.',
        );
      } else {
        buffer.writeln(
          'Tỷ số${_scoreSub(data.sportId)} hiện tại: ${data.homeName} ${data.homeScore}-${data.awayScore} ${data.awayName}.',
        );
      }
    }

    return buffer.toString().trim();
  }

  /// Part 3: Công thức tính tiền (ratioInfo)
  static String _buildRatioText(HintData data) {
    final ratio = data.ratio;
    final style = data.style;
    final styleName = OddsCalculator.getStyleName(style);
    final winFormula = OddsCalculator.getWinFormula(ratio, style);
    final loseFormula = OddsCalculator.getLoseFormula(ratio, style);

    return '''Tỷ lệ cược ${ratio.toStringAsFixed(2)} ($styleName):
• Tiền thắng = $winFormula.
• Tiền thua = $loseFormula.''';
  }

  /// Part 4: Kết quả kèo (resultText)
  static String _buildResultText(HintData data) {
    final hintType = data.getHintType();
    final buffer = StringBuffer();

    // --- Asian Handicap family (score / corner / bookings) ---
    if (_isHandicapType(hintType)) {
      buffer.writeln('Kết quả ${_handicapTitle(data)}:');
      for (final result in _handicapResults(hintType)) {
        buffer.writeln(' • $result.');
      }
      return buffer.toString().trim();
    }

    // --- Over/Under family ---
    if (_isOverUnderType(hintType)) {
      buffer.writeln('Kết quả ${_overUnderTitle(data)}:');
      for (final result in _overUnderResults(hintType, data.isOver)) {
        buffer.writeln(' • $result.');
      }
      return buffer.toString().trim();
    }

    // --- Simple markets ---
    switch (hintType) {
      case HintType.market1X2:
        final periodCode = data.period.code;
        buffer.writeln(
          'Kết quả kèo 1X2 ${data.period.text}, cược ${data.selectionName} ($periodCode.${_get1X2Code(data)}):',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.oddEven:
        buffer.writeln(
          'Kết quả kèo Chẵn Lẻ ${data.period.text}, cược ${data.selectionName}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.doubleChance:
        buffer.writeln(
          'Kết quả kèo Cơ Hội Kép ${data.period.text}, cược ${_getDoubleChanceName(data)} (${data.period.code}.${_getDoubleChanceCode(data)}):',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.moneyLine:
        buffer.writeln('Kết quả kèo đội thắng, cược ${data.teamName}:');
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.correctScore:
        buffer.writeln(
          'Kết quả kèo Tỷ Số chính xác ${data.period.text}, cược tỷ số [${data.teamName}]:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.drawNoBet:
        buffer.writeln(
          'Kết quả kèo Hòa được hoàn tiền ${data.period.text}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Hoàn tiền cược.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.outright:
        buffer.writeln('Kết quả Kèo Đội Vô Địch, cược ${data.teamName}:');
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      default:
        buffer.writeln('Kết quả kèo:');
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
    }

    return buffer.toString().trim();
  }

  /// Part 5: Ví dụ cụ thể (exampleText)
  static String _buildExampleText(HintData data) {
    // stake is in VND (e.g., 1000000.0 = 1M VND)
    final stake = data.stake > 0 ? data.stake : 100000.0;
    final win = OddsCalculator.calculateWin(stake, data.ratio, data.style);
    final lose = OddsCalculator.calculateLose(stake, data.ratio, data.style);
    final winHalf = OddsCalculator.calculateHalfWin(
      stake,
      data.ratio,
      data.style,
    );
    final loseHalf = OddsCalculator.calculateHalfLose(
      stake,
      data.ratio,
      data.style,
    );

    final hintType = data.getHintType();
    final buffer = StringBuffer();
    final caseCount = data.getCaseCount();

    buffer.writeln(
      'Ví dụ cược ${data.selectionName} ${OddsCalculator.formatMoney(stake)}, có $caseCount trường hợp:',
    );

    // --- Asian Handicap family (score / corner / bookings) ---
    if (_isHandicapType(hintType)) {
      _writeHandicapExample(
        buffer,
        data,
        hintType,
        win,
        lose,
        winHalf,
        loseHalf,
      );
      return buffer.toString().trim();
    }

    // --- Over/Under family ---
    if (_isOverUnderType(hintType)) {
      _writeOverUnderExample(
        buffer,
        data,
        hintType,
        win,
        lose,
        winHalf,
        loseHalf,
      );
      return buffer.toString().trim();
    }

    // --- Simple markets ---
    switch (hintType) {
      case HintType.market1X2:
        buffer.writeln(
          ' • TH1: ${_get1X2WinCondition(data)} → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.oddEven:
        final examples = data.isEven ? '0, 2, 4, ...' : '1, 3, 5, ...';
        buffer.writeln(
          ' • TH1: Tổng bàn thắng là số ${data.selectionName.toLowerCase()} (vd: $examples) → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.doubleChance:
        buffer.writeln(
          ' • TH1: ${_getDoubleChanceWinCondition(data)} → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.moneyLine:
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.correctScore:
        buffer.writeln(
          ' • TH1: Tỷ số chính xác là [${data.teamName}] → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.drawNoBet:
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(' • TH2: Hòa → hoàn tiền cược.');
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.outright:
        buffer.writeln(
          ' • TH1: ${data.teamName} vô địch → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      default:
        buffer.writeln(' • TH1: Thắng → ${OddsCalculator.formatMoney(win)}.');
        buffer.writeln(' • TH2: Thua → ${OddsCalculator.formatMoney(lose)}.');
    }

    return buffer.toString().trim();
  }

  // ==========================================================================
  // Asian Handicap helpers
  // ==========================================================================

  /// Result title for handicap markets, e.g. "Kèo Chấp đồng banh" /
  /// "Kèo Chấp 1 trái, bắt kèo trên".
  static String _handicapTitle(HintData data) {
    final absHc = data.handicap.abs();
    // Selected team gives -> "bắt trên", selected team receives -> "bắt dưới".
    final direction = data.handicap > 0 ? 'dưới' : 'trên';

    switch (data.market) {
      case MarketCategory.cornerHandicap:
        return absHc < 0.001
            ? 'Phạt Góc Kèo Chấp bằng nhau'
            : 'Phạt Góc Kèo Chấp ${_fmtNum(absHc)}, bắt kèo $direction';
      case MarketCategory.bookingsHandicap:
        return absHc < 0.001
            ? 'Thẻ Phạt Kèo Chấp bằng nhau'
            : 'Thẻ Phạt Kèo Chấp ${_fmtNum(absHc)}, bắt kèo $direction';
      default:
        return absHc < 0.001
            ? 'Kèo Chấp đồng banh'
            : 'Kèo Chấp ${_fmtNum(absHc)} ${_unitWord(data.sportId)}, bắt kèo $direction';
    }
  }

  /// Result bullet labels for each handicap hint type.
  static List<String> _handicapResults(HintType type) {
    switch (type) {
      case HintType.asianHandicapRound:
        return ['Thắng', 'Hoàn tiền cược', 'Thua'];
      case HintType.asianHandicapHalf:
        return ['Thắng', 'Thua'];
      case HintType.asianHandicapQuarterOver:
        return ['Thắng', 'Thua nửa tiền', 'Thua'];
      case HintType.asianHandicapQuarterUnder:
        return ['Thắng', 'Thắng nửa tiền', 'Thua'];
      case HintType.asianHandicap3QuarterOver:
        return ['Thắng', 'Thắng nửa tiền', 'Thua'];
      case HintType.asianHandicap3QuarterUnder:
        return ['Thắng', 'Thua nửa tiền', 'Thua'];
      default:
        return ['Thắng', 'Thua'];
    }
  }

  /// Write the example cases for a handicap bet.
  ///
  /// Mirrors `SbHint.ts`: the win/draw thresholds are computed relative to the
  /// CURRENT live score (`selected - opponent`), because the bet settles on
  /// goals scored after placement (in-play handicap).
  static void _writeHandicapExample(
    StringBuffer buffer,
    HintData data,
    HintType hintType,
    double win,
    double lose,
    double winHalf,
    double loseHalf,
  ) {
    final h = data.handicap;
    final h1f = _handicapPlus1Floor(h);
    final isHomeBet = data.team == HintTeamType.home;
    final name = data.teamName;

    // Live count from the SELECTED team's perspective.
    final (int sel, int other) = switch (data.market) {
      MarketCategory.cornerHandicap => isHomeBet
          ? (data.homeCorner, data.awayCorner)
          : (data.awayCorner, data.homeCorner),
      MarketCategory.bookingsHandicap => isHomeBet
          ? (data.homeBookings, data.awayBookings)
          : (data.awayBookings, data.homeBookings),
      _ => isHomeBet
          ? (data.homeScore, data.awayScore)
          : (data.awayScore, data.homeScore),
    };

    final diff = switch (hintType) {
      HintType.asianHandicapRound => h <= 0
          ? sel - other + h1f
          : sel - other - h1f + 2,
      HintType.asianHandicapHalf => h <= 0
          ? sel - other + h1f
          : sel - other - h1f + 1,
      HintType.asianHandicapQuarterOver => sel - other + h1f,
      HintType.asianHandicapQuarterUnder => sel - other - h1f + 2,
      HintType.asianHandicap3QuarterOver => sel - other + h1f + 1,
      HintType.asianHandicap3QuarterUnder => sel - other - h1f + 1,
      _ => 0,
    };

    final winCond = _diffText(data.market, data.sportId, name, true, diff);
    final midCond = _diffText(data.market, data.sportId, name, false, diff - 1);
    final winMoney = OddsCalculator.formatMoney(win);
    final loseMoney = OddsCalculator.formatMoney(lose);
    final winHalfMoney = OddsCalculator.formatMoney(winHalf);
    final loseHalfMoney = OddsCalculator.formatMoney(loseHalf);

    switch (hintType) {
      case HintType.asianHandicapRound:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → hoàn tiền cược.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicapHalf:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicapQuarterOver:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thua $loseHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicapQuarterUnder:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thắng $winHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicap3QuarterOver:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thắng $winHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      case HintType.asianHandicap3QuarterUnder:
        buffer.writeln(' • TH1: $winCond → thắng $winMoney.');
        buffer.writeln(' • TH2: $midCond → thua $loseHalfMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;
      default:
        break;
    }
  }

  // ==========================================================================
  // Over/Under helpers
  // ==========================================================================

  /// Result title for Over/Under markets.
  static String _overUnderTitle(HintData data) {
    final absHc = _fmtNum(data.handicap.abs());
    final direction = data.selectionName; // "Tài" / "Xỉu"
    switch (data.market) {
      case MarketCategory.cornerOverUnder:
        return 'kèo Phạt Góc Tài Xỉu $absHc, bắt $direction';
      case MarketCategory.bookingsOverUnder:
        return 'kèo Thẻ Phạt Tài Xỉu $absHc, bắt $direction';
      default:
        return 'kèo Tài Xỉu $absHc ${_unitWord(data.sportId)}, bắt $direction';
    }
  }

  /// Result bullet labels for each Over/Under hint type.
  static List<String> _overUnderResults(HintType type, bool isOver) {
    switch (type) {
      case HintType.overUnderRound:
        return ['Thắng', 'Hoàn tiền cược', 'Thua'];
      case HintType.overUnderHalf:
        return ['Thắng', 'Thua'];
      case HintType.overUnderQuarter:
        return ['Thắng', isOver ? 'Thua nửa tiền' : 'Thắng nửa tiền', 'Thua'];
      case HintType.overUnder3Quarter:
        return ['Thắng', isOver ? 'Thắng nửa tiền' : 'Thua nửa tiền', 'Thua'];
      default:
        return ['Thắng', 'Thua'];
    }
  }

  /// Write the example cases for an Over/Under bet.
  static void _writeOverUnderExample(
    StringBuffer buffer,
    HintData data,
    HintType hintType,
    double win,
    double lose,
    double winHalf,
    double loseHalf,
  ) {
    final isOver = data.isOver;
    final h1f = _handicapPlus1Floor(data.handicap);
    final sum = switch (data.market) {
      MarketCategory.cornerOverUnder => 'Tổng số lần phạt góc',
      MarketCategory.bookingsOverUnder => 'Tổng số thẻ phạt',
      MarketCategory.homeOverUnder =>
        'Số ${_sumWord(data.sportId)} của ${data.homeName}',
      MarketCategory.awayOverUnder =>
        'Số ${_sumWord(data.sportId)} của ${data.awayName}',
      _ => 'Tổng số ${_sumWord(data.sportId)}',
    };
    final winMoney = OddsCalculator.formatMoney(win);
    final loseMoney = OddsCalculator.formatMoney(lose);

    switch (hintType) {
      case HintType.overUnderRound:
        var winValue = h1f;
        var sign = '≥';
        var drawValue = winValue - 1;
        if (!isOver) {
          winValue -= 2;
          sign = winValue > 0 ? '≤' : '=';
          drawValue = winValue + 1;
        }
        buffer.writeln(' • TH1: $sum $sign $winValue → thắng $winMoney.');
        buffer.writeln(' • TH2: $sum = $drawValue → hoàn tiền cược.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;

      case HintType.overUnderHalf:
        var winValue = h1f;
        var sign = '≥';
        if (!isOver) {
          winValue -= 1;
          sign = winValue > 0 ? '≤' : '=';
        }
        buffer.writeln(' • TH1: $sum $sign $winValue → thắng $winMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;

      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        final is3Q = hintType == HintType.overUnder3Quarter;
        var winValue = h1f + (is3Q ? 1 : 0);
        var sign = '≥';
        var midValue = winValue - 1;
        // Over: Quarter -> half-lose, 3/4 -> half-win.
        var midIsWin = is3Q;
        if (!isOver) {
          winValue -= 2;
          sign = winValue > 0 ? '≤' : '=';
          midValue = winValue + 1;
          midIsWin = !is3Q;
        }
        final midMoney = midIsWin
            ? 'thắng ${OddsCalculator.formatMoney(winHalf)}'
            : 'thua ${OddsCalculator.formatMoney(loseHalf)}';
        buffer.writeln(' • TH1: $sum $sign $winValue → thắng $winMoney.');
        buffer.writeln(' • TH2: $sum = $midValue → $midMoney.');
        buffer.writeln(' • Các trường hợp còn lại → thua $loseMoney.');
        break;

      default:
        break;
    }
  }

  // ==========================================================================
  // Shared helpers
  // ==========================================================================

  static bool _isHandicapType(HintType type) {
    return type == HintType.asianHandicapRound ||
        type == HintType.asianHandicapHalf ||
        type == HintType.asianHandicapQuarterOver ||
        type == HintType.asianHandicapQuarterUnder ||
        type == HintType.asianHandicap3QuarterOver ||
        type == HintType.asianHandicap3QuarterUnder;
  }

  static bool _isOverUnderType(HintType type) {
    return type == HintType.overUnderRound ||
        type == HintType.overUnderHalf ||
        type == HintType.overUnderQuarter ||
        type == HintType.overUnder3Quarter;
  }

  /// floor(|handicap| + 1) — the base differential used by every handicap type.
  static int _handicapPlus1Floor(double handicap) =>
      (handicap.abs() + 1).floor();

  /// Format a number, dropping a trailing ".0" (1.0 -> "1", 2.5 -> "2.5").
  static String _fmtNum(num value) {
    if (value == value.truncate()) return value.truncate().toString();
    return value.toString();
  }

  /// Quarter-handicap range detail, e.g. " (0-0.5)" for 0.25, " (0.5-1)" for
  /// 0.75. Returns an empty string for whole/half handicaps.
  static String _handicapDetail(double handicapAbs) {
    final n = handicapAbs.floor();
    final fraction = handicapAbs - n;
    double a = n.toDouble();
    double b = n.toDouble();
    if ((fraction - 0.25).abs() < 0.001) {
      b += 0.5;
    } else if ((fraction - 0.75).abs() < 0.001) {
      a += 0.5;
      b += 1;
    }
    if (a == b) return '';
    return ' (${_fmtNum(a)}-${_fmtNum(b)})';
  }

  /// Dispatch to the correct phrasing for a handicap differential.
  static String _diffText(
    MarketCategory market,
    int sportId,
    String team,
    bool isGreaterEqual,
    int diff,
  ) {
    switch (market) {
      case MarketCategory.cornerHandicap:
        return _getCornerText(team, isGreaterEqual, diff);
      case MarketCategory.bookingsHandicap:
        return _getBookingsText(team, isGreaterEqual, diff);
      default:
        return _getScoreText(team, isGreaterEqual, diff, _unitWord(sportId));
    }
  }

  /// Score-difference phrasing — port of `getScoreText` in `SbHint.ts`.
  static String _getScoreText(
    String team,
    bool isGreaterEqual,
    int diff,
    String sub,
  ) {
    if (isGreaterEqual) {
      if (diff > 1) return '$team thắng cách biệt ≥ $diff $sub';
      if (diff == 1) return '$team thắng';
      if (diff == 0) return '$team thắng hoặc hoà';
      return '$team không thua cách biệt hơn ${-diff} $sub';
    } else {
      if (diff >= 1) return '$team thắng cách biệt $diff $sub';
      if (diff == 0) return 'Hòa';
      return '$team thua cách biệt ${-diff} $sub';
    }
  }

  /// Corner-difference phrasing — port of `getCornerText` in `SbHint.ts`.
  static String _getCornerText(String team, bool isGreaterEqual, int diff) {
    if (isGreaterEqual) {
      if (diff > 1) return '$team có số lần phạt góc cách biệt ≥ $diff';
      if (diff == 1) return '$team có số lần phạt góc cách biệt nhiều hơn';
      if (diff == 0) return '$team có số lần phạt góc nhiều hơn hoặc bằng';
      return '$team có số lần phạt góc không thua cách biệt hơn ${-diff}';
    } else {
      if (diff >= 1) return '$team có số lần phạt góc cách biệt $diff lần';
      if (diff == 0) return '2 đội có số lần phạt góc bằng nhau';
      return '$team có số lần phạt góc cách biệt ít hơn ${-diff} lần';
    }
  }

  /// Bookings-difference phrasing — port of `getBookingsText` in `SbHint.ts`.
  static String _getBookingsText(String team, bool isGreaterEqual, int diff) {
    if (isGreaterEqual) {
      if (diff > 1) return '$team có số thẻ phạt cách biệt ≥ $diff';
      if (diff == 1) return '$team có số thẻ phạt cách biệt nhiều hơn';
      if (diff == 0) return '$team có số thẻ phạt nhiều hơn hoặc bằng';
      return '$team có số thẻ phạt không thua cách biệt hơn ${-diff}';
    } else {
      if (diff >= 1) return '$team có số thẻ phạt cách biệt $diff lần';
      if (diff == 0) return '2 đội có số thẻ phạt bằng nhau';
      return '$team có số thẻ phạt cách biệt ít hơn ${-diff} lần';
    }
  }

  static String _get1X2Code(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '1';
      case HintTeamType.away:
        return '2';
      case HintTeamType.draw:
        return 'X';
      default:
        return '';
    }
  }

  static String _get1X2WinCondition(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '${data.homeName} thắng';
      case HintTeamType.away:
        return '${data.awayName} thắng';
      case HintTeamType.draw:
        return 'Hòa';
      default:
        return '';
    }
  }

  static String _getDoubleChanceName(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return 'Đội nhà hoặc hoà';
      case HintTeamType.away:
        return 'Đội khách hoặc hoà';
      case HintTeamType.draw:
        return 'Đội nhà hoặc khách';
      default:
        return '';
    }
  }

  static String _getDoubleChanceCode(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '1X';
      case HintTeamType.away:
        return 'X2';
      case HintTeamType.draw:
        return '12';
      default:
        return '';
    }
  }

  static String _getDoubleChanceWinCondition(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return '${data.homeName} thắng hoặc hòa';
      case HintTeamType.away:
        return '${data.awayName} thắng hoặc hòa';
      case HintTeamType.draw:
        return '${data.homeName} thắng hoặc ${data.awayName} thắng';
      default:
        return '';
    }
  }
}

/// Hint Content Model
///
/// Contains all parts of the hint content
class HintContent {
  final String simpleText;
  final String infoText;
  final String ratioText;
  final String resultText;
  final String exampleText;

  /// Home/away team names — used by the renderer to highlight team names.
  final String homeName;
  final String awayName;

  const HintContent({
    required this.simpleText,
    required this.infoText,
    required this.ratioText,
    required this.resultText,
    required this.exampleText,
    this.homeName = '',
    this.awayName = '',
  });

  /// Get full hint text
  String get fullText {
    return '$simpleText\n\n$infoText\n\n$ratioText\n\n$resultText\n\n$exampleText';
  }
}
