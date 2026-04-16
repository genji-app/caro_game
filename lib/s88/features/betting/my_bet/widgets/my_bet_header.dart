import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'my_bet_cascading_menu.dart';

class MyBetHeader extends StatelessWidget implements PreferredSizeWidget {
  const MyBetHeader({
    super.key,
    this.onClosePressed,
    this.onMenuChanged,
    this.myBetCount = 0,
    this.bettingSlipCount = 0,
    this.padding = const EdgeInsetsDirectional.only(end: 4),
  });

  //
  final EdgeInsetsGeometry padding;

  /// Optional callback when close button is pressed
  /// If null, defaults to Navigator.pop()
  final VoidCallback? onClosePressed;

  /// Callback when menu entry changes
  final ValueChanged<MyBetMenuEntry>? onMenuChanged;

  /// Overridable count for 'My Bet' badge
  final int myBetCount;

  /// Overridable count for 'Betting Slip' badge
  final int bettingSlipCount;

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.amberAccent,
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyBetCascadingMenu(
            onMenuChanged: onMenuChanged,
            myBetCount: myBetCount,
            bettingSlipCount: bettingSlipCount,
          ),
          CloseButton(
            onPressed: onClosePressed,
            color: AppColorStyles.contentSecondary,
          ),
        ],
      ),
    );
  }
}
