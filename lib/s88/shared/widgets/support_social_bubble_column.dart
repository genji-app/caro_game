import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart'
    show ImageHelper;
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart' show AppIcons;
import 'package:url_launcher/url_launcher.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Vertical list of social actions; each row has equal width (stadium buttons).
class SupportSocialBubbleColumn extends StatelessWidget {
  const SupportSocialBubbleColumn({super.key, this.onItemTap});

  final VoidCallback? onItemTap;

  static const double _itemWidth = 200;

  static final TextStyle _titleStyle = AppTextStyles.labelSmall(
    color: AppColors.gray25,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.gray800,
            border: Border.all(color: AppColors.gray600, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EqualWidthBubble(
                width: _itemWidth,
                icon: Icons.telegram,
                title: 'Telegram',
                titleStyle: _titleStyle,
                onTap: () async {
                  onItemTap?.call();
                  final u = Uri.parse('https://t.me/');
                  if (await canLaunchUrl(u)) await launchUrl(u);
                },
              ),
              _buildDivider(),
              _EqualWidthBubble(
                width: _itemWidth,
                icon: Icons.music_note,
                title: 'Tiktok',
                titleStyle: _titleStyle,
                onTap: () async {
                  onItemTap?.call();
                  final u = Uri.parse('https://www.tiktok.com/');
                  if (await canLaunchUrl(u)) await launchUrl(u);
                },
              ),
              _buildDivider(),
              _EqualWidthBubble(
                width: _itemWidth,
                icon: Icons.public,
                title: 'Facebook',
                titleStyle: _titleStyle,
                onTap: () async {
                  onItemTap?.call();
                  final u = Uri.parse('https://www.facebook.com/');
                  if (await canLaunchUrl(u)) await launchUrl(u);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom-right above bottom nav (Sun 24/7 tab). Barrier tap dismisses.
  static Future<void> showMobileAboveSun247Tab(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = mq.padding.bottom + _navBarHeightEstimate;
    return showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox.expand(
          child: GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Positioned(
                  right: 16,
                  bottom: bottom,
                  child: GestureDetector(
                    onTap: () {},
                    child: SupportSocialBubbleColumn(
                      onItemTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _navBarHeightEstimate = 32;

  Widget _buildDivider() => RepaintBoundary(
    child: SizedBox(
      width: _itemWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 0, bottom: 8, top: 10),
        child: ImageHelper.load(
          path: AppIcons.hr,
          width: double.infinity,
          height: 2,
          fit: BoxFit.fill,
        ),
      ),
    ),
  );
}

class _EqualWidthBubble extends StatelessWidget {
  const _EqualWidthBubble({
    required this.width,
    required this.icon,
    required this.title,
    required this.titleStyle,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final TextStyle titleStyle;
  final VoidCallback onTap;

  static const ShapeBorder _shape = StadiumBorder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 16,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, color: AppColors.gray25, size: 32),
              const SizedBox(width: 16),
              Text(title, style: titleStyle),
            ],
          ),
        ),
      ),
    );
  }
}
