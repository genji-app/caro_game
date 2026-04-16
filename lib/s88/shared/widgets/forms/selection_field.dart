import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/forms/selection_menu.dart';

/// Icon style configuration for selection field
enum SelectionIconStyle {
  /// Default style with border and padding
  defaultStyle,

  /// Minimal style without border
  minimal,

  /// Custom style (requires custom builder)
  custom,
}

/// Generic selection field widget for deposit forms
///
/// Supports:
/// - Mobile: Bottom sheet selection with icons and optional search
/// - Web/Tablet: SelectionMenu with visual feedback (border color, chevron icon)
/// - Error display and error callbacks
/// - Icon display for selected item (multiple styles supported)
/// - Customizable placeholder, padding, and bottom sheet styling
/// - Optional search functionality
/// - Loading state support
///
/// Example:
/// ```dart
/// SelectionField(
///   label: 'Chọn thẻ',
///   placeholder: 'Chọn thẻ',
///   selectedValue: formState.selectedCardType,
///   errorMessage: formState.cardTypeError,
///   items: cardTypes.map((card) => SelectionMenuItem(
///     value: card.name,
///     label: card.name,
///     iconUrl: card.url,
///   )).toList(),
///   onSelected: (value) => ref.read(provider.notifier).update(value),
///   onSelectionError: (value) => debugPrint('Invalid selection: $value'),
/// )
/// ```
class SelectionField extends StatefulWidget {
  /// Field label text
  final String label;

  /// Error message to display (null if no error)
  final String? errorMessage;

  /// Currently selected value
  final String? selectedValue;

  /// Placeholder text when no value is selected
  final String placeholder;

  /// List of selectable items
  final List<SelectionMenuItem> items;

  /// Callback when an item is selected
  final void Function(String value) onSelected;

  /// Optional: Callback when selectedValue doesn't match any item
  final void Function(String invalidValue)? onSelectionError;

  /// Optional: Icon style for selected item
  /// Defaults to [SelectionIconStyle.defaultStyle]
  final SelectionIconStyle iconStyle;

  /// Optional: Custom icon widget builder (only used when iconStyle is custom)
  /// If not provided and iconStyle is not custom, default icon builder is used
  final Widget? Function(SelectionMenuItem selectedItem)? buildSelectedIcon;

  /// Optional: Bottom sheet title (defaults to label)
  final String? bottomSheetTitle;

  /// Optional: Custom padding for the field
  final EdgeInsets? padding;

  /// Optional: Enable search in bottom sheet (mobile only)
  final bool enableSearch;

  /// Optional: Search hint text
  final String? searchHint;

  /// Optional: Show loading indicator
  final bool isLoading;

  /// Optional: Show icons in bottom sheet (mobile)
  /// Defaults to true
  final bool showIconsInBottomSheet;

  const SelectionField({
    super.key,
    required this.label,
    this.errorMessage,
    this.selectedValue,
    required this.placeholder,
    required this.items,
    required this.onSelected,
    this.onSelectionError,
    this.iconStyle = SelectionIconStyle.defaultStyle,
    this.buildSelectedIcon,
    this.bottomSheetTitle,
    this.padding,
    this.enableSearch = false,
    this.searchHint,
    this.isLoading = false,
    this.showIconsInBottomSheet = true,
  });

  @override
  State<SelectionField> createState() => _SelectionFieldState();
}

class _SelectionFieldState extends State<SelectionField> {
  final GlobalKey _buttonKey = GlobalKey();
  final ValueNotifier<bool> _isMenuOpen = ValueNotifier<bool>(false);
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<SelectionMenuItem>> _filteredItems =
      ValueNotifier<List<SelectionMenuItem>>([]);

  @override
  void initState() {
    super.initState();
    _filteredItems.value = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(SelectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      // Schedule update after build to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _filteredItems.value = widget.items;
          _searchController.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _isMenuOpen.dispose();
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredItems.value = widget.items;
    } else {
      _filteredItems.value = widget.items
          .where((item) => item.label.toLowerCase().contains(query))
          .toList();
    }
  }

  /// Get selected item from items list
  SelectionMenuItem? get _selectedItem {
    if (widget.selectedValue == null || widget.items.isEmpty) {
      return null;
    }
    try {
      return widget.items.firstWhere(
        (item) => item.value == widget.selectedValue,
      );
    } catch (e) {
      // Notify callback if provided
      if (widget.onSelectionError != null) {
        widget.onSelectionError!(widget.selectedValue!);
      }
      if (kDebugMode) {
        debugPrint(
          'SelectionField: Selected value "${widget.selectedValue}" not found in items',
        );
      }
      return null;
    }
  }

  /// Show mobile bottom sheet
  Future<void> _showMobileBottomSheet() async {
    // Reset search when opening
    _searchController.clear();
    _filteredItems.value = widget.items;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.gray950,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.bottomSheetTitle ?? widget.label,
              style: AppTextStyles.headingSmall(color: AppColors.gray25),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ValueListenableBuilder<List<SelectionMenuItem>>(
                valueListenable: _filteredItems,
                builder: (context, filteredItems, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        leading: widget.showIconsInBottomSheet
                            ? _buildIconWidget(
                                    item,
                                    size: 32,
                                    showInBottomSheet: true,
                                  ) ??
                                  const SizedBox.shrink()
                            : null,
                        title: Text(
                          item.label,
                          style: AppTextStyles.paragraphMedium(
                            color: AppColors.gray25,
                          ),
                        ),
                        selected: widget.selectedValue == item.value,
                        selectedTileColor: AppColors.gray900.withValues(
                          alpha: 0.3,
                        ),
                        onTap: () => Navigator.of(context).pop(item.value),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    // Chỉ gọi onSelected nếu giá trị thay đổi
    if (selected != null && mounted && selected != widget.selectedValue) {
      widget.onSelected(selected);
    }
  }

  /// Build icon widget with different styles
  Widget? _buildIconWidget(
    SelectionMenuItem? item, {
    required double size,
    required bool showInBottomSheet,
  }) {
    if (item == null) return null;

    // Use custom icon builder if iconStyle is custom
    if (widget.iconStyle == SelectionIconStyle.custom &&
        widget.buildSelectedIcon != null) {
      return widget.buildSelectedIcon!(item);
    }

    // Use iconUrl if available
    if (item.iconUrl != null && item.iconUrl!.isNotEmpty) {
      // For bottom sheet, use same style as selected icon (white background)
      if (showInBottomSheet) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gray25, // White background like selected icon
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageHelper.load(
              path: item.iconUrl!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorWidget: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: size * 0.5,
                  color: AppColors.gray400,
                ),
              ),
              placeholder: Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          item.iconUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.credit_card,
            size: size * 0.625,
            color: AppColors.gray950,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: size,
              height: size,
              child: Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gray950,
                  ),
                ),
              ),
            );
          },
        ),
      );

      if (widget.iconStyle == SelectionIconStyle.minimal) {
        return SizedBox(width: size, height: size, child: iconWidget);
      }

      // Default style with border
      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.gray25,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray700, width: 0.5),
        ),
        child: iconWidget,
      );
    }

    // Use iconAssetPath if available
    if (item.iconAssetPath != null && item.iconAssetPath!.isNotEmpty) {
      // For bottom sheet, use same style as selected icon (white background)
      if (showInBottomSheet) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gray25, // White background like selected icon
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray700, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageHelper.load(
              path: item.iconAssetPath!,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        );
      }

      final iconWidget = ImageHelper.load(
        path: item.iconAssetPath!,
        width: size,
        height: size,
      );

      if (widget.iconStyle == SelectionIconStyle.minimal) {
        return SizedBox(width: size, height: size, child: iconWidget);
      }

      // Default style with container
      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(right: 8),
        child: iconWidget,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    final selectedItem = _selectedItem;
    final defaultPadding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: AppTextStyles.labelSmall(color: AppColors.gray300),
        ),
        // Error message
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorMessage!,
            style: AppTextStyles.labelSmall(color: Colors.red),
          ),
        ],
        const SizedBox(height: 8),
        // Selection field
        if (deviceType == DeviceType.mobile)
          // Mobile: Bottom sheet
          InkWell(
            onTap: widget.isLoading ? null : _showMobileBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: widget.isLoading ? 0.6 : 1.0,
              child: Container(
                height: 48,
                padding: defaultPadding,
                decoration: BoxDecoration(
                  color: AppColors.gray900,
                  border: Border.all(
                    color: widget.errorMessage != null
                        ? Colors.red
                        : AppColors.gray700,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Loading indicator
                    if (widget.isLoading) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gray400,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Icon
                    if (!widget.isLoading)
                      _buildIconWidget(
                            selectedItem,
                            size: 32,
                            showInBottomSheet: false,
                          ) ??
                          const SizedBox.shrink(),
                    // Text
                    Expanded(
                      child: Text(
                        selectedItem?.label ?? widget.placeholder,
                        style: AppTextStyles.paragraphMedium(
                          color: selectedItem != null
                              ? AppColors.gray25
                              : AppColors.gray400,
                        ),
                      ),
                    ),
                    // Chevron icon
                    if (!widget.isLoading)
                      ImageHelper.load(
                        path: AppIcons.chevronDown,
                        width: 20,
                        height: 20,
                        color: AppColors.gray25,
                      ),
                  ],
                ),
              ),
            ),
          )
        else
          // Web/Tablet: SelectionMenu
          LayoutBuilder(
            builder: (context, constraints) => InkWell(
              onTap: widget.isLoading
                  ? null
                  : () async {
                      _isMenuOpen.value = true;

                      final selectedValue = await SelectionMenu.show(
                        context: context,
                        items: widget.items,
                        buttonKey: _buttonKey,
                        buttonWidth: constraints.maxWidth,
                        selectedValue: widget.selectedValue,
                      );

                      if (mounted) {
                        _isMenuOpen.value = false;
                      }

                      // Chỉ gọi onSelected nếu giá trị thay đổi
                      if (selectedValue != null &&
                          mounted &&
                          selectedValue != widget.selectedValue) {
                        widget.onSelected(selectedValue);
                      }
                    },
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: widget.isLoading ? 0.6 : 1.0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isMenuOpen,
                  builder: (context, isMenuOpen, child) {
                    return Container(
                      key: _buttonKey,
                      height: 48,
                      padding: defaultPadding,
                      decoration: BoxDecoration(
                        color: AppColors.gray900,
                        border: Border.all(
                          color: widget.errorMessage != null
                              ? Colors.red
                              : isMenuOpen
                              ? AppColors.yellow300
                              : AppColors.gray700,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Loading indicator
                          if (widget.isLoading) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.gray400,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Icon
                          if (!widget.isLoading)
                            _buildIconWidget(
                                  selectedItem,
                                  size: 32,
                                  showInBottomSheet: false,
                                ) ??
                                const SizedBox.shrink(),
                          // Text
                          Expanded(
                            child: Text(
                              selectedItem?.label ?? widget.placeholder,
                              style: AppTextStyles.paragraphMedium(
                                color: selectedItem != null
                                    ? AppColors.gray25
                                    : AppColors.gray400,
                              ),
                            ),
                          ),
                          // Chevron icon - changes based on menu state
                          if (!widget.isLoading)
                            ImageHelper.load(
                              path: isMenuOpen
                                  ? AppIcons.chevronUp
                                  : AppIcons.chevronDown,
                              width: 20,
                              height: 20,
                              color: AppColors.gray25,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
