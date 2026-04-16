import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'arrow_position.dart';
import 'internal/arrow_painter.dart';

/// A pre-styled tooltip container with optional arrow pointer.
///
/// This widget provides a consistent tooltip design following the app's
/// design system, with support for customizable arrow positioning.
///
/// ## Features
/// - Rounded corners (12px border radius)
/// - Drop shadow for depth
/// - Optional arrow pointer (15x9px, rounded)
/// - Flexible arrow positioning (13 positions + none)
/// - Auto or manual arrow offset
/// - Customizable width and padding
///
/// ## Basic Usage
/// ```dart
/// TooltipContainer(
///   child: Text('Tooltip content'),
/// )
/// ```
///
/// ## With Arrow
/// ```dart
/// TooltipContainer(
///   arrowPosition: ArrowPosition.topRight,
///   arrowOffset: 16.0,
///   child: Column(
///     children: [
///       Text('Title'),
///       Text('Description'),
///     ],
///   ),
/// )
/// ```
///
/// ## Arrow Positioning
/// ### Auto-calculate (Recommended)
/// Use [OverlayTooltipHelper.calculateArrowOffset] to automatically
/// calculate offset to point at target center:
/// ```dart
/// final offset = OverlayTooltipHelper.calculateArrowOffset(
///   targetKey: iconKey,
///   tooltipWidth: 299,
///   alignment: Alignment.bottomRight,
///   arrowPosition: ArrowPosition.topRight,
/// ) ?? 16.0;
///
/// TooltipContainer(
///   arrowPosition: ArrowPosition.topRight,
///   arrowOffset: offset,
///   child: MyContent(),
/// )
/// ```
///
/// ### Manual
/// Specify a fixed offset value:
/// ```dart
/// TooltipContainer(
///   arrowPosition: ArrowPosition.topLeft,
///   arrowOffset: 20.0, // 20px from left edge
///   child: MyContent(),
/// )
/// ```
///
/// ## Arrow Positions
/// - **Top**: `top`, `topLeft`, `topRight` (arrow points up ▲)
/// - **Bottom**: `bottom`, `bottomLeft`, `bottomRight` (arrow points down ▼)
/// - **Left**: `left`, `leftTop`, `leftBottom` (arrow points left ◄)
/// - **Right**: `right`, `rightTop`, `rightBottom` (arrow points right ►)
/// - **None**: `none` (no arrow)
///
/// ## Styling
/// - Background: `AppColorStyles.backgroundQuaternary`
/// - Border radius: 12px
/// - Shadow: 8px offset, 20px blur, -1px spread
/// - Arrow size: 15x9px (width x height)
///
/// ## See Also
/// - [ArrowPosition] for all arrow position options
/// - [OverlayTooltipHelper] for tooltip lifecycle management
class TooltipContainer extends StatelessWidget {
  /// Creates a tooltip container with optional arrow.
  ///
  /// [child] - The content to display in the tooltip
  /// [width] - Optional fixed width (default: auto)
  /// [padding] - Content padding (default: 16px all sides)
  /// [arrowPosition] - Where to position the arrow (default: top)
  /// [arrowOffset] - Distance from edge to arrow (default: 16px)
  const TooltipContainer({
    required this.child,
    super.key,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.arrowPosition = ArrowPosition.top,
    this.arrowOffset = 16.0,
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final ArrowPosition arrowPosition;
  final double arrowOffset;

  static const double _arrowWidth = 15.0;
  static const double _arrowHeight = 9.0;

  @override
  Widget build(BuildContext context) {
    if (arrowPosition == ArrowPosition.none) {
      return _buildContainer();
    }

    final isHorizontalArrow = _isHorizontalArrow();
    final arrowWidget = _buildArrow();

    // Build container with arrow based on position
    if (isHorizontalArrow) {
      // Left/Right arrows - use Row
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isArrowOnLeft()) ...[
            arrowWidget,
            _buildContainer(),
          ] else ...[
            _buildContainer(),
            arrowWidget,
          ],
        ],
      );
    } else {
      // Top/Bottom arrows - use Column
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _getColumnCrossAlignment(),
        children: [
          if (_isArrowOnBottom()) ...[
            _buildContainer(),
            arrowWidget,
          ] else ...[
            arrowWidget,
            _buildContainer(),
          ],
        ],
      );
    }
  }

  CrossAxisAlignment _getColumnCrossAlignment() {
    if (arrowPosition == ArrowPosition.topRight ||
        arrowPosition == ArrowPosition.bottomRight) {
      return CrossAxisAlignment.end;
    } else if (arrowPosition == ArrowPosition.top ||
        arrowPosition == ArrowPosition.bottom) {
      return CrossAxisAlignment.center;
    }
    return CrossAxisAlignment.start;
  }

  bool _isHorizontalArrow() {
    return arrowPosition == ArrowPosition.left ||
        arrowPosition == ArrowPosition.leftTop ||
        arrowPosition == ArrowPosition.leftBottom ||
        arrowPosition == ArrowPosition.right ||
        arrowPosition == ArrowPosition.rightTop ||
        arrowPosition == ArrowPosition.rightBottom;
  }

  bool _isArrowOnLeft() {
    return arrowPosition == ArrowPosition.left ||
        arrowPosition == ArrowPosition.leftTop ||
        arrowPosition == ArrowPosition.leftBottom;
  }

  bool _isArrowOnBottom() {
    return arrowPosition == ArrowPosition.bottom ||
        arrowPosition == ArrowPosition.bottomLeft ||
        arrowPosition == ArrowPosition.bottomRight;
  }

  EdgeInsets _getArrowEdgeInsets() {
    switch (arrowPosition) {
      case ArrowPosition.top:
      case ArrowPosition.bottom:
        return EdgeInsets.zero; // Center alignment handles it
      case ArrowPosition.topLeft:
      case ArrowPosition.bottomLeft:
        return EdgeInsets.only(left: arrowOffset);
      case ArrowPosition.topRight:
      case ArrowPosition.bottomRight:
        return EdgeInsets.only(right: arrowOffset);
      case ArrowPosition.left:
      case ArrowPosition.right:
        return EdgeInsets.zero; // Center alignment handles it
      case ArrowPosition.leftTop:
      case ArrowPosition.rightTop:
        return EdgeInsets.only(top: arrowOffset);
      case ArrowPosition.leftBottom:
      case ArrowPosition.rightBottom:
        return EdgeInsets.only(bottom: arrowOffset);
      default:
        return EdgeInsets.zero;
    }
  }

  Widget _buildContainer() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.50),
              offset: Offset(0, 8),
              blurRadius: 20,
              spreadRadius: -1,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildArrow() {
    final isHorizontal = _isHorizontalArrow();
    final size = isHorizontal
        ? const Size(_arrowHeight, _arrowWidth) // Swap for horizontal
        : const Size(_arrowWidth, _arrowHeight);

    double rotation = 0.0;

    // Determine rotation based on arrow position
    switch (arrowPosition) {
      case ArrowPosition.top:
      case ArrowPosition.topLeft:
      case ArrowPosition.topRight:
        rotation = 3.14159; // 180° - pointing up
        break;
      case ArrowPosition.bottom:
      case ArrowPosition.bottomLeft:
      case ArrowPosition.bottomRight:
        rotation = 0.0; // 0° - pointing down
        break;
      case ArrowPosition.left:
      case ArrowPosition.leftTop:
      case ArrowPosition.leftBottom:
        rotation = 1.5708; // 90° - pointing left
        break;
      case ArrowPosition.right:
      case ArrowPosition.rightTop:
      case ArrowPosition.rightBottom:
        rotation = -1.5708; // -90° - pointing right
        break;
      default:
        rotation = 0.0;
    }

    return Padding(
      padding: _getArrowEdgeInsets(),
      child: Transform.rotate(
        angle: rotation,
        child: CustomPaint(
          size: size,
          painter: const TooltipArrowPainter(
            color: AppColorStyles.backgroundQuaternary,
          ),
        ),
      ),
    );
  }
}
