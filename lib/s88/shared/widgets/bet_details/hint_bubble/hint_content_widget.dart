import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_content_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_styled/hint_styled_content_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_service.dart';

/// Tooltip content widget for displaying hint information
///
/// This widget displays hint content in a tooltip format, reusing the same
/// rendering logic as HintBubbleWidget via HintContentBuilder.
///
/// Feature flag [useStyledText] controls which implementation is used:
/// - `false` (default): Uses HintContentBuilder with RichText (V1)
/// - `true`: Uses HintStyledContent with StyledText markup (V2)
///
/// Example:
/// ```dart
/// TooltipContainer(
///   child: HintContentWidget(hintData: myHintData),
/// )
/// ```
class HintContentWidget extends StatelessWidget {
  final HintData hintData;

  /// Feature flag to switch between V1 (RichText) and V2 (StyledText)
  /// Set to `true` to enable the new StyledText implementation
  /// Set to `false` to use the legacy RichText implementation (default)
  static const bool useStyledText = true;

  const HintContentWidget({required this.hintData, super.key});

  @override
  Widget build(BuildContext context) {
    // Use V2 (StyledText) if feature flag is enabled
    if (useStyledText) {
      return HintStyledContentWidget(hintData: hintData);
    }

    // V1 (RichText) - Legacy implementation
    return _buildLegacyContent(context);
  }

  /// V1 Implementation: Using HintContentBuilder with RichText
  Widget _buildLegacyContent(BuildContext context) {
    final content = HintService.generateHint(hintData);
    final hintColors = HintContentStyle(
      simpleColor: AppColors.green300,
      defaultColor: AppColorStyles.contentPrimary,
      highlightColor: AppColors.yellow300,
      positiveColor: AppColors.green300,
      negativeColor: AppColors.red500,
      textStyle: AppTextStyles.paragraphXSmall(),
      ratioFontWeight: FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Header - matching HintBubbleWidget style
          Text(
            _getTitle(),
            style: AppTextStyles.labelSmall(color: AppColors.green300),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Content - scrollable, using static builder (optimized)
          HintContentBuilder.buildContent(
            content: content,
            ratio: hintData.ratio,
            spacing: 12.0,
            ratioPadding: 0,
            linePadding: 0,
            style: hintColors,
            useGap: true,
          ),
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
