import 'package:flutter/material.dart';

import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/texts/texts.dart';

class BetSlipCardPaymentFooter extends StatelessWidget {
  const BetSlipCardPaymentFooter({
    required this.payoutAmount,
    required this.stakeAmount,
    required this.isSettled,
    super.key,
  });

  final num stakeAmount;
  final num payoutAmount;
  final bool isSettled;

  static Widget buildrow(
    BuildContext context, {
    required Widget title,
    Widget? value,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: DefaultTextStyle(
          style: AppTextStyles.paragraphMedium(
            color: AppColorStyles.contentSecondary,
          ),
          child: title,
        ),
      ),
      if (value != null) value,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final payoutLabel = isSettled
        ? I18n.txtPaymentHasBeenMade
        : I18n.txtEstimatedPayout;

    return Container(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 16),
      child: Column(
        children: [
          // Dòng 1: Đặt cược
          buildrow(
            context,
            title: const Text(I18n.txtStake),
            value: CurrencyText.fromNumber(
              stakeAmount,
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),

          // Dòng 2: Thanh toán (Lợi nhuận)
          buildrow(
            context,
            title: Text(payoutLabel),
            value: CurrencyText.fromNumber(
              payoutAmount,
              prefixText: '+',
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
