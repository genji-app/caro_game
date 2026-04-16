import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/repositories/user_repository/user_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/input/input.dart';

class ProfilePersonalScreen extends ConsumerWidget {
  const ProfilePersonalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final username = user?.username;
    final email = user?.email;

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtPersonal),
      bodyPadding: ProfileNavigationScaffold.kBodyHorizontalPadding,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: [
            StyledTextField(
              enabled: false,
              filled: true,
              fillColor: AppColorStyles.backgroundTertiary,
              hoverColor: AppColorStyles.backgroundTertiary,
              label: const Text(I18n.txtAccount),
              initialValue: username,
            ),

            if (user?.isPhoneVerified == true)
              StyledTextField(
                enabled: false,
                filled: true,
                fillColor: AppColorStyles.backgroundTertiary,
                hoverColor: AppColorStyles.backgroundTertiary,
                initialValue: user?.maskedPhone ?? '-',
                label: const _PhoneTextFieldLabel(),
              )
            else
              ProfilePhoneVerificationWarning(
                onActivatePressed: () =>
                    ProfileNavigation.of(context).pushToPhoneVerification(),
              ),

            StyledTextField(
              enabled: false,
              filled: true,
              fillColor: AppColorStyles.backgroundTertiary,
              hoverColor: AppColorStyles.backgroundTertiary,
              label: const Text('Email'),
              initialValue: email,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneTextFieldLabel extends StatelessWidget {
  const _PhoneTextFieldLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(I18n.txtPhoneNumber),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            const ProfilePhoneVerifiedIcon(size: Size.square(20)),
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                I18n.txtActivated,
                style: AppTextStyles.labelXSmall(color: AppColors.yellow300),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
