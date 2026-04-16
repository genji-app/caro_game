import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';

class ProfileNavigationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProfileNavigationAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.surfaceColor = AppColorStyles.contentPrimary,
    this.padding = kPadding,
    this.onBackPressed,
    this.onClosePressed,
    this.showBack = true,
    this.titleStyle,
  }) : _autoHandleBack = false;

  const ProfileNavigationAppBar.autoBack({
    super.key,
    this.title,
    this.backgroundColor,
    this.surfaceColor = AppColorStyles.contentPrimary,
    this.padding = kPadding,
    this.titleStyle,
  }) : _autoHandleBack = true,
       showBack = true,
       onBackPressed = null,
       onClosePressed = null;

  /// Variant that hides the back button and only shows the close button.
  const ProfileNavigationAppBar.closeOnly({
    super.key,
    this.title,
    this.backgroundColor,
    this.surfaceColor = AppColorStyles.contentPrimary,
    this.padding = kPadding,
    this.onClosePressed,
    this.titleStyle,
  }) : _autoHandleBack = false,
       showBack = false,
       onBackPressed = null;

  static const kPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 12);

  final Widget? title;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final EdgeInsets? padding;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClosePressed;
  final bool _autoHandleBack;
  final bool showBack;
  final TextStyle? titleStyle;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    VoidCallback? effectiveOnBackPressed;
    if (_autoHandleBack) {
      final navigator = Navigator.of(context);
      final canPop = navigator.canPop();
      final goBack = canPop ? () => navigator.pop() : null;
      effectiveOnBackPressed = onBackPressed ?? goBack;
    }

    final profileNavigator = ProfileNavigation.maybeOf(context);

    return SizedBox.expand(
      child: Container(
        padding: padding,
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: [
            if (showBack)
              _AppBarAction(
                icon: ImageHelper.load(path: AppIcons.icBack, fit: BoxFit.fill),
                onPressed: effectiveOnBackPressed,
              ),
            if (title != null)
              Flexible(
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headingXXXSmall(
                    color: surfaceColor,
                  ).merge(titleStyle),
                  child: title!,
                ),
              ),

            profileNavigator == null
                ? const SizedBox.shrink()
                : _AppBarAction(
                    onPressed: onClosePressed ?? profileNavigator.close,
                    icon: const Icon(Icons.close),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({this.icon, this.onPressed});

  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      color: AppColorStyles.contentSecondary,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(36),
        disabledBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        side: BorderSide.none,
        disabledForegroundColor: AppColorStyles.contentSecondary,
        foregroundColor: AppColorStyles.contentSecondary,
      ),
      padding: EdgeInsets.zero,
      iconSize: 24,
      onPressed: onPressed,
      icon: SizedBox.square(dimension: 24, child: icon),
    );
  }
}
