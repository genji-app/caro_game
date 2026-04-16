import 'package:flutter/material.dart';
import 'arrow_position.dart';

/// Configuration for SmartTooltip appearance and behavior
class SmartTooltipConfig {
  // === Tooltip Appearance ===
  /// Width of the tooltip
  final double? tooltipWidth;

  /// Max height of the tooltip (for auto-positioning)
  final double? tooltipMaxHeight;

  /// Padding inside tooltip container
  final EdgeInsets? tooltipPadding;

  /// Arrow position on tooltip
  final ArrowPosition? arrowPosition;

  /// Arrow offset from edge
  final double? arrowOffset;

  /// Custom tooltip container builder
  /// If provided, overrides default TooltipContainer
  final Widget Function(Widget content)? tooltipContainerBuilder;

  // === Positioning (Standard Strategy) ===
  /// Alignment relative to target
  final Alignment alignment;

  /// Offset from alignment point
  final Offset offset;

  /// Enable auto-positioning to avoid screen edges
  final bool autoPosition;

  /// Constraints for auto-positioning calculation
  final BoxConstraints? tooltipConstraints;

  // === Positioning (Composited Strategy) ===
  /// Anchor point on target widget
  final Alignment targetAnchor;

  /// Anchor point on tooltip
  final Alignment followerAnchor;

  /// Offset for composited follower
  final Offset compositedOffset;

  // === Behavior ===
  /// Auto-close tooltip when scrolling
  final bool autoCloseOnScroll;

  /// Close tooltip when tapping outside
  final bool dismissOnTapOutside;

  /// Enable fade/scale animation
  final bool enableAnimation;

  /// Allow interaction with elements behind tooltip
  final bool allowBackgroundInteraction;

  /// Use root overlay (recommended)
  final bool rootOverlay;

  // === Trigger Button Appearance ===
  /// Size of default trigger icon
  final double triggerSize;

  /// Padding around trigger
  final EdgeInsets triggerPadding;

  /// Icon path for default trigger
  final String? triggerIconPath;

  /// Icon widget for default trigger
  final Widget? triggerIcon;

  /// Trigger color
  final Color? triggerColor;

  /// Trigger border radius
  final double triggerBorderRadius;

  /// Trigger splash color
  final Color? triggerSplashColor;

  const SmartTooltipConfig({
    // Tooltip appearance
    this.tooltipWidth,
    this.tooltipMaxHeight,
    this.tooltipPadding,
    this.arrowPosition,
    this.arrowOffset,
    this.tooltipContainerBuilder,

    // Standard positioning
    this.alignment = Alignment.bottomRight,
    this.offset = const Offset(-12, 12),
    this.autoPosition = true,
    this.tooltipConstraints,

    // Composited positioning
    this.targetAnchor = Alignment.bottomRight,
    this.followerAnchor = Alignment.topRight,
    this.compositedOffset = const Offset(-12, 12),

    // Behavior
    this.autoCloseOnScroll = true,
    this.dismissOnTapOutside = true,
    this.enableAnimation = true,
    this.allowBackgroundInteraction = false,
    this.rootOverlay = true,

    // Trigger appearance
    this.triggerSize = 18.0,
    this.triggerPadding = const EdgeInsets.all(4.0),
    this.triggerIconPath,
    this.triggerIcon,
    this.triggerColor,
    this.triggerBorderRadius = 100.0,
    this.triggerSplashColor,
  });

  // === Preset Configurations ===

  /// Default configuration
  static const defaults = SmartTooltipConfig();

  /// Compact configuration for small spaces
  static const compact = SmartTooltipConfig(
    tooltipWidth: 250.0,
    triggerSize: 16.0,
    triggerPadding: EdgeInsets.all(2.0),
  );

  /// Large configuration for detailed content
  static const large = SmartTooltipConfig(
    tooltipWidth: 400.0,
    tooltipMaxHeight: 600.0,
    triggerSize: 24.0,
  );

  /// Top-aligned configuration
  static const topAligned = SmartTooltipConfig(
    alignment: Alignment.topRight,
    targetAnchor: Alignment.topRight,
    followerAnchor: Alignment.bottomRight,
    arrowPosition: ArrowPosition.bottomRight,
  );

  /// Bottom-aligned configuration (default)
  static const bottomAligned = SmartTooltipConfig(
    alignment: Alignment.bottomRight,
    targetAnchor: Alignment.bottomRight,
    followerAnchor: Alignment.topRight,
    arrowPosition: ArrowPosition.topRight,
  );

  /// Copy with method for customization
  SmartTooltipConfig copyWith({
    double? tooltipWidth,
    double? tooltipMaxHeight,
    EdgeInsets? tooltipPadding,
    ArrowPosition? arrowPosition,
    double? arrowOffset,
    Widget Function(Widget content)? tooltipContainerBuilder,
    Alignment? alignment,
    Offset? offset,
    bool? autoPosition,
    BoxConstraints? tooltipConstraints,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? compositedOffset,
    bool? autoCloseOnScroll,
    bool? dismissOnTapOutside,
    bool? enableAnimation,
    bool? allowBackgroundInteraction,
    bool? rootOverlay,
    double? triggerSize,
    EdgeInsets? triggerPadding,
    String? triggerIconPath,
    Widget? triggerIcon,
    Color? triggerColor,
    double? triggerBorderRadius,
    Color? triggerSplashColor,
  }) {
    return SmartTooltipConfig(
      tooltipWidth: tooltipWidth ?? this.tooltipWidth,
      tooltipMaxHeight: tooltipMaxHeight ?? this.tooltipMaxHeight,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      arrowPosition: arrowPosition ?? this.arrowPosition,
      arrowOffset: arrowOffset ?? this.arrowOffset,
      tooltipContainerBuilder:
          tooltipContainerBuilder ?? this.tooltipContainerBuilder,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      autoPosition: autoPosition ?? this.autoPosition,
      tooltipConstraints: tooltipConstraints ?? this.tooltipConstraints,
      targetAnchor: targetAnchor ?? this.targetAnchor,
      followerAnchor: followerAnchor ?? this.followerAnchor,
      compositedOffset: compositedOffset ?? this.compositedOffset,
      autoCloseOnScroll: autoCloseOnScroll ?? this.autoCloseOnScroll,
      dismissOnTapOutside: dismissOnTapOutside ?? this.dismissOnTapOutside,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      allowBackgroundInteraction:
          allowBackgroundInteraction ?? this.allowBackgroundInteraction,
      rootOverlay: rootOverlay ?? this.rootOverlay,
      triggerSize: triggerSize ?? this.triggerSize,
      triggerPadding: triggerPadding ?? this.triggerPadding,
      triggerIconPath: triggerIconPath ?? this.triggerIconPath,
      triggerIcon: triggerIcon ?? this.triggerIcon,
      triggerColor: triggerColor ?? this.triggerColor,
      triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
      triggerSplashColor: triggerSplashColor ?? this.triggerSplashColor,
    );
  }
}
