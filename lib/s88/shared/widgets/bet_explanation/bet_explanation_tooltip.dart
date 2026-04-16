import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/overlay_tooltip/overlay_tooltip.dart';
import 'bet_tooltip_config.dart';

/// Shared widget for bet explanation tooltips
///
/// Provides consistent tooltip behavior across all betting widgets
/// with smart positioning and flexible configuration.
///
/// ## Features:
/// - Smart positioning that adapts to available screen space
/// - Customizable trigger widget
/// - Flexible configuration via [BetTooltipConfig]
/// - GPU-accelerated positioning via CompositedTransform
/// - Automatic HintData → HintContentWidget conversion
///
/// ## Basic Usage:
/// ```dart
/// BetExplanationTooltip.icon(
///   hintData: myHintData,
///   iconColor: AppColorStyles.contentSecondary,
/// )
/// ```
///
/// ## Custom Trigger:
/// ```dart
/// BetExplanationTooltip(
///   hintData: myHintData,
///   triggerBuilder: (onTap) => TextButton(
///     onPressed: onTap,
///     child: Text('Show Info'),
///   ),
/// )
/// ```
///
/// ## Custom Configuration:
/// ```dart
/// BetExplanationTooltip.icon(
///   hintData: myHintData,
///   config: BetTooltipConfig(
///     tooltipWidth: 300,
///     rootOverlay: true,
///     arrowPosition: ArrowPosition.topLeft,
///   ),
/// )
/// ```
class BetExplanationTooltip extends StatefulWidget {
  /// Input data for tooltip content
  final HintData hintData;

  /// Trigger widget builder (receives onTap callback)
  ///
  /// If null, uses default info icon button.
  final Widget Function(VoidCallback onTap)? triggerBuilder;

  /// Tooltip configuration
  final BetTooltipConfig config;

  /// Optional controller for programmatic control
  final SmartTooltipController? controller;

  /// Callback when tooltip is shown
  final VoidCallback? onShow;

  /// Callback when tooltip is hidden
  final VoidCallback? onHide;

  const BetExplanationTooltip({
    required this.hintData,
    super.key,
    this.triggerBuilder,
    this.config = const BetTooltipConfig(),
    this.controller,
    this.onShow,
    this.onHide,
  });

  /// Convenience constructor with default info icon trigger
  ///
  /// ## Example:
  /// ```dart
  /// BetExplanationTooltip.icon(
  ///   hintData: singleBet.toHintData(),
  ///   iconColor: AppColorStyles.contentSecondary,
  ///   iconSize: 18.0,
  /// )
  /// ```
  factory BetExplanationTooltip.icon({
    required HintData hintData,
    Key? key,
    Color? iconColor,
    double iconSize = 18.0,
    BetTooltipConfig config = const BetTooltipConfig(),
    SmartTooltipController? controller,
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) {
    return BetExplanationTooltip(
      hintData: hintData,
      key: key,
      config: config.copyWith(triggerColor: iconColor, triggerSize: iconSize),
      controller: controller,
      onShow: onShow,
      onHide: onHide,
    );
  }

  @override
  State<BetExplanationTooltip> createState() => _BetExplanationTooltipState();
}

class _BetExplanationTooltipState extends State<BetExplanationTooltip>
    with SmartTooltipPositioning {
  late final CompositedTooltipController _tooltipController;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _tooltipController = CompositedTooltipController();
    _attachExternalController();
  }

  @override
  void didUpdateWidget(BetExplanationTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update external controller attachment
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _attachExternalController();
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _tooltipController.dispose();
    super.dispose();
  }

  void _attachExternalController() {
    widget.controller?.attach(onShow: _showTooltip, onHide: _hideTooltip);
  }

  void _showTooltip() {
    // Always close existing tooltip first (handles case where tooltip was dismissed externally)
    _tooltipController.remove();
    _isShowing = false;

    final config = widget.config;

    // Build tooltip content
    final tooltipContent = _buildTooltipContent();

    // Determine positioning
    if (config.useSmartPositioning) {
      _showWithSmartPositioning(tooltipContent);
    } else {
      _showWithManualPositioning(tooltipContent);
    }

    _isShowing = true;
    widget.controller?.updateState(true);
    widget.onShow?.call();
  }

  void _showWithSmartPositioning(Widget content) {
    final config = widget.config;

    // Step 1: Measure actual content height
    final contentHeight = _measureContentHeight(content, config);

    // Step 2: Get trigger position on screen
    final triggerRenderBox = context.findRenderObject() as RenderBox?;
    if (triggerRenderBox == null || !triggerRenderBox.hasSize) {
      // Fallback to manual positioning if can't get trigger position
      _showWithManualPositioning(content);
      return;
    }

    final triggerOffset = triggerRenderBox.localToGlobal(Offset.zero);
    final triggerSize = triggerRenderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    // Step 3: Calculate available space above and below trigger
    final spaceAbove = triggerOffset.dy;
    final spaceBelow = screenHeight - (triggerOffset.dy + triggerSize.height);

    // Step 4: Determine optimal positioning
    final shouldShowAbove = _shouldShowAbove(
      contentHeight: contentHeight,
      spaceAbove: spaceAbove,
      spaceBelow: spaceBelow,
      bottomThreshold: config.bottomThreshold,
    );

    // Step 5: Adjust constraints if content is too tall
    final adjustedContent = _adjustContentConstraints(
      content: content,
      contentHeight: contentHeight,
      availableSpace: shouldShowAbove ? spaceAbove : spaceBelow,
      config: config,
    );

    // Step 6: Calculate positioning
    final positioning = TooltipPositioning(
      // Use config anchors if provided, otherwise use calculated anchors based on position
      targetAnchor:
          config.targetAnchor ??
          (shouldShowAbove ? Alignment.topRight : Alignment.bottomRight),
      followerAnchor:
          config.followerAnchor ??
          (shouldShowAbove ? Alignment.bottomRight : Alignment.topRight),
      // Use config offset if provided, otherwise use calculated offset based on position
      offset:
          config.offset ??
          (shouldShowAbove ? const Offset(-12, -12) : const Offset(-12, 12)),
      arrowPosition: shouldShowAbove
          ? ArrowPosition.bottomRight
          : ArrowPosition.topRight,
    ).copyWith(arrowPosition: ArrowPosition.none);

    // Step 7: Show tooltip with calculated positioning
    _tooltipController.show(
      context: context,
      targetAnchor: positioning.targetAnchor,
      followerAnchor: positioning.followerAnchor,
      offset: positioning.offset,
      autoCloseOnScroll: config.autoCloseOnScroll,
      rootOverlay: config.rootOverlay,
      dismissOnTapOutside: config.dismissOnTapOutside,
      builder: (onClose) => TooltipContainer(
        padding: config.tooltipPadding ?? EdgeInsets.zero,
        arrowPosition: config.arrowPosition ?? positioning.arrowPosition,
        arrowOffset: config.arrowOffset,
        child: adjustedContent,
      ),
    );
  }

  /// Measure the actual height of content widget
  ///
  /// Note: For accurate measurement, we would need to render the widget offscreen
  /// which is complex and has performance implications. Instead, we use the
  /// configured maxHeight as an estimate, which works well in practice since
  /// the content is constrained by maxHeight anyway.
  double _measureContentHeight(Widget content, BetTooltipConfig config) {
    // Use configured max height as estimate
    // This is practical because:
    // 1. Content is already constrained by this height
    // 2. Avoids expensive offscreen rendering
    // 3. Provides consistent behavior
    return config.tooltipMaxHeight ?? 440.0;
  }

  /// Determine if tooltip should show above or below trigger
  bool _shouldShowAbove({
    required double contentHeight,
    required double spaceAbove,
    required double spaceBelow,
    required double bottomThreshold,
  }) {
    // If content fits below with threshold, show below
    if (spaceBelow >= contentHeight + bottomThreshold) {
      return false;
    }

    // If content fits above better than below, show above
    if (spaceAbove > spaceBelow) {
      return true;
    }

    // Default: show below
    return false;
  }

  /// Adjust content constraints if it's too tall for available space
  Widget _adjustContentConstraints({
    required Widget content,
    required double contentHeight,
    required double availableSpace,
    required BetTooltipConfig config,
  }) {
    // Add some padding for safety (arrow, margins, etc.)
    const safetyPadding = 60.0;
    final maxAllowedHeight = availableSpace - safetyPadding;

    // If content fits, return as is
    if (contentHeight <= maxAllowedHeight) {
      return content;
    }

    // Otherwise, constrain the height
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: config.tooltipWidth ?? 275.0,
        maxHeight: maxAllowedHeight.clamp(
          200.0,
          config.tooltipMaxHeight ?? 440.0,
        ),
      ),
      child: content,
    );
  }

  void _showWithManualPositioning(Widget content) {
    final config = widget.config;

    _tooltipController.show(
      context: context,
      targetAnchor: config.targetAnchor ?? Alignment.bottomRight,
      followerAnchor: config.followerAnchor ?? Alignment.topRight,
      offset: config.offset ?? const Offset(-12, 12),
      autoCloseOnScroll: config.autoCloseOnScroll,
      rootOverlay: config.rootOverlay,
      dismissOnTapOutside: config.dismissOnTapOutside,
      builder: (onClose) => TooltipContainer(
        padding: config.tooltipPadding ?? EdgeInsets.zero,
        arrowPosition: config.arrowPosition ?? ArrowPosition.topRight,
        arrowOffset: config.arrowOffset,
        child: content,
      ),
    );
  }

  Widget _buildTooltipContent() {
    final constraints = widget.config.getEffectiveConstraints();

    return ConstrainedBox(
      constraints: constraints,
      child: SingleChildScrollView(
        child: HintContentWidget(hintData: widget.hintData),
      ),
    );
  }

  void _hideTooltip() {
    if (!_isShowing) return;

    _tooltipController.remove();
    _isShowing = false;
    widget.controller?.updateState(false);
    widget.onHide?.call();
  }

  Widget _buildDefaultTrigger(VoidCallback onTap) {
    final config = widget.config;

    return InkWell(
      borderRadius: BorderRadius.circular(config.triggerBorderRadius),
      onTap: onTap,
      splashColor: config.triggerSplashColor,
      child: Padding(
        padding: config.triggerPadding,
        child: SizedBox.square(
          dimension: config.triggerSize,
          child:
              config.triggerIcon ??
              ImageHelper.load(
                path: AppIcons.iconInfo,
                color: config.triggerColor,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger =
        widget.triggerBuilder?.call(_showTooltip) ??
        _buildDefaultTrigger(_showTooltip);

    // Always wrap with CompositedTransformTarget for positioning
    return _tooltipController.wrapTarget(child: trigger);
  }
}
