import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Quick amount button item
class QuickAmountButton {
  final String label;
  final String value;

  const QuickAmountButton({required this.label, required this.value});
}

/// Quick amount buttons widget - Grid of buttons for quick amount selection
class QuickAmountButtons extends StatelessWidget {
  /// List of quick amount buttons (labels and values)
  final List<QuickAmountButton> buttons;

  /// Callback when a button is tapped
  final void Function(String value) onButtonTap;

  /// Number of columns per row (default: 4)
  final int columnsPerRow;

  /// Spacing between buttons (default: 8)
  final double spacing;

  const QuickAmountButtons({
    super.key,
    required this.buttons,
    required this.onButtonTap,
    this.columnsPerRow = 4,
    this.spacing = 5,
  });

  @override
  Widget build(BuildContext context) {
    // Split buttons into rows
    final rows = <List<QuickAmountButton>>[];
    for (var i = 0; i < buttons.length; i += columnsPerRow) {
      rows.add(
        buttons.sublist(
          i,
          i + columnsPerRow > buttons.length
              ? buttons.length
              : i + columnsPerRow,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Row(
            children: [
              for (var button in rows[i]) ...[
                Expanded(
                  child: _QuickAmountButton(
                    label: button.label,
                    onTap: () => onButtonTap(button.value),
                  ),
                ),
                if (button != rows[i].last) Gap(spacing),
              ],
            ],
          ),
          if (i < rows.length - 1) Gap(spacing),
        ],
      ],
    );
  }
}

/// Individual quick amount button
class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(100),
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFDE272,
        ).withValues(alpha: 0.08), // yellow-200 with 8% opacity
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.buttonSmall(
            color: const Color(0xFFFEEE95), // yellow-200
          ).copyWith(fontSize: 13),
        ),
      ),
    ),
  );
}
