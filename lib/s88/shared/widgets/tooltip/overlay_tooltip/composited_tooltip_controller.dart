import 'package:flutter/material.dart';

/// A reusable tooltip controller using CompositedTransformFollower
/// for automatic position tracking that follows the target widget.
///
/// This is the most robust solution for tooltips in scrollable lists,
/// as it uses Flutter's native GPU-accelerated position tracking.
///
/// ## Features:
/// - ✅ Automatic position tracking (GPU-accelerated)
/// - ✅ Follows target widget during scroll
/// - ✅ No manual position calculation needed
/// - ✅ Best performance
/// - ✅ Optional auto-close on scroll
///
/// ## Basic Usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final _tooltipController = CompositedTooltipController();
///
///   @override
///   void dispose() {
///     _tooltipController.dispose();
///     super.dispose();
///   }
///
///   void _showTooltip() {
///     _tooltipController.show(
///       context: context,
///       builder: (onClose) => Container(
///         padding: EdgeInsets.all(16),
///         color: Colors.black87,
///         child: Text('Tooltip content'),
///       ),
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return _tooltipController.wrapTarget(
///       child: IconButton(
///         onPressed: _showTooltip,
///         icon: Icon(Icons.info),
///       ),
///     );
///   }
/// }
/// ```
class CompositedTooltipController {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  ScrollPosition? _scrollPosition;
  bool _autoCloseOnScroll = true;
  bool _isDisposed = false;

  /// Whether tooltip is currently showing
  bool get isShowing => _overlayEntry != null;

  /// Whether controller has been disposed
  bool get isDisposed => _isDisposed;

  /// Shows a tooltip that automatically follows the target widget.
  ///
  /// [context] - BuildContext to insert overlay
  /// [builder] - Function that builds the tooltip content
  /// [targetAnchor] - Anchor point on target widget (default: bottomRight)
  /// [followerAnchor] - Anchor point on tooltip (default: topRight)
  /// [offset] - Offset from anchor point (default: Offset(-12, 12))
  /// [autoCloseOnScroll] - Auto-close tooltip when scrolling (default: true)
  /// [dismissOnTapOutside] - Close tooltip when tapping outside (default: true)
  ///
  /// ## Example:
  /// ```dart
  /// _tooltipController.show(
  ///   context: context,
  ///   targetAnchor: Alignment.bottomCenter,
  ///   followerAnchor: Alignment.topCenter,
  ///   builder: (onClose) => MyTooltipWidget(),
  /// );
  /// ```
  void show({
    required BuildContext context,
    required Widget Function(VoidCallback onClose) builder,
    Alignment targetAnchor = Alignment.bottomRight,
    Alignment followerAnchor = Alignment.topRight,
    Offset offset = const Offset(-12, 12),
    bool autoCloseOnScroll = true,
    bool dismissOnTapOutside = true,
    bool rootOverlay = true,
  }) {
    // ✅ Check if controller is disposed
    if (_isDisposed) {
      assert(false, 'Cannot show tooltip on disposed controller');
      return;
    }

    // ✅ Check if context is still valid
    if (!context.mounted) {
      return;
    }

    // Close existing tooltip
    remove();

    _autoCloseOnScroll = autoCloseOnScroll;

    // Setup scroll listener if auto-close enabled
    if (_autoCloseOnScroll) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = Scrollable.maybeOf(context)?.position;
      _scrollPosition?.addListener(_onScroll);
    }

    // Create overlay with CompositedTransformFollower
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: dismissOnTapOutside ? remove : null,
          child: Stack(
            children: [
              // Transparent backdrop
              if (dismissOnTapOutside)
                Positioned.fill(child: Container(color: Colors.transparent)),

              // Tooltip that follows target
              CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                offset: offset,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping tooltip
                    child: builder(remove),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // ✅ Insert into overlay with safety check
    try {
      Overlay.of(context, rootOverlay: rootOverlay).insert(_overlayEntry!);
    } catch (e) {
      // If overlay insertion fails, clean up
      _overlayEntry = null;
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = null;
    }
  }

  /// Removes the tooltip if showing
  void remove() {
    if (_isDisposed) return;

    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Wraps the target widget with CompositedTransformTarget
  ///
  /// This must be called in the build method to link the tooltip
  /// to the target widget.
  ///
  /// ## Example:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return _tooltipController.wrapTarget(
  ///     child: IconButton(
  ///       onPressed: _showTooltip,
  ///       icon: Icon(Icons.info),
  ///     ),
  ///   );
  /// }
  /// ```
  Widget wrapTarget({required Widget child}) {
    if (_isDisposed) {
      // Return child without wrapping if disposed
      return child;
    }
    return CompositedTransformTarget(link: _layerLink, child: child);
  }

  void _onScroll() {
    if (_autoCloseOnScroll && isShowing) {
      remove();
    }
  }

  /// Disposes the controller and removes any active tooltip
  void dispose() {
    if (_isDisposed) return;

    remove();
    _isDisposed = true;
  }
}
