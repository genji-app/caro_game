import 'package:flutter/material.dart';
import 'arrow_position.dart';
import 'composited_tooltip_controller.dart';
import 'smart_tooltip_config.dart';
import 'smart_tooltip_controller.dart';
import 'tooltip_container.dart';
import 'tooltip_strategy.dart';

/// A smart, reusable tooltip widget with flexible positioning strategies
///
/// SmartTooltip provides a generic tooltip solution with no dependencies
/// on other modules. It supports composited positioning strategy for
/// automatic position tracking.
///
/// ## Features:
/// - GPU-accelerated position tracking
/// - Customizable trigger widget
/// - Flexible content builder
/// - Auto-close on scroll (optional)
/// - Programmatic control via controller
/// - Automatic TooltipContainer wrapping
///
/// ## Basic Usage:
/// ```dart
/// SmartTooltip(
///   contentBuilder: (onClose) => Text('Tooltip content'),
/// )
/// ```
///
/// ## Custom Trigger:
/// ```dart
/// SmartTooltip(
///   contentBuilder: (onClose) => Text('Tooltip'),
///   triggerBuilder: (onTap) => ElevatedButton(
///     onPressed: onTap,
///     child: Text('Show'),
///   ),
/// )
/// ```
class SmartTooltip extends StatefulWidget {
  /// Builder for tooltip content
  ///
  /// Required. Receives onClose callback to programmatically close tooltip.
  /// Content will be automatically wrapped with TooltipContainer unless
  /// it's already a TooltipContainer or custom container builder is provided.
  final Widget Function(VoidCallback onClose) contentBuilder;

  /// Builder for trigger widget
  ///
  /// If null, uses default info icon button.
  /// Receives onTap callback to show tooltip.
  final Widget Function(VoidCallback onTap)? triggerBuilder;

  /// Tooltip configuration
  final SmartTooltipConfig config;

  /// Positioning strategy (currently only composited is supported)
  final TooltipStrategy strategy;

  /// Callback when tooltip is shown
  final VoidCallback? onShow;

  /// Callback when tooltip is hidden
  final VoidCallback? onHide;

  /// Optional controller for external control
  final SmartTooltipController? controller;

  const SmartTooltip({
    required this.contentBuilder,
    super.key,
    this.triggerBuilder,
    this.config = const SmartTooltipConfig(),
    this.strategy = TooltipStrategy.composited,
    this.onShow,
    this.onHide,
    this.controller,
  });

  @override
  State<SmartTooltip> createState() => _SmartTooltipState();
}

class _SmartTooltipState extends State<SmartTooltip> {
  late final CompositedTooltipController _compositedController;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _compositedController = CompositedTooltipController();
    _attachExternalController();
  }

  @override
  void didUpdateWidget(SmartTooltip oldWidget) {
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
    _compositedController.dispose();
    super.dispose();
  }

  void _attachExternalController() {
    widget.controller?.attach(onShow: _showTooltip, onHide: _hideTooltip);
  }

  void _showTooltip() {
    if (_isShowing) return;

    final config = widget.config;

    _compositedController.show(
      context: context,
      targetAnchor: config.targetAnchor,
      followerAnchor: config.followerAnchor,
      offset: config.compositedOffset,
      autoCloseOnScroll: config.autoCloseOnScroll,
      dismissOnTapOutside: config.dismissOnTapOutside,
      rootOverlay: config.rootOverlay,
      builder: (onClose) {
        // Build content with combined onClose callback
        final content = widget.contentBuilder(() {
          onClose();
          _hideTooltip();
        });

        // If custom container builder provided, use it
        if (config.tooltipContainerBuilder != null) {
          return config.tooltipContainerBuilder!(content);
        }

        // If content is already a TooltipContainer, return as is
        if (content is TooltipContainer) {
          return content;
        }

        // Otherwise, wrap with default TooltipContainer
        return TooltipContainer(
          width: config.tooltipWidth ?? 326,
          padding: config.tooltipPadding ?? EdgeInsets.zero,
          arrowPosition: config.arrowPosition ?? ArrowPosition.topRight,
          arrowOffset: config.arrowOffset ?? 14.0,
          child: content,
        );
      },
    );

    _isShowing = true;
    widget.controller?.updateState(true);
    widget.onShow?.call();
  }

  void _hideTooltip() {
    if (!_isShowing) return;

    _compositedController.remove();
    _isShowing = false;
    widget.controller?.updateState(false);
    widget.onHide?.call();
  }

  Widget _buildDefaultTrigger(VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(widget.config.triggerBorderRadius),
      onTap: onTap,
      splashColor: widget.config.triggerSplashColor,
      child: Padding(
        padding: widget.config.triggerPadding,
        child: SizedBox.square(
          dimension: widget.config.triggerSize,
          child:
              widget.config.triggerIcon ??
              Icon(
                Icons.info_outline,
                size: widget.config.triggerSize,
                color: widget.config.triggerColor,
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

    // Always wrap with CompositedTransformTarget
    return _compositedController.wrapTarget(child: trigger);
  }
}
