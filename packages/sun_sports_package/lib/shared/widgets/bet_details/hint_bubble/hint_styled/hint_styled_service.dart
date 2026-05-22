import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_service.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_styled/tag_helpers.dart';

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
/// Thin styling layer on top of [HintService]. It takes the plain hint
/// content — the single source of truth for all wording and betting logic —
/// and adds the XML-like markup tags consumed by StyledText.
///
/// Keeping this a *converter* instead of a second implementation guarantees
/// the bubble (V1, [HintService] + HintContentBuilder) and the tooltip
/// (V2, StyledText) can never drift apart again: every fix to [HintService]
/// flows here automatically.
///
/// Only the colored tags are applied:
/// - `<simple>` — green explanation block
/// - `<team>`   — yellow team names
/// - `<score>`  — yellow live score
/// - `<positive>` / `<negative>` — green / red odds ratio
/// - `<win>` / `<lose>` — green / red "thắng" / "thua" keywords
class HintStyledService {
  HintStyledService._();

  /// Matches a live score "X-Y" surrounded by whitespace (so the quarter
  /// handicap detail like "(0-0.5)" is not mistaken for a score).
  static final RegExp _scoreRegex = RegExp(r'(?<=\s)\d+-\d+(?=\s)');

  /// Matches the win/lose keywords ("thắng" / "thua", either case).
  static final RegExp _winLoseRegex = RegExp(r'[Tt]hắng|[Tt]hua');

  /// Generate styled hint content with tags.
  static StyledHintContent generateStyledHint(HintData data) {
    final content = HintService.generateHint(data);

    // Longest first so a short name that is a substring of a longer one
    // cannot corrupt an already-wrapped name.
    final teams =
        <String>[
          if (data.homeName.isNotEmpty) data.homeName,
          if (data.awayName.isNotEmpty) data.awayName,
        ]..sort((a, b) => b.length.compareTo(a.length));

    return StyledHintContent(
      simpleText: TagHelpers.wrapTag('simple', content.simpleText),
      infoText: _tagInfo(content.infoText, teams),
      ratioText: _tagRatio(content.ratioText, data.ratio),
      resultText: _wrapWinLose(_wrapTeams(content.resultText, teams)),
      exampleText: _wrapWinLose(_wrapTeams(content.exampleText, teams)),
    );
  }

  /// Wrap every "thắng" / "thua" keyword with a `<win>` / `<lose>` tag.
  static String _wrapWinLose(String text) {
    return text.replaceAllMapped(_winLoseRegex, (match) {
      final word = match.group(0)!;
      return word.contains('ắ')
          ? TagHelpers.win(word)
          : TagHelpers.lose(word);
    });
  }

  /// Tag the info section: team names + the live score.
  static String _tagInfo(String text, List<String> teams) {
    final withTeams = _wrapTeams(text, teams);
    return withTeams.replaceAllMapped(
      _scoreRegex,
      (match) => TagHelpers.score(match.group(0)!),
    );
  }

  /// Highlight the odds ratio (green when ≥ 0, red when negative).
  static String _tagRatio(String text, double ratio) {
    final ratioStr = ratio.toStringAsFixed(2);
    final tagged = ratio >= 0
        ? TagHelpers.positiveRatio(ratioStr)
        : TagHelpers.negativeRatio(ratioStr);
    return text.replaceFirst(ratioStr, tagged);
  }

  /// Wrap every team-name occurrence in [text] with a `<team>` tag.
  ///
  /// Scans left-to-right and advances past each match so overlapping names
  /// (or a name appearing inside an already-wrapped one) cannot be corrupted.
  static String _wrapTeams(String text, List<String> teams) {
    if (teams.isEmpty) return text;

    final buffer = StringBuffer();
    var pos = 0;
    while (pos < text.length) {
      int hitIndex = -1;
      String hitName = '';
      for (final name in teams) {
        final index = text.indexOf(name, pos);
        if (index >= 0 && (hitIndex < 0 || index < hitIndex)) {
          hitIndex = index;
          hitName = name;
        }
      }
      if (hitIndex < 0) {
        buffer.write(text.substring(pos));
        break;
      }
      buffer.write(text.substring(pos, hitIndex));
      buffer.write(TagHelpers.team(hitName));
      pos = hitIndex + hitName.length;
    }
    return buffer.toString();
  }
}
