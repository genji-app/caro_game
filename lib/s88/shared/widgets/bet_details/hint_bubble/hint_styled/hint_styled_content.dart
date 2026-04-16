import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_service.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_tags.dart';

/// Styled Hint Content Builder
///
/// Builds hint content using StyledText with XML-like markup tags.
/// Uses [HintStyledService] to generate pre-tagged content strings.
///
/// Usage:
/// ```dart
/// HintStyledContent.buildContent(
///   content: styledHintContent, // from HintStyledService
/// )
/// ```
class HintStyledContent {
  HintStyledContent._();

  /// Default spacing between content sections
  static const double _defaultSpacing = 12.0;

  /// Build complete hint content widget from pre-tagged StyledHintContent
  static Widget buildContent({
    required StyledHintContent content,
    double spacing = _defaultSpacing,
  }) {
    final tags = HintStyledTags.tags;
    final baseStyle = AppTextStyles.paragraphXSmall(
      color: AppColorStyles.contentPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Part 1: Simple explanation
        StyledText(text: content.simpleText, tags: tags, style: baseStyle),
        SizedBox(height: spacing),

        // Part 2: Info text
        if (content.infoText.isNotEmpty) ...[
          StyledText(text: content.infoText, tags: tags, style: baseStyle),
          SizedBox(height: spacing),
        ],

        // Part 3: Ratio text
        if (content.ratioText.isNotEmpty) ...[
          StyledText(text: content.ratioText, tags: tags, style: baseStyle),
          SizedBox(height: spacing),
        ],

        // Part 4: Result text
        if (content.resultText.isNotEmpty) ...[
          StyledText(text: content.resultText, tags: tags, style: baseStyle),
          SizedBox(height: spacing),
        ],

        // Part 5: Example text
        if (content.exampleText.isNotEmpty)
          StyledText(text: content.exampleText, tags: tags, style: baseStyle),
      ],
    );
  }
}
