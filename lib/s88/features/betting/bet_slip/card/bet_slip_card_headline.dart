import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

import 'bet_slip_card_status_badge.dart';

class BetSlipCardHeadline extends StatelessWidget {
  const BetSlipCardHeadline({
    required this.settlementStatus,
    required this.betTime,
    super.key,
  });

  final SettlementStatusEnum settlementStatus;
  final DateTime betTime;

  // --- Date & Time Formats ---
  static const String dateTimeFormat = 'HH:mm - dd/MM/yyyy';
  static String formatTimeTxt(DateTime time) =>
      DateFormat(dateTimeFormat).format(time);

  @override
  Widget build(BuildContext context) {
    final timeTxt = formatTimeTxt(betTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06)),
      child: Row(
        spacing: 8,
        children: [
          if (settlementStatus.isSettled)
            BetSlipCardStatusBadge(settlementStatus),
          Flexible(
            child: DefaultTextStyle(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentSecondary,
              ),
              child: Text(timeTxt),
            ),
          ),
        ],
      ),
    );
  }
}
