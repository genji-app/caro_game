import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

import 'profile_navigation_appbar.dart';

class ProfileNavigationScaffold extends StatelessWidget {
  const ProfileNavigationScaffold({
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = kBodyVerticalPadding,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  });

  ProfileNavigationScaffold.withDefaultAppBar({
    Widget? title,
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = kBodyVerticalPadding,
    this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  }) : appBar = ProfileNavigationAppBar.autoBack(title: title);

  ProfileNavigationScaffold.withCenterTitle({
    Widget? title,
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.bodyPadding = kBodyVerticalPadding,
    this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  }) : appBar = ProfileNavigationAppBar.autoBack(title: title);

  final Color? backgroundColor;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final bool primary;

  static const kBodyHorizontalPadding = EdgeInsets.symmetric(horizontal: 12);
  static const kBodyVerticalPadding = EdgeInsets.only(top: 20);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: PlatformUtils.isAndroid,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: Container(padding: bodyPadding, child: body),
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
      ),
    );
  }
}
