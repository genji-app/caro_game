import 'package:flutter/material.dart';

/// Custom painter for drawing tooltip arrow with rounded corners.
///
/// This painter creates a triangular arrow shape with smooth, rounded corners
/// matching the Figma design specifications (15x9px).
///
/// The arrow is drawn pointing downward by default (tip at bottom),
/// and can be rotated using [Transform.rotate] to point in other directions.
///
/// ## Features
/// - Rounded corners using quadratic bezier curves
/// - Anti-aliased rendering for smooth edges
/// - Customizable color
/// - Matches Figma SVG design (15x9px)
///
/// ## Internal Use Only
/// This class is used internally by [TooltipContainer] and should not be
/// instantiated directly.
class TooltipArrowPainter extends CustomPainter {
  /// Creates a tooltip arrow painter with the specified [color].
  const TooltipArrowPainter({required this.color});

  /// The fill color of the arrow.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Create path with rounded corners matching Figma SVG
    // Arrow points DOWN (tip at bottom) - base shape
    final path = Path();

    // Start from top-left with curve
    path.moveTo(1.0, 0);

    // Line to top-right
    path.lineTo(size.width - 1.0, 0);

    // Curve at top-right corner
    path.quadraticBezierTo(size.width, 0, size.width - 0.5, 0.5);

    // Line to bottom center (tip)
    path.lineTo(size.width / 2 + 0.5, size.height - 0.3);

    // Curve at tip (bottom center)
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width / 2 - 0.5,
      size.height - 0.3,
    );

    // Line to top-left corner
    path.lineTo(0.5, 0.5);

    // Curve at top-left corner
    path.quadraticBezierTo(0, 0, 1.0, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TooltipArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
