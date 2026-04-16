import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/currency_helper.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';

/// Balance container widget - dùng chung cho mobile và desktop header
/// Hiển thị balance với gradient text và currency icon
class BalanceContainer extends StatelessWidget {
  final double balance;
  final double? width;
  final EdgeInsets? padding;
  final bool showRefillButton;

  const BalanceContainer({
    required this.balance,
    super.key,
    this.width,
    this.padding,
    this.showRefillButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 219,
      padding:
          padding ??
          const EdgeInsets.only(top: 4, left: 8, right: 4, bottom: 4),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x1EFFE5C0)),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: _BalanceText(balance: balance, showRefillButton: showRefillButton),
    );
  }
}

/// Balance text with gold gradient effect
class _BalanceText extends ConsumerWidget {
  final double balance;
  final bool showRefillButton;

  const _BalanceText({required this.balance, this.showRefillButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Balance text + icon - center trong available space
      // S Coin icon from Figma design - bên trái số tiền.
      const SCoinIcon(),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final balanceText = MoneyFormatter.formatCompact(balance.toInt());

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  balanceText,
                  style: AppTextStyles.textStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
      // Image không có gradient - bên phải
      if (showRefillButton)
        InkWell(
          onTap: () {
            // Fetch deposit data (banks, codepay, etc.) when clicking Nạp
            // Invalidate and trigger fetch immediately
            ref.invalidate(configDepositProvider);
            // Trigger fetch by reading the future
            unawaited(ref.read(configDepositProvider.future));

            final deviceType = ResponsiveBuilder.getDeviceType(context);
            if (deviceType == DeviceType.mobile) {
              // Mobile: Show bottom sheet
              DepositMobileBottomSheet.show(context);
            } else {
              // Close ProfileOverlay and show DepositOverlay
              ProfileNavigation.maybeOf(context)?.close();
              ref.read(depositOverlayVisibleProvider.notifier).state = true;
            }
          },
          child: ImageHelper.getNetworkImage(
            imageUrl: AppImages.btnRefill,
            width: 56,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
    ],
  );
}
