import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Sport Detail Desktop Header with back button and sport name
class SportDetailDesktopHeader extends ConsumerWidget {
  final VoidCallback? onBackPressed;

  const SportDetailDesktopHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch selectedSportV2Provider to get the current sport
    final selectedSport = ref.watch(selectedSportV2Provider);
    final sportData = _getSportData(selectedSport);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Back button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap:
                  onBackPressed ??
                  () => ref.read(mainContentProvider.notifier).goToSport(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColorStyles.backgroundQuaternary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ImageHelper.load(
                  path: AppIcons.icBack,
                  width: 24,
                  height: 24,
                  color: const Color(0xFFFFFCDB),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Sport icon and name
          ImageHelper.load(path: sportData.icon, width: 28, height: 28),
          const SizedBox(width: 8),
          Text(
            sportData.name,
            style: AppTextStyles.textStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  _SportData _getSportData(v2.SportType sport) {
    switch (sport) {
      case v2.SportType.soccer:
        return _SportData(name: 'Bóng đá', icon: AppIcons.iconSoccerSelected);
      case v2.SportType.tennis:
        return _SportData(name: 'Quần vợt', icon: AppIcons.iconTennisSelected);
      case v2.SportType.basketball:
        return _SportData(
          name: 'Bóng rổ',
          icon: AppIcons.iconBasketballSelected,
        );
      case v2.SportType.volleyball:
        return _SportData(
          name: 'Bóng chuyền',
          icon: AppIcons.iconVolleyballSelected,
        );
      case v2.SportType.tableTennis:
        return _SportData(
          name: 'Bóng bàn',
          icon: AppIcons.iconTableTennisSelected,
        );
      case v2.SportType.badminton:
        return _SportData(
          name: 'Cầu lông',
          icon: AppIcons.iconBadmintonSelected,
        );
      default:
        return _SportData(name: 'Bóng đá', icon: AppIcons.iconSoccerSelected);
    }
  }
}

class _SportData {
  final String name;
  final String icon;

  _SportData({required this.name, required this.icon});
}
