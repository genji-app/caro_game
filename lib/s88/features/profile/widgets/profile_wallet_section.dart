import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/mobile/deposit_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/presentation/mobile/withdraw_mobile_bottom_sheet.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

/// Wallet section with Deposit, Withdraw, and History actions
class ProfileWalletSection extends ConsumerWidget {
  const ProfileWalletSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section title
      Text(
        'Ví',
        style: AppTextStyles.headingXXSmall(
          color: AppColorStyles.contentPrimary,
        ),
      ),
      const SizedBox(height: 16),
      // Action buttons
      Row(
        children: [
          // Deposit button (highlighted)
          Expanded(
            child: ProfileActionButton(
              icon: ImageHelper.load(
                path: AppIcons.profileAddMoneySelected,
                width: 24,
                height: 24,
              ),
              label: const Text('Nạp'),
              isHighlighted: true,
              onPressed: () {
                final deviceType = ResponsiveBuilder.getDeviceType(context);
                if (deviceType == DeviceType.mobile ||
                    deviceType == DeviceType.tablet) {
                  // Mobile: Show bottom sheet
                  DepositMobileBottomSheet.show(context);
                } else {
                  // Close ProfileOverlay and show DepositOverlay
                  ProfileNavigation.of(context).close();
                  ref.read(depositOverlayVisibleProvider.notifier).state = true;
                }
                // Defer fetch until after the open animation frame so that
                // invalidate + rebuild does not jank the sheet transition.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.invalidate(configDepositProvider);
                  unawaited(ref.read(configDepositProvider.future));
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Withdraw button
          Expanded(
            child: ProfileActionButton(
              icon: ImageHelper.load(
                path: AppIcons.profileWithdraw,
                width: 24,
                height: 24,
              ),
              label: const Text('Rút'),
              onPressed: () {
                final deviceType = ResponsiveBuilder.getDeviceType(context);
                if (deviceType == DeviceType.mobile ||
                    deviceType == DeviceType.tablet) {
                  // Mobile: Show bottom sheet
                  WithdrawMobileBottomSheet.show(context);
                } else {
                  // Close ProfileOverlay and show WithdrawOverlay
                  ProfileNavigation.of(context).close();
                  ref.read(withdrawOverlayVisibleProvider.notifier).state =
                      true;
                }
                // Defer fetch until after the open animation frame so that
                // invalidate + rebuild does not jank the sheet transition.
                // bankListProvider auto-invalidates since it depends on configDepositProvider.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.invalidate(configDepositProvider);
                  unawaited(ref.read(configDepositProvider.future));
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // History button
          Expanded(
            child: ProfileActionButton(
              icon: ImageHelper.load(
                path: AppIcons.profileHistory,
                width: 24,
                height: 24,
              ),
              label: const Text('Lịch sử'),
              onPressed: () =>
                  ProfileNavigation.of(context).pushToTransactionHistory(),
            ),
          ),
        ],
      ),
    ],
  );
}
