import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/shine_button.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class _AppVersionInfo extends StatefulWidget {
  const _AppVersionInfo();

  @override
  State<_AppVersionInfo> createState() => _AppVersionInfoState();
}

class _AppVersionInfoState extends State<_AppVersionInfo> {
  late final Future<({String version, int? patchNumber})> _future = _load();

  Future<({String version, int? patchNumber})> _load() async {
    final info = await PackageInfo.fromPlatform();
    int? patchNumber;
    try {
      final updater = ShorebirdUpdater();
      if (updater.isAvailable) {
        final current = await updater.readCurrentPatch();
        patchNumber = current?.number;
      }
    } catch (_) {
      patchNumber = null;
    }
    return (
      version: '${info.version}+${info.buildNumber}',
      patchNumber: patchNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({String version, int? patchNumber})>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 18);
        }
        final data = snapshot.data!;
        final patchText =
            data.patchNumber != null ? ' - Patch ${data.patchNumber}' : '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Versions: ${data.version}$patchText',
            style: AppTextStyles.paragraphXSmall(
              color: AppColorStyles.contentTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final navigator = ProfileNavigation.of(context);

    const horizontalPadding = ProfileNavigationScaffold.kBodyHorizontalPadding;
    return ProfileNavigationScaffold(
      bodyPadding: EdgeInsets.zero,
      appBar: ProfileNavigationAppBar.closeOnly(
        titleStyle: AppTextStyles.headingXSmall(
          color: AppColorStyles.contentPrimary,
        ),
        title: const Padding(
          padding: EdgeInsetsDirectional.only(start: 8.0),
          child: Text(I18n.txtUserInfo),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // User Card
          ProfileUserCard(
            customerId: user?.custId ?? '-',
            displayName: user?.displayName ?? I18n.txtUser,
            avatarUrl: user?.avatarUrl,
          ),

          // Scrollable content
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: horizontalPadding,
                    child: Column(
                      children: [
                        // Account Activate Warning
                        if (user?.isPhoneVerified == false)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: ProfilePhoneVerificationWarning(
                              onActivatePressed: () =>
                                  navigator.pushToPhoneVerification(),
                            ),
                          ),

                        // Wallet Section
                        const SizedBox(height: 20),
                        const ProfileWalletSection(),

                        // Account Section
                        const SizedBox(height: 32),
                        ProfileAccountSection(
                          onSupportPressed: () => AppToast.showError(
                            context,
                            message: I18n.txtFeatureUnderDevelopment,
                          ),
                          onMailboxPressed: () => AppToast.showError(
                            context,
                            message: I18n.txtFeatureUnderDevelopment,
                          ),
                          onPromoPressed: () => AppToast.showError(
                            context,
                            message: I18n.txtFeatureUnderDevelopment,
                          ),
                          onPersonalPressed: () => navigator.pushToPersonal(),
                          onSecurityPressed: () => navigator.pushToSecurity(),
                          onSettingsPressed: () => navigator.pushToSettings(),
                          onBetHistoryPressed: () =>
                              navigator.pushToBettingHistory(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                // App version + patch info
                const _AppVersionInfo(),
                // Logout button
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ShineButton(
                    text: I18n.txtLogout,
                    height: 36,
                    style: ShineButtonStyle.primaryGray,
                    onPressed: () async {
                      final confirmed =
                          await DialogConfirmLogout.show(context);
                      if (confirmed != true) return;
                      await ref.read(authProvider.notifier).logout();
                      navigator.close();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
