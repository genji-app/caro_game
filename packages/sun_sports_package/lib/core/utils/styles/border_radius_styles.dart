import 'package:flutter/material.dart';

class AppBorderRadiusStyles {
  AppBorderRadiusStyles._();

  // ========== Primitive Border Radius Tokens ==========

  /// border-radius-0: 0px
  static const double radius0 = 0;

  /// border-radius-050: 2px
  static const double radius050 = 2;

  /// border-radius-100: 4px
  static const double radius100 = 4;

  /// border-radius-150: 6px
  static const double radius150 = 6;

  /// border-radius-200: 8px
  static const double radius200 = 8;

  /// border-radius-300: 12px
  static const double radius300 = 12;

  /// border-radius-400: 16px
  static const double radius400 = 16;

  /// border-radius-500: 20px
  static const double radius500 = 20;

  /// border-radius-750: 30px
  static const double radius750 = 30;

  /// border-radius-full: 9999px (fully rounded)
  static const double radiusFull = 9999;

  // ========== BorderRadius Objects (for direct use) ==========

  /// border-radius-0: 0px
  static const BorderRadius borderRadius0 = BorderRadius.zero;

  /// border-radius-050: 2px
  static BorderRadius get borderRadius050 => BorderRadius.circular(radius050);

  /// border-radius-100: 4px
  static BorderRadius get borderRadius100 => BorderRadius.circular(radius100);

  /// border-radius-150: 6px
  static BorderRadius get borderRadius150 => BorderRadius.circular(radius150);

  /// border-radius-200: 8px
  static BorderRadius get borderRadius200 => BorderRadius.circular(radius200);

  /// border-radius-300: 12px
  static BorderRadius get borderRadius300 => BorderRadius.circular(radius300);

  /// border-radius-400: 16px
  static BorderRadius get borderRadius400 => BorderRadius.circular(radius400);

  /// border-radius-500: 20px
  static BorderRadius get borderRadius500 => BorderRadius.circular(radius500);

  /// border-radius-750: 30px
  static BorderRadius get borderRadius750 => BorderRadius.circular(radius750);

  /// border-radius-full: fully rounded
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ========== Semantic Border Radius Tokens ==========

  /// button-radius: border-radius-200 (8px)
  static const double buttonRadius = radius200;

  /// group-button-radius: border-radius-200 (8px)
  static const double groupButtonRadius = radius200;

  /// input-radius: border-radius-200 (8px)
  static const double inputRadius = radius200;

  /// card-radius: border-radius-300 (12px)
  static const double cardRadius = radius300;

  /// popover-radius: border-radius-300 (12px)
  static const double popoverRadius = radius300;

  // ========== Semantic BorderRadius Objects ==========

  /// button-radius: border-radius-200 (8px)
  static BorderRadius get buttonBorderRadius => borderRadius200;

  /// group-button-radius: border-radius-200 (8px)
  static BorderRadius get groupButtonBorderRadius => borderRadius200;

  /// input-radius: border-radius-200 (8px)
  static BorderRadius get inputBorderRadius => borderRadius200;

  /// card-radius: border-radius-300 (12px)
  static BorderRadius get cardBorderRadius => borderRadius300;

  /// popover-radius: border-radius-300 (12px)
  static BorderRadius get popoverBorderRadius => borderRadius300;
}
