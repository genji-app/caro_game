import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/waiting_payment_confirm_section.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';

/// Mobile deposit waiting payment confirmation bottom sheet
class DepositMobileWaitingPaymentConfirmBottomSheet
    extends ConsumerStatefulWidget {
  // 7 required variables
  final String amount; // 1. Số tiền
  final PaymentMethod paymentMethod; // 2. Phương thức nạp
  final String transactionCode; // 3. ID (transaction code)
  final String bankName; // 4. Ngân hàng
  final String accountName; // 5. Tên tài khoản
  final String accountNumber; // 6. Số tài khoản
  final String note; // 7. Ghi chú

  // Optional fields
  final String? bankBranch;

  const DepositMobileWaitingPaymentConfirmBottomSheet({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.transactionCode,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.note,
    this.bankBranch,
  });

  /// Show the waiting payment confirmation bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String amount,
    required PaymentMethod paymentMethod,
    required String transactionCode,
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String note,
    String? bankBranch,
  }) => showGeneralDialog(
    context: context,
    barrierColor: AppColorStyles.backgroundQuaternary,
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
        DepositMobileWaitingPaymentConfirmBottomSheet(
          amount: amount,
          paymentMethod: paymentMethod,
          transactionCode: transactionCode,
          bankName: bankName,
          accountName: accountName,
          accountNumber: accountNumber,
          note: note,
          bankBranch: bankBranch,
        ),
  );

  @override
  ConsumerState<DepositMobileWaitingPaymentConfirmBottomSheet> createState() =>
      _DepositMobileWaitingPaymentConfirmBottomSheetState();
}

class _DepositMobileWaitingPaymentConfirmBottomSheetState
    extends ConsumerState<DepositMobileWaitingPaymentConfirmBottomSheet> {
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
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildWaitingPaymentSection()],
                        ),
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

  /// Build waiting payment section using 7 variables already received
  Widget _buildWaitingPaymentSection() {
    // Use the 7 variables directly - no need to extract from BankAccountItem
    return WaitingPaymentConfirmSection(
      amount: widget.amount,
      paymentMethod: widget.paymentMethod,
      transactionCode: widget.transactionCode,
      bankName: widget.bankName,
      accountName: widget.accountName,
      accountNumber: widget.accountNumber,
      note: widget.note,
      bankBranch: widget.bankBranch,
      layout: WaitingPaymentLayout.mobile,
    );
  }

  /// Header with back button and close button (title is hidden)
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Close button
        InkWell(
          onTap: () => DepositNavigator().closeAll<void>(context),
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
      onPressed: () => DepositNavigator().closeAll<void>(context),
    ),
  );
}
