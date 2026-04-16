import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/texts/texts.dart';

// =============================================================================
// BUTTON STATE ENUM
// =============================================================================

/// Represents the current state of the resell button.
enum ResellButtonState { initial, confirming, processing }

// =============================================================================
// NOTIFIER
// =============================================================================

class _ResellButtonNotifier
    extends AutoDisposeFamilyNotifier<ResellButtonState, String> {
  Timer? _timeoutTimer;
  Duration _confirmTimeout = const Duration(seconds: 3);

  @override
  ResellButtonState build(String arg) {
    ref.onDispose(_cancelTimer);
    return ResellButtonState.initial;
  }

  void setConfirmTimeout(Duration timeout) {
    _confirmTimeout = timeout;
  }

  void _cancelTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _startConfirmTimer() {
    _cancelTimer();
    _timeoutTimer = Timer(_confirmTimeout, () {
      if (state == ResellButtonState.confirming) {
        debugPrint('[ResellButton] Confirm timeout - resetting');
        state = ResellButtonState.initial;
      }
    });
  }

  void switchToConfirm() {
    debugPrint('[ResellButton] Switching to confirm mode');
    state = ResellButtonState.confirming;
    _startConfirmTimer();
  }

  void switchToProcessing() {
    debugPrint('[ResellButton] Processing resell');
    _cancelTimer();
    state = ResellButtonState.processing;
  }

  void reset() {
    debugPrint('[ResellButton] Resetting to initial');
    _cancelTimer();
    state = ResellButtonState.initial;
  }

  void onSuccess() {
    debugPrint('[ResellButton] Resell successful');
    _cancelTimer();
    // Keep processing state - button will be hidden when bet is removed
  }
}

final _resellButtonProvider =
    AutoDisposeNotifierProvider.family<
      _ResellButtonNotifier,
      ResellButtonState,
      String
    >(() => _ResellButtonNotifier());

// =============================================================================
// MAIN WIDGET
// =============================================================================

/// Resell button with two-tap confirmation flow.
///
/// ## Flow:
/// 1. User taps "Bán vé" → button changes to "Xác nhận bán"
/// 2. User taps "Xác nhận bán" → triggers [onConfirm] callback
/// 3. If success → button is hidden (bet removed from list)
/// 4. If failure → button resets to initial state
class BetSlipResellButton extends ConsumerStatefulWidget {
  const BetSlipResellButton({
    required this.amount,
    required this.buttonKey,
    super.key,
    this.onConfirm,
    this.size = const Size(double.infinity, 44),
    this.confirmTimeout = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 200),
    this.loadingIndicatorSize = 18.0,
    this.loadingIndicatorStroke = 2.0,
  });

  final num amount;

  /// Unique key to identify this button instance for state management.
  final String buttonKey;

  final Future<bool> Function()? onConfirm;

  /// Button size (width, height). Default is full width with height 44.
  final Size size;

  final Duration confirmTimeout;
  final Duration animationDuration;
  final double loadingIndicatorSize;
  final double loadingIndicatorStroke;

  @override
  ConsumerState<BetSlipResellButton> createState() =>
      _BetSlipResellButtonState();
}

class _BetSlipResellButtonState extends ConsumerState<BetSlipResellButton> {
  @override
  void initState() {
    super.initState();
    // Set timeout after first frame to ensure provider is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(_resellButtonProvider(widget.buttonKey).notifier)
          .setConfirmTimeout(widget.confirmTimeout);
    });
  }

  Future<void> _handleTap() async {
    final notifier = ref.read(_resellButtonProvider(widget.buttonKey).notifier);
    final currentState = ref.read(_resellButtonProvider(widget.buttonKey));

    switch (currentState) {
      case ResellButtonState.initial:
        notifier.switchToConfirm();

      case ResellButtonState.confirming:
        notifier.switchToProcessing();

        final success = await widget.onConfirm?.call() ?? false;

        if (success) {
          notifier.onSuccess();
        } else {
          notifier.reset();
        }

      case ResellButtonState.processing:
        debugPrint('[ResellButton] Ignoring tap - processing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.size,
      child: AnimatedSwitcher(
        duration: widget.animationDuration,
        child: SizedBox.expand(
          child: Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(_resellButtonProvider(widget.buttonKey));

              return switch (state) {
                ResellButtonState.initial => _SellButton(
                  amount: widget.amount,
                  onPressed: _handleTap,
                ),
                ResellButtonState.confirming => _ConfirmButton(
                  amount: widget.amount,
                  onPressed: _handleTap,
                ),
                ResellButtonState.processing => _LoadingButton(
                  indicatorSize: widget.loadingIndicatorSize,
                  indicatorStroke: widget.loadingIndicatorStroke,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BUTTON VARIANTS
// =============================================================================

class _SellButton extends StatelessWidget {
  const _SellButton({required this.amount, required this.onPressed});

  final num amount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand forces button to fill parent size
    return SecondaryButton.yellow(
      key: const ValueKey('resell_sell'),
      onPressed: onPressed,
      size: SecondaryButtonSize.md,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(I18n.txtSellTicket),
          const Text(':'),
          const Gap(6),
          CurrencyText.fromNumber(
            amount,
            spacing: 2,
            suffix: Container(
              margin: const EdgeInsets.only(top: 2),
              child: CurrencyText.defaultSuffix(size: 20),
            ),
            style: AppTextStyles.labelMedium(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.amount, required this.onPressed});

  final num amount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand forces ShineButton to fill parent size
    return SizedBox.expand(
      child: ShineButton(
        key: const ValueKey('resell_confirm'),
        text:
            '${I18n.txtConfirmSellTicket}: ${CurrencyText.formatCurrency(amount)}',
        style: ShineButtonStyle.primaryYellow,
        width: double.infinity,
        onPressed: onPressed,
        trailingIcon: CurrencyText.defaultSuffix(size: 20),
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  const _LoadingButton({
    required this.indicatorSize,
    required this.indicatorStroke,
  });

  final double indicatorSize;
  final double indicatorStroke;

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand forces button to fill parent size
    return SecondaryButton.yellow(
      key: const ValueKey('resell_loading'),
      onPressed: null,
      label: SizedBox.square(
        dimension: indicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: indicatorStroke,
          color: AppColorStyles.contentTertiary,
        ),
      ),
    );
  }
}
