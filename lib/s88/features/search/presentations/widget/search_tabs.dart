import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/shared/widgets/tab_layout/s88_tab.dart';

/// Tab Thể thao | Casino cho search. Dùng chung cho dialog và mobile.
class SearchTabs extends StatelessWidget {
  const SearchTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.tabs,
    this.backgroundColor = Colors.transparent,
    this.defaultColor,
    this.selectedColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.borderColor,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  /// Mặc định Thể thao (iconSoccer) + Casino (iconCasino).
  final List<S88TabItem>? tabs;

  final Color backgroundColor;
  final Color? defaultColor;
  final Color? selectedColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? borderColor;

  static final List<S88TabItem> defaultTabs = [
    S88TabItem(text: 'Thể thao', iconPath: AppIcons.iconSoccer),
    S88TabItem(text: 'Casino', iconPath: AppIcons.iconCasino),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor ?? AppColorStyles.borderPrimary,
            width: 1,
          ),
        ),
      ),
      child: S88Tab(
        tabs: tabs ?? defaultTabs,
        selectedIndex: selectedIndex,
        onTabChanged: onTabChanged,
        backgroundColor: backgroundColor,
        defaultColor: defaultColor ?? AppColorStyles.contentSecondary,
        selectedColor: selectedColor ?? AppColors.yellow300,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
