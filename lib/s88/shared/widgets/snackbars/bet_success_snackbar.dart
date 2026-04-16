import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/widgets/snackbars/providers/bet_success_snackbar_provider.dart';

class BetSuccessSnackBar extends ConsumerWidget {
  const BetSuccessSnackBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(betSuccessSnackBarProvider);
    final parlayState = ref.watch(parlayStateProvider);

    debugPrint(
      '[BetSuccessSnackBar] build() - isVisible=${state.isVisible}, latestBet=${state.latestBet?.displayName}',
    );

    // Check if there are any valid bets (not disabled)
    final hasValidBets = parlayState.singleBets.any((bet) => !bet.isDisabled);

    if (!state.isVisible || state.latestBet == null) {
      debugPrint('[BetSuccessSnackBar] returning SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    // Hide snackbar if no valid bets remain (all deleted or all disabled/cancelled)
    if (parlayState.singleBets.isEmpty || !hasValidBets) {
      debugPrint(
        '[BetSuccessSnackBar] hiding - no valid bets remain (empty=${parlayState.singleBets.isEmpty}, hasValidBets=$hasValidBets)',
      );
      return const SizedBox.shrink();
    }

    debugPrint('[BetSuccessSnackBar] showing snackbar widget');

    return Container(
      width: double.infinity,
      height: 64, // Estimated height based on design description
      margin: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        // color: const Color(0xFF1A1A1A), // Fallback background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageHelper.load(
                path: AppImages.backgroundBetting,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Icon Success
                ImageHelper.load(
                  path: AppIcons.iconBetSuccess,
                  width: 32,
                  height: 32,
                ),
                const Gap(12),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã thêm kèo vào phiếu cược',
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentPrimary,
                        ),
                      ),
                      const Gap(2),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          debugPrint(
                            '[BetSuccessSnackBar] Xem vé cược đơn tapped',
                          );
                          // Get the latest bet from parlay state
                          final parlayState = ref.read(parlayStateProvider);
                          debugPrint(
                            '[BetSuccessSnackBar] singleBets.length = ${parlayState.singleBets.length}',
                          );
                          if (parlayState.singleBets.isNotEmpty) {
                            final latestBet = parlayState.singleBets.last;
                            debugPrint(
                              '[BetSuccessSnackBar] Opening popup for: ${latestBet.displayName}',
                            );
                            BetDetailsBottomSheet.show(
                              context,
                              data: latestBet.toBettingPopupData(),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Xem vé cược đơn',
                                style: AppTextStyles.labelXSmall(
                                  color: AppColorStyles.contentSecondary,
                                ),
                              ),
                              const Gap(4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColorStyles.contentSecondary,
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close Icon
                GestureDetector(
                  onTap: () {
                    ref.read(betSuccessSnackBarProvider.notifier).hide();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.transparent, // Hit target
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
