import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_content.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_service.dart';

/// Hint Styled Content Widget
///
/// Widget that uses StyledText with XML-like markup tags for more
/// flexible and maintainable styling.
///
/// Uses [HintStyledService] to generate pre-tagged content strings.
///
/// Example:
/// ```dart
/// TooltipContainer(
///   child: HintStyledContentWidget(hintData: myHintData),
/// )
/// ```
class HintStyledContentWidget extends StatelessWidget {
  final HintData hintData;

  const HintStyledContentWidget({required this.hintData, super.key});

  @override
  Widget build(BuildContext context) {
    // Generate styled content with tags
    final content = HintStyledService.generateStyledHint(hintData);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - matching HintBubbleWidget style
          Text(
            _getTitle(),
            style: AppTextStyles.labelSmall(color: AppColors.green300),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Content - using new styled content builder
          HintStyledContent.buildContent(content: content, spacing: 12.0),
        ],
      ),
    );
  }

  /// Get title from hint data using MarketHelper
  String _getTitle() {
    final title = MarketHelper.getMarketNameViDisplay(hintData.marketId);
    return _capitalizeFirst(title);
  }

  /// Capitalize only the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
