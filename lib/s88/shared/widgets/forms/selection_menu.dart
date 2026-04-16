import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

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
  /// Show selection menu from bottom position
  ///
  /// [context] - BuildContext to show the menu
  /// [items] - List of menu items to display
  /// [buttonKey] - GlobalKey of the button to position menu below it
  /// [buttonWidth] - Width of the button (should match menu width)
  /// [selectedValue] - Currently selected value (optional)
  ///
  /// Returns the selected value (string), or null if dismissed
  static Future<String?> show({
    required BuildContext context,
    required List<SelectionMenuItem> items,
    required GlobalKey buttonKey,
    required double buttonWidth,
    String? selectedValue,
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

    final selectedId = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.gray700, // Golden border
          width: 1,
        ),
      ),
      color: AppColors.gray800, // Dark background
      constraints: BoxConstraints(
        minWidth: buttonWidth,
        maxWidth: buttonWidth,
        maxHeight: _calculateMaxHeight(items.length),
      ),
      items: items.map((item) {
        return PopupMenuItem<String>(
          value: item.value,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Icon
              _buildIcon(item),
              // Label
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
                ),
              ),
              // Check icon if selected
              if (selectedValue == item.value)
                const Icon(Icons.check, size: 20, color: AppColors.yellow300),
            ],
          ),
        );
      }).toList(),
    );

    return selectedId;
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
