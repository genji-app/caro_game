import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/features/search/presentations/mobile/search_mobile_screen.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';
import 'package:co_caro_flame/s88/shared/widgets/balance_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';

class SportDetailMobileHeader extends ConsumerWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;

  const SportDetailMobileHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceVND = ref.watch(balanceInVNDProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      decoration: const BoxDecoration(
        color: AppColorStyles.backgroundPrimary,
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     Color(0xFF000000), // #000000
        //     Color(0x00000000), // rgba(0,0,0,0) (transparent)
        //   ],
        //   stops: [0.0, 1.0], // Black until 50.61%, then fade to transparent
        // ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundQuaternary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ImageHelper.load(
                path: AppIcons.icBack,
                width: 24,
                height: 24,
                color: const Color(0xFFFFFCDB),
              ),
            ),
          ),
          const Spacer(),
          // Center: Balance Section
          if (isAuthenticated)
            BalanceContainer(balance: balanceVND, width: 210),
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
                  text: 'Đăng nhập',
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
                  text: 'Đăng ký',
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
