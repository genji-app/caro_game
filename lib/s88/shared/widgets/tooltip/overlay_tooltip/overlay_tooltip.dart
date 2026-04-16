// ignore_for_file: unnecessary_library_name

/// # Overlay Tooltip System
///
/// A comprehensive tooltip system with overlay positioning, smooth animations,
/// and customizable arrow pointers.
///
/// ## Overview
///
/// This package provides a complete tooltip solution with:
/// - **Flexible positioning** using Flutter's Alignment system
/// - **Smooth animations** (fade + scale)
/// - **Arrow pointers** with 13 position options
/// - **Auto-calculation** of arrow offset to point at targets
/// - **Lifecycle management** for showing/hiding tooltips
///
/// ## Quick Start
///
/// ### 1. Basic Tooltip
/// ```dart
/// final controller = OverlayTooltipController();
///
/// helper.show(
///   context: context,
///   targetKey: buttonKey,
///   builder: (onClose) => TooltipContainer(
///     child: Text('Hello, World!'),
///   ),
/// );
/// ```
///
/// ### 2. Tooltip with Arrow
/// ```dart
/// helper.show(
///   context: context,
///   targetKey: iconKey,
///   alignment: Alignment.bottomRight,
///   builder: (onClose) => TooltipContainer(
///     arrowPosition: ArrowPosition.topRight,
///     arrowOffset: 16.0,
///     child: Column(
///       children: [
///         Text('Title'),
///         Text('Description'),
///       ],
///     ),
///   ),
/// );
/// ```
///
/// ### 3. Auto-calculate Arrow Offset
/// ```dart
/// // Calculate offset to point arrow at target center
/// final offset = OverlayTooltipController.calculateArrowOffset(
///   targetKey: iconKey,
///   tooltipWidth: 299,
///   alignment: Alignment.bottomRight,
///   arrowPosition: ArrowPosition.topRight,
/// ) ?? 16.0;
///
/// helper.show(
///   context: context,
///   targetKey: iconKey,
///   alignment: Alignment.bottomRight,
///   builder: (onClose) => TooltipContainer(
///     width: 299,
///     arrowPosition: ArrowPosition.topRight,
///     arrowOffset: offset, // Arrow points exactly at icon center
///     child: MyContent(),
///   ),
/// );
/// ```
///
/// ## Components
///
/// ### OverlayTooltipController
/// Main class for managing tooltip lifecycle and positioning.
///
/// **Key Methods:**
/// - `show()` - Display a tooltip
/// - `remove()` - Dismiss the tooltip
/// - `calculateArrowOffset()` - Auto-calculate arrow offset (static)
///
/// **Features:**
/// - Automatic positioning based on Alignment
/// - Optional animations (fade + scale)
/// - Root overlay support for nested contexts
/// - Backdrop dismissal
///
/// ### TooltipContainer
/// Pre-styled container widget for tooltip content.
///
/// **Features:**
/// - Consistent design (background, border-radius, shadow)
/// - Optional arrow pointer (15x9px, rounded corners)
/// - 13 arrow positions + none
/// - Customizable width and padding
///
/// ### ArrowPosition
/// Enum defining arrow positions on the tooltip.
///
/// **Options:**
/// - Top: `top`, `topLeft`, `topRight`
/// - Bottom: `bottom`, `bottomLeft`, `bottomRight`
/// - Left: `left`, `leftTop`, `leftBottom`
/// - Right: `right`, `rightTop`, `rightBottom`
/// - None: `none`
///
/// ## Positioning Guide
///
/// ### Tooltip Alignment
/// Use Flutter's `Alignment` to position tooltip relative to target:
///
/// ```dart
/// // Below target, right-aligned
/// alignment: Alignment.bottomRight
///
/// // Above target, left-aligned
/// alignment: Alignment.topLeft
///
/// // Below target, centered
/// alignment: Alignment.bottomCenter
/// ```
///
/// ### Arrow Positioning
///
/// #### Manual Offset
/// ```dart
/// TooltipContainer(
///   arrowPosition: ArrowPosition.topRight,
///   arrowOffset: 20.0, // 20px from right edge
///   child: MyContent(),
/// )
/// ```
///
/// #### Auto-calculated Offset
/// ```dart
/// final offset = OverlayTooltipController.calculateArrowOffset(
///   targetKey: targetKey,
///   tooltipWidth: 299,
///   alignment: Alignment.bottomRight,
///   arrowPosition: ArrowPosition.topRight,
/// ) ?? 16.0;
///
/// TooltipContainer(
///   arrowPosition: ArrowPosition.topRight,
///   arrowOffset: offset, // Points at target center
///   child: MyContent(),
/// )
/// ```
///
/// ## Animation
///
/// Tooltips support smooth fade and scale animations:
///
/// ```dart
/// // With animation (default)
/// helper.show(
///   enableAnimation: true,
///   // ...
/// );
///
/// // Without animation
/// helper.show(
///   enableAnimation: false,
///   // ...
/// );
/// ```
///
/// **Animation Details:**
/// - Duration: 200ms
/// - Curve: Curves.easeOut
/// - Fade: 0.0 → 1.0 opacity
/// - Scale: 0.95 → 1.0 size
///
/// ## Best Practices
///
/// ### 1. Use Root Overlay
/// Always use root overlay (default) for consistent positioning:
/// ```dart
/// helper.show(
///   rootOverlay: true, // Default
///   // ...
/// );
/// ```
///
/// ### 2. Cleanup on Dispose
/// ```dart
/// @override
/// void dispose() {
///   helper.remove();
///   super.dispose();
/// }
/// ```
///
/// ### 3. One Tooltip at a Time
/// ```dart
/// // Close all other tooltips before showing new one
/// for (final helper in tooltipHelpers.values) {
///   helper.remove();
/// }
/// helper.show(/* ... */);
/// ```
///
/// ### 4. Auto-calculate for Precision
/// Use auto-calculation when arrow needs to point exactly at target:
/// ```dart
/// final offset = OverlayTooltipController.calculateArrowOffset(
///   targetKey: key,
///   tooltipWidth: width,
///   alignment: alignment,
///   arrowPosition: arrowPos,
/// ) ?? defaultOffset;
/// ```
///
/// ## Styling
///
/// ### Tooltip Container
/// - Background: `AppColorStyles.backgroundTertiary`
/// - Border radius: 12px
/// - Shadow: 8px offset, 20px blur, -1px spread
///
/// ### Arrow
/// - Size: 15x9px (width x height)
/// - Rounded corners (quadratic bezier curves)
/// - Color: Matches container background
///
/// ## Examples
///
/// ### Example 1: Simple Text Tooltip
/// ```dart
/// final helper = OverlayTooltipController();
///
/// helper.show(
///   context: context,
///   targetKey: buttonKey,
///   builder: (onClose) => TooltipContainer(
///     child: Text('Click to continue'),
///   ),
/// );
/// ```
///
/// ### Example 2: Rich Content with Arrow
/// ```dart
/// helper.show(
///   context: context,
///   targetKey: iconKey,
///   alignment: Alignment.bottomRight,
///   builder: (onClose) => TooltipContainer(
///     width: 299,
///     padding: EdgeInsets.zero,
///     arrowPosition: ArrowPosition.topRight,
///     arrowOffset: 16.0,
///     child: Column(
///       children: [
///         Padding(
///           padding: EdgeInsets.all(16),
///           child: Text('Title', style: headingStyle),
///         ),
///         Divider(),
///         Padding(
///           padding: EdgeInsets.all(16),
///           child: Text('Description'),
///         ),
///       ],
///     ),
///   ),
/// );
/// ```
///
/// ### Example 3: Multiple Tooltips with Auto-offset
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final Map<String, GlobalKey> _keys = {};
///   final Map<String, OverlayTooltipController> _helpers = {};
///
///   @override
///   void initState() {
///     super.initState();
///     for (final item in items) {
///       _keys[item] = GlobalKey();
///       _helpers[item] = OverlayTooltipController();
///     }
///   }
///
///   @override
///   void dispose() {
///     for (final helper in _helpers.values) {
///       helper.remove();
///     }
///     super.dispose();
///   }
///
///   void _showTooltip(String item) {
///     // Close all others
///     for (final helper in _helpers.values) {
///       helper.remove();
///     }
///
///     // Calculate arrow offset
///     final offset = OverlayTooltipController.calculateArrowOffset(
///       targetKey: _keys[item]!,
///       tooltipWidth: 299,
///       alignment: Alignment.bottomRight,
///       arrowPosition: ArrowPosition.topRight,
///     ) ?? 16.0;
///
///     // Show tooltip
///     _helpers[item]!.show(
///       context: context,
///       targetKey: _keys[item]!,
///       alignment: Alignment.bottomRight,
///       builder: (onClose) => TooltipContainer(
///         width: 299,
///         arrowPosition: ArrowPosition.topRight,
///         arrowOffset: offset,
///         child: Text('Info about $item'),
///       ),
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: items.map((item) =>
///         IconButton(
///           key: _keys[item],
///           icon: Icon(Icons.help),
///           onTap: () => _showTooltip(item),
///         ),
///       ).toList(),
///     );
///   }
/// }
/// ```
///
/// ## See Also
/// - [OverlayTooltipController] - Main tooltip manager
/// - [TooltipContainer] - Styled container widget
/// - [ArrowPosition] - Arrow position options
library overlay_tooltip;

export 'arrow_position.dart';
export 'composited_tooltip_controller.dart';
export 'overlay_tooltip_controller.dart';
export 'smart_tooltip.dart';
export 'smart_tooltip_config.dart';
export 'smart_tooltip_controller.dart';
export 'smart_tooltip_positioning.dart';
export 'tooltip_container.dart';
export 'tooltip_strategy.dart';
