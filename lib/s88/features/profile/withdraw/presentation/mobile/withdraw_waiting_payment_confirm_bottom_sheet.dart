import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/withdraw_waiting_payment_confirm_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Mobile withdraw waiting payment confirmation bottom sheet
class WithdrawMobileWaitingPaymentConfirmBottomSheet
    extends ConsumerStatefulWidget {
  const WithdrawMobileWaitingPaymentConfirmBottomSheet({super.key});

  /// Show the waiting payment confirmation bottom sheet
  static Future<void> show(BuildContext context) => showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        const WithdrawMobileWaitingPaymentConfirmBottomSheet(),
  );

  @override
  ConsumerState<WithdrawMobileWaitingPaymentConfirmBottomSheet> createState() =>
      _WithdrawMobileWaitingPaymentConfirmBottomSheetState();
}

class _WithdrawMobileWaitingPaymentConfirmBottomSheetState
    extends ConsumerState<WithdrawMobileWaitingPaymentConfirmBottomSheet> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint(
        '🟣 [withdraw_mobile_waiting_payment_confirm_bottom_sheet] initState',
      );
    }
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
      // If no confirmation data, close the bottom sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final maxHeight = screenSize.height;

    return Dialog(
      backgroundColor: AppColorStyles.backgroundSecondary,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        width: screenSize.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundSecondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header
              _buildHeader(),
              // Scrollable content
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
              // Bottom button
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title and close button
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        // Title
        Expanded(
          child: Text(
            'Đang chờ xác nhận rút',
            style: AppTextStyles.headingSmall(color: AppColors.gray25),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 12),
        // Close button
        InkWell(
          onTap: () {
            ref.read(withdrawConfirmationDataProvider.notifier).state = null;
            Navigator.of(context).pop();
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

  /// Bottom button
  Widget _buildBottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
    child: ShineButton(
      text: 'Quay lại',
      height: 48,
      size: ShineButtonSize.large,
      width: double.infinity,
      style: ShineButtonStyle.primaryGray,
      onPressed: () {
        ref.read(withdrawConfirmationDataProvider.notifier).state = null;
        Navigator.of(context).pop();
      },
    ),
  );
}
