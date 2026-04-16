// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart' hide CloseButton;

import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/features/transaction/extensions.dart';
import 'package:co_caro_flame/s88/shared/widgets/texts/currency_text.dart';

import 'transaction_status_badge.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    required this.transaction,
    super.key,
    this.onPressed,
  });

  final Transaction transaction;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.all(12);
    final contentPrimaryColor = AppColorStyles.contentPrimary;
    final contentSecondaryColor = AppColorStyles.contentSecondary;

    final paymentMethod = transaction.paymentMethod;
    final transactionSlipType = transaction.transactionSlipType;

    final slipTypeTxt = transactionSlipType.label;
    final paymentMethodTxt = paymentMethod.label;
    final prefixTxt = transactionSlipType == TransactionSlipType.deposit
        ? '+'
        : '-';

    return Card(
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      child: ListTile(
        minTileHeight: 52,
        onTap: onPressed,
        contentPadding: contentPadding,
        leading: SizedBox.square(
          dimension: 32,
          child: _TransactionSlipTypeIcon(transaction.transactionSlipType),
        ),
        titleTextStyle: AppTextStyles.paragraphSmall(
          color: contentPrimaryColor,
        ),
        title: Row(
          spacing: 24,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints.tightFor(width: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      slipTypeTxt,
                      maxLines: 1,
                      style: AppTextStyles.paragraphSmall(
                        color: contentPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      paymentMethodTxt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.paragraphXSmall(
                        color: contentSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: TransactionStatusBadge(
                statusDescription: transaction.statusDescription,
                status: transaction.transactionStatus,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: CurrencyText.fromNumber(
                transaction.amount,
                prefixText: prefixTxt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(color: contentPrimaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSlipTypeIcon extends StatelessWidget {
  // ignore: unused_element_parameter
  const _TransactionSlipTypeIcon(this.type, {super.key});

  final TransactionSlipType type;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: AppColorStyles.backgroundQuaternary,
    child: SizedBox.square(dimension: 20, child: type.icon),
  );
}

// class TransactionListTile extends StatelessWidget {
//   const TransactionListTile({
//     required this.transaction,
//     super.key,
//     this.onPressed,
//   });

//   final Transaction transaction;
//   final VoidCallback? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     const contentPadding = EdgeInsets.all(12);
//     final contentPrimaryColor = AppColorStyles.contentPrimary;
//     final amountTxt = MoneyFormatter.formatWithCurrency(transaction.amount);

//     final paymentMethod = transaction.paymentMethod;
//     final transactionSlipType = transaction.transactionSlipType;

//     final slipTypeTxt = transactionSlipType.label;
//     final paymentMethodTxt = paymentMethod.label;
//     final titleTxt = '$slipTypeTxt $paymentMethodTxt';

//     return Card(
//       shape: const RoundedRectangleBorder(),
//       elevation: 0,
//       color: Colors.transparent,
//       margin: EdgeInsets.zero,
//       child: ListTile(
//         minTileHeight: 52,
//         onTap: onPressed,
//         contentPadding: contentPadding,
//         leading: SizedBox.square(
//           dimension: 40,
//           child: TransactionSlipTypeIcon(transaction.transactionSlipType),
//         ),
//         title: Text(titleTxt, maxLines: 2, overflow: TextOverflow.ellipsis),
//         titleTextStyle: AppTextStyles.paragraphSmall(
//           color: contentPrimaryColor,
//         ),
//         leadingAndTrailingTextStyle: AppTextStyles.labelSmall(
//           color: contentPrimaryColor,
//         ),
//         trailing: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           spacing: 8,
//           children: [
//             Flexible(
//               child: Text(
//                 amountTxt,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             Flexible(
//               child: TransactionStatusBadge(
//                 statusDescription: transaction.statusDescription,
//                 status: transaction.transactionStatus,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
