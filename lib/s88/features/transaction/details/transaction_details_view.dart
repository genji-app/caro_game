import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/transaction/payment_config/payment_config.dart';
import 'package:co_caro_flame/s88/features/transaction/transaction.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';
import 'package:co_caro_flame/s88/shared/widgets/texts/currency_text.dart';

/// Displays detailed information about a transaction
///
/// Note: Requires [paymentConfigProvider] to be loaded before use.
/// The parent screen should load payment config via:
/// ```dart
/// ref.read(paymentConfigProvider.notifier).loadFromApi(httpManager);
/// ```
class TransactionDetailsView extends ConsumerWidget {
  const TransactionDetailsView(this.transaction, {super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = AppColorStyles.backgroundTertiary;

    final transactionSlipType = transaction.transactionSlipType;
    final displayBank = switch (transactionSlipType) {
      TransactionSlipType.deposit => transaction.bankReceive,
      TransactionSlipType.withdraw => transaction.bankReceive,
      TransactionSlipType.other => transaction.bankReceive,
    };

    final amount = transaction.amount;
    final paymentMethod = transaction.paymentMethod;
    final status = transaction.transactionStatus;
    final accountName = displayBank.accountName;
    final accountNumber = displayBank.accountNumber;
    final date = transaction.date;
    final transferContent = transaction.transactionCode;

    final idTxt = transaction.id.toString();
    final statusTxt = transaction.statusText;
    final dateTxt = DateFormat('HH:mm - dd/MM/yyyy').format(date);
    final paymentMethodTxt = paymentMethod.label;

    // Get payment method info from config provider using bankId
    final bankId = displayBank.bankId;
    final paymentInfo = ref.watch(paymentMethodInfoProvider(bankId));
    final bankNameTxt = paymentInfo?.displayName ?? I18n.txtNotAvailable;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: AppTextStyles.labelSmall(
            color: AppColorStyles.contentTertiary,
          ),
          child: Text(dateTxt),
        ),

        SectionContainer(
          children: [
            SectionRow(
              label: const Text(I18n.txtMethod),
              value: Text(paymentMethodTxt),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              backgoundColor: backgroundColor,
            ),
            const Gap(8),
            SectionRow(
              label: const Text(I18n.txtAmountOfMoney),
              value: CurrencyText.fromNumber(amount),
            ),
            SectionRow(label: const Text(I18n.txtID), value: Text(idTxt)),
            SectionRow(
              label: const Text(I18n.txtStatus),
              value: TransactionStatusBadge(
                statusDescription: statusTxt,
                status: status,
              ),
            ),
            const Gap(8),
          ],
        ),

        // Display bank section
        SectionContainer(
          children: [
            const Gap(8),
            SectionRow(
              label: const Text(I18n.txtBank),
              value: Text(bankNameTxt),
              trailing: const SizedBox.square(dimension: 28),
            ),

            if (accountName != null)
              SectionRow(
                label: const Text(I18n.txtAccountName),
                value: Text(accountName),
                trailing: const SizedBox.square(dimension: 28),
              ),

            if (accountNumber != null)
              SectionRow(
                label: const Text(I18n.txtAccountNumber),
                value: Text(accountNumber),
                trailing: ClipboradCopyField.iconButton(
                  copyvalue: accountNumber,
                ),
              ),

            if (transferContent.isNotEmpty)
              SectionRow(
                label: const Text(I18n.txtContent),
                value: Text(transferContent),
                trailing: ClipboradCopyField.iconButton(
                  copyvalue: transferContent,
                ),
              ),
            const Gap(8),
          ],
        ),
      ],
    );
  }
}

class SectionRow extends StatelessWidget {
  const SectionRow({
    this.label,
    this.value,
    this.trailing,
    this.padding = kPadding,
    this.backgoundColor,
    super.key,
  });

  final Widget? label;
  final Widget? value;
  final Widget? trailing;
  final Color? backgoundColor;
  final EdgeInsetsGeometry? padding;

  static const kPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    color: backgoundColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall(
            color: AppColorStyles.contentSecondary,
          ),
          child: label ?? const SizedBox.shrink(),
        ),

        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              DefaultTextStyle(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
                child: value ?? const SizedBox.shrink(),
              ),

              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    ),
  );
}

class SectionContainer extends StatelessWidget {
  const SectionContainer({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const borderColor = AppColorStyles.borderSecondary;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.5, color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
