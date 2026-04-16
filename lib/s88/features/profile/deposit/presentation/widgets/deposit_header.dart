import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Header for deposit overlay with title and close button
/// For mobile: includes back button on the left
/// For web/tablet: only title and close button
class DepositHeader extends StatelessWidget {
  final VoidCallback onClose;
  final bool showBackButton;

  const DepositHeader({
    super.key,
    required this.onClose,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(17, 12, 16, 12),
    child: Row(
      children: [
        // Back button (only for mobile)
        if (showBackButton) ...[
          InkWell(
            onTap: onClose,
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
          const Gap(12),
        ],
        // Title
        Expanded(
          child: Text(
            'Nạp tiền',
            style: AppTextStyles.headingXSmall(
              color: AppColors.gray25, // #fffef5
            ),
            textAlign: showBackButton ? TextAlign.start : TextAlign.center,
          ),
        ),
        // Close button
        InkWell(
          onTap: onClose,
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
}
