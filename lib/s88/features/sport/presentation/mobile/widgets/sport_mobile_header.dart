import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/currency_helper.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';

class SportMobileHeader extends ConsumerWidget implements PreferredSizeWidget {
  const SportMobileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      // alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Colors.black,
            //     Color(0xFF11100F).withValues(alpha: 0.97),
            //     // Color(0xFF11100F),
            //   ],
            //   stops: [0.3, 1.0],
            // ),
          ),
          child: Row(
            children: [
              // Left: Logo and Search
              SizedBox(
                // height: 44,
                child: ImageHelper.load(
                  path: AppIcons.sun88,
                  width: 77,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              // Center: Balance Section
              Container(
                width: 219,
                padding: const EdgeInsets.only(
                  top: 4,
                  left: 16,
                  right: 4,
                  bottom: 4,
                ),
                // margin: const EdgeInsets.symmetric(horizontal: 14.5),
                decoration: ShapeDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: const Color(0x1EFFE5C0)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text với gradient - chỉ wrap Text widgets
                    ShaderMask(
                      shaderCallback: (Rect bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        '\$',
                        style: AppTextStyles.labelMedium().copyWith(
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (Rect bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE5B8), Color(0xFFFFB732)],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        CurrencyHelper.formatCurrencyNoUnit(2000000),
                        style: AppTextStyles.labelMedium().copyWith(
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ImageHelper.getNetworkImage(
                      imageUrl: AppImages.btnRefill,
                      width: 56,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Avatar
              ProfileAvatar.user(
                size: const Size.square(44),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                onPressed: () => context.openProfile(),
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
