import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/security/security.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';
import 'package:co_caro_flame/s88/shared/widgets/buttons/buttons.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    const surfaceColor = AppColorStyles.contentPrimary;

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtSecurtity),
      body: SingleChildScrollView(
        padding: ProfileNavigationScaffold.kBodyHorizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTextStyle(
              style: AppTextStyles.headingXXXSmall(color: surfaceColor),
              child: const Text(I18n.txtPassword),
            ),

            const Gap(16),

            SecondaryButton.yellow(
              size: SecondaryButtonSize.xl,
              label: const Text(I18n.txtChangePassword),
              onPressed: () {
                Navigator.of(context).push(ChangePasswordScreen.route());
              },
            ),

            // const Gap(32),

            // DefaultTextStyle(
            //   style: AppTextStyles.headingXXXSmall(color: surfaceColor),
            //   child: const Text(I18n.txtAuth2FA),
            // ),

            // const Gap(16),

            // SecondaryButton.xl(
            //   onPressed: () {},
            //   label: const Text(I18n.txtAuth2FA),
            // ),
          ],
        ),
      ),
    );
  }
}

// return DialogScaffold.withCenterTitle(
//   title: const Text(txtSecurtity),
//   body: SingleChildScrollView(
//     padding: horizontalPadding,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const Gap(20),

//         DefaultTextStyle(
//           style: AppTextStyles.headingXXXSmall(color: surfaceColor),
//           child: const Text(txtPassword),
//         ),

//         const Gap(16),

//         SecondaryButton.xl(
//           label: const Text(txtChangePassword),
//           onPressed: () {},
//         ),

//         const Gap(32),

//         DefaultTextStyle(
//           style: AppTextStyles.headingXXXSmall(color: surfaceColor),
//           child: const Text(txtAuth2FA),
//         ),

//         const Gap(16),

//         SecondaryButton.xl(
//           autofocus: true,
//           onPressed: () {},
//           label: const Text(txtAuth2FA),
//         ),
//       ],
//     ),
//   ),
// );
