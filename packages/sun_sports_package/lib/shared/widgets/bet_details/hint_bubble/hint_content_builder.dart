import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'hint_service.dart';

/// Hint Content Style
///
/// Defines colors and text styles for hint content rendering.
/// Use predefined schemes or create custom ones.
class HintContentStyle {
  final Color simpleColor;
  final Color defaultColor;
  final Color highlightColor;
  final Color positiveColor;
  final Color negativeColor;

  // Optional custom colors for win/lose keywords
  final Color winColor;
  final Color loseColor;

  // Color for team names (homeName / awayName)
  final Color teamColor;

  // Optional custom text style (if null, uses AppTextStyles.paragraphSmall)
  final TextStyle? textStyle;

  // Optional custom font weight for ratio (default: FontWeight.bold)
  final FontWeight ratioFontWeight;

  const HintContentStyle({
    required this.simpleColor,
    required this.defaultColor,
    required this.highlightColor,
    required this.positiveColor,
    required this.negativeColor,
    this.winColor = AppColors.green500, // Default green for "thắng"
    this.loseColor = AppColors.red500, // Default red for "thua"
    this.teamColor = const Color(0xFF2E90FA), // Default blue for team names
    this.textStyle,
    this.ratioFontWeight = FontWeight.bold, // Default bold for ratio
  });

  /// Get text style with color applied
  TextStyle getTextStyle(Color color) {
    if (textStyle != null) {
      return textStyle!.copyWith(color: color);
    }
    return AppTextStyles.paragraphSmall(color: color);
  }
}

/// Hint Content Builder
///
/// Shared builder for rendering hint content in both dialog and tooltip.
/// Optimized for performance with cached regex and const widgets.
///
/// Performance optimizations:
/// - Cached regex patterns (created once, reused forever)
/// - Const widgets where possible
/// - Minimized string operations
/// - Efficient list building
///
/// Usage:
/// ```dart
/// HintContentBuilder.buildContent(
///   content: hintContent,
///   ratio: 1.95,
///   colors: HintContentStyle(
///     simpleColor: Colors.white,
///     defaultColor: Colors.grey,
///     highlightColor: Colors.yellow,
///     positiveColor: Colors.green,
///     negativeColor: Colors.red,
///     textStyle: TextStyle(fontSize: 14), // Optional custom style
///   ),
/// )
/// ```
class HintContentBuilder {
  HintContentBuilder._();

  // Cached regex patterns for performance (created once, live forever)
  static final _ratioRegex = RegExp(r'(-?\d+\.?\d*)');
  static final _thRegex = RegExp(r'(TH\d+:)');

  /// Build complete hint content widget
  static Widget buildContent({
    required HintContent content,
    required double ratio,
    required HintContentStyle style,
    bool useGap = false,
    double spacing = 16.0, // Spacing between sections
    double linePadding = 2.0, // Padding between lines
    double ratioPadding = 4.0, // Padding for ratio line
  }) {
    final spacingWidget = useGap ? Gap(spacing) : SizedBox(height: spacing);
    final teamNames = _teamNameList(content.homeName, content.awayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSimpleText(content.simpleText, style),
        spacingWidget,
        buildInfoText(content.infoText, style, linePadding, teamNames),
        spacingWidget,
        buildRatioText(
          content.ratioText,
          ratio,
          style,
          linePadding,
          ratioPadding,
        ),
        spacingWidget,
        buildResultText(content.resultText, style, linePadding, teamNames),
        spacingWidget,
        buildExampleText(content.exampleText, style, linePadding, teamNames),
      ],
    );
  }

  /// Build the list of team names to highlight, longest first so that a
  /// shorter name that is a prefix of the other does not shadow it.
  static List<String> _teamNameList(String homeName, String awayName) {
    final names = [homeName, awayName].where((n) => n.isNotEmpty).toList();
    names.sort((a, b) => b.length.compareTo(a.length));
    return names;
  }

  /// Split [text] into spans, coloring occurrences of [teamNames] with the
  /// team color. Non-team segments are handed to [segment] for further
  /// styling (e.g. win/lose keyword coloring).
  static List<InlineSpan> _teamSpans(
    String text,
    List<String> teamNames,
    TextStyle teamStyle,
    List<InlineSpan> Function(String) segment,
  ) {
    if (teamNames.isEmpty || text.isEmpty) return segment(text);

    final spans = <InlineSpan>[];
    var pos = 0;
    while (pos < text.length) {
      int hitIndex = -1;
      String hitName = '';
      for (final name in teamNames) {
        final index = text.indexOf(name, pos);
        if (index >= 0 && (hitIndex < 0 || index < hitIndex)) {
          hitIndex = index;
          hitName = name;
        }
      }
      if (hitIndex < 0) {
        spans.addAll(segment(text.substring(pos)));
        break;
      }
      if (hitIndex > pos) {
        spans.addAll(segment(text.substring(pos, hitIndex)));
      }
      spans.add(TextSpan(text: hitName, style: teamStyle));
      pos = hitIndex + hitName.length;
    }
    return spans;
  }

  /// Part 1: Simple text
  static Widget buildSimpleText(String text, HintContentStyle style) {
    return Text(text, style: style.getTextStyle(style.simpleColor));
  }

  /// Part 2: Info text (match info)
  static Widget buildInfoText(
    String text,
    HintContentStyle style,
    double linePadding, [
    List<String> teamNames = const [],
  ]) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final textStyle = style.getTextStyle(style.defaultColor);
    final teamStyle = style.getTextStyle(style.teamColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: RichText(
              text: TextSpan(
                style: textStyle,
                children: _teamSpans(
                  line,
                  teamNames,
                  teamStyle,
                  (segment) => [TextSpan(text: segment)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Part 3: Ratio text (formula)
  static Widget buildRatioText(
    String text,
    double ratio,
    HintContentStyle style,
    double linePadding,
    double ratioPadding,
  ) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final textStyle = style.getTextStyle(style.defaultColor);
    final padding = EdgeInsets.only(bottom: linePadding);
    final ratioPad = EdgeInsets.only(bottom: ratioPadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // First line with highlighted ratio
        Padding(
          padding: ratioPad,
          child: buildRatioLine(lines[0], ratio, style),
        ),
        // Remaining lines
        for (int i = 1; i < lines.length; i++)
          Padding(
            padding: padding,
            child: Text(lines[i], style: textStyle),
          ),
      ],
    );
  }

  /// Build ratio line with highlighted ratio value
  static Widget buildRatioLine(
    String line,
    double ratio,
    HintContentStyle style,
  ) {
    final ratioColor = ratio >= 0 ? style.positiveColor : style.negativeColor;
    final match = _ratioRegex.firstMatch(line);

    if (match == null) {
      return Text(line, style: style.getTextStyle(style.defaultColor));
    }

    final defaultStyle = style.getTextStyle(style.defaultColor);
    final ratioStyle = style
        .getTextStyle(ratioColor)
        .copyWith(fontWeight: style.ratioFontWeight);

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: [
          if (match.start > 0) TextSpan(text: line.substring(0, match.start)),
          TextSpan(text: match.group(0), style: ratioStyle),
          if (match.end < line.length)
            TextSpan(text: line.substring(match.end)),
        ],
      ),
    );
  }

  /// Part 4: Result text
  static Widget buildResultText(
    String text,
    HintContentStyle style,
    double linePadding, [
    List<String> teamNames = const [],
  ]) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final defaultStyle = style.getTextStyle(style.defaultColor);
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final teamStyle = style.getTextStyle(style.teamColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: RichText(
              text: TextSpan(
                style: line.trimLeft().startsWith('•')
                    ? highlightStyle
                    : defaultStyle,
                children: _teamSpans(
                  line,
                  teamNames,
                  teamStyle,
                  (segment) => [TextSpan(text: segment)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Part 5: Example text
  static Widget buildExampleText(
    String text,
    HintContentStyle style,
    double linePadding, [
    List<String> teamNames = const [],
  ]) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: _buildExampleLine(line, style, highlightStyle, teamNames),
          ),
      ],
    );
  }

  /// Build single example line (optimized)
  static Widget _buildExampleLine(
    String line,
    HintContentStyle style,
    TextStyle highlightStyle,
    List<String> teamNames,
  ) {
    // Check for TH patterns (most specific first)
    if (line.contains('TH')) {
      final match = _thRegex.firstMatch(line);
      if (match != null) {
        return buildCaseLine(line, style, match, teamNames);
      }
    }

    // Check for win/lose keywords
    final hasWin = line.contains('thắng');
    final hasLose = line.contains('thua');

    if (hasWin || hasLose) {
      return buildResultLine(line, style, teamNames);
    }

    // Default text (still highlight team names)
    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: _teamSpans(
          line,
          teamNames,
          style.getTextStyle(style.teamColor),
          (segment) => [TextSpan(text: segment)],
        ),
      ),
    );
  }

  /// Build case line (TH1, TH2, etc.) - optimized with pre-matched regex
  static Widget buildCaseLine(
    String line,
    HintContentStyle style,
    RegExpMatch match, [
    List<String> teamNames = const [],
  ]) {
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final boldStyle = highlightStyle.copyWith(fontWeight: FontWeight.bold);
    final teamStyle = style.getTextStyle(style.teamColor);

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: [
          if (match.start > 0) TextSpan(text: line.substring(0, match.start)),
          TextSpan(text: match.group(0), style: boldStyle),
          ..._teamSpans(
            line.substring(match.end),
            teamNames,
            teamStyle,
            (segment) => buildResultSpans(segment, style),
          ),
        ],
      ),
    );
  }

  /// Build result line with bullet
  static Widget buildResultLine(
    String line,
    HintContentStyle style, [
    List<String> teamNames = const [],
  ]) {
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final teamStyle = style.getTextStyle(style.teamColor);

    // Remove bullet if present
    final cleanLine = line.trimLeft().startsWith('•')
        ? line.replaceFirst(RegExp(r'^\s*•\s*'), '')
        : line;

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: [
          const TextSpan(text: ' • '),
          ..._teamSpans(
            cleanLine,
            teamNames,
            teamStyle,
            (segment) => buildResultSpans(segment, style),
          ),
        ],
      ),
    );
  }

  /// Build result spans with win/lose highlighting (optimized)
  static List<TextSpan> buildResultSpans(String text, HintContentStyle style) {
    if (text.isEmpty) return const [];

    final defaultStyle = style.getTextStyle(style.defaultColor);
    final spans = <TextSpan>[];
    var pos = 0;

    while (pos < text.length) {
      final remaining = text.substring(pos);
      final winIndex = remaining.indexOf('thắng');
      final loseIndex = remaining.indexOf('thua');

      // Find next keyword
      int nextIndex = -1;
      String keyword = '';
      Color keywordColor = style.defaultColor;

      if (winIndex >= 0 && (loseIndex < 0 || winIndex < loseIndex)) {
        nextIndex = winIndex;
        keyword = 'thắng';
        keywordColor = style.winColor; // Always has default
      } else if (loseIndex >= 0) {
        nextIndex = loseIndex;
        keyword = 'thua';
        keywordColor = style.loseColor; // Always has default
      }

      if (nextIndex < 0) {
        // No more keywords, add remaining text
        if (remaining.isNotEmpty) {
          spans.add(TextSpan(text: remaining, style: defaultStyle));
        }
        break;
      }

      // Add text before keyword
      if (nextIndex > 0) {
        spans.add(
          TextSpan(
            text: remaining.substring(0, nextIndex),
            style: defaultStyle,
          ),
        );
      }

      // Add keyword with bold style
      spans.add(
        TextSpan(
          text: keyword,
          style: style
              .getTextStyle(keywordColor)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );

      pos += nextIndex + keyword.length;
    }

    return spans;
  }
}
