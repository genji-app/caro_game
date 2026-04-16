import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class BannerCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final Widget? backgroundImage;
  final Color? backgroundColor;
  final String? amount;

  const BannerCard({
    super.key,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
    this.backgroundImage,
    this.backgroundColor,
    this.amount,
  });

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    child: Container(
      height: 163,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1B1A18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image positioned on the right
          if (backgroundImage != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
                child: backgroundImage,
              ),
            ),
          // Ellipse decoration (if needed, can be added as a separate image)
          // Main content on the left
          Positioned(
            left: 12,
            top: 16,
            bottom: 12,
            right: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sun88 logo
                    if (title == null || title == 'Sun88')
                      SizedBox(
                        height: 16,
                        child: ImageHelper.load(
                          path: AppIcons.sun88,
                          width: 102,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                      )
                    else if (title != null)
                      Text(
                        title!,
                        style: AppTextStyles.displayStyle(
                          color: const Color(0xFFFFD691),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.33,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 122,
                        child: Text(
                          subtitle!,
                          style: AppTextStyles.paragraphXSmall(
                            color: const Color(0xFFFFFCDA),
                          ).copyWith(height: 1.33),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (amount != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        amount!,
                        style: AppTextStyles.headingXSmall(
                          color: Colors.black87,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quà chào mừng',
                        style: AppTextStyles.paragraphXSmall(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
                // Button at the bottom
                if (buttonLabel != null)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0x1EFFD691), // rgba(255,215,145,0.12)
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: onButtonTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        buttonLabel!,
                        style: AppTextStyles.displayStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFD791),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class BannerJoinCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final Widget? backgroundImage;
  final Color? backgroundColor;
  final String? amount;

  const BannerJoinCard({
    super.key,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
    this.backgroundImage,
    this.backgroundColor,
    this.amount,
  });

  @override
  Widget build(BuildContext context) => InnerShadowCard(
    child: Container(
      width: double.infinity,
      height: 163,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1B1A18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background image positioned on the right
          if (backgroundImage != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              left: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: backgroundImage,
              ),
            ),
          // Main content centered
          Padding(
            padding: const EdgeInsets.only(top: 33),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Amount with gradient text
                if (amount != null) ...[
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFCE79), // #ffce79
                        Color(0xFFFFCE79), // #ffce79
                        Color(0xFFFFCE79), // #ffce79
                        Color(0xFFFFCE79), // #ffce79
                        Color(0xFFBB5E1B), // #bb5e1b
                        Color(0xFFBB5E1B), // #bb5e1b
                        Color(0xFFBB5E1B), // #bb5e1b
                      ],
                    ).createShader(bounds),
                    child: Text(
                      amount!,
                      style: AppTextStyles.displayStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900, // Heavy
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // "Quà chào mừng" text
                  Text(
                    'Quà chào mừng',
                    style: AppTextStyles.displayStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600, // Semibold
                      color: const Color(0xFFFFFCDA), // #fffcdb
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ],
            ),
          ),
          // Button at the bottom
          if (buttonLabel != null)
            Positioned(
              bottom: 12,
              child: Container(
                height: 28,

                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1B19), // #1d1b19
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: onButtonTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    buttonLabel!,
                    style: AppTextStyles.displayStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500, // Medium
                      color: const Color(0xFFFFD791), // #ffd791
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
