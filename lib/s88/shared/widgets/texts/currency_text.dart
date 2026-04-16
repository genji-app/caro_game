import 'package:flutter/material.dart';

import 'package:co_caro_flame/s88/core/utils/extensions/currency_helper.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Reusable CurrencyText widget that displays amount with custom styling and S-Coin icon
///
/// ## Usage:
/// ```dart
/// // Default with S-Coin suffix
/// CurrencyText.fromNumber(1234567)
///
/// // Custom prefix widget
/// CurrencyText.fromNumber(
///   1234567,
///   prefix: Icon(Icons.add),
/// )
///
/// // Custom suffix (replace default S-Coin)
/// CurrencyText.fromNumber(
///   1234567,
///   suffix: Text('VND'),
/// )
///
/// // No suffix - pass empty widget
/// CurrencyText.fromNumber(
///   1234567,
///   suffix: SizedBox.shrink(),
/// )
///
/// // Use default suffix with custom size
/// CurrencyText.fromNumber(
///   1234567,
///   suffix: CurrencyText.defaultSuffix(size: 32),
/// )
/// ```
class CurrencyText extends StatelessWidget {
  /// Default constructor accepts a pre-formatted string.
  ///
  /// By default, shows [CurrencySymbol] as suffix.
  /// Pass custom [suffix] to replace it, or [SizedBox.shrink()] to hide it.
  const CurrencyText(
    this.text, {
    super.key,
    this.prefixText,
    this.prefix,
    this.suffix,
    this.amountColor,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.iconSize = 24.0,
    this.spacing = 4.0,
  });

  /// Constructor to accept number and format it automatically.
  ///
  /// By default, shows [CurrencySymbol] as suffix.
  /// Pass custom [suffix] to replace it, or [SizedBox.shrink()] to hide it.
  CurrencyText.fromNumber(
    num amount, {
    super.key,
    this.prefixText,
    this.prefix,
    this.suffix,
    this.amountColor,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.iconSize = 24.0,
    this.spacing = 4.0,
  }) : text = formatCurrency(amount);

  // ===========================================================================
  // STATIC HELPERS
  // ===========================================================================

  /// Returns the default suffix widget (S-Coin icon).
  ///
  /// Use this when you want to include the default currency symbol
  /// in a custom context.
  ///
  /// Usage:
  /// ```dart
  /// // Get default suffix with custom size
  /// CurrencyText.defaultSuffix(size: 32)
  ///
  /// // Use in Row with other elements
  /// Row(
  ///   children: [
  ///     Text('Price: 1,000'),
  ///     CurrencyText.defaultSuffix(),
  ///   ],
  /// )
  /// ```
  static Widget defaultSuffix({double size = 24.0}) =>
      CurrencySymbol(size: size);

  /// Default icon size for the currency symbol.
  static const double defaultIconSize = 24.0;

  /// Default spacing between elements.
  static const double defaultSpacing = 4.0;

  /// Formats a number as currency string (without unit).
  ///
  /// This is a convenient wrapper around [CurrencyHelper.formatCurrencyNoUnit].
  /// Can be used outside of widget context.
  ///
  /// Usage:
  /// ```dart
  /// CurrencyText.formatCurrency(1234567);  // "1,234,567"
  /// ```
  static String formatCurrency(num amount) =>
      CurrencyHelper.formatCurrencyNoUnit(amount);

  /// Formats a number as currency string with unit prefix.
  ///
  /// This is a convenient wrapper around [CurrencyHelper.formatCurrencyDouble].
  ///
  /// Usage:
  /// ```dart
  /// CurrencyText.formatCurrencyWithUnit(1234567);  // "$ 1,234,567"
  /// ```
  static String formatCurrencyWithUnit(num amount) {
    if (amount is int) {
      return CurrencyHelper.formatCurrencyInt(amount);
    }
    return CurrencyHelper.formatCurrencyDouble(amount.toDouble());
  }

  /// Formats a string amount as currency.
  ///
  /// This is a convenient wrapper around [CurrencyHelper.formatCurrency].
  ///
  /// Usage:
  /// ```dart
  /// CurrencyText.formatCurrencyString("1234567");  // "$ 1,234,567"
  /// ```
  static String formatCurrencyString(String amount) =>
      CurrencyHelper.formatCurrency(amount);

  // ===========================================================================
  // PROPERTIES
  // ===========================================================================

  /// The formatted currency text to display.
  final String text;

  /// Optional text prefix (displayed before the amount in the same Text widget).
  final String? prefixText;

  /// Optional widget prefix (displayed before the text, as a separate widget).
  final Widget? prefix;

  /// Custom suffix widget. If null, shows default [CurrencySymbol].
  ///
  /// To hide suffix entirely, pass [SizedBox.shrink()].
  /// To use default suffix with custom size, use [CurrencyText.defaultSuffix(size: 32)].
  final Widget? suffix;

  final Color? amountColor;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Size of the default [CurrencySymbol] icon. Default is 24.0.
  /// Ignored if custom [suffix] is provided.
  final double iconSize;

  /// Spacing between elements (prefix, text, suffix). Default is 4.0.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final themeStyle = DefaultTextStyle.of(context).style;

    // Use custom suffix or default CurrencySymbol
    final effectiveSuffix = suffix ?? CurrencySymbol(size: iconSize);

    return Row(
      spacing: spacing,
      mainAxisSize: MainAxisSize.min,

      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Prefix widget (if any)
        if (prefix != null) prefix!,

        // Main text
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                if (prefixText != null) TextSpan(text: prefixText),
                TextSpan(text: text),
              ],
            ),

            // Merge order (lowest to highest priority):
            // 1. themeStyle - inherited from parent (DefaultTextStyle)
            // 2. AppTextStyles.labelSmall - widget default style
            // 3. style - custom style from user (highest priority)
            style: themeStyle
                .merge(AppTextStyles.labelSmall(color: amountColor))
                .merge(style),
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          ),
        ),

        // Suffix widget (always shown - use SizedBox.shrink() to hide)
        effectiveSuffix,
      ],
    );
  }
}

/// S Coin icon - currency unit icon from assets
/// Design from Figma: node-id=3939:13
/// Icon nằm bên phải số tiền
class CurrencySymbol extends StatelessWidget {
  const CurrencySymbol({super.key, this.size = 24.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ImageHelper.load(path: AppIcons.iconCurrencyUnit),
    );
  }
}
