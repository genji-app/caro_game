import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/button_enums.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/button_enums.dart';

class ShineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final ShineButtonSize size;
  final bool isExpanded;
  final ShineButtonStyle style;
  final double? height;
  final double? width;
  final bool isEnabled;

  const ShineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = ShineButtonSize.xl,
    this.isExpanded = false,
    this.style = ShineButtonStyle.primaryGray,
    this.height = 48,
    this.width,
    this.isEnabled = true,
  });

  @override
  State<ShineButton> createState() => _ShineButtonState();
}

class _ShineButtonState extends State<ShineButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final padding = _getPadding();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();
    final isEnabled = widget.isEnabled && widget.onPressed != null;

    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: isEnabled ? (_) => setState(() => _isHovering = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovering = false) : null,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled
            ? () => setState(() => _isPressed = false)
            : null,
        child: !isEnabled
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: AppColors.gray700,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leadingIcon != null) ...[
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: widget.leadingIcon,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: AppTextStyles.buttonMedium(
                          color: AppColors.gray500,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: widget.trailingIcon,
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: padding,
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      color: _isPressed
                          ? widget.style.pressedColor
                          : _isHovering
                          ? widget.style.hoverColor
                          : widget.style.defaultColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Opacity(
                      opacity: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leadingIcon != null) ...[
                            SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: widget.leadingIcon,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTextStyles.textStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.trailingIcon != null) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: widget.trailingIcon,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Shine layer using CustomPaint
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _isPressed
                          ? const ShineButtonPressedPainter()
                          : _isHovering
                          ? const ShineButtonHoverPainter()
                          : const ShineButtonDefaultPainter(),
                    ),
                  ),
                  // Content layer (text and icons)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leadingIcon != null) ...[
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: widget.leadingIcon,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: AppTextStyles.buttonMedium(color: Colors.white),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: widget.trailingIcon,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );

    return button;
  }

  EdgeInsets _getPadding() =>
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  double _getFontSize() => 14;

  double _getIconSize() => 20;
}

/// Default state painter - full opacity shine effect
class ShineButtonDefaultPainter extends CustomPainter {
  const ShineButtonDefaultPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Clip to rounded rect
    canvas.save();
    canvas.clipRRect(rrect);

    // Background gradient: linear-gradient(180deg, rgba(255,255,255,0.24) 0%, rgba(255,255,255,0) 55.23%)
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.24),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        stops: [0.0, 0.5523],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);
    canvas.restore();

    // Border with sweep gradient
    const strokeWidth = 1.0;
    final borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth / 2),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2.62 * 2,
        transform: const GradientRotation(
          3.7 * 3 / 4,
        ), // Start from bottom-left
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0), // bottom-left - transparent
          Color.fromRGBO(255, 255, 255, 0.12), // left
          Color.fromRGBO(255, 255, 255, 0.18), // top-left
          Color.fromRGBO(255, 255, 255, 0.24), // top
          Color.fromRGBO(255, 255, 255, 0.18), // top-right
          Color.fromRGBO(255, 255, 255, 0.12), // right
          Color.fromRGBO(0, 0, 0, 0.0), // bottom-right - transparent
          Color.fromRGBO(0, 0, 0, 0.0), // close loop
        ],
        stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hover state painter - 50% opacity of default
class ShineButtonHoverPainter extends CustomPainter {
  const ShineButtonHoverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Clip to rounded rect
    canvas.save();
    canvas.clipRRect(rrect);

    // Background gradient with 50% opacity
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.12), // 0.24 * 0.5
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        stops: [0.0, 0.5523],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);
    canvas.restore();

    // Border with 50% opacity
    const strokeWidth = 1.0;
    final borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth / 2),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2.62 * 2,
        transform: const GradientRotation(3.7 * 3 / 4),
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(255, 255, 255, 0.06), // 0.12 * 0.5
          Color.fromRGBO(255, 255, 255, 0.09), // 0.18 * 0.5
          Color.fromRGBO(255, 255, 255, 0.12), // 0.24 * 0.5
          Color.fromRGBO(255, 255, 255, 0.09),
          Color.fromRGBO(255, 255, 255, 0.06),
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.0),
        ],
        stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pressed state painter - dark border effect
class ShineButtonPressedPainter extends CustomPainter {
  const ShineButtonPressedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Clip to rounded rect
    canvas.save();
    canvas.clipRRect(rrect);

    // No background gradient for pressed state (transparent)
    canvas.restore();

    // Dark border for pressed state
    const strokeWidth = 1.5;
    final borderRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth / 2),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2.62 * 2,
        transform: const GradientRotation(3.7 * 3 / 4),
        colors: const [
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.12),
          Color.fromRGBO(0, 0, 0, 0.18),
          Color.fromRGBO(0, 0, 0, 0.24),
          Color.fromRGBO(0, 0, 0, 0.18),
          Color.fromRGBO(0, 0, 0, 0.12),
          Color.fromRGBO(0, 0, 0, 0.0),
          Color.fromRGBO(0, 0, 0, 0.0),
        ],
        stops: const [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
