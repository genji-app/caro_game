import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_payment_methods_grid_web.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/deposit_payment_method_container_web.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_header.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

/// Deposit overlay widget that displays as a popup dialog for web/tablet
/// Matches Figma design: https://www.figma.com/design/Kmxt5j4aqDHQBPQNOCpuEw/Sun-Sport?node-id=1411-22490
class DepositOverlay extends ConsumerWidget {
  const DepositOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(depositOverlayVisibleProvider);
    final selectedMethod = ref.watch(
      depositSelectionProvider.select((state) => state.selectedMethod),
    );

    // Initialize with codepay selected only if no method is currently selected
    if (isVisible && selectedMethod == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(depositSelectionProvider.notifier)
            .selectPaymentMethod(PaymentMethod.codepay);
      });
    }

    // Don't render if not visible
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(depositOverlayVisibleProvider.notifier).state = false;
            },
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            elevation: 24,
            color: Colors.transparent,
            child: Container(
              width: 640,
              height: 823,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundSecondary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.75),
                    offset: const Offset(-20, 4),
                    blurRadius: 200,
                  ),
                  BoxShadow(
                    offset: const Offset(0, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ],
                border: Border.all(color: AppColors.gray700, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DepositHeader(
                    onClose: () {
                      ref.read(depositOverlayVisibleProvider.notifier).state =
                          false;
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const DepositPaymentMethodsGridWeb(),
                          const SizedBox(height: 40),
                          Expanded(child: DepositPaymentMethodContainerWeb()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
