import 'package:flutter/material.dart' hide CloseButton;
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/preferences/bet/bet_preferences_view.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Build UI
    const hPadding = 12.0;
    const surfaceColor = AppColorStyles.contentPrimary;

    return ProfileNavigationScaffold.withCenterTitle(
      title: const Text(I18n.txtSettings),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: hPadding),
            child: DefaultTextStyle(
              style: AppTextStyles.headingXXXSmall(color: surfaceColor),
              child: const Text(I18n.txtOdds),
            ),
          ),

          const Gap(16),

          const SingleChildScrollView(
            padding: EdgeInsets.only(left: hPadding),
            child: BetPreferencesView(),
          ),
        ],
      ),
    );
  }
}
