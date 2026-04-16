import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// A card widget for the verification flow.
///
/// Displays a title, subtitle, and a form widget in a styled card container.
/// Used for both phone input and OTP input steps.
class VerificationCard extends StatelessWidget {
  const VerificationCard({
    required this.title,
    required this.subtitle,
    required this.form,
    super.key,
  });

  /// The title text displayed at the top of the card.
  final String title;

  /// The subtitle text displayed below the title.
  final String subtitle;

  /// The form widget to display (PhoneInputForm or OtpInputForm).
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return InnerShadowCard(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            _CardHeader(title: title, subtitle: subtitle),
            form,
          ],
        ),
      ),
    );
  }
}

/// Internal widget for the card header.
///
/// Displays the title and subtitle with appropriate styling.
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium(
            color: AppColorStyles.contentPrimary,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    );
  }
}
