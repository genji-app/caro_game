import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/border_radius_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class GameBannerProvidersAnimated extends StatefulWidget {
  const GameBannerProvidersAnimated({
    this.buttonText = '',
    this.color = AppColorStyles.backgroundSecondary,
    this.colorOverlay,
    this.borderColor = AppColors.orange400,
    this.onPressed,
    this.overlayImageBuilder,
    super.key,
  });

  final String buttonText;
  final Color color;
  final Color? colorOverlay;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final Widget Function(bool isHovered)? overlayImageBuilder;

  @override
  State<GameBannerProvidersAnimated> createState() =>
      _GameBannerProvidersAnimatedState();
}

class _GameBannerProvidersAnimatedState
    extends State<GameBannerProvidersAnimated> {
  bool _isHovered = false;

  static const _animationDuration = Duration(milliseconds: 300);
  static const _animationCurve = Curves.easeOut;
  static final _borderRadius = AppBorderRadiusStyles.borderRadius400;

  void _handleHover(bool isHovered) {
    if (_isHovered != isHovered) {
      setState(() => _isHovered = isHovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 104, maxWidth: 860),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: InnerShadowCard(
            borderRadius: AppBorderRadiusStyles.radius400,
            child: ClipRRect(
              borderRadius: _borderRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Base Background Color
                  DecoratedBox(decoration: BoxDecoration(color: widget.color)),

                  // 2. Animated Background Pattern
                  AnimatedScale(
                    scale: _isHovered ? 1.05 : 1.0,
                    duration: _animationDuration,
                    curve: _animationCurve,
                    child: ImageHelper.load(
                      path: AppIcons.backgroundS,
                      color: widget.colorOverlay,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 3. Static Background Overlay
                  ImageHelper.load(
                    path: AppIcons.backgroundLight,
                    color: Colors.black.withValues(alpha: 0.5),
                    fit: BoxFit.cover,
                  ),

                  // 4. Animated Interactive Border
                  TweenAnimationBuilder<double>(
                    duration: _animationDuration,
                    curve: _animationCurve,
                    tween: Tween<double>(
                      begin: 0.0,
                      end: _isHovered ? 1.0 : 0.0,
                    ),
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _PartialBorderPainter(
                          color: widget.borderColor ?? const Color(0xFFFDE272),
                          radius: AppBorderRadiusStyles.radius400,
                          strokeWidth: 2,
                          progress: value,
                        ),
                      );
                    },
                  ),

                  // 5. Custom Overlay Content
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

    // --- ENHANCED GRADIENT CONFIGURATION ---
    // Start orange very short (0.05) and make it more visible on hover (opacity lerp)
    final endOpacity =
        0.0 +
        (0.6 * progress); // Base state is very faded on right, grows on hover
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color,
        color.withValues(alpha: endOpacity),
      ],
      stops: const [0.05, 0.95],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Dynamic segments: the border "fills" towards the right
    // Base: Top covers 25%, Bottom covers 25% (or 75% depending on previous version, user likes long lines but short color)
    // Actually, user said 0.75 was better for "long lines", just colors were off.
    final topStartX = w * 0.75 + (w - radius - w * 0.75) * progress;
    final bottomEndX = w * 0.75 + (w - radius - w * 0.75) * progress;

    paint.shader = borderGradient;

    // 1. Top Segment
    final topPath = Path()
      ..moveTo(radius, inset)
      ..lineTo(topStartX, inset);
    canvas.drawPath(topPath, paint);

    // 2. Left C-Shape (Static part)
    final leftPath = Path()
      ..moveTo(radius, inset)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, radius), radius: r),
        -math.pi / 2,
        -math.pi / 2,
        false,
      )
      ..lineTo(inset, h - radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, h - radius), radius: r),
        math.pi,
        -math.pi / 2,
        false,
      );
    canvas.drawPath(leftPath, paint);

    // 3. Bottom Segment
    final bottomPath = Path()
      ..moveTo(radius, h - inset)
      ..lineTo(bottomEndX, h - inset);
    canvas.drawPath(bottomPath, paint);

    // 4. Right Edge / Full Border - Show the rest when hovering
    if (progress > 0) {
      final rightPath = Path()
        ..moveTo(topStartX, inset)
        ..arcTo(
          Rect.fromCircle(center: Offset(w - radius, radius), radius: r),
          -math.pi / 2,
          math.pi / 2,
          false,
        )
        ..lineTo(w - inset, h - radius)
        ..arcTo(
          Rect.fromCircle(center: Offset(w - radius, h - radius), radius: r),
          0,
          math.pi / 2,
          false,
        )
        ..lineTo(bottomEndX, h - inset);

      // Same shader, visibility controlled by shader's endOpacity
      canvas.drawPath(rightPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PartialBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
