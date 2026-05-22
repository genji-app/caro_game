import 'package:flutter/material.dart';
import 'arrow_position.dart';
import 'internal/animated_overlay_content.dart';
import 'internal/overlay_content.dart';

/// A reusable overlay tooltip controller that manages tooltip lifecycle and positioning.
///
/// This class handles:
/// - Tooltip positioning relative to a target widget
/// - Overlay lifecycle management (show/remove)
/// - Optional smooth animations
/// - Auto-calculation of arrow offset to point at target
///
/// ## Basic Usage
/// ```dart
/// final controller = OverlayTooltipController();
///
/// // Show tooltip
/// controller.show(
///   context: context,
///   targetKey: iconKey,
///   builder: (onClose) => TooltipContainer(
///     child: Text('Tooltip content'),
///   ),
/// );
///
/// // Remove tooltip
/// controller.remove();
/// ```
///
/// ## Advanced Usage with Arrow Offset
/// ```dart
/// // Auto-calculate arrow offset to point at target center
/// final arrowOffset = OverlayTooltipController.calculateArrowOffset(
///   targetKey: iconKey,
///   tooltipWidth: 299,
///   alignment: Alignment.bottomRight,
///   arrowPosition: ArrowPosition.topRight,
/// ) ?? 16.0;
///
/// controller.show(
///   context: context,
///   targetKey: iconKey,
///   alignment: Alignment.bottomRight,
///   builder: (onClose) => TooltipContainer(
///     arrowPosition: ArrowPosition.topRight,
///     arrowOffset: arrowOffset,
///     child: MyContent(),
///   ),
/// );
/// ```
///
/// ## Positioning
/// Use [Alignment] to control tooltip position:
/// - `Alignment.bottomRight`: Below target, right-aligned
/// - `Alignment.bottomLeft`: Below target, left-aligned
/// - `Alignment.topRight`: Above target, right-aligned
/// - `Alignment.topLeft`: Above target, left-aligned
/// - `Alignment.bottomCenter`: Below target, centered
/// - `Alignment.topCenter`: Above target, centered
///
/// ## Animation
/// Enable smooth fade and scale animations:
/// ```dart
/// controller.show(
///   enableAnimation: true, // Default
///   // ...
/// );
/// ```
///
/// ## Root Overlay
/// Use root overlay for consistent positioning across nested overlays:
/// ```dart
/// controller.show(
///   rootOverlay: true, // Default - recommended
///   // ...
/// );
/// ```
class OverlayTooltipController {
  OverlayEntry? _overlayEntry;

  /// Shows a tooltip overlay positioned relative to the target widget.
  ///
  /// [context] - BuildContext to insert overlay
  /// [targetKey] - GlobalKey of the widget to position tooltip relative to
  /// [builder] - Function that builds tooltip content, receives onClose callback and effectiveAlignment
  /// [offset] - Optional offset from the target widget (default: Offset.zero)
  /// [alignment] - How to align the tooltip relative to target (default: Alignment.bottomRight)
  /// [enableAnimation] - Enable fade and scale animations (default: true)
  /// [rootOverlay] - Use root overlay instead of nearest overlay (default: true)
  /// [allowBackgroundInteraction] - Allow interaction with elements behind tooltip (default: false)
  /// [autoPosition] - Automatically choose best position to avoid screen edges (default: false)
  /// [tooltipConstraints] - Size constraints for auto-positioning (default: maxHeight=400, maxWidth=326)
  ///
  /// ## Example - Auto Position with Arrow
  /// ```dart
  /// controller.show(
  ///   context: context,
  ///   targetKey: buttonKey,
  ///   autoPosition: true,
  ///   builder: (onClose, alignment) {
  ///     // Arrow position adapts to alignment
  ///     final arrowPos = alignment == Alignment.topRight
  ///       ? ArrowPosition.bottomRight
  ///       : ArrowPosition.topRight;
  ///
  ///     return TooltipContainer(
  ///       arrowPosition: arrowPos,
  ///       child: Text('Smart tooltip'),
  ///     );
  ///   },
  /// );
  /// ```
  void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required Widget Function(VoidCallback onClose, Alignment effectiveAlignment)
    builder,
    Offset offset = Offset.zero,
    Alignment alignment = Alignment.bottomRight,
    bool enableAnimation = true,
    bool rootOverlay = true,
    bool allowBackgroundInteraction = false,
    bool autoPosition = false,
    BoxConstraints tooltipConstraints = const BoxConstraints(
      maxWidth: 326.0,
      maxHeight: 400.0,
    ),
  }) {
    // Remove existing overlay if any
    remove();

    // Get the position of the target widget
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Auto-detect best alignment if enabled
    final effectiveAlignment = autoPosition
        ? _detectBestAlignment(
            targetPosition: position,
            targetSize: targetSize,
            screenSize: screenSize,
            tooltipConstraints: tooltipConstraints,
          )
        : alignment;

    // Calculate tooltip position based on alignment
    final tooltipPosition = _calculatePosition(
      targetPosition: position,
      targetSize: targetSize,
      screenSize: screenSize,
      offset: offset,
      alignment: effectiveAlignment,
    );

    // Create overlay entry with animation support
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => enableAnimation
          ? AnimatedOverlayTooltipContent(
              top: tooltipPosition.top,
              left: tooltipPosition.left,
              right: tooltipPosition.right,
              bottom: tooltipPosition.bottom,
              alignment: effectiveAlignment,
              onClose: remove,
              allowBackgroundInteraction: allowBackgroundInteraction,
              child: builder(
                remove,
                effectiveAlignment,
              ), // ✅ Pass effectiveAlignment
            )
          : OverlayTooltipContent(
              top: tooltipPosition.top,
              left: tooltipPosition.left,
              right: tooltipPosition.right,
              bottom: tooltipPosition.bottom,
              onClose: remove,
              allowBackgroundInteraction: allowBackgroundInteraction,
              child: builder(
                remove,
                effectiveAlignment,
              ), // ✅ Pass effectiveAlignment
            ),
    );

    Overlay.of(context, rootOverlay: rootOverlay).insert(_overlayEntry!);
  }

  /// Removes the current overlay tooltip.
  ///
  /// Safe to call even if no tooltip is showing.
  void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Checks if tooltip is currently showing.
  bool get isShowing => _overlayEntry != null;

  /// Automatically detect the best alignment for tooltip based on available space.
  ///
  /// This method analyzes the space available in all directions and chooses
  /// the alignment that provides the most room for the tooltip.
  ///
  /// Priority order:
  /// 1. Bottom positions (if space available)
  /// 2. Top positions (if bottom doesn't fit)
  /// 3. Prevent overflow at screen edges
  Alignment _detectBestAlignment({
    required Offset targetPosition,
    required Size targetSize,
    required Size screenSize,
    required BoxConstraints tooltipConstraints,
  }) {
    final tooltipWidth = tooltipConstraints.maxWidth;
    final tooltipHeight = tooltipConstraints.maxHeight;
    const minPadding = 16.0; // Minimum padding from screen edge

    // Calculate available space in each direction
    final spaceAbove = targetPosition.dy;
    final spaceBelow =
        screenSize.height - (targetPosition.dy + targetSize.height);
    final spaceLeft = targetPosition.dx;
    final spaceRight =
        screenSize.width - (targetPosition.dx + targetSize.width);

    // Check if tooltip fits below
    final fitsBelow = spaceBelow >= tooltipHeight + minPadding;

    // Check if tooltip fits above
    final fitsAbove = spaceAbove >= tooltipHeight + minPadding;

    // Helper to check if tooltip would overflow horizontally
    bool wouldOverflowRight(Alignment alignment) {
      if (alignment == Alignment.bottomRight ||
          alignment == Alignment.topRight) {
        // For right-aligned, tooltip right edge aligns with target right edge
        final tooltipRight = targetPosition.dx + targetSize.width;
        final tooltipLeft = tooltipRight - tooltipWidth;
        return tooltipLeft < minPadding; // Would overflow left edge
      }
      return false;
    }

    bool wouldOverflowLeft(Alignment alignment) {
      if (alignment == Alignment.bottomLeft || alignment == Alignment.topLeft) {
        // For left-aligned, tooltip left edge aligns with target left edge
        final tooltipLeft = targetPosition.dx;
        final tooltipRight = tooltipLeft + tooltipWidth;
        return tooltipRight >
            screenSize.width - minPadding; // Would overflow right edge
      }
      return false;
    }

    // Prefer bottom positions if there's enough space
    if (fitsBelow) {
      // Try right alignment first
      if (!wouldOverflowRight(Alignment.bottomRight)) {
        return Alignment.bottomRight;
      }
      // Try left alignment
      if (!wouldOverflowLeft(Alignment.bottomLeft)) {
        return Alignment.bottomLeft;
      }
      // Fallback to center
      return Alignment.bottomCenter;
    }

    // If doesn't fit below, try above
    if (fitsAbove) {
      // Try right alignment first
      if (!wouldOverflowRight(Alignment.topRight)) {
        return Alignment.topRight;
      }
      // Try left alignment
      if (!wouldOverflowLeft(Alignment.topLeft)) {
        return Alignment.topLeft;
      }
      // Fallback to center
      return Alignment.topCenter;
    }

    // Fallback: Use the side with most space
    if (spaceBelow >= spaceAbove) {
      return spaceRight >= spaceLeft
          ? Alignment.bottomRight
          : Alignment.bottomLeft;
    } else {
      return spaceRight >= spaceLeft ? Alignment.topRight : Alignment.topLeft;
    }
  }

  _TooltipPosition _calculatePosition({
    required Offset targetPosition,
    required Size targetSize,
    required Size screenSize,
    required Offset offset,
    required Alignment alignment,
  }) {
    double? top, left, right, bottom;

    // Map Flutter Alignment to tooltip positioning
    if (alignment == Alignment.bottomRight) {
      top = targetPosition.dy + targetSize.height + offset.dy;
      right =
          screenSize.width - targetPosition.dx - targetSize.width + offset.dx;
    } else if (alignment == Alignment.bottomLeft) {
      top = targetPosition.dy + targetSize.height + offset.dy;
      left = targetPosition.dx + offset.dx;
    } else if (alignment == Alignment.topRight) {
      bottom = screenSize.height - targetPosition.dy + offset.dy;
      right =
          screenSize.width - targetPosition.dx - targetSize.width + offset.dx;
    } else if (alignment == Alignment.topLeft) {
      bottom = screenSize.height - targetPosition.dy + offset.dy;
      left = targetPosition.dx + offset.dx;
    } else if (alignment == Alignment.bottomCenter) {
      top = targetPosition.dy + targetSize.height + offset.dy;
      left = targetPosition.dx + (targetSize.width / 2) + offset.dx;
    } else if (alignment == Alignment.topCenter) {
      bottom = screenSize.height - targetPosition.dy + offset.dy;
      left = targetPosition.dx + (targetSize.width / 2) + offset.dx;
    } else {
      // Default to bottomRight for any other alignment
      top = targetPosition.dy + targetSize.height + offset.dy;
      right =
          screenSize.width - targetPosition.dx - targetSize.width + offset.dx;
    }

    return _TooltipPosition(top: top, left: left, right: right, bottom: bottom);
  }

  /// Calculate arrow offset to point at the center of target widget.
  ///
  /// This helper method automatically calculates the arrow offset needed
  /// to make the arrow point precisely at the center of the target widget.
  ///
  /// [targetKey] - GlobalKey of the target widget
  /// [tooltipWidth] - Width of the tooltip
  /// [alignment] - Tooltip alignment (used for calculation method)
  /// [arrowPosition] - Arrow position on tooltip
  ///
  /// Returns the calculated offset, or null if calculation fails.
  ///
  /// ## Supported Arrow Positions
  /// - `topRight` / `bottomRight`: Calculates from right edge
  /// - `topLeft` / `bottomLeft`: Calculates from left edge
  /// - `top` / `bottom`: Returns 0 (center alignment handles it)
  /// - Other positions: Returns null (use manual offset)
  ///
  /// ## Example
  /// ```dart
  /// final offset = OverlayTooltipController.calculateArrowOffset(
  ///   targetKey: iconKey,
  ///   tooltipWidth: 299,
  ///   alignment: Alignment.bottomRight,
  ///   arrowPosition: ArrowPosition.topRight,
  /// ) ?? 16.0; // Fallback to default
  /// ```
  static double? calculateArrowOffset({
    required GlobalKey targetKey,
    required double tooltipWidth,
    required Alignment alignment,
    required ArrowPosition arrowPosition,
  }) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return null;

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final targetCenterX = targetPosition.dx + (targetSize.width / 2);

    // Calculate based on arrow position
    if (arrowPosition == ArrowPosition.topRight ||
        arrowPosition == ArrowPosition.bottomRight) {
      // For right-aligned arrows
      // Tooltip right edge aligns with target right edge (bottomRight alignment)
      final tooltipRight = targetPosition.dx + targetSize.width;
      final offset = tooltipRight - targetCenterX;
      return offset.clamp(8.0, tooltipWidth - 20.0);
    } else if (arrowPosition == ArrowPosition.topLeft ||
        arrowPosition == ArrowPosition.bottomLeft) {
      // For left-aligned arrows
      final tooltipLeft = targetPosition.dx;
      final offset = targetCenterX - tooltipLeft;
      return offset.clamp(8.0, tooltipWidth - 20.0);
    } else if (arrowPosition == ArrowPosition.top ||
        arrowPosition == ArrowPosition.bottom) {
      // For center arrows - no offset needed (alignment handles it)
      return 0.0;
    }

    return null; // For other positions, let user specify manually
  }
}

class _TooltipPosition {
  const _TooltipPosition({this.top, this.left, this.right, this.bottom});

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
}
