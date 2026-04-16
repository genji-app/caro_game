import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// A customizable dashed divider widget that can be horizontal or vertical
class DashedDivider extends StatelessWidget {
  /// The color of the dashed line
  final Color? color;

  /// The height of the divider (for horizontal) or width (for vertical)
  final double thickness;

  /// The length of each dash
  final double dashLength;

  /// The gap between dashes
  final double dashGap;

  /// Whether the divider is vertical or horizontal
  final Axis direction;

  /// The total height (for horizontal) or width (for vertical) of the widget
  final double? extent;

  const DashedDivider({
    super.key,
    this.color,
    this.thickness = 1,
    this.dashLength = 5,
    this.dashGap = 3,
    this.direction = Axis.horizontal,
    this.extent,
  });

  /// Creates a horizontal dashed divider
  const DashedDivider.horizontal({
    Key? key,
    Color? color,
    double thickness = 1,
    double dashLength = 5,
    double dashGap = 3,
    double? height,
  }) : this(
         key: key,
         color: color,
         thickness: thickness,
         dashLength: dashLength,
         dashGap: dashGap,
         direction: Axis.horizontal,
         extent: height,
       );

  /// Creates a vertical dashed divider
  const DashedDivider.vertical({
    Key? key,
    Color? color,
    double thickness = 1,
    double dashLength = 5,
    double dashGap = 3,
    double? width,
  }) : this(
         key: key,
         color: color,
         thickness: thickness,
         dashLength: dashLength,
         dashGap: dashGap,
         direction: Axis.vertical,
         extent: width,
       );

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? AppColorStyles.borderSecondary;

    return SizedBox(
      height: direction == Axis.horizontal ? (extent ?? thickness) : null,
      width: direction == Axis.vertical ? (extent ?? thickness) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            painter: _DashedLinePainter(
              color: dividerColor,
              thickness: thickness,
              dashLength: dashLength,
              dashGap: dashGap,
              direction: direction,
            ),
            child: SizedBox.expand(),
          );
        },
      ),
    );
  }
}

/// Custom painter for drawing dashed lines
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashLength;
  final double dashGap;
  final Axis direction;

  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashLength,
    required this.dashGap,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final isHorizontal = direction == Axis.horizontal;
    final totalLength = isHorizontal ? size.width : size.height;

    if (totalLength.isInfinite || totalLength <= 0) return;

    final dashPattern = dashLength + dashGap;
    double startPos = 0;

    while (startPos < totalLength) {
      final endPos = (startPos + dashLength).clamp(0.0, totalLength);

      if (isHorizontal) {
        canvas.drawLine(
          Offset(startPos, size.height / 2),
          Offset(endPos, size.height / 2),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(size.width / 2, startPos),
          Offset(size.width / 2, endPos),
          paint,
        );
      }

      startPos += dashPattern;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.direction != direction;
  }
}
