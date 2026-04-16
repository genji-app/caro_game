import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';

class BetSlipCardStatusBadge extends StatelessWidget {
  const BetSlipCardStatusBadge(this.status, {super.key});

  final SettlementStatusEnum status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      color: status.color,
    ),
    child: Text(
      status.label,
      style: AppTextStyles.labelXSmall(
        color: AppColors.gray950,
      ).copyWith(fontWeight: FontWeight.w600, height: 1.50),
    ),
  );
}
