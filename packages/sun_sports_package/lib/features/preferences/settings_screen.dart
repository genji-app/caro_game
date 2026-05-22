import 'package:flutter/material.dart' hide CloseButton;
import 'package:gap/gap.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/preferences/bet/bet_preferences_view.dart';
import 'package:sun_sports/shared/profile_navigation_system/profile_navigation_system.dart';

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
