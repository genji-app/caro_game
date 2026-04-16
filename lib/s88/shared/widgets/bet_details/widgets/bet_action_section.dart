import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class BetActionSection extends ConsumerWidget {
  final bool isMobile;
  final Function(String) onAddAmount;
  final VoidCallback onSetAllIn;

  const BetActionSection({
    super.key,
    this.isMobile = false,
    required this.onAddAmount,
    required this.onSetAllIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = isMobile
        ? MediaQuery.of(context).padding.bottom
        : 0.0;
    final bettingState = ref.watch(bettingPopupProvider);
    final bettingNotifier = ref.read(bettingPopupProvider.notifier);

    // Calculate winnings from provider state
    final winnings = bettingState.calculateWinnings();
    final isLoading = bettingState.isPlacingBet || bettingState.isCalculating;
    final canPlaceBet =
        !isLoading &&
        bettingState.betAmount.isNotEmpty &&
        bettingState.betAmount != '0' &&
        winnings > 0;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ).copyWith(bottom: PlatformUtils.isMobile ? 32 : 12 + bottomPadding),
          decoration: const BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _QuickBetButton(
                      label: '+50K',
                      onTap: () => onAddAmount('50,000'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickBetButton(
                      label: '+500K',
                      onTap: () => onAddAmount('500,000'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickBetButton(
                      label: '+5M',
                      onTap: () => onAddAmount('5,000,000'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickBetButton(
                      label: '+10M',
                      onTap: () => onAddAmount('10,000,000'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickBetButton(label: 'All-in', onTap: onSetAllIn),
                  ),
                ],
              ),
              const Gap(16),
              RepaintBoundary(
                child: SizedBox(
                  width: double.infinity,
                  child: ImageHelper.load(
                    path: AppIcons.hr,
                    width: double.infinity,
                    height: 2,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thanh toán dự kiến',
                          style: AppTextStyles.labelSmall(
                            color: AppColorStyles.contentSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatMoney(winnings),
                              style: AppTextStyles.labelMedium(
                                color: AppColorStyles.contentPrimary,
                              ),
                            ),
                            const Gap(2),
                            const SCoinIcon(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Place bet button with shine effect
                  ShineButton(
                    isEnabled: canPlaceBet,
                    text: 'Đặt cược',
                    style: ShineButtonStyle.primaryYellow,
                    height: 36,
                    onPressed: () => _onPlaceBet(
                      context,
                      ref,
                      canPlaceBet,
                      bettingNotifier,
                      bettingState,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          child: RepaintBoundary(
            child: SizedBox(
              width: double.infinity,
              child: ImageHelper.load(
                path: AppIcons.hr,
                width: double.infinity,
                height: 2,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatMoney(int amount) {
    if (amount == 0) return '0';
    return NumberFormat('#,###').format(amount);
  }

  Future<void> _onPlaceBet(
    BuildContext context,
    WidgetRef ref,
    bool canPlaceBet,
    BettingPopupNotifier bettingNotifier,
    BettingPopupState bettingState,
  ) async {
    if (!canPlaceBet) return;

    final success = await bettingNotifier.placeBet();
    if (!context.mounted) return;

    if (success) {
      // Show success toast and close popup
      AppToast.showSuccess(context, message: 'Đặt cược thành công!');
      ref.read(userProvider.notifier).refreshBalance();
      // Remove this bet from single bets list (if exists)
      final selectionId = bettingState.bettingData?.getSelectionId();
      debugPrint(
        '[BetActionSection] Trying to remove bet with selectionId: $selectionId',
      );
      if (selectionId != null) {
        final parlayState = ref.read(parlayStateProvider);
        final parlayNotifier = ref.read(parlayStateProvider.notifier);
        debugPrint(
          '[BetActionSection] Current singleBets count: ${parlayState.singleBets.length}',
        );
        debugPrint(
          '[BetActionSection] singleBets selectionIds: ${parlayState.singleBets.map((b) => b.selectionId).toList()}',
        );
        final index = parlayState.singleBets.indexWhere(
          (bet) => bet.selectionId == selectionId,
        );
        debugPrint('[BetActionSection] Found bet at index: $index');
        if (index >= 0) {
          parlayNotifier.removeSingleBetAt(index);
          debugPrint(
            '[BetActionSection] Removed bet. New count: ${ref.read(parlayStateProvider).singleBets.length}',
          );
        } else {
          debugPrint(
            '[BetActionSection] WARNING: Bet not found in singleBets!',
          );
        }
      }

      // Popup will close automatically via isClosed state
    } else {
      // Show error toast
      final currentState = ref.read(bettingPopupProvider);
      final errorCode = currentState.errorCode;
      final errorMessage = bettingApiErrorDisplayMessage(
        errorCode,
        serverMessage: currentState.error,
        fallback: bettingApiPlaceBetFailureFallback,
      );
      AppToast.showError(context, message: errorMessage);

      // For non-money errors, remove bet from parlay list
      if (!BettingPopupNotifier.isMoneyRelatedError(errorCode)) {
        final selectionId = bettingState.bettingData?.getSelectionId();
        if (selectionId != null) {
          final parlayState = ref.read(parlayStateProvider);
          final parlayNotifier = ref.read(parlayStateProvider.notifier);
          final index = parlayState.singleBets.indexWhere(
            (bet) => bet.selectionId == selectionId,
          );
          if (index >= 0) {
            parlayNotifier.removeSingleBetAt(index);
            debugPrint(
              '[BetActionSection] Removed bet due to non-money error: $errorCode',
            );
          }
        }
      }

      // Clear error from state so it doesn't show in popup
      bettingNotifier.clearError();
      Navigator.of(context).pop();
    }
  }
}

class _QuickBetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.yellow300.withValues(alpha: 0.08),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.buttonSmall(color: AppColors.yellow300),
        ),
      ),
    ),
  );
}
