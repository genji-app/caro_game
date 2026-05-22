import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

/// Quick amount button item.
///
/// [isSelected] is the **initial** selected state used the first time the
/// enclosing [QuickAmountButtons] mounts. After mount, [QuickAmountButtons]
/// owns the selection internally — tapping a button promotes it to
/// `selected` and demotes every other button. Defaults to `false` so
/// existing callsites start with nothing selected.
class QuickAmountButton {
  final String label;
  final String value;
  final bool isSelected;

  const QuickAmountButton({
    required this.label,
    required this.value,
    this.isSelected = false,
  });
}

/// Quick amount buttons widget - Grid of buttons for quick amount selection.
///
/// Selection is managed **internally**:
///   - On first build the widget picks up the initial selection from any
///     button whose `isSelected` is `true` (or `null` if none).
///   - When the user taps a button, that button becomes selected and every
///     other button is deselected.
///   - The [onButtonTap] callback still fires on every tap so the caller
///     can react (update form state, recompute totals, ...).
///
/// The widget does NOT keep itself in sync with subsequent prop changes to
/// `isSelected` on the button items. Pass a unique `key` to force a reset
/// if the upstream selection has to override the internal state.
class QuickAmountButtons extends StatefulWidget {
  /// List of quick amount buttons (labels and values)
  final List<QuickAmountButton> buttons;

  /// Callback when a button is tapped
  final void Function(String value) onButtonTap;

  /// Number of columns per row (default: 4)
  final int columnsPerRow;

  /// Spacing between buttons (default: 5)
  final double spacing;

  const QuickAmountButtons({
    super.key,
    required this.buttons,
    required this.onButtonTap,
    this.columnsPerRow = 4,
    this.spacing = 5,
  });

  @override
  State<QuickAmountButtons> createState() => _QuickAmountButtonsState();
}

class _QuickAmountButtonsState extends State<QuickAmountButtons> {
  /// Currently selected button's value, or `null` when nothing is selected.
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    // Seed the initial selection from the first button flagged `isSelected`,
    // if any. Otherwise leave it null so no button is highlighted.
    for (final QuickAmountButton button in widget.buttons) {
      if (button.isSelected) {
        _selectedValue = button.value;
        break;
      }
    }
  }

  void _handleTap(QuickAmountButton button) {
    if (_selectedValue != button.value) {
      setState(() => _selectedValue = button.value);
    }
    widget.onButtonTap(button.value);
  }

  @override
  Widget build(BuildContext context) {
    // Split buttons into rows
    final rows = <List<QuickAmountButton>>[];
    for (var i = 0; i < widget.buttons.length; i += widget.columnsPerRow) {
      rows.add(
        widget.buttons.sublist(
          i,
          i + widget.columnsPerRow > widget.buttons.length
              ? widget.buttons.length
              : i + widget.columnsPerRow,
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
                    isSelected: button.value == _selectedValue,
                    onTap: () => _handleTap(button),
                  ),
                ),
                if (button != rows[i].last) Gap(widget.spacing),
              ],
            ],
          ),
          if (i < rows.length - 1) Gap(widget.spacing),
        ],
      ],
    );
  }
}

/// Individual quick amount button
class _QuickAmountButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  /// Default background tint when the button is not selected — Yellow 200
  /// at 8% opacity, matching the previous visual.
  static final Color _idleBackground = const Color(
    0xFFFDE272,
  ).withValues(alpha: 0.08);

  /// Highlighted background when [isSelected] is true.
  static const Color _selectedBackground = AppColors.yellow950;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(100),
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? _selectedBackground : _idleBackground,
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
