import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';

/// Configuration for bet explanation tooltips
///
/// Provides comprehensive configuration options for tooltip appearance,
/// positioning, and behavior. All properties are optional with sensible defaults.
///
/// ## Example:
/// ```dart
/// const config = BetTooltipConfig(
///   tooltipWidth: 300,
///   useSmartPositioning: true,
///   arrowPosition: ArrowPosition.topRight,
/// );
/// ```
class BetTooltipConfig {
  // ============================================================
  // TOOLTIP DIMENSIONS
  // ============================================================

  /// Width of the tooltip container
  ///
  /// Default: 275.0
  final double? tooltipWidth;

  /// Maximum height of the tooltip container
  ///
  /// Default: 440.0
  final double? tooltipMaxHeight;

  /// Custom constraints for tooltip container
  ///
  /// If provided, overrides [tooltipWidth] and [tooltipMaxHeight]
  final BoxConstraints? tooltipConstraints;

  /// Padding inside the tooltip container
  ///
  /// Default: EdgeInsets.zero
  final EdgeInsets? tooltipPadding;

  // ============================================================
  // POSITIONING
  // ============================================================

  /// Enable smart positioning that adapts to available space
  ///
  /// When true, tooltip will automatically position itself above or below
  /// the trigger based on available screen space.
  ///
  /// Default: true
  final bool useSmartPositioning;

  /// Minimum space required at bottom before switching to top positioning
  ///
  /// Only used when [useSmartPositioning] is true.
  ///
  /// Default: 100.0
  final double bottomThreshold;

  /// Target anchor point (on trigger widget)
  ///
  /// Only used when [useSmartPositioning] is false.
  final Alignment? targetAnchor;

  /// Follower anchor point (on tooltip)
  ///
  /// Only used when [useSmartPositioning] is false.
  final Alignment? followerAnchor;

  /// Offset from anchor points
  ///
  /// Only used when [useSmartPositioning] is false.
  final Offset? offset;

  // ============================================================
  // ARROW
  // ============================================================

  /// Position of the arrow pointer
  ///
  /// If null and [useSmartPositioning] is true, will be calculated automatically.
  final ArrowPosition? arrowPosition;

  /// Offset of the arrow from its edge
  ///
  /// Default: 14.0
  final double arrowOffset;

  // ============================================================
  // BEHAVIOR
  // ============================================================

  /// Auto-close tooltip when scrolling
  ///
  /// Default: true
  final bool autoCloseOnScroll;

  /// Dismiss tooltip when tapping outside
  ///
  /// Default: true
  final bool dismissOnTapOutside;

  /// Use root overlay instead of nearest overlay
  ///
  /// Set to false for nested overlays (e.g., inside bottom sheets).
  /// Set to true for top-level tooltips.
  ///
  /// Default: false
  final bool rootOverlay;

  // ============================================================
  // TRIGGER STYLING
  // ============================================================

  /// Color of the trigger icon
  final Color? triggerColor;

  /// Size of the trigger icon
  ///
  /// Default: 18.0
  final double triggerSize;

  /// Padding around the trigger
  ///
  /// Default: EdgeInsets.all(4.0)
  final EdgeInsets triggerPadding;

  /// Border radius for trigger ink well
  ///
  /// Default: 100.0 (circular)
  final double triggerBorderRadius;

  /// Custom trigger icon widget
  ///
  /// If null, uses default info icon
  final Widget? triggerIcon;

  /// Splash color for trigger tap
  final Color? triggerSplashColor;

  const BetTooltipConfig({
    // Dimensions
    this.tooltipWidth = 275.0,
    this.tooltipMaxHeight = 440.0,
    this.tooltipConstraints,
    this.tooltipPadding,
    // Positioning
    this.useSmartPositioning = true,
    this.bottomThreshold = 100.0,
    this.targetAnchor,
    this.followerAnchor,
    this.offset,
    // Arrow
    this.arrowPosition,
    this.arrowOffset = 14.0,
    // Behavior
    this.autoCloseOnScroll = true,
    this.dismissOnTapOutside = true,
    this.rootOverlay = false,
    // Trigger
    this.triggerColor,
    this.triggerSize = 18.0,
    this.triggerPadding = const EdgeInsets.all(4.0),
    this.triggerBorderRadius = 100.0,
    this.triggerIcon,
    this.triggerSplashColor,
  });

  /// Create a copy with modified properties
  BetTooltipConfig copyWith({
    double? tooltipWidth,
    double? tooltipMaxHeight,
    BoxConstraints? tooltipConstraints,
    EdgeInsets? tooltipPadding,
    bool? useSmartPositioning,
    double? bottomThreshold,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? offset,
    ArrowPosition? arrowPosition,
    double? arrowOffset,
    bool? autoCloseOnScroll,
    bool? dismissOnTapOutside,
    bool? rootOverlay,
    Color? triggerColor,
    double? triggerSize,
    EdgeInsets? triggerPadding,
    double? triggerBorderRadius,
    Widget? triggerIcon,
    Color? triggerSplashColor,
  }) {
    return BetTooltipConfig(
      tooltipWidth: tooltipWidth ?? this.tooltipWidth,
      tooltipMaxHeight: tooltipMaxHeight ?? this.tooltipMaxHeight,
      tooltipConstraints: tooltipConstraints ?? this.tooltipConstraints,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      useSmartPositioning: useSmartPositioning ?? this.useSmartPositioning,
      bottomThreshold: bottomThreshold ?? this.bottomThreshold,
      targetAnchor: targetAnchor ?? this.targetAnchor,
      followerAnchor: followerAnchor ?? this.followerAnchor,
      offset: offset ?? this.offset,
      arrowPosition: arrowPosition ?? this.arrowPosition,
      arrowOffset: arrowOffset ?? this.arrowOffset,
      autoCloseOnScroll: autoCloseOnScroll ?? this.autoCloseOnScroll,
      dismissOnTapOutside: dismissOnTapOutside ?? this.dismissOnTapOutside,
      rootOverlay: rootOverlay ?? this.rootOverlay,
      triggerColor: triggerColor ?? this.triggerColor,
      triggerSize: triggerSize ?? this.triggerSize,
      triggerPadding: triggerPadding ?? this.triggerPadding,
      triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
      triggerIcon: triggerIcon ?? this.triggerIcon,
      triggerSplashColor: triggerSplashColor ?? this.triggerSplashColor,
    );
  }

  /// Get effective constraints for tooltip
  BoxConstraints getEffectiveConstraints() {
    if (tooltipConstraints != null) {
      return tooltipConstraints!;
    }

    return BoxConstraints(
      maxWidth: tooltipWidth ?? 275.0,
      maxHeight: tooltipMaxHeight ?? 440.0,
    );
  }
}
