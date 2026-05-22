import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:sun_sports/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';

class HandicapSection extends StatelessWidget {
  final BettingPopupData? data;
  final double? currentOdds;
  final int stake;

  const HandicapSection({
    super.key,
    this.data,
    this.currentOdds,
    this.stake = 100,
  });

  @override
  Widget build(BuildContext context) {
    // Early return if no data
    if (data == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColorStyles.backgroundQuaternary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.getMarketNameViDisplay() ?? 'Toàn trận - Kèo chấp',
                  style: AppTextStyles.labelXSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data != null
                      ? '${data!.getTeamName()} (${data!.getSelectedPointsDisplay()})'
                      : '-',
                  style: AppTextStyles.labelMedium(
                    color: AppColorStyles.contentPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Right column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Help circle icon - tappable to show hint bubble
              GestureDetector(
                onTap: () => _showHintBubble(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ImageHelper.load(
                    path: AppIcons.iconInfo,
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getDisplayOdds(),
                style: AppTextStyles.labelMedium(color: AppColors.yellow300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Display odds string, ưu tiên giá trị realtime từ WebSocket (currentOdds)
  /// thay vì giá trị tĩnh ban đầu trong bettingData.
  String _getDisplayOdds() {
    if (data == null) return '-';
    final odds = currentOdds ?? data!.getSelectedOddsValue();
    if (odds <= 0 || odds == -100) return '-';
    return odds.toStringAsFixed(2);
  }

  /// Show hint bubble dialog
  void _showHintBubble(BuildContext context) {
    if (data == null) return;

    final odds = currentOdds ?? data!.getSelectedOddsValue();

    // stake is in VND (int), convert to double for HintData
    final stakeInVND = stake.toDouble();

    final hintData = HintData.fromBettingPopup(
      popupData: data!,
      currentOdds: odds,
      stake: stakeInVND,
    );

    final hintContent = HintService.generateHint(hintData);

    showHintBubble(
      context: context,
      title: data!.getMarketNameViDisplay(),
      content: hintContent,
      ratio: odds,
    );
  }
}
