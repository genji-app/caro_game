import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// An enhanced enum to define the available menus and their shortcuts.
enum MyBetMenuEntry { bettingSlip, myBet }

extension LinkMenuEntryEx on MyBetMenuEntry {
  Widget get icon => switch (this) {
    MyBetMenuEntry.bettingSlip => ImageHelper.load(
      path: AppIcons.icBettingSlip,
    ),
    MyBetMenuEntry.myBet => ImageHelper.load(path: AppIcons.icMyBet),
  };

  String get label => switch (this) {
    MyBetMenuEntry.bettingSlip => I18n.txtBettingSlip,
    MyBetMenuEntry.myBet => I18n.txtMyBets,
  };
}

class MyBetCascadingMenu extends StatefulWidget {
  const MyBetCascadingMenu({
    super.key,
    this.onMenuChanged,
    this.myBetCount = 0,
    this.bettingSlipCount = 0,
    this.initialValue = MyBetMenuEntry.bettingSlip,
  });

  final ValueChanged<MyBetMenuEntry>? onMenuChanged;
  final int myBetCount;
  final int bettingSlipCount;
  final MyBetMenuEntry? initialValue;

  @override
  State<MyBetCascadingMenu> createState() => _MyBetCascadingMenuState();
}

class _MyBetCascadingMenuState extends State<MyBetCascadingMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  late final ValueNotifier<MyBetMenuEntry> _selectedMenuNotifier;
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _selectedMenuNotifier = ValueNotifier(
      widget.initialValue ?? MyBetMenuEntry.bettingSlip,
    );
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    _selectedMenuNotifier.dispose();
    _isOpenNotifier.dispose();
    super.dispose();
  }

  void _activate(MyBetMenuEntry selection) {
    if (_selectedMenuNotifier.value != selection) {
      _selectedMenuNotifier.value = selection;
      widget.onMenuChanged?.call(selection);
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
      ),
      menuChildren: [
        ValueListenableBuilder<MyBetMenuEntry>(
          valueListenable: _selectedMenuNotifier,
          builder: (context, selected, _) {
            return MyBetMenuItemButton(
              selected: selected == MyBetMenuEntry.bettingSlip,
              onPressed: () => _activate(MyBetMenuEntry.bettingSlip),
              leadingIcon: MyBetMenuEntry.bettingSlip.icon,
              trailingIcon: MyBetBadgeCount(count: widget.bettingSlipCount),
              child: Text(MyBetMenuEntry.bettingSlip.label),
            );
          },
        ),
        ValueListenableBuilder<MyBetMenuEntry>(
          valueListenable: _selectedMenuNotifier,
          builder: (context, selected, _) {
            return MyBetMenuItemButton(
              selected: selected == MyBetMenuEntry.myBet,
              onPressed: () => _activate(MyBetMenuEntry.myBet),
              leadingIcon: MyBetMenuEntry.myBet.icon,
              trailingIcon: MyBetBadgeCount(count: widget.myBetCount),
              child: Text(MyBetMenuEntry.myBet.label),
            );
          },
        ),
      ],
      builder: (context, controller, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isOpenNotifier,
          builder: (context, isOpen, _) {
            return ValueListenableBuilder<MyBetMenuEntry>(
              valueListenable: _selectedMenuNotifier,
              builder: (context, selectedValue, _) {
                return MyBetTriggerButton(
                  label: selectedValue.label,
                  leadingIcon: selectedValue.icon,
                  isOpen: isOpen,
                  // Show appropriate badge based on selection
                  trailingIcon: selectedValue == MyBetMenuEntry.bettingSlip
                      ? MyBetBadgeCount(count: widget.bettingSlipCount)
                      : MyBetBadgeCount(count: widget.myBetCount),
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
      },
    );
  }
}

class MyBetTriggerButton extends StatelessWidget {
  const MyBetTriggerButton({
    required this.label,
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.isOpen = false,
  });

  final String label;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    // return InkWell(
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        // borderRadius: BorderRadius.circular(16),
        child: Padding(
          // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Row(
                  key: ValueKey<String>(label),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[leadingIcon!, const Gap(8)],
                    Flexible(
                      child: Text(
                        label,
                        style: AppTextStyles.labelSmall(
                          color: AppColorStyles.contentPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null) ...[const Gap(8), trailingIcon!],
              const Gap(8),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: const Icon(
                  Icons.expand_more_rounded,
                  size: 27,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBetMenuItemButton extends StatelessWidget {
  const MyBetMenuItemButton({
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.child,
    this.onPressed,
    this.selected = false,
  });

  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        foregroundColor: const WidgetStatePropertyAll(
          AppColorStyles.contentPrimary,
        ),
        backgroundColor: selected
            ? const WidgetStatePropertyAll(AppColorStyles.backgroundQuaternary)
            : null,
      ),
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [trailingIcon!, const Gap(64)],
            )
          : null,
      child: child,
    );
  }
}

class MyBetBadgeCount extends StatelessWidget {
  const MyBetBadgeCount({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.green300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: AppTextStyles.labelXSmall(color: AppColors.gray950).copyWith(
          fontWeight: FontWeight.w700,
          height: 1.1, // Adjust line height for better centering
        ),
      ),
    );
  }
}
