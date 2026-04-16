import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/features/notification/presentation/notification_panel.dart';
import 'package:co_caro_flame/s88/features/search/presentations/mobile/search_mobile_screen.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';
import 'package:co_caro_flame/s88/shared/widgets/balance_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';

/// Header chung cho mobile layout
class ShellMobileHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ShellMobileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);
    return Container(
      color: const Color(0xFF111010),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF000000), // #000000
                    Color(0x00000000), // rgba(0,0,0,0) (transparent)
                  ],
                  stops: [
                    0.0,
                    1.0,
                  ], // Black until 50.61%, then fade to transparent
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColorStyles.borderSecondary,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Left: Logo
                SizedBox(
                  child: ImageHelper.getNetworkImage(
                    imageUrl: AppImages.logoS88Home,
                    width: 60,
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Center: Balance Section
                if (isAuthenticated)
                  BalanceContainer(balance: balanceVND, width: 146),
                const Spacer(),
                GestureDetector(
                  onTap: () => SearchMobileScreen.showAsBottomSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: ImageHelper.load(
                    path: AppIcons.btnSearch,
                    width: 44,
                    height: 44,
                    color: const Color(0xB3FFFFFF),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColorStyles.backgroundTertiary,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: isAuthenticated
                        ? () => NotificationPanel.show(context)
                        : null,
                    borderRadius: BorderRadius.circular(100),
                    child: Center(
                      child: ImageHelper.load(
                        path: AppIcons.iconNotification,
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Avatar
                if (isAuthenticated)
                  ProfileAvatar.user(
                    size: const Size.square(44),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    onPressed: () => context.openProfile(),
                  ),
                if (!isAuthenticated)
                  // Not authenticated: Show Login and Register buttons
                  Row(
                    children: [
                      // Login Button
                      ShineButton(
                        text: I18n.txtLogin,
                        size: ShineButtonSize.large,
                        height: 36,
                        style: ShineButtonStyle.primaryGray,
                        onPressed: () {
                          // TODO: Navigate to login screen
                          GoRouter.of(context).push('/auth/true');
                        },
                      ),
                      const SizedBox(width: 12),
                      // Register Button
                      ShineButton(
                        text: I18n.txtRegister,
                        size: ShineButtonSize.large,
                        height: 36,
                        style: ShineButtonStyle.primaryYellow,
                        onPressed: () {
                          // TODO: Navigate to register screen
                          GoRouter.of(context).push('/auth/false');
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
