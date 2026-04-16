import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';

class SportDesktopHeader extends ConsumerWidget implements PreferredSizeWidget {
  const SportDesktopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      // alignment: Alignment.topCenter,
      children: [
        // Yellow oval shadow at top center
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -20,
          child: ImageHelper.getNetworkImage(
            imageUrl: AppImages.headerShadow,
            fit: BoxFit.fill,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // decoration: const BoxDecoration(color: Color(0xFF070606)),
          child: Row(
            children: [
              // Left: Logo and Search
              Row(
                children: [
                  // Sun88 Logo
                  SizedBox(
                    height: 44,
                    child: ImageHelper.load(
                      path: AppIcons.sun88,
                      width: 102.406,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Search Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: ImageHelper.load(
                          path: AppIcons.btnSearch,
                          width: 44,
                          height: 44,
                          color: const Color(0xB3FFFFFF), // opacity-70 white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Center: Balance Section
              SizedBox(
                width: 219,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      // width: 119,
                      height: 44,
                      child: ImageHelper.getNetworkImage(
                        imageUrl: AppImages.backgroundBalance,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: ImageHelper.load(
                                path: AppIcons.moneyTxt,
                                width: 119,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Refill Button
                          //AppIcons.btnRefill.svg(
                          //   width: 56,
                          //   height: 36,
                          //   fit: BoxFit.contain,
                          // ),
                          ImageHelper.getNetworkImage(
                            imageUrl: AppImages.btnRefill,
                            width: 56,
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Right: Betting Ticket, Notification, Avatar
              Row(
                children: [
                  // Betting Ticket Badge
                  Container(
                    height: 44,
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 12,
                      top: 10,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0x0FFFFCDB,
                      ), // rgba(255, 252, 219, 0.06)
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD791), // #ffd791
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '4',
                              style: AppTextStyles.textStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF27231C),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Phiếu cược',
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xB3FFFCDB), // opacity-70
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notification Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: ImageHelper.load(
                          path: AppIcons.btnNotification,
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  ProfileAvatar.user(
                    size: const Size.square(44),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    onPressed: () {
                      ProfileNavigation.maybeOf(context)?.close();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68); // 12*2 + 44
}
