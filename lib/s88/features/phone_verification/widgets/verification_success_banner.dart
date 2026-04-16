import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/phone_verification/provider/phone_verification_validators.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class VerifySuccessBanner extends StatelessWidget {
  const VerifySuccessBanner({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final formattedPhone = formatPhoneForPrivacy(phoneNumber);

    return InnerShadowCard(
      child: Container(
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfilePhoneVerifiedIcon(size: Size.square(72)),
            const Gap(16),
            Text(
              I18n.txtVerifyByPhoneSuccess,
              style: AppTextStyles.labelLarge(
                color: AppColorStyles.contentPrimary,
              ),
            ),
            const Gap(8),
            Text(
              '${I18n.txtPhoneNumber}: $formattedPhone',
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
