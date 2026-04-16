import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/models/withdraw_payment_method.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Payment method card widget for withdraw overlay
class WithdrawPaymentMethodCard extends StatelessWidget {
  final WithdrawPaymentMethod method;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const WithdrawPaymentMethodCard({
    super.key,
    required this.method,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.gray900,
        border: isSelected
            ? Border.all(
                color: const Color(0xFFF9DBAF).withValues(alpha: 0.2),
                width: 0.5,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            offset: const Offset(0, 0.5),
            blurRadius: 0.5,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: ImageHelper.load(
                path: AppIcons.profileIconSInside,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          if (isSelected)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: ImageHelper.getNetworkImage(
                  imageUrl: AppImages.activatedglow,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 36, height: 36, child: _getPaymentMethodIcon()),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTextStyles.paragraphXSmall(
                    color: isSelected
                        ? const Color(0xFFF9DBAF)
                        : AppColors.gray25,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String _getPaymentMethodIconPath() {
    switch (method) {
      case WithdrawPaymentMethod.bank:
        return AppIcons.icPaymentBank;
      case WithdrawPaymentMethod.scratchCard:
        return AppIcons.icPaymentScratchCard;
      case WithdrawPaymentMethod.crypto:
        return AppIcons.icPaymentCrypto;
    }
  }

  Widget _getPaymentMethodIcon() {
    const iconSize = 36.0;
    return ImageHelper.getSVG(
      path: _getPaymentMethodIconPath(),
      width: iconSize,
      height: iconSize,
    );
  }
}
