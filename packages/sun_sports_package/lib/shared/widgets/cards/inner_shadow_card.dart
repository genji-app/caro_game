import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Card với "inner shadow" — một vạch sáng mảnh chạy dọc cạnh trên.
///
/// Vạch được vẽ bằng [CustomPainter] (cùng hướng tiếp cận với
/// `_PartialBorderPainter` của `WelcomeBannerCard`) thay cho
/// `BoxShadow(blurStyle: BlurStyle.inner)`: không maskFilter blur, không cấp
/// buffer tạm khi rasterize → rẻ hơn nhiều khi dùng đại trà.
///
/// Đường sáng: đặc ở cạnh trên + 2 góc (top-left, top-right) rồi mờ dần khi
/// lệch xuống một đoạn ngắn ở cạnh trái và cạnh phải — không "dừng cứng" ngay
/// tại góc. Hai cạnh bên dùng chung một hàm vẽ nên đối xứng tuyệt đối.
class InnerShadowCard extends StatelessWidget {
  final double borderRadius;
  final Color? color;

  /// Widget con bên trong
  final Widget child;

  const InnerShadowCard({
    required this.child,
    super.key,
    this.borderRadius = 16,
    this.color,
  });

  /// Màu vạch sáng (trắng 12% — giữ nguyên như BoxShadow cũ).
  static const _highlightColor = Color(0x1FFFFFFF);

  /// Độ dày vạch sáng.
  static const _strokeWidth = 1.0;

  /// Đoạn vạch sáng lệch xuống dọc 2 cạnh trái/phải (px) trước khi mờ hẳn.
  static const _sideExtent = 16.0;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      // Nền (nếu có) — vẽ dưới content.
      if (color != null)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      // Content
      child,
      // Vạch sáng — vẽ ĐÈ lên content nên luôn thấy kể cả khi child đục.
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _InnerShadowHighlightPainter(
              color: _highlightColor,
              radius: borderRadius,
              strokeWidth: _strokeWidth,
              sideExtent: _sideExtent,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Vẽ vạch sáng cạnh trên: đặc ở top + 2 góc, mờ dần khi xuống 2 cạnh bên.
class _InnerShadowHighlightPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double sideExtent;

  _InnerShadowHighlightPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.sideExtent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final inset = strokeWidth / 2;
    final r = math.max(0.0, radius - inset);

    // Điểm kết thúc đoạn lệch xuống 2 cạnh bên, kẹp trong chiều cao card.
    final sideEndY = math.min(radius + sideExtent, h - radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // --- 1. Hai đoạn cạnh bên ---
    // Dùng CHUNG _drawFadeSegment cho trái & phải, chỉ khác toạ độ x → bảo
    // đảm đối xứng tuyệt đối (đặc ở y = radius, mờ hẳn ở y = sideEndY).
    if (sideEndY > radius) {
      _drawFadeSegment(canvas, paint, inset, radius, sideEndY);
      _drawFadeSegment(canvas, paint, w - inset, radius, sideEndY);
    }

    // --- 2. Đoạn đặc: góc top-left + cạnh trên + góc top-right ---
    final topPath = Path()
      ..moveTo(inset, radius)
      // Góc top-left: 180° -> 270° (theo chiều kim đồng hồ)
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, radius), radius: r),
        math.pi,
        math.pi / 2,
        false,
      )
      // Cạnh trên
      ..lineTo(w - radius, inset)
      // Góc top-right: 270° -> 360°
      ..arcTo(
        Rect.fromCircle(center: Offset(w - radius, radius), radius: r),
        -math.pi / 2,
        math.pi / 2,
        false,
      );
    paint
      ..shader = null
      ..color = color;
    canvas.drawPath(topPath, paint);
  }

  /// Vẽ một đoạn dọc tại [x]: đặc tại [solidY], mờ hẳn (alpha 0) tại [fadeY].
  /// Gradient lấy đúng 2 điểm đầu–cuối nên không phụ thuộc bề rộng rect.
  void _drawFadeSegment(
    Canvas canvas,
    Paint paint,
    double x,
    double solidY,
    double fadeY,
  ) {
    paint.shader = ui.Gradient.linear(
      Offset(x, solidY),
      Offset(x, fadeY),
      [color, color.withValues(alpha: 0)],
    );
    canvas.drawPath(
      Path()
        ..moveTo(x, solidY)
        ..lineTo(x, fadeY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_InnerShadowHighlightPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.sideExtent != sideExtent;
}
