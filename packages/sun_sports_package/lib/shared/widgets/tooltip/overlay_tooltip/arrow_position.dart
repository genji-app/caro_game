/// Arrow position options for [TooltipContainer].
///
/// Defines where the arrow pointer should be positioned on the tooltip
/// and which direction it should point.
///
/// ## Vertical Arrows (Top/Bottom)
/// - [top]: Arrow at top center, pointing up ▲
/// - [topLeft]: Arrow at top left, pointing up ▲
/// - [topRight]: Arrow at top right, pointing up ▲
/// - [bottom]: Arrow at bottom center, pointing down ▼
/// - [bottomLeft]: Arrow at bottom left, pointing down ▼
/// - [bottomRight]: Arrow at bottom right, pointing down ▼
///
/// ## Horizontal Arrows (Left/Right)
/// - [left]: Arrow at left center, pointing left ◄
/// - [leftTop]: Arrow at left top, pointing left ◄
/// - [leftBottom]: Arrow at left bottom, pointing left ◄
/// - [right]: Arrow at right center, pointing right ►
/// - [rightTop]: Arrow at right top, pointing right ►
/// - [rightBottom]: Arrow at right bottom, pointing right ►
///
/// ## No Arrow
/// - [none]: No arrow displayed
///
/// ## Example
/// ```dart
/// TooltipContainer(
///   arrowPosition: ArrowPosition.topRight,
///   arrowOffset: 16.0,
///   child: Text('Tooltip content'),
/// )
/// ```
enum ArrowPosition {
  /// Arrow at top center, pointing up
  top,

  /// Arrow at top left, pointing up
  topLeft,

  /// Arrow at top right, pointing up
  topRight,

  /// Arrow at bottom center, pointing down
  bottom,

  /// Arrow at bottom left, pointing down
  bottomLeft,

  /// Arrow at bottom right, pointing down
  bottomRight,

  /// Arrow at left center, pointing left
  left,

  /// Arrow at left top, pointing left
  leftTop,

  /// Arrow at left bottom, pointing left
  leftBottom,

  /// Arrow at right center, pointing right
  right,

  /// Arrow at right top, pointing right
  rightTop,

  /// Arrow at right bottom, pointing right
  rightBottom,

  /// No arrow
  none,
}
