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
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/preferences/bet/odds_info.dart';
import 'package:co_caro_flame/s88/features/preferences/bet/preferences/bet_preferences.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_dialog.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';
import 'package:co_caro_flame/s88/shared/widgets/balance_container.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/flying_bet_animation.dart';

/// Header chung cho desktop layout
/// Sử dụng lại từ sport_desktop_header
class ShellTabletHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ShellTabletHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final balanceVND = ref.watch(balanceInVNDProvider);

    return Container(
      color: const Color(0xFF111010),
      child: Stack(
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
          Stack(
            clipBehavior: Clip.none,
            // alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Logo
                    GestureDetector(
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
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _buildOddStyleButton(context),
                      ),
                    ),
                    if (isAuthenticated) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: BalanceContainer(
                            balance: balanceVND,
                            width: 236,
                          ),
                        ),
                      ),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: isAuthenticated
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyBetOverlayToggleButton(
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
                                    child: ImageHelper.load(
                                      path: AppIcons.btnSearch,
                                      width: 44,
                                      height: 44,
                                      color: const Color(0xB3FFFFFF),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ProfileAvatar.user(
                                  size: const Size.square(44),
                                  onPressed: () {
                                    ProfileNavigation.of(context).toggle();
                                  },
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOddStyleButton(BuildContext context) {
    return GestureDetector(
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
                    Flexible(
                      child: Text(
                        'Tỷ lệ cược:',
                        style: AppTextStyles.labelXSmall(
                          color: AppColorStyles.contentTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, _) {
                                final oddsStyle = ref.watch(
                                  betPreferencesProvider
                                      .select((s) => s.oddsStyle),
                                );
                                return Text(
                                  oddsStyle.label,
                                  style: AppTextStyles.labelXSmall(
                                    color: AppColors.green300,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                          const Gap(8),
                          ImageHelper.load(
                            path: AppIcons.iconSwitch,
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
