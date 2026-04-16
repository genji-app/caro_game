import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Reusable table widget - renders only table header and rows
/// Parent is responsible for wrapping with cards, adding section headers, and styling
class AppTable extends StatelessWidget {
  const AppTable({
    required this.header,
    required this.rows,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.rowSpacing = 4.0,
  });

  /// Table columns header widget
  final Widget header;

  /// List of row widgets
  final List<Widget> rows;

  /// Padding around the table content
  final EdgeInsetsGeometry padding;

  /// Spacing between rows
  final double rowSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          header,
          Gap(rowSpacing),
          if (rows.isNotEmpty)
            Column(
              children: List.generate(
                rows.length,
                (index) => Container(
                  margin: EdgeInsets.only(top: index > 0 ? rowSpacing : 0),
                  child: rows[index],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper widget to build consistent table headers
class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({
    required this.columns,
    super.key,
    this.height = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final List<Widget> columns;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      child: Row(children: columns),
    );
  }
}

/// Helper widget to build consistent table data rows
class TableDataRow extends StatelessWidget {
  const TableDataRow({
    required this.columns,
    super.key,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.backgroundColor = AppColorStyles.backgroundQuaternary,
    this.borderRadius = 8.0,
  });

  final List<Widget> columns;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: Row(children: columns),
    );
  }
}

/// Standardized column text style helper
class TableText extends StatelessWidget {
  const TableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.color = AppColorStyles.contentSecondary,
    this.flex = 1,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color color;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: DefaultTextStyle(
        style: style ?? AppTextStyles.labelXSmall(color: color),
        child: Text(text, textAlign: textAlign),
      ),
    );
  }
}
