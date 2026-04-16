import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/clipboard_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';

/// Layout type for shared "waiting payment confirmation" section
enum WaitingPaymentLayout { mobile, web }

/// Shared content for "Đang chờ xác nhận thanh toán"
/// Used by both DepositMobileWaitingPaymentConfirmBottomSheet (mobile)
/// and DepositWaitingPaymentConfirmOverlayWeb (web/tablet)
///
/// This widget is flexible and can be used for all payment methods:
/// - Bank transfer: bankName, accountName, accountNumber, bankBranch
/// - EWallet/Codepay: walletName/bankName (account details optional)
/// - Crypto: walletAddress, network (optional)
/// - Card/Giftcode: minimal info required
class WaitingPaymentConfirmSection extends StatelessWidget {
  final WaitingPaymentLayout layout;

  // Core payment information (7 main fields)
  final String amount; // Số tiền
  final PaymentMethod paymentMethod; // Phương thức nạp
  final String transactionCode; // ID (transaction code)
  final String bankName; // Ngân hàng
  final String accountName; // Tên tài khoản
  final String accountNumber; // Số tài khoản
  final String note; // Ghi chú

  // Additional optional fields
  final String? bankBranch; // Bank branch (optional)
  final String? walletAddress; // For crypto payments (optional)
  final String? network; // Network name for crypto (optional)

  const WaitingPaymentConfirmSection({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.transactionCode,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.note,
    this.bankBranch,
    this.walletAddress,
    this.network,
    this.layout = WaitingPaymentLayout.mobile,
  });

  factory WaitingPaymentConfirmSection.fromBankAccountItem({
    required BankAccountItem bankAccountItem,
    required String amount,
    required PaymentMethod paymentMethod,
    required String transactionCode,
    String? note,
    WaitingPaymentLayout layout = WaitingPaymentLayout.mobile,
  }) {
    final accounts = bankAccountItem.accounts;
    final firstAccount = accounts.isNotEmpty ? accounts.first : null;

    final extractedAmount = amount;
    final extractedPaymentMethod = paymentMethod;
    final extractedTransactionCode = transactionCode;
    final extractedBankName = bankAccountItem.name;
    final extractedAccountName = firstAccount?.accountName ?? '';
    final extractedAccountNumber = firstAccount?.accountNumber ?? '';
    final extractedNote = note ?? transactionCode;
    final extractedBankBranch = firstAccount?.bankBranch;

    return WaitingPaymentConfirmSection(
      amount: extractedAmount,
      paymentMethod: extractedPaymentMethod,
      transactionCode: extractedTransactionCode,
      bankName: extractedBankName,
      accountName: extractedAccountName,
      accountNumber: extractedAccountNumber,
      note: extractedNote,
      bankBranch: extractedBankBranch,
      layout: layout,
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.codepay:
        return 'Codepay';
      case PaymentMethod.bank:
        return 'Ngân hàng';
      case PaymentMethod.eWallet:
        return 'Ví điện tử';
      case PaymentMethod.crypto:
        return 'Tiền điện tử';
      case PaymentMethod.scratchCard:
        return 'Thẻ cào';
      case PaymentMethod.giftcode:
        return 'Giftcode';
    }
  }

  String _getBankOrWalletLabel() {
    switch (paymentMethod) {
      case PaymentMethod.eWallet:
      case PaymentMethod.codepay:
        return 'Loại ví';
      case PaymentMethod.crypto:
        return 'Loại tiền';
      default:
        return 'Ngân hàng';
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildTitle(),
      const SizedBox(height: 32),
      _buildPaymentInfoCard(context),
      const SizedBox(height: 16),
      _buildTransactionDetailsSection(context),
    ],
  );

  /// Title section
  Widget _buildTitle() => Text(
    'Đang chờ xác nhận thanh toán',
    style: AppTextStyles.headingSmall(color: AppColors.gray25),
  );

  /// Payment info card with header
  Widget _buildPaymentInfoCard(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.gray700, width: 0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Nạp tiền',
                style: AppTextStyles.labelSmall(color: AppColors.green400),
              ),
              const Gap(8),
              Text(
                _getPaymentMethodName(paymentMethod),
                style: AppTextStyles.labelSmall(color: AppColors.gray25),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              _buildPaymentInfoRow(
                label: 'Số tiền',
                value: '$amount',
                showCopy: false,
              ),
              _buildPaymentInfoRow(
                label: 'ID',
                value: transactionCode,
                showCopy: true,
                onCopy: () => _copyToClipboard(context, transactionCode),
                color: AppColors.green400,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildPaymentInfoRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
    Color? color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 79,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(color: color ?? AppColors.gray25),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Visibility(
          visible: label == 'Số tiền',
          child: const Row(children: [Gap(4), SCoinIcon()]),
        ),
        SizedBox(
          width: 56,
          child: showCopy
              ? Center(child: _buildCopyButton(onCopy ?? () {}))
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  /// Transaction details section
  Widget _buildTransactionDetailsSection(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.gray700, width: 0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Column(
      children: [
        // Show appropriate label based on payment method
        _buildTransactionDetailRow(
          label: _getBankOrWalletLabel(),
          value: bankName,
          showCopy: false,
        ),
        // Show network for crypto
        if (paymentMethod == PaymentMethod.crypto && network != null)
          _buildTransactionDetailRow(
            label: 'Network',
            value: network!,
            showCopy: false,
          ),
        // Show wallet address for crypto
        if (paymentMethod == PaymentMethod.crypto && walletAddress != null)
          _buildTransactionDetailRow(
            label: 'Địa chỉ ví',
            value: walletAddress!,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, walletAddress!),
          ),
        // Show account name for bank/ewallet (if not empty)
        if (accountName.isNotEmpty)
          _buildTransactionDetailRow(
            label: 'Tên TK',
            value: accountName,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, accountName),
          ),
        // Show account number for bank/ewallet (if not empty)
        if (accountNumber.isNotEmpty)
          _buildTransactionDetailRow(
            label: 'Số TK',
            value: accountNumber,
            showCopy: true,
            onCopy: () =>
                _copyToClipboard(context, accountNumber.replaceAll(' ', '')),
          ),
        // Show note (ghi chú) if not empty and different from transactionCode
        if (note.isNotEmpty && note != transactionCode)
          _buildTransactionDetailRow(
            label: 'Ghi chú',
            value: note,
            showCopy: true,
            onCopy: () => _copyToClipboard(context, note),
          ),
        // Show bank branch for bank transfer
        if (bankBranch != null)
          _buildTransactionDetailRow(
            label: 'Chi nhánh',
            value: bankBranch!,
            showCopy: false,
          ),
      ],
    ),
  );

  Widget _buildTransactionDetailRow({
    required String label,
    required String value,
    required bool showCopy,
    VoidCallback? onCopy,
    Color? color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.gray300),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelSmall(color: color ?? AppColors.gray25),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 56,
          child: showCopy
              ? Center(child: _buildCopyButton(onCopy ?? () {}))
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  Widget _buildCopyButton(VoidCallback onCopy) => SizedBox(
    width: 28,
    height: 28,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: AppColors.gray700,
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

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await ClipboardUtils.copyToClipboard(context, text);
  }
}
