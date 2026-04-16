/// Tag Helper Utilities
///
/// Provides helper methods for creating XML-like markup tags
/// to reduce code duplication in hint styled service.
class TagHelpers {
  TagHelpers._();

  // ===========================================================================
  // Tag Wrapping Helpers
  // ===========================================================================

  /// Wrap content with a tag
  /// Example: wrapTag('team', 'Arsenal') => '<team>Arsenal</team>'
  static String wrapTag(String tag, String content) => '<$tag>$content</$tag>';

  /// Wrap content with multiple nested tags
  /// Example: wrapTags(['team', 'bold'], 'Arsenal') => '<team><bold>Arsenal</bold></team>'
  static String wrapTags(List<String> tags, String content) {
    if (tags.isEmpty) return content;
    return tags.reversed.fold(content, (acc, tag) => wrapTag(tag, acc));
  }

  // ===========================================================================
  // Bullet Point Helpers
  // ===========================================================================

  /// Create a bullet point line
  /// Example: bulletPoint('Thắng') => ' <bullet-point>•</bullet-point> <bullet>Thắng</bullet>'
  static String bulletPoint(String content) =>
      ' <bullet-point>•</bullet-point> <bullet>$content</bullet>';

  /// Create a bullet point with result tag
  /// Example: bulletResult('win', 'Thắng') => ' <bullet-point>•</bullet-point> <bullet><win>Thắng</win>.</bullet>'
  static String bulletResult(String resultTag, String text) =>
      ' <bullet-point>•</bullet-point> <bullet><$resultTag>$text</$resultTag>.</bullet>';

  // ===========================================================================
  // Case Item Helpers
  // ===========================================================================

  /// Create a case item line
  /// Example: caseItem('TH1', 'Arsenal thắng') => ' <bullet-point>•</bullet-point> <case>TH1:</case> Arsenal thắng'
  static String caseItem(String caseNum, String content) =>
      ' <bullet-point>•</bullet-point> <case>$caseNum:</case> $content';

  /// Create a remaining cases line (without case label)
  /// Example: remainingCase('thua 100K') => ' <bullet-point>•</bullet-point> Các trường hợp còn lại → thua 100K'
  static String remainingCase(String content) =>
      ' <bullet-point>•</bullet-point> Các trường hợp còn lại → $content';

  // ===========================================================================
  // Common Tag Combinations
  // ===========================================================================

  /// Wrap team name
  static String team(String name) => wrapTag('team', name);

  /// Wrap selection name
  static String selection(String name) => wrapTag('selection', name);

  /// Wrap selection team name (for example title)
  static String selectionTeam(String name) => wrapTag('selection-team', name);

  /// Wrap period
  static String period(String text) => wrapTag('period', text);

  /// Wrap handicap value
  static String handicap(String value) => wrapTag('handicap', value);

  /// Wrap score
  static String score(String value) => wrapTag('score', value);

  /// Wrap money amount
  static String money(String amount) => wrapTag('money', amount);

  /// Wrap number
  static String number(String value) => wrapTag('number', value);

  /// Wrap condition
  static String condition(String text) => wrapTag('condition', text);

  /// Wrap positive ratio
  static String positiveRatio(String value) => wrapTag('positive', value);

  /// Wrap negative ratio
  static String negativeRatio(String value) => wrapTag('negative', value);

  // ===========================================================================
  // Result Tags
  // ===========================================================================

  /// Wrap win text
  static String win(String text) => wrapTag('win', text);

  /// Wrap lose text
  static String lose(String text) => wrapTag('lose', text);

  /// Wrap draw text
  static String draw(String text) => wrapTag('draw', text);

  /// Wrap half win text
  static String halfWin(String text) => wrapTag('halfwin', text);

  /// Wrap half lose text
  static String halfLose(String text) => wrapTag('halflose', text);
}
