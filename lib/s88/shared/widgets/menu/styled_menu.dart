import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

import 'styled_menu_item.dart';
import 'styled_menu_trigger.dart';

class StyledMenuConfig {
  const StyledMenuConfig({
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
}

class StyledMenu<T> extends StatefulWidget {
  const StyledMenu({
    required this.items,
    required this.configBuilder,
    required this.selectedValue,
    required this.onChanged,
    super.key,
    this.minWidth = 160.0,
  });

  final List<T> items;
  final StyledMenuConfig Function(T item) configBuilder;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double minWidth;

  @override
  State<StyledMenu<T>> createState() => _StyledMenuState<T>();
}

class _StyledMenuState<T> extends State<StyledMenu<T>> {
  final FocusNode _buttonFocusNode = FocusNode(
    debugLabel: 'Styled Menu Button',
  );
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    _isOpenNotifier.dispose();
    super.dispose();
  }

  void _activate(T selection) {
    if (widget.selectedValue != selection) {
      widget.onChanged(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      onOpen: () => _isOpenNotifier.value = true,
      onClose: () => _isOpenNotifier.value = false,
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
        backgroundColor: const WidgetStatePropertyAll(
          AppColorStyles.backgroundTertiary,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        minimumSize: WidgetStatePropertyAll(Size(widget.minWidth, 0)),
      ),
      menuChildren: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((entry) {
            final config = widget.configBuilder(entry);
            return StyledMenuItem(
              selected: widget.selectedValue == entry,
              onPressed: () => _activate(entry),
              minWidth: widget.minWidth,
              leadingIcon: config.leadingIcon,
              trailingIcon: config.trailingIcon,
              child: Text(config.label),
            );
          }).toList(),
        ),
      ],
      builder: (context, controller, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isOpenNotifier,
          builder: (context, isOpen, _) {
            final config = widget.configBuilder(widget.selectedValue);
            return StyledMenuTrigger(
              label: config.label,
              isOpen: isOpen,
              minWidth: widget.minWidth,
              leadingIcon: config.leadingIcon,
              trailingIcon: config.trailingIcon,
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
        );
      },
    );
  }
}
