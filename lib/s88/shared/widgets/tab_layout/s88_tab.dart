import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart';
import 'package:co_caro_flame/s88/core/services/models/sport_enums.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/border_radius_styles.dart';

final List<S88TabItem> sportTabItems = [
  S88TabItem(text: 'Bóng đá', iconPath: AppIcons.iconSoccer),
  S88TabItem(text: 'Cầu lông', iconPath: AppIcons.iconBadminton),
  S88TabItem(text: 'Bóng rổ', iconPath: AppIcons.iconBasketball),
  S88TabItem(text: 'Bóng chuyền', iconPath: AppIcons.iconVolleyball),
  S88TabItem(text: 'Quần vợt', iconPath: AppIcons.iconTennis),
];

final List<int> sportIds = [
  SportType.soccer.id,
  SportType.badminton.id,
  SportType.basketball.id,
  SportType.volleyball.id,
  SportType.tennis.id,
];

/// Data for a single tab: [text] and optional [iconPath].
class S88TabItem {
  final String text;
  final String? iconPath;

  const S88TabItem({required this.text, this.iconPath});
}

/// Reusable tab bar component.
///
/// - **text, icon**: via [tabs] as [S88TabItem] (icon optional).
/// - **width**: if [width] is set use it; if null, takes full width.
/// - **height**: tab bar height; default 44.
/// - **isScrollable**: when true, tabs scroll horizontally (supports overlapsContent / many tabs).
/// - **colors**: [defaultColor] (unselected), [selectedColor].
/// - **borderRadius**: [borderRadius]; default 12px top corners.
/// - Optional selected indicator (glow image) via [selectedIndicatorPath].
class S88Tab extends StatelessWidget {
  final List<S88TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  /// If non-null, tab bar has this width; otherwise expands to parent (full width).
  final double? width;

  /// Height of the tab bar. Default 44.
  final double height;

  /// When true, tabs are in a horizontal scroll view so many tabs don't overflow;
  /// supports use in overlapping headers (overlapsContent).
  final bool isScrollable;

  /// When [isScrollable] is true, minimum width per tab. Ignored when [isScrollable] is false.
  final double scrollableTabWidth;

  /// Unselected tab text/icon color.
  final Color defaultColor;

  /// Selected tab text/icon color.
  final Color selectedColor;

  /// Tab bar container border radius.
  final BorderRadius borderRadius;

  /// Background color of the tab bar.
  final Color backgroundColor;

  /// Optional: path to image used as selected indicator (e.g. glow). If null, uses [AppIcons.sportStatusSelected].
  final String? selectedIndicatorPath;

  /// Padding for each tab content (icon + text).
  final EdgeInsets tabPadding;

  /// Font size for tab label.
  final double fontSize;

  /// Font weight for tab label.
  final FontWeight fontWeight;

  const S88Tab({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.width,
    this.height = 44,
    this.isScrollable = false,
    this.scrollableTabWidth = 88,
    Color? defaultColor,
    Color? selectedColor,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    this.selectedIndicatorPath,
    EdgeInsets? tabPadding,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
  }) : defaultColor = defaultColor ?? AppColors.gray300,
       selectedColor = selectedColor ?? AppColors.yellow300,
       borderRadius =
           borderRadius ??
           const BorderRadius.only(
             topLeft: Radius.circular(AppBorderRadiusStyles.radius300),
             topRight: Radius.circular(AppBorderRadiusStyles.radius300),
           ),
       backgroundColor = backgroundColor ?? AppColorStyles.backgroundTertiary,
       tabPadding = tabPadding ?? const EdgeInsets.all(0);

  @override
  Widget build(BuildContext context) {
    final rowChildren = List.generate(tabs.length, (index) {
      final item = tabs[index];
      final isSelected = selectedIndex == index;
      final tile = _S88TabTile(
        text: item.text,
        iconPath: item.iconPath,
        isSelected: isSelected,
        defaultColor: defaultColor,
        selectedColor: selectedColor,
        tabPadding: tabPadding,
        fontSize: fontSize,
        fontWeight: fontWeight,
        indicatorPath: selectedIndicatorPath ?? AppIcons.sportStatusSelected,
        onTap: () => onTabChanged(index),
      );
      if (isScrollable) {
        return SizedBox(width: scrollableTabWidth, child: tile);
      }
      return Expanded(child: tile);
    });

    final rowOrScroll = isScrollable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
          )
        : Row(children: rowChildren);

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: backgroundColor,
              ),
            ),
          ),
          rowOrScroll,
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, height: height, child: content);
    }
    return SizedBox(height: height, child: content);
  }
}

class _S88TabTile extends StatelessWidget {
  final String text;
  final String? iconPath;
  final bool isSelected;
  final Color defaultColor;
  final Color selectedColor;
  final EdgeInsets tabPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final String indicatorPath;
  final VoidCallback onTap;

  const _S88TabTile({
    required this.text,
    this.iconPath,
    required this.isSelected,
    required this.defaultColor,
    required this.selectedColor,
    required this.tabPadding,
    required this.fontSize,
    required this.fontWeight,
    required this.indicatorPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : defaultColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ImageHelper.load(path: indicatorPath, fit: BoxFit.fill),
              ),
            Center(
              child: Padding(
                padding: tabPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconPath != null) ...[
                      RepaintBoundary(
                        child: ImageHelper.load(
                          path: iconPath!,
                          width: 16,
                          height: 16,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      text,
                      style: AppTextStyles.paragraphXSmall(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
