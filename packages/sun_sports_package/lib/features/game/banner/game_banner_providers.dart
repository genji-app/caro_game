import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/casino/casino_banners.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';

class GameBannerProviders extends StatelessWidget {
  const GameBannerProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, type) {
        switch (type) {
          case DeviceType.mobile:
            return const _MediumBanner(isMobile: true, onTap: null);
          case DeviceType.tablet:
          case DeviceType.desktop:
          case DeviceType.largeDesktop:
            return const _LargeBanner(isMobile: false, onTap: null);
        }
      },
    );
  }
}

class _MediumBanner extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onTap;
  const _MediumBanner({required this.isMobile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: GameBannerCard(
        buttonText: 'Cược ngay',
        color: AppColorStyles.backgroundSecondary,
        colorOverlay: Colors.grey.withValues(alpha: 0.45),
        borderColor: const Color(0xFFF38744),
        onTap: onTap,
        childTextContent: CardText(
          title: '500+',
          subtitle: 'Casino game',
          titleColor: AppColors.orange400,
          isMobile: isMobile,
        ),
        // Image stretches full width below the text.
        // BoxFit.contain preserves aspect ratio inside the available area;
        // switch to BoxFit.cover if you want to fill the area (with cropping).
        inlineImageBuilder: (_) => ImageHelper.load(
          path: AppImages.imageBannerGame,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _LargeBanner extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onTap;
  const _LargeBanner({required this.isMobile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: GameBannerCard(
        buttonText: 'Cược ngay',
        color: AppColorStyles.backgroundSecondary,
        colorOverlay: Colors.grey.withValues(alpha: 0.45),
        borderColor: const Color(0xFFF38744),
        onTap: onTap,
        childTextContent: CardText(
          title: '500+',
          subtitle: 'Casino game',
          titleColor: AppColors.orange400,
          isMobile: isMobile,
        ),
        overlayImageBuilder: (isHovered) => CardImage(
          path: AppImages.imageBannerGame,
          isMobile: isMobile,
          isHovered: isHovered,
          mobileWidth: 153,
          desktopWidth: 350,
          hoverWidth: 370,
          top: 15,
          right: 0,
        ),
      ),
    );
  }
}

class GameBannerCard extends StatefulWidget {
  final String buttonText;
  final Color color;
  final Color? colorOverlay;
  final Color? borderColor;
  final Widget? childTextContent;

  /// Image rendered as a Stack overlay (must return Positioned/AnimatedPositioned).
  /// Use for floating icons that sit absolutely on top of the card.
  final Widget Function(bool isHovered)? overlayImageBuilder;

  /// Image rendered inline in the Column flow, BELOW the text.
  /// The widget will fill the remaining vertical space and the full card width.
  /// Should return a plain widget (NOT Positioned).
  final Widget Function(bool isHovered)? inlineImageBuilder;

  final VoidCallback? onTap;

  const GameBannerCard({
    required this.buttonText,
    required this.color,
    super.key,
    this.colorOverlay,
    this.borderColor,
    this.childTextContent,
    this.overlayImageBuilder,
    this.inlineImageBuilder,
    this.onTap,
  });

  @override
  State<GameBannerCard> createState() => _GameBannerCardState();
}

class _GameBannerCardState extends State<GameBannerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InnerShadowCard(
          borderRadius: 16,
          child: Container(
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundTertiary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Base color
                  Container(
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: ImageHelper.load(
                          path: AppIcons.backgroundS,
                          color: widget.colorOverlay,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Background image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ImageHelper.load(
                        path: AppIcons.backgroundLight,
                        color: Colors.black.withValues(alpha: 0.5),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Content area — spans full width of the card.
                  // Layout: text on top, optional inline image fills remaining
                  // vertical space at full width.
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0.5,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          widget.childTextContent ?? const SizedBox.shrink(),
                          if (widget.inlineImageBuilder != null) ...[
                            const SizedBox(height: 8),
                            Expanded(
                              child: widget.inlineImageBuilder!(_isHovered),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _isHovered ? 1.0 : 0.0,
                      ),
                      builder: (context, value, child) {
                        return CustomPaint(
                          painter: _PartialBorderPainter(
                            color:
                                widget.borderColor ?? const Color(0xFFFDE272),
                            radius: 16,
                            strokeWidth: 2,
                            progress: value,
                          ),
                        );
                      },
                    ),
                  ),

                  // Image overlay — must be a direct child of Stack
                  // (the builder returns Positioned/AnimatedPositioned).
                  if (widget.overlayImageBuilder != null)
                    widget.overlayImageBuilder!(_isHovered),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PartialBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double progress;

  _PartialBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final inset = strokeWidth / 2;
    final r = radius - inset;

    // Helper: interpolate between transparent and solid color
    final fadeEndColor = Color.lerp(
      color.withValues(alpha: 0),
      color,
      progress,
    )!;

    // 1. Top Fade Segment (Right to Left)
    // Partial Start: 0.75w. Full Target: w - radius.
    final topStartX = w * 0.75 + (w - radius - w * 0.75) * progress;

    final topFadePath = Path();
    topFadePath.moveTo(topStartX, inset);
    topFadePath.lineTo(radius, inset);

    // Gradient:
    // Partial: Solid (Left) -> Transparent (Right)
    // Full: Solid -> Solid (effectively solid line)
    final topGradient = LinearGradient(
      colors: [color, fadeEndColor],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromLTRB(radius, 0, topStartX, strokeWidth * 2));

    paint.shader = topGradient;
    canvas.drawPath(topFadePath, paint);

    // 2. Solid Segment (Left C-Shape)
    final solidPath = Path();
    solidPath.moveTo(radius, inset);
    // Top-Left Corner
    solidPath.arcTo(
      Rect.fromCircle(center: Offset(radius, radius), radius: r),
      -math.pi / 2,
      -math.pi / 2,
      false,
    );
    // Left Edge
    solidPath.lineTo(inset, h - radius);
    // Bottom-Left Corner
    solidPath.arcTo(
      Rect.fromCircle(center: Offset(radius, h - radius), radius: r),
      math.pi,
      -math.pi / 2,
      false,
    );
    // Bottom Edge Solid part (up to 50%)
    solidPath.lineTo(w * 0.5, h - inset);

    paint.shader = null;
    paint.color = color;
    canvas.drawPath(solidPath, paint);

    // 3. Bottom Fade Segment (Left to Right)
    // Partial End: 0.75w. Full Target: w - radius.
    final bottomEndX = w * 0.75 + (w - radius - w * 0.75) * progress;

    final bottomFadePath = Path();
    bottomFadePath.moveTo(w * 0.5, h - inset);
    bottomFadePath.lineTo(bottomEndX, h - inset);

    final bottomGradient = LinearGradient(
      colors: [color, fadeEndColor],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromLTRB(w * 0.5, h - strokeWidth, bottomEndX, h));

    paint.shader = bottomGradient;
    canvas.drawPath(bottomFadePath, paint);

    // 4. Right Side (The Gap)
    // Only draw if we have some progress
    if (progress > 0) {
      final rightPath = Path();
      // Top line end from previous segment
      rightPath.moveTo(topStartX, inset);
      // Top-Right Corner
      rightPath.arcTo(
        Rect.fromCircle(center: Offset(w - radius, radius), radius: r),
        -math.pi / 2,
        math.pi / 2,
        false,
      );
      // Right Edge
      rightPath.lineTo(w - inset, h - radius);
      // Bottom-Right Corner
      rightPath.arcTo(
        Rect.fromCircle(center: Offset(w - radius, h - radius), radius: r),
        0,
        math.pi / 2,
        false,
      );
      // Connect to bottom segment
      rightPath.lineTo(bottomEndX, h - inset);

      paint.shader = null;
      paint.color = color.withValues(alpha: progress);
      canvas.drawPath(rightPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PartialBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
