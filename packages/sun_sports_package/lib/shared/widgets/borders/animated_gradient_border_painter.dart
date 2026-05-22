import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vẽ viền gradient động xoay quanh chu vi bo góc của một widget.
///
/// Dùng `SweepGradient` xoay theo [rotation] (0..1, lặp vô tận từ
/// `AnimationController.repeat()`) để tạo cảm giác dải sáng chạy quanh viền.
/// Hai pass: pass 1 vẽ với [MaskFilter.blur] để tạo glow, pass 2 vẽ sắc nét đè
/// lên trên.
///
/// Cách dùng cùng `AnimatedBuilder` + `CustomPaint`:
/// ```dart
/// AnimatedBuilder(
///   animation: controller,
///   builder: (context, child) => CustomPaint(
///     foregroundPainter: AnimatedGradientBorderPainter(
///       rotation: controller.value,
///       borderRadius: 16,
///       strokeWidth: 1.5,
///       glowBlur: 4,
///       highlight: const Color(0xFFB95100),
///       spark: const Color(0xFFFFFFFF),
///     ),
///     child: child,
///   ),
///   child: yourWidget,
/// );
/// ```
class AnimatedGradientBorderPainter extends CustomPainter {
  AnimatedGradientBorderPainter({
    required this.rotation,
    required this.borderRadius,
    required this.strokeWidth,
    required this.glowBlur,
    required this.highlight,
    required this.spark,
  });

  /// 0..1 — vị trí hiện tại của animation, được nhân với 2π để xoay gradient.
  final double rotation;

  /// Bán kính bo góc của viền, nên trùng với `borderRadius` của widget con.
  final double borderRadius;

  /// Độ dày của viền (đơn vị logical pixel).
  final double strokeWidth;

  /// Độ blur của vầng glow lan ra ngoài viền. Đặt `0` để tắt glow.
  final double glowBlur;

  /// Màu chính chiếm phần lớn dải gradient (thường là tông cùng nền widget).
  final Color highlight;

  /// Màu điểm sáng tương phản chạy nổi bật trên dải gradient.
  final Color spark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    final SweepGradient gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      transform: GradientRotation(rotation * 2 * math.pi),
      colors: <Color>[
        highlight,
        spark,
        highlight,
        spark,
        highlight,
      ],
      stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
    );
    final Shader shader = gradient.createShader(rect);

    if (glowBlur > 0) {
      final Paint glowPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);
      canvas.drawRRect(rrect, glowPaint);
    }

    final Paint borderPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(AnimatedGradientBorderPainter old) {
    return rotation != old.rotation ||
        borderRadius != old.borderRadius ||
        strokeWidth != old.strokeWidth ||
        glowBlur != old.glowBlur ||
        highlight != old.highlight ||
        spark != old.spark;
  }
}
