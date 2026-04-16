import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/odds_calculator.dart';

/// Hint Service
///
/// Service for generating hint content based on market type.
/// Based on FLUTTER_HINT_BUBBLE_IMPLEMENTATION_GUIDE.md Section 5-7
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
    );
  }

  /// Part 1: Giải thích kèo (simpleText)
  static String _buildSimpleText(HintData data) {
    final period = data.period.text;

    switch (data.market) {
      case MarketCategory.asianHandicap:
        return 'Kèo Châu Á với đội chấp phải thắng cách biệt hơn tỷ lệ đưa ra trong thời gian $period.';

      case MarketCategory.overUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số bàn thắng của cả 2 đội, trong thời gian $period.';

      case MarketCategory.market1X2:
        return 'Kèo Châu Âu trong thời gian $period.\nCó 3 cửa:\n • 1 : Đội nhà thắng.\n • X : hòa.\n • 2 : Đội khách thắng.';

      case MarketCategory.oddEven:
        return 'Kèo cược tổng số bàn thắng của hai đội là số chẵn hoặc số lẻ, trong thời gian $period.';

      case MarketCategory.doubleChance:
        return 'Kèo Châu Âu cơ hội kép trong thời gian $period.\nNgười chơi có thể chọn:\n • 1X : Đội nhà hoặc hoà.\n • 2X : Đội khách hoặc hoà.\n • 12 : Đội nhà hoặc khách.';

      case MarketCategory.cornerOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số lần phạt góc của cả 2 đội, trong thời gian $period.';

      case MarketCategory.cornerHandicap:
        return 'Kèo chấp phạt góc với đội chấp phải có số lần phạt góc nhiều hơn tỷ lệ đưa ra trong thời gian $period.';

      case MarketCategory.bookingsOverUnder:
        return 'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số thẻ phạt của cả 2 đội, trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.';

      case MarketCategory.bookingsHandicap:
        return 'Kèo chấp thẻ phạt với đội chấp phải có tổng thẻ phạt nhiều hơn tỷ lệ đưa ra trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.';

      case MarketCategory.drawNoBet:
        return 'Kèo hòa hoàn tiền trong thời gian $period.\nNếu kết quả hòa, người chơi được hoàn lại tiền cược.';

      case MarketCategory.moneyLine:
        return 'Kèo Money Line trong thời gian $period.\nChọn đội thắng trận đấu.';

      case MarketCategory.correctScore:
        return 'Dự đoán tỷ số chính xác của trận đấu trong thời gian $period.';

      case MarketCategory.outright:
        return 'Kèo cược đội vô địch giải đấu.';

      default:
        return 'Kèo cược trong thời gian $period.';
    }
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

    // Handicap info for Asian Handicap
    if (data.market == MarketCategory.asianHandicap ||
        data.market == MarketCategory.cornerHandicap ||
        data.market == MarketCategory.bookingsHandicap) {
      final handicapAbs = data.handicap.abs();
      // data.handicap is the market-level value from HOME team's perspective:
      // < 0: home team gives (home is stronger/favorite)
      // > 0: away team gives (away is stronger/favorite)
      final isHomeGiving = data.handicap < 0;
      final overTeamName = isHomeGiving ? data.homeName : data.awayName;

      if (handicapAbs == 0) {
        buffer.writeln('Trận đấu đồng banh.');
      } else {
        buffer.writeln('$overTeamName chấp $handicapAbs trái.');
      }
    }

    // Over/Under info
    if (data.market == MarketCategory.overUnder ||
        data.market == MarketCategory.cornerOverUnder ||
        data.market == MarketCategory.bookingsOverUnder) {
      final handicapAbs = data.handicap.abs();
      buffer.writeln(
        'Kèo Tài Xỉu $handicapAbs trái (${_getScoreRange(data)}).',
      );
    }

    // Score info
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
          'Tỷ số hiện tại: ${data.homeName} ${data.homeScore}-${data.awayScore} ${data.awayName}.',
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

    switch (hintType) {
      case HintType.asianHandicapRound:
        buffer.writeln(
          'Kết quả kèo Chấp ${data.handicap.abs()} trái, bắt ${_getBetDirection(data)}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Hoàn tiền cược.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.asianHandicapHalf:
        buffer.writeln(
          'Kết quả kèo Chấp ${data.handicap.abs()} trái, bắt ${_getBetDirection(data)}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.asianHandicapQuarterOver:
      case HintType.asianHandicap3QuarterOver:
        buffer.writeln(
          'Kết quả kèo Chấp ${data.handicap.abs()} trái, bắt ${_getBetDirection(data)}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua nửa tiền.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.asianHandicapQuarterUnder:
      case HintType.asianHandicap3QuarterUnder:
        buffer.writeln(
          'Kết quả kèo Chấp ${data.handicap.abs()} trái, bắt ${_getBetDirection(data)}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thắng nửa tiền.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.overUnderRound:
        buffer.writeln(
          'Kết quả kèo Tài Xỉu ${data.handicap.abs()} bàn, bắt ${data.selectionName}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Hoàn tiền cược.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.overUnderHalf:
        buffer.writeln(
          'Kết quả kèo Tài Xỉu ${data.handicap.abs()} bàn, bắt ${data.selectionName}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        buffer.writeln(
          'Kết quả kèo Tài Xỉu ${data.handicap.abs()} bàn, bắt ${data.selectionName}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(
          ' • ${data.isOver ? 'Thua nửa tiền' : 'Thắng nửa tiền'}.',
        );
        buffer.writeln(' • Thua.');
        break;

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
          'Kết quả kèo Cơ Hội Kép ${data.period.text}, cược ${_getDoubleChanceSelection(data)}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.moneyLine:
        buffer.writeln(
          'Kết quả kèo Money Line ${data.period.text}, cược ${data.teamName}:',
        );
        buffer.writeln(' • Thắng.');
        buffer.writeln(' • Thua.');
        break;

      case HintType.outright:
        buffer.writeln(
          'Kết quả Kèo Đội Vô Địch, cược ${data.teamName}:',
        );
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
    // stake is now in VND (e.g., 1000000.0 = 1M VND)
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

    // stake is already in VND, formatCompact expects VND
    buffer.writeln(
      'Ví dụ cược ${data.selectionName} ${MoneyFormatter.formatCompact(stake.toInt())}, có $caseCount trường hợp:',
    );

    switch (hintType) {
      case HintType.asianHandicapRound:
        final diff = (data.handicap.abs() + 1).toInt();
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng cách biệt ≥ $diff trái → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • TH2: ${data.teamName} thắng cách biệt ${diff - 1} trái → hoàn tiền cược.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.asianHandicapHalf:
        final diff = data.handicap.abs().ceil();
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng cách biệt ≥ $diff trái → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.asianHandicapQuarterOver:
      case HintType.asianHandicap3QuarterOver:
        final diff = data.handicap.abs().ceil();
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng cách biệt ≥ $diff trái → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • TH2: ${data.teamName} thắng cách biệt ${diff - 1} trái → thua ${OddsCalculator.formatMoney(loseHalf)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.asianHandicapQuarterUnder:
      case HintType.asianHandicap3QuarterUnder:
        final diff = data.handicap.abs().ceil();
        buffer.writeln(
          ' • TH1: ${data.teamName} thắng cách biệt ≥ $diff trái → thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • TH2: ${data.teamName} thắng cách biệt ${diff - 1} trái → thắng ${OddsCalculator.formatMoney(winHalf)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      case HintType.overUnderRound:
        final threshold = data.handicap.abs().toInt();
        if (data.isOver) {
          buffer.writeln(
            ' • TH1: Tổng số bàn thắng ≥ ${threshold + 1} → thắng ${OddsCalculator.formatMoney(win)}.',
          );
          buffer.writeln(
            ' • TH2: Tổng số bàn thắng = $threshold → hoàn tiền cược.',
          );
          buffer.writeln(
            ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
          );
        } else {
          buffer.writeln(
            ' • TH1: Tổng số bàn thắng ≤ ${threshold - 1} → thắng ${OddsCalculator.formatMoney(win)}.',
          );
          buffer.writeln(
            ' • TH2: Tổng số bàn thắng = $threshold → hoàn tiền cược.',
          );
          buffer.writeln(
            ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
          );
        }
        break;

      case HintType.overUnderHalf:
        final threshold = data.handicap.abs().ceil();
        if (data.isOver) {
          buffer.writeln(
            ' • TH1: Tổng số bàn thắng ≥ $threshold → thắng ${OddsCalculator.formatMoney(win)}.',
          );
          buffer.writeln(
            ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
          );
        } else {
          buffer.writeln(
            ' • TH1: Tổng số bàn thắng ≤ ${threshold - 1} → thắng ${OddsCalculator.formatMoney(win)}.',
          );
          buffer.writeln(
            ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
          );
        }
        break;

      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        final threshold = data.handicap.abs().ceil();
        if (data.isOver) {
          buffer.writeln(
            ' • TH1: Tổng số bàn thắng ≥ $threshold → thắng ${OddsCalculator.formatMoney(win)}.',
          );
          buffer.writeln(
            ' • TH2: Tổng số bàn thắng = ${threshold - 1} → thua ${OddsCalculator.formatMoney(loseHalf)}.',
          );
          buffer.writeln(
            ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
          );
        } else {
          buffer.writeln(
            ' • TH1: Tổng số bàn thắng ≤ ${threshold - 2} → thắng ${OddsCalculator.formatMoney(win)}.',
          );
          buffer.writeln(
            ' • TH2: Tổng số bàn thắng = ${threshold - 1} → thắng ${OddsCalculator.formatMoney(winHalf)}.',
          );
          buffer.writeln(
            ' • Các trường hợp còn lại → thua ${OddsCalculator.formatMoney(lose)}.',
          );
        }
        break;

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

      case HintType.outright:
        buffer.writeln(
          ' • TH1: ${data.teamName} vô địch ⇒ thắng ${OddsCalculator.formatMoney(win)}.',
        );
        buffer.writeln(
          ' • Các trường hợp còn lại ⇒ thua ${OddsCalculator.formatMoney(lose)}.',
        );
        break;

      default:
        buffer.writeln(' • TH1: Thắng → ${OddsCalculator.formatMoney(win)}.');
        buffer.writeln(' • TH2: Thua → ${OddsCalculator.formatMoney(lose)}.');
    }

    return buffer.toString().trim();
  }

  // Helper methods

  static String _getBetDirection(HintData data) {
    return data.team == HintTeamType.home ? 'trên' : 'dưới';
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

  static String _getDoubleChanceSelection(HintData data) {
    switch (data.team) {
      case HintTeamType.home:
        return 'Đội nhà hoặc hoà (1X)';
      case HintTeamType.away:
        return 'Đội khách hoặc hoà (X2)';
      case HintTeamType.draw:
        return 'Đội nhà hoặc khách (12)';
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

  static String _getScoreRange(HintData data) {
    final currentTotal = data.homeScore + data.awayScore;
    final handicap = data.handicap.abs();
    return '$currentTotal-$handicap';
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

  const HintContent({
    required this.simpleText,
    required this.infoText,
    required this.ratioText,
    required this.resultText,
    required this.exampleText,
  });

  /// Get full hint text
  String get fullText {
    return '$simpleText\n\n$infoText\n\n$ratioText\n\n$resultText\n\n$exampleText';
  }
}
