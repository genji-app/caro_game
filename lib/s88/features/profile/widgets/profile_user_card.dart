import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/avatar/avatar.dart';

/// User card showing avatar, username, ID, and activation button
class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    required this.displayName,
    required this.customerId,
    this.avatarUrl,
    super.key,
  });

  final String? avatarUrl;
  final String displayName;
  final String customerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageHelper.load(
                path: AppIcons.backgroundProfile,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // User info
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Avatar
                ProfileAvatar.url(avatarUrl, size: const Size.square(80)),

                const SizedBox(width: 16),
                // Username and ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.headingXSmall(
                          color: AppColorStyles.contentPrimary, // #9c9b95
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${I18n.txtID}: $customerId',
                        style: AppTextStyles.paragraphSmall(
                          color: AppColorStyles.contentSecondary, // #9c9b95
                        ),
                      ),
                    ],
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
