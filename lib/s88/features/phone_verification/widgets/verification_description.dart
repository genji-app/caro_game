import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Description text widget for the verification screen.
///
/// Displays the account verification description message with proper styling.
class VerificationDescription extends StatelessWidget {
  const VerificationDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      I18n.msgAccountVerificationDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.paragraphSmall(
        color: AppColorStyles.contentSecondary,
      ),
    );
  }
}
