import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/welcome_banner_card.dart';

/// An adaptive banner section for the Casino feature.
///
/// Consolidates mobile, tablet, and desktop banner implementations into a modular component.
class CasinoBanners extends StatelessWidget {
  const CasinoBanners({
    super.key,
    this.onSun88Pressed,
    this.onCasinoGamePressed,
  });

  final VoidCallback? onSun88Pressed;
  final VoidCallback? onCasinoGamePressed;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final isMobile = deviceType == DeviceType.mobile;

        if (isMobile) {
          return _MobileLayout(
            onSun88Pressed: onSun88Pressed,
            onCasinoGamePressed: onCasinoGamePressed,
          );
        }

        return _TabletDesktopLayout(
          isTablet: deviceType == DeviceType.tablet,
          onSun88Pressed: onSun88Pressed,
          onCasinoGamePressed: onCasinoGamePressed,
        );
      },
    );
  }
}

/// Layout for mobile devices: Horizontal scrollable list.
class _MobileLayout extends StatelessWidget {
  final VoidCallback? onSun88Pressed;
  final VoidCallback? onCasinoGamePressed;

  const _MobileLayout({this.onSun88Pressed, this.onCasinoGamePressed});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            SizedBox(
              width: 320,
              height: 160,
              child: _Sun88Card(isMobile: true, onTap: onSun88Pressed),
            ),
            const Gap(8),
            SizedBox(
              width: 320,
              height: 160,
              child: _CasinoGameCard(
                isMobile: true,
                onTap: onCasinoGamePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layout for tablet and desktop: Fixed-height Row with adaptive spacing.
class _TabletDesktopLayout extends StatelessWidget {
  final bool isTablet;
  final VoidCallback? onSun88Pressed;
  final VoidCallback? onCasinoGamePressed;

  const _TabletDesktopLayout({
    required this.isTablet,
    this.onSun88Pressed,
    this.onCasinoGamePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: EdgeInsets.only(top: isTablet ? 0 : 16),
      child: Row(
        children: [
          Expanded(child: _Sun88Card(isMobile: false, onTap: onSun88Pressed)),
          const Gap(12),
          Expanded(
            child: _CasinoGameCard(isMobile: false, onTap: onCasinoGamePressed),
          ),
        ],
      ),
    );
  }
}

/// Specific card for Sun88 branding.
class _Sun88Card extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onTap;

  const _Sun88Card({required this.isMobile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return WelcomeBannerCard(
      buttonText: 'Cược ngay',
      color: const Color(0xFF111010),
      colorOverlay: AppColors.yellow300.withValues(alpha: 0.45),
      onTap: onTap,
      childTextContent: _CardText(
        title: 'Sun88',
        subtitle: 'Thương hiệu cá cược thể thao của SunWin',
        titleColor: AppColors.yellow500,
        isMobile: isMobile,
      ),
      overlayImageBuilder: (isHovered) => _CardImage(
        path: AppImages.imageBannerSun88,
        isMobile: isMobile,
        isHovered: isHovered,
        mobileWidth: 170,
        desktopWidth: 190,
        hoverWidth: 210,
        top: isMobile ? 5 : -10,
        right: isMobile ? -10 : 20,
        hoverTopOffset: -10,
        hoverRightOffset: -10,
      ),
    );
  }
}

/// Specific card for Casino Game counts.
class _CasinoGameCard extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onTap;

  const _CasinoGameCard({required this.isMobile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return WelcomeBannerCard(
      buttonText: 'Cược ngay',
      color: AppColorStyles.backgroundSecondary,
      colorOverlay: const Color(0xFF86CB3C).withValues(alpha: 0.45),
      borderColor: const Color(0xFF86CB3C),
      onTap: onTap,
      childTextContent: _CardText(
        title: '500+',
        subtitle: 'Casino game',
        titleColor: AppColors.green400,
        isMobile: isMobile,
      ),
      overlayImageBuilder: (isHovered) => _CardImage(
        path: AppImages.imageBannerCasino,
        isMobile: isMobile,
        isHovered: isHovered,
        mobileWidth: 153,
        desktopWidth: 153,
        hoverWidth: 173,
        top: 10,
        right: 0,
      ),
    );
  }
}

/// Reusable widget for the text content within a card.
class _CardText extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final bool isMobile;

  const _CardText({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium(
            color: titleColor,
          ).copyWith(fontWeight: FontWeight.w600, height: 28 / 24),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 157 : 167),
          child: Text(
            subtitle,
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable widget for the floating/animated image within a card.
class _CardImage extends StatelessWidget {
  final String path;
  final bool isMobile;
  final bool isHovered;
  final double mobileWidth;
  final double desktopWidth;
  final double hoverWidth;
  final double top;
  final double right;
  final double hoverTopOffset;
  final double hoverRightOffset;

  const _CardImage({
    required this.path,
    required this.isMobile,
    required this.isHovered,
    required this.mobileWidth,
    required this.desktopWidth,
    required this.hoverWidth,
    required this.top,
    required this.right,
    this.hoverTopOffset = 0,
    this.hoverRightOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Positioned(
        top: top,
        right: right,
        width: mobileWidth,
        child: ImageHelper.load(path: path, fit: BoxFit.contain),
      );
    }
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: isHovered ? top + hoverTopOffset : top,
      right: isHovered ? right + hoverRightOffset : right,
      width: isHovered ? hoverWidth : desktopWidth,
      child: ImageHelper.load(path: path, fit: BoxFit.contain),
    );
  }
}
