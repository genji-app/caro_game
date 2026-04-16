import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/bet_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class ParlaySummarySection extends StatelessWidget {
  /// Override for placing bet state (for loading button)
  final bool isPlacingBetOverride;

  /// Callback when place bet button is pressed
  final VoidCallback? onPlaceBetPressed;

  const ParlaySummarySection({
    super.key,
    this.isPlacingBetOverride = false,
    this.onPlaceBetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(
        bottom:
            28 +
            (PlatformUtils.isAndroid
                ? MediaQuery.of(context).viewPadding.bottom
                : 0.0),
      ),
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundQuaternary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary rows - only rebuild when totalBet/potentialWin changes
          Consumer(
            builder: (context, ref, _) {
              final totalBet = ref.watch(
                parlayStateProvider.select((s) => s.totalBet),
              );
              return _SummaryRow(label: 'Tổng cược', value: totalBet);
            },
          ),
          const Gap(4),
          Consumer(
            builder: (context, ref, _) {
              final potentialWin = ref.watch(
                parlayStateProvider.select((s) => s.potentialWin),
              );
              return _SummaryRow(
                label: 'Thanh toán dự kiến',
                value: potentialWin,
              );
            },
          ),
          const Gap(12),
          // Action buttons - isolated rebuild
          _ActionButtonsSection(
            isPlacingBetOverride: isPlacingBetOverride,
            onPlaceBetPressed: onPlaceBetPressed,
          ),
          const Gap(4),
          // Listeners for toast/error - no UI, just side effects
          _PlaceBetResultListener(),
          _ErrorListener(),
        ],
      ),
    );
  }
}

/// Listener widget for place bet result - handles toast notifications
class _PlaceBetResultListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PlaceBetResponse?>(
      parlayStateProvider.select((s) => s.lastPlaceBetResult),
      (previous, next) {
        if (previous != next && next != null) {
          if (next.isSuccess) {
            _showSuccessSnackbar(
              context,
              next.message ?? 'Đặt cược thành công!',
            );
          } else {
            _showErrorSnackbar(
              context,
              bettingApiErrorDisplayMessage(
                next.errorCode,
                serverMessage: next.message,
                fallback: bettingApiPlaceBetFailureFallback,
              ),
            );
          }
        }
      },
    );
    return const SizedBox.shrink();
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showSuccess(context, message: message);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    AppToast.showError(context, message: message);
  }
}

/// Listener widget for error handling
class _ErrorListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(parlayErrorProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            AppToast.showError(context, message: next);
          }
          ref.read(parlayStateProvider.notifier).clearError();
        });
      }
    });
    return const SizedBox.shrink();
  }
}

/// Action buttons section with isolated state watching
class _ActionButtonsSection extends ConsumerWidget {
  final bool isPlacingBetOverride;
  final VoidCallback? onPlaceBetPressed;

  const _ActionButtonsSection({
    required this.isPlacingBetOverride,
    this.onPlaceBetPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlacingBet =
        isPlacingBetOverride || ref.watch(isPlacingBetProvider);
    final tab = ref.watch(parlayStateProvider.select((s) => s.tab));

    if (tab == ParlayTab.single) {
      return _SingleTabButtons(
        isPlacingBet: isPlacingBet,
        onPlaceBetPressed: onPlaceBetPressed,
      );
    }

    if (tab == ParlayTab.combo) {
      return _ComboTabButtons(
        isPlacingBet: isPlacingBet,
        onPlaceBetPressed: onPlaceBetPressed,
      );
    }

    // Default buttons for multi tab
    return Consumer(
      builder: (context, ref, _) {
        final canPlaceBet = ref.watch(
          parlayStateProvider.select((s) => s.canPlaceBet),
        );
        return Row(
          children: [
            Expanded(
              child: ShineButton(
                height: 40,
                width: double.infinity,
                text: 'Thêm vào xiên',
                style: ShineButtonStyle.primaryGray,
                onPressed: () {},
              ),
            ),
            const Gap(8),
            Expanded(
              child: ShineButton(
                height: 40,
                width: double.infinity,
                text: 'Đặt cược',
                style: ShineButtonStyle.primaryYellow,
                onPressed: canPlaceBet ? () {} : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Single tab buttons with selective state watching
class _SingleTabButtons extends ConsumerWidget {
  final bool isPlacingBet;
  final VoidCallback? onPlaceBetPressed;

  const _SingleTabButtons({required this.isPlacingBet, this.onPlaceBetPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the fields we need for single bets
    final singleBetsData = ref.watch(
      parlayStateProvider.select(
        (s) => (singleBets: s.singleBets, totalBet: s.totalBet),
      ),
    );

    final validBetsCount = singleBetsData.singleBets
        .where((bet) => bet.canPlaceBet)
        .length;
    final canPlaceSingleBet =
        singleBetsData.singleBets.isNotEmpty && singleBetsData.totalBet > 0;

    return _SingleBetButtons(
      canPlaceBet: canPlaceSingleBet,
      isPlacingBet: isPlacingBet,
      betsCount: validBetsCount,
      singleBetsCount: singleBetsData.singleBets.length,
      onClearAll: () {
        ref.read(parlayStateProvider.notifier).clearAllSingleBets();
      },
      onPlaceBet:
          onPlaceBetPressed ??
          () async {
            final successCount = await ref
                .read(parlayStateProvider.notifier)
                .placeAllSingleBets();
            if (successCount > 0 && context.mounted) {
              if (ref.read(parlayStateProvider).singleBets.isEmpty) {
                Navigator.of(context).pop();
              }
            }
          },
      onAcceptChanges: () {
        ref.read(parlayStateProvider.notifier).acceptOddsChanges();
      },
    );
  }
}

/// Combo tab buttons with selective state watching
class _ComboTabButtons extends ConsumerWidget {
  final bool isPlacingBet;
  final VoidCallback? onPlaceBetPressed;

  const _ComboTabButtons({required this.isPlacingBet, this.onPlaceBetPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the fields we need for combo bets
    final comboData = ref.watch(
      parlayStateProvider.select(
        (s) => (
          canPlaceBet: s.canPlaceBet,
          hasEnoughMatches: s.hasEnoughMatches,
          comboBetsCount: s.comboBets.length,
        ),
      ),
    );

    return _ComboBetButtons(
      canPlaceBet: comboData.canPlaceBet,
      isPlacingBet: isPlacingBet,
      hasEnoughMatches: comboData.hasEnoughMatches,
      comboBetsCount: comboData.comboBetsCount,
      onClearAll: () {
        ref.read(parlayStateProvider.notifier).clearAllComboBets();
      },
      onPlaceBet:
          onPlaceBetPressed ??
          () async {
            final success = await ref
                .read(parlayStateProvider.notifier)
                .placeComboParlay();
            if (success && context.mounted) {
              if (ref.read(parlayStateProvider).comboBets.isEmpty) {
                Navigator.of(context).pop();
              }
            }
          },
      onAcceptChanges: () {
        ref.read(parlayStateProvider.notifier).acceptOddsChanges();
      },
    );
  }
}

/// Combo bet action buttons
class _ComboBetButtons extends StatelessWidget {
  final bool canPlaceBet;
  final bool isPlacingBet;
  final bool hasEnoughMatches;
  final int comboBetsCount;
  // final bool showAcceptChanges;
  final VoidCallback onClearAll;
  final VoidCallback onPlaceBet;
  final VoidCallback onAcceptChanges;

  const _ComboBetButtons({
    required this.canPlaceBet,
    required this.isPlacingBet,
    required this.hasEnoughMatches,
    required this.comboBetsCount,
    // required this.showAcceptChanges,
    required this.onClearAll,
    required this.onPlaceBet,
    required this.onAcceptChanges,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ShineButton(
          height: 40,
          width: double.infinity,
          text: 'Xóa tất cả',
          style: ShineButtonStyle.primaryGray,
          onPressed: comboBetsCount > 0 && !isPlacingBet ? onClearAll : null,
        ),
      ),
      const Gap(8),
      Expanded(
        child: isPlacingBet
            ? _LoadingButton()
            : canPlaceBet
            ? ShineButton(
                height: 40,
                text: 'Đặt cược',
                width: double.infinity,
                style: ShineButtonStyle.primaryYellow,
                onPressed: onPlaceBet,
              )
            : const _DisabledPlaceBetButton(),
      ),
    ],
  );
}

/// Single bet action buttons
class _SingleBetButtons extends StatelessWidget {
  final bool canPlaceBet;
  final bool isPlacingBet;
  final int betsCount;
  final int singleBetsCount;
  // final bool showAcceptChanges;
  final VoidCallback onClearAll;
  final VoidCallback onPlaceBet;
  final VoidCallback onAcceptChanges;

  const _SingleBetButtons({
    required this.canPlaceBet,
    required this.isPlacingBet,
    required this.betsCount,
    required this.singleBetsCount,
    // required this.showAcceptChanges,
    required this.onClearAll,
    required this.onPlaceBet,
    required this.onAcceptChanges,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ShineButton(
          height: 40,
          width: double.infinity,
          text: 'Xóa cược',
          style: ShineButtonStyle.primaryGray,
          onPressed: singleBetsCount > 0 && !isPlacingBet ? onClearAll : null,
        ),
      ),
      const Gap(8),
      Expanded(
        child: isPlacingBet
            ? _LoadingButton()
            : canPlaceBet
            ? ShineButton(
                height: 40,
                text: 'Đặt cược',
                width: double.infinity,
                style: ShineButtonStyle.primaryYellow,
                onPressed: onPlaceBet,
              )
            : const _DisabledPlaceBetButton(),
      ),
    ],
  );
}

/// Disabled place bet button
/// Gray background with tertiary text color
class _DisabledPlaceBetButton extends StatelessWidget {
  const _DisabledPlaceBetButton();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 40,
    decoration: ShapeDecoration(
      color: const Color(0xFF393836),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đặt cược',
          style: AppTextStyles.buttonMedium(
            color: AppColorStyles.contentTertiary,
          ),
        ),
      ],
    ),
  );
}

/// Loading button while placing bet
/// Gray background with circular progress indicator
class _LoadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      color: AppColorStyles.borderPrimary,
      borderRadius: BorderRadius.circular(100),
    ),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColorStyles.contentSecondary,
          ),
        ),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentSecondary),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GoldText(text: _formatCurrency(value)),
          const Gap(4),
          const SCoinIcon(),
        ],
      ),
    ],
  );

  String _formatCurrency(double value) =>
      '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';
}

/// Notification widget showing count of changed odds
/// Based on Figma design: orange background with info icon
class _OddsChangedNotification extends StatelessWidget {
  final int count;

  const _OddsChangedNotification({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0x1FEF6820), // 0.12 opacity = 0x1F
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppColors.orange500, size: 24),
        const Gap(12),
        Text(
          '$count mức cược đã thay đổi',
          style: AppTextStyles.labelMedium(color: AppColors.orange200),
        ),
      ],
    ),
  );
}

class _GoldText extends StatelessWidget {
  final String text;

  const _GoldText({required this.text});

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (Rect bounds) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
    ).createShader(bounds),
    blendMode: BlendMode.srcIn,
    child: Text(text, style: AppTextStyles.labelSmall()),
  );
}
