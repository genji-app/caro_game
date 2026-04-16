import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_explanation/bet_explanation.dart';
import 'package:co_caro_flame/s88/shared/widgets/dashed_divider_widget.dart';
import 'package:co_caro_flame/s88/shared/widgets/divider/divider.dart';

import 'bet_slip_card_headline.dart';
import 'bet_slip_card_match.dart';
import 'bet_slip_card_payment_footer.dart';

export 'bet_slip_card.dart';
export 'bet_slip_card_headline.dart';
export 'bet_slip_card_match.dart';
export 'bet_slip_card_payment_footer.dart';
export 'bet_slip_card_status_badge.dart';

class BetSlipCard extends StatelessWidget {
  const BetSlipCard({
    required this.bet,
    super.key,
    this.onPressed,
    this.actionButton,
  });

  const BetSlipCard.details(
    this.bet, {
    super.key,
    this.onPressed,
    this.actionButton,
  });

  final BetSlip bet;
  final VoidCallback? onPressed;

  /// Optional action button widget (e.g., resell button, cancel button)
  /// Displayed at the bottom of the card if provided
  final Widget? actionButton;

  /// Build match content for single bet
  Widget _buildSingleMatchContent() {
    return BetSlipCardMatch.fromBetSlip(bet: bet, hintData: bet.toHintData());
  }

  /// Build match content for combo bet (main bet + child bets)
  Widget _buildComboMatchContent() {
    return Column(
      children: [
        // Main bet
        _buildMainBetItem(),

        // Child bets with dividers
        ..._buildChildBetItems(),
      ],
    );
  }

  /// Build main bet item for combo bet
  Widget _buildMainBetItem() {
    return BetSlipCardMatch.fromBetSlip(bet: bet, hintData: bet.toHintData());
  }

  /// Build child bet items with dividers
  List<Widget> _buildChildBetItems() {
    final items = <Widget>[];

    for (final childBet in bet.childBets) {
      items.add(const _DashDivider());
      items.add(
        BetSlipCardMatch.fromChildBet(
          subBet: childBet,
          hintData: childBet.toHintData(),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    // Determine match info content
    final matchContent = bet.isComboBet
        ? _buildComboMatchContent()
        : _buildSingleMatchContent();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: AppColorStyles.backgroundQuaternary,
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HEADER
            BetSlipCardHeadline(
              settlementStatus: bet.settlementStatusEnum,
              betTime: bet.betTime,
            ),

            // 2. MATCH INFO & SELECTION
            const Gap(8),
            matchContent,

            const Gap(16),
            const SunDivider(),
            const Gap(16),

            // 4. PAYMENT FOOTER
            BetSlipCardPaymentFooter(
              stakeAmount: bet.stake,
              payoutAmount: bet.winning,
              isSettled: bet.isSettled,
            ),

            // 5. Action Button
            if (actionButton != null) ...[
              const Gap(12),
              Padding(padding: const EdgeInsets.all(12), child: actionButton),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashDivider extends StatelessWidget {
  const _DashDivider();

  @override
  Widget build(BuildContext context) {
    return const DashedDivider.horizontal(
      height: 20,
      thickness: 4,
      dashGap: 6,
      color: AppColorStyles.backgroundTertiary,
    );
  }
}
