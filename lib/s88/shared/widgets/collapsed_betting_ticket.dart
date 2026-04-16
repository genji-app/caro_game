import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/screens/parlay_mobile_screen.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Widget hiển thị nút "Phiếu cược" thu gọn với badge
/// Được sử dụng khi bottom navigation collapse
class CollapsedBettingTicket extends ConsumerWidget {
  final VoidCallback? onTap;

  const CollapsedBettingTicket({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch bet counts to show badge
    final singleBetsCount = ref.watch(singleBetsCountProvider);
    final comboBetsCount = ref.watch(comboBetsCountProvider);
    final minMatches = ref.watch(minMatchesProvider);
    // Combo only counts as 1 valid ticket if it has enough matches
    final hasValidCombo = comboBetsCount >= minMatches;
    final totalBetCount = singleBetsCount + (hasValidCombo ? 1 : 0);

    return GestureDetector(
      key: FlyingBetController.instance.collapsedTicketKey,
      onTap: onTap ?? () => _showParlayBottomSheet(context, ref),
      child: InnerShadowCard(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.77327],
              colors: [Color(0xFF1A1A17), Color(0xFF000000)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 8),
                blurRadius: 20,
                color: Color.fromRGBO(0, 0, 0, 0.5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Phiếu cược',
                    style: AppTextStyles.labelXSmall(
                      color: const Color(0xFFFFFEF5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Badge counter
                  if (totalBetCount > 0)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.green200,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        totalBetCount > 99 ? '99+' : totalBetCount.toString(),
                        style: AppTextStyles.labelXSmall(
                          color: AppColors.gray950,
                        ).copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParlayBottomSheet(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAuthenticatedProvider)) {
      AppToast.showError(
        context,
        message: 'Vui lòng đăng nhập để thực hiện hành động này',
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.9,
        widthFactor: 1,
        child: ParlayMobileScreen(),
      ),
    );
  }
}
