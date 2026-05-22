/// Strategy for tooltip positioning
enum TooltipStrategy {
  /// Standard positioning using OverlayTooltipController
  ///
  /// Features:
  /// - Manual position calculation
  /// - Auto-positioning to avoid screen edges
  /// - More positioning options
  ///
  /// Best for:
  /// - Static tooltips
  /// - Non-scrollable contexts
  /// - When you need precise control
  standard,

  /// Composited positioning using CompositedTooltipController
  ///
  /// Features:
  /// - GPU-accelerated position tracking
  /// - Automatically follows target
  /// - Perfect for scrollable lists
  ///
  /// Best for:
  /// - Tooltips in scrollable lists
  /// - Dynamic content
  /// - When position accuracy is critical
  composited,
}
