import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:co_caro_flame/s88/core/constants/breakpoints.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

class AppTextStyles {
  AppTextStyles._();

  static const double _scaleMobile = 1.0;
  static const double _scaleTablet = 1.5;
  static const double _scaleDesktop = 1.1;

  static double _fontScale(BuildContext? context) {
    if (context == null) return _scaleMobile;
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.desktop) return _scaleDesktop;
    if (w >= Breakpoints.mobile) return _scaleTablet;
    return _scaleMobile;
  }

  static double _fontSize(BuildContext? context, double base) =>
      base * _fontScale(context);

  static TextStyle _base({
    required double fontSize,
    required double height,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color ?? AppColorStyles.backgroundPrimary,
      letterSpacing: letterSpacing ?? 0,
      decoration: decoration,
    );
  }

  // ========== Heading Styles (Plus Jakarta Sans, Semibold) ==========

  /// Heading XXLarge: 48px, lineHeight: 56, weight: 600
  static TextStyle headingXXLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 48),
    height: 56 / 48,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading XLarge: 40px, lineHeight: 48, weight: 600
  static TextStyle headingXLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 40),
    height: 48 / 40,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading Large: 32px, lineHeight: 40, weight: 600
  static TextStyle headingLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 32),
    height: 40 / 32,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading Medium: 28px, lineHeight: 36, weight: 600
  static TextStyle headingMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 28),
    height: 36 / 28,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading Small: 24px, lineHeight: 32, weight: 600
  static TextStyle headingSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 24),
    height: 32 / 24,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading XSmall: 20px, lineHeight: 28, weight: 600
  static TextStyle headingXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 20),
    height: 28 / 20,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading XXSmall: 18px, lineHeight: 28, weight: 600
  static TextStyle headingXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 28 / 18,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Heading XXXSmall: 16px, lineHeight: 20, weight: 600
  static TextStyle headingXXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 20 / 16,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  // ========== Label Styles (Plus Jakarta Sans, Medium) ==========

  /// Label Large: 18px, lineHeight: 28, weight: 500
  static TextStyle labelLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 28 / 18,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Label Medium: 16px, lineHeight: 24, weight: 500
  static TextStyle labelMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 24 / 16,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Label Small: 14px, lineHeight: 20, weight: 500
  static TextStyle labelSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 14),
    height: 20 / 14,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Label XSmall: 12px, lineHeight: 18, weight: 500
  static TextStyle labelXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 12),
    height: 18 / 12,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Label XXSmall: 10px, lineHeight: 16, weight: 500
  static TextStyle labelXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 10),
    height: 16 / 10,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  // ========== Paragraph Styles (Plus Jakarta Sans, Regular) ==========

  /// Paragraph Large: 18px, lineHeight: 28, weight: 400
  static TextStyle paragraphLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 28 / 18,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Paragraph Medium: 16px, lineHeight: 24, weight: 400
  static TextStyle paragraphMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Paragraph Small: 14px, lineHeight: 20, weight: 400
  static TextStyle paragraphSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 14),
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Paragraph XSmall: 12px, lineHeight: 18, weight: 400
  static TextStyle paragraphXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 12),
    height: 18 / 12,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Paragraph XXSmall: 10px, lineHeight: 16, weight: 400
  static TextStyle paragraphXXSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 10),
    height: 16 / 10,
    fontWeight: FontWeight.w500,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  // ========== Button Styles (Plus Jakarta Sans, Semibold) ==========

  /// Button Large: 18px, lineHeight: 24, weight: 600
  static TextStyle buttonLarge({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 18),
    height: 24 / 18,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Button Medium: 16px, lineHeight: 24, weight: 600
  static TextStyle buttonMedium({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 16),
    height: 24 / 16,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  /// Button Small: 14px, lineHeight: 20, weight: 600
  static TextStyle buttonSmall({
    BuildContext? context,
    Color? color,
    double? letterSpacing,
  }) => _base(
    fontSize: _fontSize(context, 14),
    height: 20 / 14,
    fontWeight: FontWeight.bold,
    color: color ?? AppColorStyles.backgroundPrimary,
    letterSpacing: letterSpacing ?? 0,
  );

  // ========== Legacy Helper Methods (for backward compatibility) ==========

  static TextStyle textStyle({
    BuildContext? context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    double? letterSpacing,
  }) => GoogleFonts.plusJakartaSans(
    height: height,
    fontSize: fontSize != null
        ? _fontSize(context, fontSize)
        : _fontSize(context, 12),
    decoration: decoration,
    color: color ?? AppColorStyles.backgroundPrimary,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: letterSpacing ?? 0,
  );

  static TextStyle displayStyle({
    BuildContext? context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    double? letterSpacing,
  }) => GoogleFonts.plusJakartaSans(
    height: height,
    fontSize: fontSize != null
        ? _fontSize(context, fontSize)
        : _fontSize(context, 12),
    decoration: decoration,
    color: color ?? AppColorStyles.backgroundPrimary,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: letterSpacing ?? 0,
  );
}
