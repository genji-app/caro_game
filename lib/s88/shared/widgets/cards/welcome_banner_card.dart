import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class WelcomeBannerCard extends StatefulWidget {
  final String buttonText;
  final Color color;
  final Color? colorOverlay;
  final Color? borderColor;
  final Widget? childTextContent;
  final Widget Function(bool isHovered)? overlayImageBuilder;
  final VoidCallback? onTap;

  const WelcomeBannerCard({
    super.key,
    required this.buttonText,
    required this.color,
    this.colorOverlay,
    this.borderColor,
    this.childTextContent,
    this.overlayImageBuilder,
    this.onTap,
  });

  @override
  State<WelcomeBannerCard> createState() => _WelcomeBannerCardState();
}

class _WelcomeBannerCardState extends State<WelcomeBannerCard> {
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
                // Content on the left
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.childTextContent ?? const SizedBox.shrink(),
                        // Button
                        ShineButton(
                          text: widget.buttonText,
                          height: 36,
                          onPressed: () => widget.onTap?.call(),
                        ),
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
                          color: widget.borderColor ?? const Color(0xFFFDE272),
                          radius: 16,
                          strokeWidth: 2,
                          progress: value,
                        ),
                      );
                    },
                  ),
                ),

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
