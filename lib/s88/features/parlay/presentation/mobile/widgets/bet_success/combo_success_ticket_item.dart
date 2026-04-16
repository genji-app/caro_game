import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';

/// Ticket item for combo bet success view
/// Matches the layout of ParlayStakeSection but in success state
class ComboSuccessTicketItem extends StatelessWidget {
  final List<SingleBetData> selections;
  final double totalOdds;
  final int stake;
  final double potentialWin;

  const ComboSuccessTicketItem({
    super.key,
    required this.selections,
    required this.totalOdds,
    required this.stake,
    required this.potentialWin,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundTertiary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSummaryCard(),
        for (var i = 0; i < selections.length; i++)
          _ComboLegTileSuccess(bet: selections[i]),
        _buildBottomPadding(),
      ],
    ),
  );

  /// Header with success icon and "xN Chân"
  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.green400),
        const Gap(8),
        Expanded(
          child: Text(
            'x${selections.length} Chân',
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ),
      ],
    ),
  );

  /// Summary card with total odds, stake, and potential win
  Widget _buildSummaryCard() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tổng tỷ lệ
        Row(
          children: [
            Expanded(
              child: Text(
                'Tổng tỷ lệ',
                style: AppTextStyles.labelMedium(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
            Text(
              totalOdds.toStringAsFixed(2),
              style: AppTextStyles.labelMedium(color: const Color(0xFFFDE272)),
            ),
          ],
        ),
        const Gap(12),
        // Tổng cược và Tổng thắng (cùng 1 hàng)
        Row(
          children: [
            _buildTotalColumn(
              label: 'Tổng cược',
              value: stake.toDouble(),
              alignment: CrossAxisAlignment.start,
            ),
            Expanded(
              child: _buildTotalColumn(
                label: 'Thanh toán dự kiến',
                value: potentialWin,
                alignment: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildTotalColumn({
    required String label,
    required double value,
    required CrossAxisAlignment alignment,
  }) => Column(
    crossAxisAlignment: alignment,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentSecondary),
      ),
      const Gap(4),
      RichText(
        text: TextSpan(
          style: AppTextStyles.labelMedium(
            color: AppColorStyles.contentSecondary,
          ),
          children: [TextSpan(text: _formatCurrency(value))],
        ),
      ),
      const SCoinIcon(),
    ],
  );

  /// Bottom padding with rounded corners
  Widget _buildBottomPadding() => Container(
    width: double.infinity,
    height: 12,
    decoration: const BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
    ),
  );

  String _formatCurrency(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

/// Success state leg tile (simplified from _ComboLegTile)
class _ComboLegTileSuccess extends StatelessWidget {
  final SingleBetData bet;

  const _ComboLegTileSuccess({required this.bet});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColorStyles.backgroundQuaternary,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(12),
        _buildDivider(),
        const Gap(12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match name
              Row(
                children: [
                  if (bet.isLive) ...[_SuccessDot(), const Gap(8)],
                  Expanded(
                    child: Text(
                      '${bet.eventData.homeName} vs ${bet.eventData.awayName}',
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              // Selection card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bet.marketName,
                            style: AppTextStyles.paragraphMedium(
                              color: AppColorStyles.contentSecondary,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            bet.displayName,
                            style: AppTextStyles.labelMedium(
                              color: AppColorStyles.contentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ImageHelper.load(
                          path: AppIcons.iconInfo,
                          width: 18,
                          height: 18,
                          color: AppColorStyles.contentSecondary,
                        ),
                        const Gap(6),
                        Text(
                          bet.displayOddsString,
                          style: AppTextStyles.labelMedium(
                            color: const Color(0xFFFDE272),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Green success dot for live bets
class _SuccessDot extends StatelessWidget {
  static const _successColor = AppColors.green400;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _successColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

/// Gradient divider line
Widget _buildDivider() => Container(
  width: double.infinity,
  height: 1,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(0.06),
        Colors.white.withOpacity(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ),
  ),
);
