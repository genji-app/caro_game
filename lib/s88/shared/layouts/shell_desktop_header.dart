import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/preferences/bet/odds_info.dart';
import 'package:co_caro_flame/s88/features/preferences/bet/preferences/bet_preferences.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/features/notification/presentation/notification_panel.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_dialog.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';
import 'package:co_caro_flame/s88/shared/widgets/balance_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';

/// Header chung cho desktop layout
/// Sử dụng lại từ sport_desktop_header
class ShellDesktopHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ShellDesktopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Yellow oval shadow at top center
        Positioned(
          top: 0,
          left: 50,
          right: 50,
          bottom: 20,
          child: ImageHelper.getNetworkImage(
            imageUrl: AppImages.headerShadow,
            fit: BoxFit.fill,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const sidebarWidth = 260.0;
            const gap = AppSpacingStyles.space300;
            const rightSidebarWidth = 402.0;
            const mainMaxWidth = 1140.0;
            final availableForContent =
                constraints.maxWidth -
                sidebarWidth -
                gap -
                gap -
                rightSidebarWidth;
            final contentWidth = availableForContent > mainMaxWidth
                ? mainMaxWidth
                : availableForContent;
            final mainContentLeft =
                sidebarWidth + gap + (availableForContent - contentWidth) / 2;

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Left: Logo and Search
                      Row(
                        children: [
                          // Sun88 Logo
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                ref.read(mainContentProvider.notifier).goToHome();
                              },
                              child: SizedBox(
                                height: 44,
                                child: ImageHelper.load(
                                  path: AppImages.logoS88Home,
                                  width: 60,
                                  height: 56,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 120),
                        ],
                      ),
                      const Spacer(),
                      // Center: Balance Section (only show if authenticated)
                      if (isAuthenticated)
                        BalanceContainer(balance: balanceVND, width: 236),
                      const Spacer(),
                      // Right: Show different widgets based on authentication
                      if (isAuthenticated)
                        // Authenticated: Show Betting Ticket, Notification, Avatar
                        Row(
                          children: [
                            // Betting Ticket Badge
                            MyBetOverlayToggleButton(
                              // Use GlobalKey from FlyingBetController for animation target
                              key: FlyingBetController
                                  .instance
                                  .desktopBettingBadgeKey,
                            ),
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => SearchDialog.show(context),
                                borderRadius: BorderRadius.circular(100),
                                child: Center(
                                  child: ImageHelper.load(
                                    path: AppIcons.btnSearch,
                                    width: 44,
                                    height: 44,
                                    color: const Color(0xB3FFFFFF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Notification Button
                            Builder(
                              builder: (anchorContext) {
                                return Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0x1A000000),
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    onTap: () => NotificationPanel.show(
                                      context,
                                      anchorContext: anchorContext,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    child: Center(
                                      child: ImageHelper.load(
                                        path: AppIcons.btnNotification,
                                        width: 44,
                                        height: 44,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            // Avatar - Click to open profile overlay
                            ProfileAvatar.user(
                              size: const Size.square(44),
                              onPressed: () {
                                ProfileNavigation.of(context).toggle();
                              },
                            ),
                          ],
                        )
                      else
                        // Not authenticated: Show Login and Register buttons
                        Row(
                          children: [
                            // Login Button
                            ShineButton(
                              text: I18n.txtLogin,
                              size: ShineButtonSize.large,
                              height: 44,
                              style: ShineButtonStyle.primaryGray,
                              onPressed: () {
                                GoRouter.of(context).push('/auth/true');
                              },
                            ),
                            const SizedBox(width: 12),
                            // Register Button
                            ShineButton(
                              text: I18n.txtRegister,
                              size: ShineButtonSize.large,
                              height: 44,
                              style: ShineButtonStyle.primaryYellow,
                              onPressed: () {
                                GoRouter.of(context).push('/auth/false');
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: mainContentLeft,
                  child: _buildOddStyleButton(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOddStyleButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ProfileNavigation.of(context).pushToSettingsAndRemoveUntil();
        },
        child: Container(
          decoration: BoxDecoration(
            // color: Color(0x1A000000),
            border: Border.all(color: const Color(0x33FFFFFF)),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1000),
            child: Stack(
              children: [
                Positioned.fill(
                  right: -1,
                  child: ImageHelper.load(
                    path: AppIcons.backgroundOddStyle,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tỷ lệ cược:',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentTertiary,
                        ),
                      ),
                      const Gap(30),
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final oddsStyle = ref.watch(
                                betPreferencesProvider.select(
                                  (s) => s.oddsStyle,
                                ),
                              );
                              return Text(
                                oddsStyle.label,
                                style: AppTextStyles.labelXSmall(
                                  color: AppColors.green300,
                                ),
                              );
                            },
                          ),
                          const Gap(8),
                          ImageHelper.load(
                            path: AppIcons.iconSwitch,
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

// /// Betting ticket badge widget - separate to isolate provider watching
// /// This widget is the target for flying bet animation on desktop
// class _BettingTicketBadge extends ConsumerWidget {
//   const _BettingTicketBadge();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch parlay bet counts for badge
//     final singleBetsCount = ref.watch(singleBetsCountProvider);
//     final comboBetsCount = ref.watch(comboBetsCountProvider);
//     final minMatches = ref.watch(minMatchesProvider);
//     // Combo only counts as 1 valid ticket if it has enough matches
//     final hasValidCombo = comboBetsCount >= minMatches;
//     final totalBetCount = singleBetsCount + (hasValidCombo ? 1 : 0);

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         // Use GlobalKey from FlyingBetController for animation target
//         key: FlyingBetController.instance.desktopBettingBadgeKey,
//         onTap: () => ref.read(myBetOverlayVisibleProvider.notifier).open(),
//         borderRadius: BorderRadius.circular(1000),
//         child: Container(
//           height: 44,
//           padding: const EdgeInsets.only(
//             left: 8,
//             right: 12,
//             top: 10,
//             bottom: 10,
//           ),
//           decoration: BoxDecoration(
//             color: const Color(0x0FFFFCDB),
//             borderRadius: BorderRadius.circular(1000),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // BettingTicketBadge(),
//               // Container(
//               //   width: 28,
//               //   height: 24,
//               //   decoration: BoxDecoration(
//               //     color: const Color(0xFFFFD791),
//               //     borderRadius: BorderRadius.circular(16),
//               //   ),
//               //   child: Center(
//               //     child: Text(
//               //       totalBetCount > 99 ? '99+' : totalBetCount.toString(),
//               //       style: AppTextStyles.textStyle(
//               //         fontSize: 12,
//               //         fontWeight: FontWeight.w600,
//               //         color: const Color(0xFF27231C),
//               //       ),
//               //     ),
//               //   ),
//               // ),
//               // const SizedBox(width: 8),
//               // Text(
//               //   'Phiếu cược',
//               //   style: AppTextStyles.textStyle(
//               //     fontSize: 12,
//               //     fontWeight: FontWeight.w400,
//               //     color: const Color(0xB3FFFCDB),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
