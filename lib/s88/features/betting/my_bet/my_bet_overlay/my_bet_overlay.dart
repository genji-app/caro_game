import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

// Import specific files to avoid circular dependency via betting.dart
import '../my_bet_notifier.dart';
import '../my_bet_providers.dart';

class MyBetOverlayNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;
  void close() => state = false;
  void toggle() => state = !state;
}

/// Side Panel Overlay implementation
class MyBetOverlay extends ConsumerWidget {
  const MyBetOverlay({
    required this.child,
    required this.visibleProvider,
    super.key,
    this.decoration,
    this.constraints = const BoxConstraints.tightFor(width: 430),
  });

  /// The provider that controls the visibility of this overlay.
  /// Defaults to [myBetOverlayVisibleProvider] if null.
  final NotifierProvider<MyBetOverlayNotifier, bool> visibleProvider;

  final Widget child;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve the provider to use (injected or default)
    final provider = visibleProvider;

    final isVisible = ref.watch(provider);
    // final notifier = ref.read(provider.notifier);

    return AnimatedOverlay(
      isVisible: isVisible,
      slideBeginOffset: const Offset(1.0, 0.0), // Slide from Right
      alignment: Alignment.centerRight,
      backdropColor: Colors.transparent,
      // onBackdropTap: notifier.close,
      decoration: decoration,
      constraints: constraints,
      child: child,
    );
  }
}

/// Betting ticket badge widget - separate to isolate provider watching
/// This widget is the target for flying bet animation on desktop
class MyBetOverlayToggleButton extends ConsumerWidget {
  const MyBetOverlayToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the count to minimize rebuilds
    final totalBetCount = ref.watch<int>(
      myBetNotifierProvider.select((MyBetState s) => s.betSlipCount),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(myBetOverlayVisibleProvider.notifier).toggle(),
        borderRadius: BorderRadius.circular(1000),
        child: Container(
          height: 44,
          padding: const EdgeInsets.only(
            left: 8,
            right: 12,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0x0FFFFCDB),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageHelper.load(
                path: AppIcons.icBettingSlip,
                width: 22,
                height: 20,
              ),
              const Gap(9),
              Text(
                I18n.txtBettingSlip,
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xB3FFFCDB),
                ),
              ),
              const Gap(9),
              Container(
                width: 28,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.green300,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Center(
                  child: Text(
                    totalBetCount > 99 ? '99+' : totalBetCount.toString(),
                    style: AppTextStyles.textStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray950,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
