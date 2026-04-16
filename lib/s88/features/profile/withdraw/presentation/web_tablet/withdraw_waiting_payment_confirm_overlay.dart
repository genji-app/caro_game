import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// Web/tablet overlay for "waiting payment confirmation"
class WithdrawWaitingPaymentConfirmOverlayWeb extends ConsumerStatefulWidget {
  const WithdrawWaitingPaymentConfirmOverlayWeb({super.key});

  @override
  ConsumerState<WithdrawWaitingPaymentConfirmOverlayWeb> createState() =>
      _WithdrawWaitingPaymentConfirmOverlayWebState();
}

class _WithdrawWaitingPaymentConfirmOverlayWebState
    extends ConsumerState<WithdrawWaitingPaymentConfirmOverlayWeb> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Show loading briefly, then display content
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final confirmationData = ref.watch(withdrawConfirmationDataProvider);

    if (confirmationData == null) {
      // If no confirmation data, don't show overlay
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleGoBack,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: InnerShadowCard(
              child: Container(
                width: 640,
                height: 823,
                constraints: BoxConstraints(maxHeight: size.height * 0.9),
                decoration: BoxDecoration(
                  color: AppColors.gray950,
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
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.yellow400,
                                ),
                              )
                            : WithdrawWaitingPaymentConfirmContainer(
                                data: confirmationData,
                              ),
                      ),
                      _buildBottomButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Handle go back - clear confirmation data and close
  void _handleGoBack() {
    if (!mounted) return;
    ref.read(withdrawConfirmationDataProvider.notifier).state = null;
    Navigator.of(context).pop();
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '',
            style: AppTextStyles.headingXSmall(color: AppColors.gray25),
          ),
        ),
        InkWell(
          onTap: () async {
            _handleGoBack();
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
    child: ShineButton(
      text: 'Quay lại',
      height: 48,
      size: ShineButtonSize.large,
      width: double.infinity,
      style: ShineButtonStyle.primaryGray,
      onPressed: () async {
        _handleGoBack();
      },
    ),
  );
}
