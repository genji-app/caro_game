import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

/// Helper class for smart tooltip positioning
class TooltipPositioning {
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;
  final ArrowPosition arrowPosition;

  const TooltipPositioning({
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
    required this.arrowPosition,
  });

  /// Create a copy with optional overrides
  TooltipPositioning copyWith({
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? offset,
    ArrowPosition? arrowPosition,
  }) {
    return TooltipPositioning(
      targetAnchor: targetAnchor ?? this.targetAnchor,
      followerAnchor: followerAnchor ?? this.followerAnchor,
      offset: offset ?? this.offset,
      arrowPosition: arrowPosition ?? this.arrowPosition,
    );
  }

  static const TooltipPositioning below = TooltipPositioning(
    targetAnchor: Alignment.bottomRight,
    followerAnchor: Alignment.topRight,
    offset: Offset(8, 4),
    arrowPosition: ArrowPosition.topRight,
  );

  static const TooltipPositioning above = TooltipPositioning(
    targetAnchor: Alignment.topRight,
    followerAnchor: Alignment.bottomRight,
    offset: Offset(8, -4),
    arrowPosition: ArrowPosition.bottomRight,
  );
}

/// Mixin for widgets that need smart tooltip positioning
///
/// Provides automatic tooltip position calculation based on available screen space.
/// Ensures tooltips don't overflow screen boundaries.
mixin SmartTooltipPositioning {
  /// Calculate tooltip positioning based on available screen space
  ///
  /// Returns [TooltipPositioning.above] if there's not enough space below,
  /// otherwise returns [TooltipPositioning.below]
  ///
  /// Parameters:
  /// - [context]: BuildContext to get screen size and button position
  /// - [tooltipHeight]: Maximum height of the tooltip
  /// - [bottomThreshold]: Minimum space needed below button to show tooltip below
  /// - [customOffsetBelow]: Optional custom offset when showing below (defaults to Offset(8, 4))
  /// - [customOffsetAbove]: Optional custom offset when showing above (defaults to Offset(8, -4))
  TooltipPositioning calculateTooltipPosition(
    BuildContext context, {
    required double tooltipHeight,
    required double bottomThreshold,
    Offset? customOffsetBelow,
    Offset? customOffsetAbove,
  }) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return TooltipPositioning.below.copyWith(offset: customOffsetBelow);
    }

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - buttonPosition.dy - renderBox.size.height;

    // Check if there's enough space below for tooltip + threshold
    final shouldShowAbove = spaceBelow < (tooltipHeight + bottomThreshold);

    if (shouldShowAbove) {
      return TooltipPositioning.above.copyWith(offset: customOffsetAbove);
    } else {
      return TooltipPositioning.below.copyWith(offset: customOffsetBelow);
    }
  }
}
