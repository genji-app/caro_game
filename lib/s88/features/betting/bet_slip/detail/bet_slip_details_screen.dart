import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/sb_bottom_navigation_bar.dart';

class BetSlipDetailsScreen extends ConsumerWidget {
  const BetSlipDetailsScreen({required this.slip, super.key});

  final BetSlip slip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 12);
    final resellState = ref.watch(betResellProvider);

    // Derive current bet from initial bet and resell state
    BetSlip currentBet = slip;
    bool canSell = slip.isCashoutAvailable;
    num cashoutAmount = slip.cashOutAbleAmount ?? 0;

    // Update bet based on resell state
    resellState.maybeWhen(
      quoteFetched: (stateBet, quote) {
        if (stateBet.ticketId == slip.ticketId) {
          canSell = quote.isCashoutAvailable;
          cashoutAmount = quote.cashoutAmount?.toDouble() ?? 0;
        }
      },
      success: (stateBet, response) {
        if (stateBet.ticketId == slip.ticketId) {
          currentBet = slip.applyCashout(response);
          canSell = false;
          cashoutAmount = 0;
        }
      },
      orElse: () {},
    );

    // Sell Ticket Button (if available)
    Widget? bottomNavigationBar;
    if (canSell && cashoutAmount > 0) {
      bottomNavigationBar = SBBottomNavigationBar.withDivider(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BetSlipResellButton(
            buttonKey: currentBet.ticketId,
            amount: cashoutAmount,
            onConfirm: () => ref
                .read(betResellControllerProvider)(ref)
                .startResellFlow(context, currentBet),
          ),
        ),
      );
    }

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtBetDetails),
      bottomNavigationBar: bottomNavigationBar,
      bodyPadding: EdgeInsets.zero,
      body: SingleChildScrollView(
        padding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(20),

            // Header info (subtitle and bet ID) - outside AppBar
            _buildHeaderInfo(context, currentBet.ticketId),
            const Gap(12),

            // Bet Information Card
            BetSlipCard.details(currentBet),

            const Gap(12),
          ],
        ),
      ),
    );
  }

  /// Build header info (subtitle and bet ID) - displayed in body
  Widget _buildHeaderInfo(BuildContext context, String id) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Subtitle: "Thể thao - Bóng đá"
        Text(
          I18n.txtSportsFootball,
          style: AppTextStyles.headingXSmall(color: AppColors.gray25),
        ),

        const Gap(8),

        // Bet ID with copy icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Text(
              '${I18n.txtID} $id',
              style: AppTextStyles.labelMedium(color: AppColors.gray25),
            ),
            ClipboradCopyField.iconButton(copyvalue: id),
          ],
        ),
      ],
    ),
  );
}
