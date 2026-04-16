import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSimpleText(content.simpleText, style),
        spacingWidget,
        buildInfoText(content.infoText, style, linePadding),
        spacingWidget,
        buildRatioText(
          content.ratioText,
          ratio,
          style,
          linePadding,
          ratioPadding,
        ),
        spacingWidget,
        buildResultText(content.resultText, style, linePadding),
        spacingWidget,
        buildExampleText(content.exampleText, style, linePadding),
      ],
    );
  }

  /// Part 1: Simple text
  static Widget buildSimpleText(String text, HintContentStyle style) {
    return Text(text, style: style.getTextStyle(style.simpleColor));
  }

  /// Part 2: Info text (match info)
  static Widget buildInfoText(
    String text,
    HintContentStyle style,
    double linePadding,
  ) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final textStyle = style.getTextStyle(style.defaultColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: Text(line, style: textStyle),
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
    double linePadding,
  ) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final defaultStyle = style.getTextStyle(style.defaultColor);
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final padding = EdgeInsets.only(bottom: linePadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: padding,
            child: Text(
              line,
              style: line.trimLeft().startsWith('•')
                  ? highlightStyle
                  : defaultStyle,
            ),
          ),
      ],
    );
  }

  /// Part 5: Example text
  static Widget buildExampleText(
    String text,
    HintContentStyle style,
    double linePadding,
  ) {
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
            child: _buildExampleLine(line, style, highlightStyle),
          ),
      ],
    );
  }

  /// Build single example line (optimized)
  static Widget _buildExampleLine(
    String line,
    HintContentStyle style,
    TextStyle highlightStyle,
  ) {
    // Check for TH patterns (most specific first)
    if (line.contains('TH')) {
      final match = _thRegex.firstMatch(line);
      if (match != null) {
        return buildCaseLine(line, style, match);
      }
    }

    // Check for win/lose keywords
    final hasWin = line.contains('thắng');
    final hasLose = line.contains('thua');

    if (hasWin || hasLose) {
      return buildResultLine(line, style);
    }

    // Default text
    return Text(line, style: highlightStyle);
  }

  /// Build case line (TH1, TH2, etc.) - optimized with pre-matched regex
  static Widget buildCaseLine(
    String line,
    HintContentStyle style,
    RegExpMatch match,
  ) {
    final highlightStyle = style.getTextStyle(style.highlightColor);
    final boldStyle = highlightStyle.copyWith(fontWeight: FontWeight.bold);

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: [
          if (match.start > 0) TextSpan(text: line.substring(0, match.start)),
          TextSpan(text: match.group(0), style: boldStyle),
          ...buildResultSpans(line.substring(match.end), style),
        ],
      ),
    );
  }

  /// Build result line with bullet
  static Widget buildResultLine(String line, HintContentStyle style) {
    final highlightStyle = style.getTextStyle(style.highlightColor);

    // Remove bullet if present
    final cleanLine = line.trimLeft().startsWith('•')
        ? line.replaceFirst(RegExp(r'^\s*•\s*'), '')
        : line;

    return RichText(
      text: TextSpan(
        style: highlightStyle,
        children: [
          const TextSpan(text: ' • '),
          ...buildResultSpans(cleanLine, style),
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
