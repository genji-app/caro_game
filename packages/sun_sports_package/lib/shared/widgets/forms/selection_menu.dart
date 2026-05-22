import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';

/// Menu item model for selection menu
class SelectionMenuItem {
  final String value; // Value to return when selected
  final String label; // Display label
  final String? iconUrl; // Optional icon URL (network image)
  /// Path/URL; ưu tiên getter [AppIcons] / [AppImages].
  final String? iconAssetPath;
  final bool showDefaultIcon; // Show default icon when no icon source provided

  const SelectionMenuItem({
    required this.value,
    required this.label,
    this.iconUrl,
    this.iconAssetPath,
    this.showDefaultIcon = false, // Default to false (no icon when no source)
  });
}

/// Utility class for showing selection menu from bottom
class SelectionMenu {
  /// Default hover background color applied when the pointer is over an item.
  /// Slightly lighter than the menu background ([AppColors.gray600]) so the
  /// hovered item visibly stands out on web/desktop.
  static const Color defaultHoverBackgroundColor = AppColors.gray300;

  /// Outer border radius of the menu container. Kept in one place so the
  /// hover background of the first/last items can mirror it and avoid
  /// painting square corners over the menu's rounded outline.
  static const double _menuBorderRadius = 12;

  /// Show selection menu from bottom position
  ///
  /// [context] - BuildContext to show the menu
  /// [items] - List of menu items to display
  /// [buttonKey] - GlobalKey of the button to position menu below it
  /// [buttonWidth] - Width of the button (should match menu width)
  /// [selectedValue] - Currently selected value (optional)
  /// [hoverBackgroundColor] - Background color shown when the pointer hovers
  ///     over an item (web/desktop only). Defaults to
  ///     [defaultHoverBackgroundColor]. Pass [Colors.transparent] to disable
  ///     the custom hover effect entirely.
  ///
  /// Returns the selected value (string), or null if dismissed
  static Future<String?> show({
    required BuildContext context,
    required List<SelectionMenuItem> items,
    required GlobalKey buttonKey,
    required double buttonWidth,
    String? selectedValue,
    Color hoverBackgroundColor = defaultHoverBackgroundColor,
  }) async {
    final RenderBox? buttonBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return null;

    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;

    // Calculate position: bottom of button, same x position
    final position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy + buttonSize.height + 4, // 4px gap below button
      buttonPosition.dx + buttonSize.width,
      double.infinity, // Menu will expand upward
    );

    // Show the menu with `popupMenuTheme.menuPadding` zeroed out. Without
    // this override, [showMenu] wraps its items in a `SingleChildScrollView`
    // with 8px vertical padding (Material default), which leaves a visible
    // gap between the first/last items' hover background and the menu's
    // rounded outline. Zeroing the padding lets the hover background of the
    // top/bottom items sit flush with the menu's rounded corners.
    final selectedId = await _showMenuWithThemeOverride<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_menuBorderRadius),
        side: BorderSide(
          color: AppColors.gray700, // Golden border
          width: 1,
        ),
      ),
      color: AppColors.gray500, // Dark background
      constraints: BoxConstraints(
        minWidth: buttonWidth,
        maxWidth: buttonWidth,
        maxHeight: _calculateMaxHeight(items.length),
      ),
      items: List<PopupMenuEntry<String>>.generate(items.length, (index) {
        final item = items[index];
        // padding is zero on the PopupMenuItem so the hover background can
        // fill the entire tile (icon + label + check). The actual padding
        // is applied inside [_SelectionMenuItemTile]. isFirst/isLast let the
        // tile round the hover background's outer corners so it never spills
        // over the menu's rounded outline.
        return PopupMenuItem<String>(
          value: item.value,
          padding: EdgeInsets.zero,
          child: _SelectionMenuItemTile(
            item: item,
            isSelected: selectedValue == item.value,
            hoverBackgroundColor: hoverBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            isFirst: index == 0,
            isLast: index == items.length - 1,
            menuBorderRadius: _menuBorderRadius,
          ),
        );
      }),
    );

    return selectedId;
  }

  /// Wrapper around [showMenu] that installs a transient [OverlayEntry]
  /// providing a [Theme] override (`popupMenuTheme.menuPadding =
  /// EdgeInsets.zero`). The menu route picks the override up through
  /// `InheritedTheme.capture`, so the menu's internal
  /// `SingleChildScrollView` renders with no vertical padding.
  ///
  /// This works around [showMenu] not exposing a `menuPadding` parameter
  /// directly. The override entry is mounted only for the duration of the
  /// menu and removed in a `finally` block to guarantee cleanup even if
  /// [showMenu] throws.
  static Future<T?> _showMenuWithThemeOverride<T>({
    required BuildContext context,
    required RelativeRect position,
    required List<PopupMenuEntry<T>> items,
    required ShapeBorder shape,
    required Color color,
    required BoxConstraints constraints,
  }) async {
    // Insert into the local overlay (matches the Navigator that [showMenu]
    // will push its route into) so themes captured from [themedContext]
    // include our override.
    final overlay = Overlay.of(context);
    final completer = Completer<BuildContext>();
    OverlayEntry? overrideEntry;
    overrideEntry = OverlayEntry(
      builder: (overlayContext) {
        final baseTheme = Theme.of(overlayContext);
        final basePopupTheme = PopupMenuTheme.of(overlayContext);
        // Override the menu padding at TWO levels:
        //   1. [PopupMenuTheme] widget — picked up first by
        //      `PopupMenuTheme.of(context)` lookups inside the menu.
        //   2. [Theme] widget's `popupMenuTheme` — fallback for callers
        //      that read it through `Theme.of(context).popupMenuTheme`.
        // Both are [InheritedTheme]s so they propagate through
        // `InheritedTheme.capture` into the showMenu route.
        return Theme(
          data: baseTheme.copyWith(
            popupMenuTheme: basePopupTheme.copyWith(
              menuPadding: EdgeInsets.zero,
            ),
          ),
          child: PopupMenuTheme(
            data: basePopupTheme.copyWith(menuPadding: EdgeInsets.zero),
            child: Builder(
              builder: (themedContext) {
                if (!completer.isCompleted) {
                  completer.complete(themedContext);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
    overlay.insert(overrideEntry);

    try {
      final themedContext = await completer.future;
      if (!themedContext.mounted) return null;
      return await showMenu<T>(
        context: themedContext,
        position: position,
        shape: shape,
        color: color,
        constraints: constraints,
        // Clip the menu's content to its rounded outline. Without this, any
        // sub-pixel overflow at the rounded corners (e.g. the hover
        // background of the first/last items) would render outside the
        // visible menu shape.
        clipBehavior: Clip.antiAlias,
        items: items,
      );
    } finally {
      overrideEntry.remove();
    }
  }

  /// Build icon widget based on available sources
  /// Priority: iconAssetPath > iconUrl > default icon (if showDefaultIcon is true)
  static Widget _buildIcon(SelectionMenuItem item) {
    // Priority 1: Use asset path if available
    if (item.iconAssetPath != null && item.iconAssetPath!.isNotEmpty) {
      return _buildIconContainer(child: _buildAssetIcon(item.iconAssetPath!));
    }

    // Priority 2: Use network URL if available
    if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
      return _buildIconContainer(child: _buildNetworkIcon(item.iconUrl!));
    }

    // Priority 3: Default icon only if showDefaultIcon is true
    if (item.showDefaultIcon) {
      return _buildDefaultIcon();
    }

    // No icon when no source and showDefaultIcon is false
    return const SizedBox.shrink();
  }

  /// Build icon container with consistent styling
  static Widget _buildIconContainer({required Widget child}) => Container(
    width: 32,
    height: 32,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: AppColors.gray25,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.gray700, width: 0.5),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(7.5), // Sát với border (8 - 0.5)
      child: child,
    ),
  );

  /// Build asset icon (SVG or Image)
  static Widget _buildAssetIcon(String assetPath) {
    final isSvg = assetPath.endsWith('.svg');

    if (isSvg) {
      return ImageHelper.getSVG(
        path: assetPath,
        width: 32,
        height: 32,
        fit: BoxFit.cover, // Fill toàn bộ container, sát với border
      );
    }
    return ImageHelper.load(
      path: assetPath,
      width: 32,
      height: 32,
      fit: BoxFit.cover, // Fill toàn bộ container, sát với border
    );
  }

  /// Build network icon
  /// Note: ImageHelper.load automatically detects if path is network URL or asset path
  /// Wrapped in Builder with try-catch to handle SVG loading errors
  static Widget _buildNetworkIcon(String url) {
    return Builder(
      builder: (context) {
        try {
          return ImageHelper.load(
            path: url,
            width: 32,
            height: 32,
            fit: BoxFit.cover, // Fill toàn bộ container, sát với border
            errorWidget: const Icon(
              Icons.account_balance,
              size: 20,
              color: AppColors.gray950,
            ),
            placeholder: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gray950,
                ),
              ),
            ),
          );
        } catch (e) {
          // Fallback if ImageHelper.load throws error (e.g., SVG parsing error)
          return const Icon(
            Icons.account_balance,
            size: 20,
            color: AppColors.gray950,
          );
        }
      },
    );
  }

  /// Build default icon (when no icon source is provided)
  static Widget _buildDefaultIcon() => Container(
    width: 32,
    height: 32,
    margin: const EdgeInsets.only(right: 12),
    child: const Icon(Icons.account_balance, size: 20, color: AppColors.gray25),
  );

  /// Calculate max height based on number of items
  /// Each item has approximately 48px height (32px icon + padding)
  /// Add some padding for menu container
  static double _calculateMaxHeight(int itemCount) {
    const double itemHeight = 48.0; // Approximate height per item
    const double menuPadding = 8.0; // Top and bottom padding
    const double maxScreenHeight = 400.0; // Maximum height to prevent overflow

    final double calculatedHeight = (itemCount * itemHeight) + menuPadding;

    // Return the smaller value to prevent menu from being too tall
    return calculatedHeight > maxScreenHeight
        ? maxScreenHeight
        : calculatedHeight;
  }
}

/// Single tile inside [SelectionMenu] that paints a custom hover background
/// on web/desktop. Uses [MouseRegion] to track pointer enter/exit and an
/// [AnimatedContainer] for a smooth color transition.
///
/// Touch platforms (Android/iOS) never emit hover events, so on those
/// platforms the tile simply renders with a transparent background — the
/// default tap ripple from the enclosing [PopupMenuItem] still works.
class _SelectionMenuItemTile extends StatefulWidget {
  const _SelectionMenuItemTile({
    required this.item,
    required this.isSelected,
    required this.hoverBackgroundColor,
    required this.padding,
    required this.isFirst,
    required this.isLast,
    required this.menuBorderRadius,
  });

  final SelectionMenuItem item;
  final bool isSelected;
  final Color hoverBackgroundColor;
  final EdgeInsetsGeometry padding;

  /// Whether this tile is the first item in the menu.
  /// When true, the top-left/top-right corners of the hover background are
  /// rounded so they nest cleanly inside the menu's rounded outline.
  final bool isFirst;

  /// Whether this tile is the last item in the menu.
  /// When true, the bottom-left/bottom-right corners of the hover background
  /// are rounded so they nest cleanly inside the menu's rounded outline.
  final bool isLast;

  /// Outer border radius of the menu container (in logical pixels). Used to
  /// match the hover background's rounded corners to the menu outline.
  final double menuBorderRadius;

  @override
  State<_SelectionMenuItemTile> createState() => _SelectionMenuItemTileState();
}

class _SelectionMenuItemTileState extends State<_SelectionMenuItemTile> {
  bool _isHovered = false;

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  /// Build the hover background's border radius, rounding only the corners
  /// that touch the menu outline. Middle items use square corners.
  BorderRadius get _hoverBorderRadius {
    final corner = Radius.circular(widget.menuBorderRadius);
    return BorderRadius.only(
      topLeft: widget.isFirst ? corner : Radius.zero,
      topRight: widget.isFirst ? corner : Radius.zero,
      bottomLeft: widget.isLast ? corner : Radius.zero,
      bottomRight: widget.isLast ? corner : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _isHovered ? widget.hoverBackgroundColor : Colors.transparent,
          borderRadius: _hoverBorderRadius,
        ),
        padding: widget.padding,
        child: Row(
          children: [
            SelectionMenu._buildIcon(widget.item),
            Expanded(
              child: Text(
                widget.item.label,
                style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
              ),
            ),
            if (widget.isSelected)
              const Icon(Icons.check, size: 20, color: AppColors.yellow300),
          ],
        ),
      ),
    );
  }
}
