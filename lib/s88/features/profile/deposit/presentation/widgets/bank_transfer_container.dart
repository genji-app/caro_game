import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/item_account.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/clipboard_utils.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/bank/bank_confirm_money_transfer_bottomsheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/bank/bank_transfer_money_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/bank_confirm_money_transfer_overlay.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/web_tablet/bank_transfer_overlay.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/responsive_enums.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

class BankTransferContainer extends ConsumerStatefulWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;
  final BuildContext parentContext;

  const BankTransferContainer({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
    required this.parentContext,
  });

  @override
  ConsumerState<BankTransferContainer> createState() =>
      _BankTransferContainerState();
}

class _BankTransferContainerState extends ConsumerState<BankTransferContainer> {
  @override
  Widget build(BuildContext context) {
    final bankAccountItem = widget.bankAccountItem;

    if (bankAccountItem.accounts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Text(
                'Ngân hàng này không có tài khoản',
                style: AppTextStyles.labelMedium(color: AppColors.gray300),
              ),
            ),
          ),
        ],
      );
    }

    // Get first account (you can modify this logic if needed)
    final account = bankAccountItem.accounts.first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QR Code section
                _buildQRCodeSection(account: account),
                const SizedBox(height: 24),
                // Bank account details
                _buildBankAccountDetailsSection(
                  bankName: bankAccountItem.name,
                  accountNumber: account.accountNumber,
                  accountName: account.accountName,
                  branch: account.bankBranch,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      children: [
        // Back button
        InkWell(
          onTap: () => DepositNavigator().pop<void>(context),
          child: Container(
            width: 20,
            height: 20,
            color: Colors.transparent,
            child: ImageHelper.load(
              path: AppIcons.icBack,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Title (centered)
        Expanded(
          child: Text(
            'Nạp tiền ngân hàng',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25, // #fffef5
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 32), // Balance space for back button
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

  /// QR Code section
  Widget _buildQRCodeSection({required ItemAccount account}) {
    // Generate QR code data from account information
    // If qrCodeImage contains data string, use it; otherwise generate from accountNumber
    if (account.qrCodeImage.isEmpty) return const SizedBox.shrink();

    final Uint8List strQrcode = base64Decode(account.qrCodeImage);

    // QR Code size - standard size for clear scanning
    const qrSize = 180.0;
    const containerPadding = 16.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(containerPadding),
      child: Column(
        children: [
          // QR Code Container with white background
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray25, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.memory(
                strQrcode,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // QR Code label
          Text(
            'Mã QR tài khoản',
            style: AppTextStyles.textStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray25, // #fffef5
              height: 1.25, // 20px line height for 16px font
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Bank account details section
  Widget _buildBankAccountDetailsSection({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String branch,
  }) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(
        color: AppColors.gray700, // #252423
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Column(
      children: [
        _buildBankDetailRow(
          label: 'Ngân hàng',
          value: bankName,
          valueColor: AppColors.green400, // #3ccb7f
          showCopy: false,
        ),
        _buildBankDetailRow(
          label: 'Tên TK',
          value: accountName,
          showCopy: false,
        ),
        _buildBankDetailRow(
          label: 'Số TK',
          value: accountNumber,
          valueColor: AppColors.green400, // #3ccb7f
          showCopy: true,
          onCopy: () => _copyToClipboard(accountNumber.replaceAll(' ', '')),
        ),
        _buildBankDetailRow(label: 'Chi nhánh', value: branch, showCopy: false),
      ],
    ),
  );

  /// Bank detail row
  Widget _buildBankDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    required bool showCopy,
    VoidCallback? onCopy,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        // Label column
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              color: AppColors.gray300, // #9c9b95
            ),
          ),
        ),
        // Value column
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(
              color: valueColor ?? AppColors.gray25, // #fffef5
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Copy button column
        SizedBox(
          width: 56,
          child: showCopy
              ? Center(child: _buildCopyButton(onCopy ?? () {}))
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  /// Copy button
  Widget _buildCopyButton(VoidCallback onCopy) => SizedBox(
    width: 28,
    height: 28,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: AppColors.gray700, // #252423
        child: InkWell(
          onTap: onCopy,
          child: Center(
            child: ImageHelper.load(
              path: AppIcons.icCopy,
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    ),
  );

  /// Copy to clipboard
  Future<void> _copyToClipboard(String text) async {
    if (!mounted) return;
    await ClipboardUtils.copyToClipboardWithSnackBar(context, text);
  }

  /// Bottom action button
  Widget _buildBottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: AppColors.gray700, // #252423
          width: 0.5,
        ),
      ),
    ),
    child: _buildActionButton(
      text: 'Xác nhận chuyển khoản',
      backgroundColor: AppColors.yellow700, // #a15c07
      textColor: Colors.white,
      onTap: () async {
        final rootContext = Navigator.of(context, rootNavigator: true).context;
        final navigator = DepositNavigator();

        // Use DepositNavigator to track previous dialog (BankTransferOverlay/BottomSheet)
        navigator.push(
          context: rootContext,
          mobileShowMethod: (ctx) => BankConfirmMoneyTransferBottomSheet.show(
            ctx,
            bankAccountItem: widget.bankAccountItem,
            paymentMethod: widget.paymentMethod,
          ),
          webShowMethod: (ctx) => DepositNavigator.showWebDialog<void>(
            context: ctx,
            builder: (dialogContext, animation, secondaryAnimation) {
              return BankConfirmMoneyTransferOverlay(
                bankAccountItem: widget.bankAccountItem,
                paymentMethod: widget.paymentMethod,
              );
            },
          ),
          showPreviousDialog: (rootContext, deviceType) async {
            if (deviceType == DeviceType.mobile) {
              // Show BankTransferMoneyBottomSheet for mobile
              await BankTransferMoneyBottomSheet.show(
                rootContext,
                bankAccountItem: widget.bankAccountItem,
                amount: '',
                paymentMethod: widget.paymentMethod,
              );
            } else {
              // Show BankTransferOverlay for web/tablet
              await DepositNavigator.showWebDialog<void>(
                context: rootContext,
                builder: (dialogContext, animation, secondaryAnimation) =>
                    BankTransferOverlay(
                      bankAccountItem: widget.bankAccountItem,
                      paymentMethod: widget.paymentMethod,
                    ),
              );
            }
          },
        );
      },
    ),
  );

  /// Action button with shine effect
  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) => SizedBox(
    width: double.infinity,
    height: 48,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          // Gradient shine effect (from top to 55.232% as per Figma design)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55232], // Stop at 55.232% as per Figma
                    colors: [
                      Colors.white.withValues(
                        alpha: 0.24,
                      ), // rgba(255,255,255,0.24)
                      Colors.white.withValues(alpha: 0.0), // Transparent
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Text
          Center(
            child: Text(
              text,
              style: AppTextStyles.textStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.5, // 24px line height for 16px font
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
