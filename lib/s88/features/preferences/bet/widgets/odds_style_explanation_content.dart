import 'package:flutter/material.dart' hide CloseButton;
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

import 'package:co_caro_flame/s88/features/preferences/bet/odds_info.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:styled_text/styled_text.dart';

/// Styled text tag definitions for odds style explanation tooltips
///
/// Provides consistent styling for odds explanation content with tags:
/// - `<title>` - Section headers (Label/Small)
/// - `<odds>` - Odds style names (Malaysia, Hong Kong, etc.) - Green
/// - `<content>` - Formula lines (Paragraph/XSmall)
/// - `<number>` - Odds values only (0.78, -0.78, etc.) - Green
class OddsStyledTextTags {
  OddsStyledTextTags._();

  /// Tags for odds style explanation tooltips
  ///
  /// Usage:
  /// ```dart
  /// StyledText(
  ///   text: '<title>Tỷ lệ cược <odds>Malaysia</odds>:</title>',
  ///   tags: OddsStyledTextTags.tags,
  /// )
  /// ```
  static Map<String, StyledTextTag> get tags => {
    // Title/header for each section (Label/Small style)
    'title': StyledTextTag(
      style: AppTextStyles.labelSmall(color: AppColorStyles.contentPrimary),
    ),

    // Highlight odds style name (Malaysia, Hong Kong, etc.)
    'odds': StyledTextTag(style: const TextStyle(color: AppColors.green300)),

    // Formula/content lines (Paragraph/XSmall style)
    'content': StyledTextTag(
      style: AppTextStyles.paragraphXSmall(
        color: AppColorStyles.contentPrimary,
      ),
    ),

    // Highlight odds numbers only (0.78, -0.78, 1.23, etc.) - NOT money amounts
    'number': StyledTextTag(style: const TextStyle(color: AppColors.green300)),
  };
}

/// Tooltip widget to display odds style information
class OddsStyleExplanationContent extends StatelessWidget {
  const OddsStyleExplanationContent({required this.odds, super.key});

  final OddsStyle odds;

  @override
  Widget build(BuildContext context) {
    // Define base text style
    final baseStyle = AppTextStyles.paragraphXSmall(
      color: AppColorStyles.contentSecondary,
    );

    // Get styled text tags
    final tags = OddsStyledTextTags.tags;

    // Get sections for this odds style
    final sections = odds.sections;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          // Render each section (each section = one card's content)
          ...sections.map((sectionContent) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromRGBO(255, 255, 255, 0.04),
              ),
              child: StyledText(
                text: sectionContent,
                tags: tags,
                style: baseStyle,
              ),
            );
          }),
        ],
      ),
    );
  }
}
