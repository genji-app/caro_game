import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_service.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_styled/tag_helpers.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/odds_calculator.dart';

/// Styled Hint Content
///
/// Contains hint content strings with XML-like markup tags for styling.
/// Similar to [HintContent] but with tags for StyledText rendering.
class StyledHintContent {
  final String simpleText;
  final String infoText;
  final String ratioText;
  final String resultText;
  final String exampleText;

  const StyledHintContent({
    required this.simpleText,
    required this.infoText,
    required this.ratioText,
    required this.resultText,
    required this.exampleText,
  });
}

/// Styled Hint Service
///
/// Generates hint content with XML-like markup tags for StyledText rendering.
/// Wraps the existing HintService logic but applies semantic tags.
///
/// Tag Categories:
/// - Structure: `<title>`, `<content>`, `<bullet>`
/// - Entity: `<team>`, `<selection>`, `<period>`
/// - Numeric: `<ratio>`, `<handicap>`, `<score>`, `<money>`, `<number>`
/// - Result: `<win>`, `<lose>`, `<draw>`, `<halfwin>`, `<halflose>`
/// - Case: `<case>`, `<condition>`
///
/// Usage:
/// ```dart
/// final styledContent = HintStyledService.generateStyledHint(hintData);
/// // styledContent.simpleText contains tagged string
/// ```
class HintStyledService {
  HintStyledService._();

  /// Generate styled hint content with tags
  static StyledHintContent generateStyledHint(HintData data) {
    return StyledHintContent(
      simpleText: _buildSimpleText(data),
      infoText: _buildInfoText(data),
      ratioText: _buildRatioText(data),
      resultText: _buildResultText(data),
      exampleText: _buildExampleText(data),
    );
  }

  // ===========================================================================
  // Part 1: Simple Text (Giải thích kèo)
  // ===========================================================================
  static String _buildSimpleText(HintData data) {
    final period = TagHelpers.period(data.period.text);

    String wrapSimple(String text) => TagHelpers.wrapTag('simple', text);
    String bullet(String text) => TagHelpers.wrapTag('bullet', text);

    switch (data.market) {
      case MarketCategory.asianHandicap:
        return wrapSimple(
          'Kèo Châu Á với đội chấp phải thắng cách biệt hơn tỷ lệ đưa ra trong thời gian $period.',
        );

      case MarketCategory.overUnder:
        return wrapSimple(
          'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số bàn thắng của cả 2 đội, trong thời gian $period.',
        );

      case MarketCategory.market1X2:
        return wrapSimple(
          'Kèo Châu Âu trong thời gian $period.\nCó 3 cửa:\n • ${bullet('1 : Đội nhà thắng.')}\n • ${bullet('X : hòa.')}\n • ${bullet('2 : Đội khách thắng.')}',
        );

      case MarketCategory.oddEven:
        return wrapSimple(
          'Kèo cược tổng số bàn thắng của hai đội là số chẵn hoặc số lẻ, trong thời gian $period.',
        );

      case MarketCategory.doubleChance:
        return wrapSimple(
          'Kèo Châu Âu cơ hội kép trong thời gian $period.\nNgười chơi có thể chọn:\n • ${bullet('1X : Đội nhà hoặc hoà.')}\n • ${bullet('2X : Đội khách hoặc hoà.')}\n • ${bullet('12 : Đội nhà hoặc khách.')}',
        );

      case MarketCategory.cornerOverUnder:
        return wrapSimple(
          'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số lần phạt góc của cả 2 đội, trong thời gian $period.',
        );

      case MarketCategory.cornerHandicap:
        return wrapSimple(
          'Kèo chấp phạt góc với đội chấp phải có số lần phạt góc nhiều hơn tỷ lệ đưa ra trong thời gian $period.',
        );

      case MarketCategory.bookingsOverUnder:
        return wrapSimple(
          'Người chơi sẽ đặt tài hoặc xỉu dựa vào tổng số thẻ phạt của cả 2 đội, trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.',
        );

      case MarketCategory.bookingsHandicap:
        return wrapSimple(
          'Kèo chấp thẻ phạt với đội chấp phải có tổng thẻ phạt nhiều hơn tỷ lệ đưa ra trong thời gian $period.\nThẻ vàng tính 1, thẻ đỏ tính 2.',
        );

      case MarketCategory.drawNoBet:
        return wrapSimple(
          'Kèo hòa hoàn tiền trong thời gian $period.\nNếu kết quả hòa, người chơi được hoàn lại tiền cược.',
        );

      case MarketCategory.moneyLine:
        return wrapSimple(
          'Kèo Money Line trong thời gian $period.\nChọn đội thắng trận đấu.',
        );

      case MarketCategory.correctScore:
        return wrapSimple(
          'Dự đoán tỷ số chính xác của trận đấu trong thời gian $period.',
        );

      case MarketCategory.outright:
        return wrapSimple('Kèo cược đội vô địch giải đấu.');

      default:
        return wrapSimple('Kèo cược trong thời gian $period.');
    }
  }

  // ===========================================================================
  // Part 2: Info Text (Thông tin trận đấu)
  // ===========================================================================
  static String _buildInfoText(HintData data) {
    final buffer = StringBuffer();
    String wrapContent(String text) => TagHelpers.wrapTag('content', text);

    // Outright bet info: show event name and date
    if (data.market == MarketCategory.outright) {
      if (data.eventName.isNotEmpty) {
        buffer.writeln(wrapContent(data.eventName));
      }
      if (data.eventDate.isNotEmpty) {
        buffer.writeln(wrapContent(data.eventDate));
      }
      return buffer.toString().trim();
    }

    // Handicap info
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
        buffer.writeln(wrapContent('Trận đấu đồng banh.'));
      } else {
        final team = TagHelpers.team(overTeamName);
        final handicap = TagHelpers.handicap('$handicapAbs');
        buffer.writeln(wrapContent('$team chấp $handicap trái.'));
      }
    }

    // Over/Under info
    if (data.market == MarketCategory.overUnder ||
        data.market == MarketCategory.cornerOverUnder ||
        data.market == MarketCategory.bookingsOverUnder) {
      final handicapAbs = data.handicap.abs();
      final scoreRange = _getScoreRange(data);
      final handicap = TagHelpers.handicap('$handicapAbs');
      buffer.writeln(wrapContent('Kèo Tài Xỉu $handicap trái ($scoreRange).'));
    }

    // Score info
    if (!data.isLive) {
      buffer.writeln(wrapContent('Trận đấu chưa bắt đầu.'));
    } else {
      final homeTeam = TagHelpers.team(data.homeName);
      final awayTeam = TagHelpers.team(data.awayName);

      if (data.market == MarketCategory.cornerOverUnder ||
          data.market == MarketCategory.cornerHandicap) {
        final score = TagHelpers.score('${data.homeCorner}-${data.awayCorner}');
        buffer.writeln(
          wrapContent('Số lần phạt góc hiện tại: $homeTeam $score $awayTeam.'),
        );
      } else if (data.market == MarketCategory.bookingsOverUnder ||
          data.market == MarketCategory.bookingsHandicap) {
        final score = TagHelpers.score(
          '${data.homeBookings}-${data.awayBookings}',
        );
        buffer.writeln(
          wrapContent('Số thẻ phạt hiện tại: $homeTeam $score $awayTeam.'),
        );
      } else {
        final score = TagHelpers.score('${data.homeScore}-${data.awayScore}');
        buffer.writeln(
          wrapContent('Tỷ số hiện tại: $homeTeam $score $awayTeam.'),
        );
      }
    }

    return buffer.toString().trim();
  }

  // ===========================================================================
  // Part 3: Ratio Text (Công thức tính tiền)
  // ===========================================================================
  static String _buildRatioText(HintData data) {
    final ratio = data.ratio;
    final style = data.style;
    final styleName = OddsCalculator.getStyleName(style);
    final winFormula = OddsCalculator.getWinFormula(ratio, style);
    final loseFormula = OddsCalculator.getLoseFormula(ratio, style);

    final ratioStr = ratio.toStringAsFixed(2);
    final ratioTagged = ratio >= 0
        ? TagHelpers.positiveRatio(ratioStr)
        : TagHelpers.negativeRatio(ratioStr);
    final styleTagged = TagHelpers.selection(styleName);
    final winBullet = TagHelpers.wrapTag('bullet', 'Tiền thắng = $winFormula.');
    final loseBullet = TagHelpers.wrapTag(
      'bullet',
      'Tiền thua = $loseFormula.',
    );

    return TagHelpers.wrapTag(
      'content',
      'Tỷ lệ cược $ratioTagged ($styleTagged):\n• $winBullet\n• $loseBullet',
    );
  }

  // ===========================================================================
  // Part 4: Result Text (Kết quả kèo)
  // ===========================================================================
  static String _buildResultText(HintData data) {
    final hintType = data.getHintType();
    final buffer = StringBuffer();

    switch (hintType) {
      case HintType.asianHandicapRound:
        buffer.writeln(_buildHandicapResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('draw', 'Hoàn tiền cược'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.asianHandicapHalf:
        buffer.writeln(_buildHandicapResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.asianHandicapQuarterOver:
      case HintType.asianHandicap3QuarterOver:
        buffer.writeln(_buildHandicapResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('halflose', 'Thua nửa tiền'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.asianHandicapQuarterUnder:
      case HintType.asianHandicap3QuarterUnder:
        buffer.writeln(_buildHandicapResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('halfwin', 'Thắng nửa tiền'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.overUnderRound:
        buffer.writeln(_buildOverUnderResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('draw', 'Hoàn tiền cược'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.overUnderHalf:
        buffer.writeln(_buildOverUnderResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        buffer.writeln(_buildOverUnderResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        if (data.isOver) {
          buffer.writeln(TagHelpers.bulletResult('halflose', 'Thua nửa tiền'));
        } else {
          buffer.writeln(TagHelpers.bulletResult('halfwin', 'Thắng nửa tiền'));
        }
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.market1X2:
        buffer.writeln(_build1X2ResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.oddEven:
        buffer.writeln(_buildOddEvenResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.doubleChance:
        buffer.writeln(_buildDoubleChanceResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.moneyLine:
        buffer.writeln(_buildMoneyLineResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      case HintType.outright:
        buffer.writeln(_buildOutrightResultTitle(data));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
        break;

      default:
        buffer.writeln(TagHelpers.wrapTag('result-title', 'Kết quả kèo:'));
        buffer.writeln(TagHelpers.bulletResult('win', 'Thắng'));
        buffer.writeln(TagHelpers.bulletResult('lose', 'Thua'));
    }

    return buffer.toString().trim();
  }

  // ===========================================================================
  // Part 5: Example Text (Ví dụ cụ thể)
  // ===========================================================================
  static String _buildExampleText(HintData data) {
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
    final stakeFormatted = MoneyFormatter.formatCompact(stake.toInt());

    buffer.writeln(
      '<example-title>Ví dụ cược <selection-team>${data.selectionName}</selection-team> <money>$stakeFormatted</money>, có <number>$caseCount</number> trường hợp:</example-title>',
    );

    switch (hintType) {
      case HintType.asianHandicapRound:
        final diff = (data.handicap.abs() + 1).toInt();
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH1:</case> <team>${data.teamName}</team> thắng cách biệt <condition>≥ $diff trái</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH2:</case> <team>${data.teamName}</team> thắng cách biệt <condition>${diff - 1} trái</condition> → <draw>hoàn tiền cược</draw>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
        );
        break;

      case HintType.asianHandicapHalf:
        final diff = data.handicap.abs().ceil();
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH1:</case> <team>${data.teamName}</team> thắng cách biệt <condition>≥ $diff trái</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH2:</case> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
        );
        break;

      case HintType.asianHandicapQuarterOver:
      case HintType.asianHandicap3QuarterOver:
        final diff = data.handicap.abs().ceil();
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH1:</case> <team>${data.teamName}</team> thắng cách biệt <condition>≥ $diff trái</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH2:</case> <team>${data.teamName}</team> thắng cách biệt <condition>${diff - 1} trái</condition> → <halflose>thua</halflose> <money>${_formatMoney(loseHalf)}</money>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
        );
        break;

      case HintType.asianHandicapQuarterUnder:
      case HintType.asianHandicap3QuarterUnder:
        final diff = data.handicap.abs().ceil();
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH1:</case> <team>${data.teamName}</team> thắng cách biệt <condition>≥ $diff trái</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> <case>TH2:</case> <team>${data.teamName}</team> thắng cách biệt <condition>${diff - 1} trái</condition> → <halfwin>thắng</halfwin> <money>${_formatMoney(winHalf)}</money>.',
        );
        buffer.writeln(
          ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
        );
        break;

      case HintType.overUnderRound:
        final threshold = data.handicap.abs().toInt();
        if (data.isOver) {
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH1:</case> Tổng số bàn thắng <condition>≥ ${threshold + 1}</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH2:</case> Tổng số bàn thắng <condition>= $threshold</condition> → <draw>hoàn tiền cược</draw>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
          );
        } else {
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH1:</case> Tổng số bàn thắng <condition>≤ ${threshold - 1}</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH2:</case> Tổng số bàn thắng <condition>= $threshold</condition> → <draw>hoàn tiền cược</draw>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
          );
        }
        break;

      case HintType.overUnderHalf:
        final threshold = data.handicap.abs().ceil();
        if (data.isOver) {
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH1:</case> Tổng số bàn thắng <condition>≥ $threshold</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH2:</case> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
          );
        } else {
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH1:</case> Tổng số bàn thắng <condition>≤ ${threshold - 1}</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH2:</case> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
          );
        }
        break;

      case HintType.overUnderQuarter:
      case HintType.overUnder3Quarter:
        final threshold = data.handicap.abs().ceil();
        if (data.isOver) {
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH1:</case> Tổng số bàn thắng <condition>≥ $threshold</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH2:</case> Tổng số bàn thắng <condition>= ${threshold - 1}</condition> → <halflose>thua</halflose> <money>${_formatMoney(loseHalf)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
          );
        } else {
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH1:</case> Tổng số bàn thắng <condition>≤ ${threshold - 2}</condition> → <win>thắng</win> <money>${_formatMoney(win)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> <case>TH2:</case> Tổng số bàn thắng <condition>= ${threshold - 1}</condition> → <halfwin>thắng</halfwin> <money>${_formatMoney(winHalf)}</money>.',
          );
          buffer.writeln(
            ' <bullet-point>•</bullet-point> Các trường hợp còn lại → <lose>thua</lose> <money>${_formatMoney(lose)}</money>.',
          );
        }
        break;

      case HintType.market1X2:
        final sel = TagHelpers.selection(data.selectionName);
        final winMoney = TagHelpers.money(_formatMoney(win));
        final loseMoney = TagHelpers.money(_formatMoney(lose));
        buffer.writeln(
          TagHelpers.caseItem(
            'TH1',
            '$sel thắng → ${TagHelpers.win('thắng')} $winMoney.',
          ),
        );
        buffer.writeln(
          TagHelpers.caseItem(
            'TH2',
            '$sel không thắng → ${TagHelpers.lose('thua')} $loseMoney.',
          ),
        );
        break;

      case HintType.oddEven:
        final sel = TagHelpers.selection(data.selectionName);
        final winMoney = TagHelpers.money(_formatMoney(win));
        final loseMoney = TagHelpers.money(_formatMoney(lose));
        buffer.writeln(
          TagHelpers.caseItem(
            'TH1',
            'Tổng bàn thắng là $sel → ${TagHelpers.win('thắng')} $winMoney.',
          ),
        );
        buffer.writeln(
          TagHelpers.caseItem(
            'TH2',
            'Tổng bàn thắng không là $sel → ${TagHelpers.lose('thua')} $loseMoney.',
          ),
        );
        break;

      case HintType.doubleChance:
        final sel = TagHelpers.selection(_getDoubleChanceSelection(data));
        final winMoney = TagHelpers.money(_formatMoney(win));
        final loseMoney = TagHelpers.money(_formatMoney(lose));
        buffer.writeln(
          TagHelpers.caseItem(
            'TH1',
            '$sel xảy ra → ${TagHelpers.win('thắng')} $winMoney.',
          ),
        );
        buffer.writeln(
          TagHelpers.caseItem(
            'TH2',
            '$sel không xảy ra → ${TagHelpers.lose('thua')} $loseMoney.',
          ),
        );
        break;

      case HintType.moneyLine:
        final team = TagHelpers.team(data.teamName);
        final winMoney = TagHelpers.money(_formatMoney(win));
        final loseMoney = TagHelpers.money(_formatMoney(lose));
        buffer.writeln(
          TagHelpers.caseItem(
            'TH1',
            '$team thắng → ${TagHelpers.win('thắng')} $winMoney.',
          ),
        );
        buffer.writeln(
          TagHelpers.caseItem(
            'TH2',
            '$team không thắng → ${TagHelpers.lose('thua')} $loseMoney.',
          ),
        );
        break;

      case HintType.outright:
        final team = TagHelpers.team(data.teamName);
        final winMoney = TagHelpers.money(_formatMoney(win));
        final loseMoney = TagHelpers.money(_formatMoney(lose));
        buffer.writeln(
          TagHelpers.caseItem(
            'TH1',
            '$team vô địch ⇒ ${TagHelpers.win('thắng')} $winMoney.',
          ),
        );
        buffer.writeln(
          TagHelpers.remainingCase(
            '${TagHelpers.lose('thua')} $loseMoney.',
          ),
        );
        break;

      default:
        final winMoney = TagHelpers.money(_formatMoney(win));
        final loseMoney = TagHelpers.money(_formatMoney(lose));
        buffer.writeln(
          TagHelpers.caseItem(
            'TH1',
            'Thắng cược → ${TagHelpers.win('thắng')} $winMoney.',
          ),
        );
        buffer.writeln(
          TagHelpers.caseItem(
            'TH2',
            'Thua cược → ${TagHelpers.lose('thua')} $loseMoney.',
          ),
        );
    }

    return buffer.toString().trim();
  }

  // ===========================================================================
  // Helper Methods
  // ===========================================================================

  static String _formatMoney(double amount) =>
      OddsCalculator.formatMoney(amount);

  static String _getBetDirection(HintData data) {
    return data.team == HintTeamType.home ? 'trên' : 'dưới';
  }

  static String _get1X2Code(HintData data) {
    switch (data.selectionName.toLowerCase()) {
      case 'đội nhà':
      case 'home':
      case '1':
        return '1';
      case 'hòa':
      case 'draw':
      case 'x':
        return 'X';
      case 'đội khách':
      case 'away':
      case '2':
        return '2';
      default:
        return data.selectionName;
    }
  }

  static String _getDoubleChanceSelection(HintData data) {
    switch (data.selectionName.toLowerCase()) {
      case '1x':
        return 'Đội nhà hoặc Hòa';
      case '2x':
      case 'x2':
        return 'Đội khách hoặc Hòa';
      case '12':
        return 'Đội nhà hoặc Đội khách';
      default:
        return data.selectionName;
    }
  }

  static String _getScoreRange(HintData data) {
    final currentTotal = data.homeScore + data.awayScore;
    final handicap = data.handicap.abs();
    return '$currentTotal-$handicap';
  }

  // ===========================================================================
  // Tag Helper Wrappers
  // ===========================================================================

  /// Build result title for handicap bets
  static String _buildHandicapResultTitle(HintData data) {
    final handicapValue = TagHelpers.handicap('${data.handicap.abs()}');
    final direction = TagHelpers.selection(_getBetDirection(data));
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả kèo Chấp $handicapValue trái, bắt $direction:',
    );
  }

  /// Build result title for over/under bets
  static String _buildOverUnderResultTitle(HintData data) {
    final handicapValue = TagHelpers.handicap('${data.handicap.abs()}');
    final selectionName = TagHelpers.selection(data.selectionName);
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả kèo Tài Xỉu $handicapValue bàn, bắt $selectionName:',
    );
  }

  /// Build result title for 1X2 bets
  static String _build1X2ResultTitle(HintData data) {
    final periodText = TagHelpers.period(data.period.text);
    final selectionName = TagHelpers.selection(data.selectionName);
    final periodCode = data.period.code;
    final code = _get1X2Code(data);
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả kèo 1X2 $periodText, cược $selectionName ($periodCode.$code):',
    );
  }

  /// Build result title for odd/even bets
  static String _buildOddEvenResultTitle(HintData data) {
    final periodText = TagHelpers.period(data.period.text);
    final selectionName = TagHelpers.selection(data.selectionName);
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả kèo Chẵn Lẻ $periodText, cược $selectionName:',
    );
  }

  /// Build result title for double chance bets
  static String _buildDoubleChanceResultTitle(HintData data) {
    final periodText = TagHelpers.period(data.period.text);
    final selectionName = TagHelpers.selection(_getDoubleChanceSelection(data));
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả kèo Cơ Hội Kép $periodText, cược $selectionName:',
    );
  }

  /// Build result title for outright bets
  static String _buildOutrightResultTitle(HintData data) {
    final teamName = TagHelpers.team(data.teamName);
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả Kèo Đội Vô Địch, cược $teamName:',
    );
  }

  /// Build result title for money line bets
  static String _buildMoneyLineResultTitle(HintData data) {
    final periodText = TagHelpers.period(data.period.text);
    final teamName = TagHelpers.team(data.teamName);
    return TagHelpers.wrapTag(
      'result-title',
      'Kết quả kèo Money Line $periodText, cược $teamName:',
    );
  }
}
