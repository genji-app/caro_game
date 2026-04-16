import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/deposit_payment_methods_grid_web.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/deposit_payment_method_container_web.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/deposit_header.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

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
        // Backdrop overlay - fill entire screen
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(depositOverlayVisibleProvider.notifier).state = false;
            },
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        // Deposit panel - centered dialog style
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: Container(
              width: 640,
              height: 823,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray950, // #111010
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
                  // Header
                  DepositHeader(
                    onClose: () {
                      ref.read(depositOverlayVisibleProvider.notifier).state =
                          false;
                    },
                  ),
                  // Scrollable content with payment methods grid and container
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          // Payment methods grid (1 row for web/tablet)
                          DepositPaymentMethodsGridWeb(),
                          SizedBox(height: 40),
                          // Payment method specific container (with spaceBetween)
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
