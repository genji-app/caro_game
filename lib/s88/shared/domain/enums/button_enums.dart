import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

/// Button Size Enum
enum ShineButtonSize { small, medium, large, xl }

/// Button Style với 3 màu cho 3 trạng thái: default, hover, pressed
enum ShineButtonStyle {
  /// Primary Gray: gray950 -> gray800 -> gray700
  primaryGray(
    defaultColor: AppColors.gray950,
    hoverColor: AppColors.gray800,
    pressedColor: AppColors.gray700,
  ),

  /// Primary Yellow: yellow700 -> yellow800 -> yellow900
  primaryYellow(
    defaultColor: AppColors.yellow700,
    hoverColor: AppColors.yellow800,
    pressedColor: AppColors.yellow900,
  ),

  /// Primary Red: red700 -> red800 -> red900
  primaryRed(
    defaultColor: AppColors.red700,
    hoverColor: AppColors.red800,
    pressedColor: AppColors.red900,
  );

  final Color defaultColor;
  final Color hoverColor;
  final Color pressedColor;

  const ShineButtonStyle({
    required this.defaultColor,
    required this.hoverColor,
    required this.pressedColor,
  });
}
