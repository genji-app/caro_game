import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/models/sport_enums.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    as v2;
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/top_league_provider.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Data for one sport tab (name, icon path, sportId).
class SportDesktopTypeFilterItem {
  final String name;
  final String icon;
  final String iconDisabled;
  final String iconSelected;
  final int sportId;

  const SportDesktopTypeFilterItem({
    required this.name,
    required this.icon,
    required this.iconDisabled,
    required this.iconSelected,
    required this.sportId,
  });
}

/// Danh sách sport dùng chung cho [SportDesktopTypeFilterTabs].
final List<SportDesktopTypeFilterItem> sportDesktopTypeFilterItems = [
  SportDesktopTypeFilterItem(
    name: 'Bóng đá',
    icon: AppIcons.soccer,
    iconDisabled: AppIcons.iconSoccer,
    iconSelected: AppIcons.iconSoccerSelected,
    sportId: SportType.soccer.id,
  ),
  SportDesktopTypeFilterItem(
    name: 'Tennis',
    icon: AppIcons.tennis,
    iconDisabled: AppIcons.iconTennis,
    iconSelected: AppIcons.iconTennisSelected,
    sportId: SportType.tennis.id,
  ),
  SportDesktopTypeFilterItem(
    name: 'Bóng rổ',
    icon: AppIcons.basketball,
    iconDisabled: AppIcons.iconBasketball,
    iconSelected: AppIcons.iconBasketballSelected,
    sportId: SportType.basketball.id,
  ),
  SportDesktopTypeFilterItem(
    name: 'Bóng chuyền',
    icon: AppIcons.volleyball,
    iconDisabled: AppIcons.iconVolleyball,
    iconSelected: AppIcons.iconVolleyballSelected,
    sportId: SportType.volleyball.id,
  ),
  SportDesktopTypeFilterItem(
    name: 'Cầu lông',
    icon: AppIcons.badminton,
    iconDisabled: AppIcons.iconBadminton,
    iconSelected: AppIcons.iconBadmintonSelected,
    sportId: SportType.badminton.id,
  ),
];

/// Sport type filter tabs (desktop) – dùng chung cho TopLeagueDesktopScreen, SportDesktopLiveMatchesSection, ...
/// Horizontal scroll, mỗi sport tab đi kèm sub-league tabs ngay sau nó.
/// Tap sport → goToSportDetail, tap league → goToLeagueDetail.
///
/// Mỗi sport + sub-leagues được gói trong [_SportWithLeagues] riêng,
/// chỉ rebuild khi topLeagues của sport đó thay đổi.
class SportDesktopTypeFilterTabs extends StatelessWidget {
  const SportDesktopTypeFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final sports = sportDesktopTypeFilterItems;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (int i = 0; i < sports.length; i++)
              _SportWithLeagues(
                sport: sports[i],
                isLast: i == sports.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

/// Mỗi sport tab + sub-league tabs của nó.
/// Watch [topLeagueEventsProvider] riêng cho từng sportId,
/// sport nào không có leagues thì chỉ hiển thị sport tab.
class _SportWithLeagues extends ConsumerWidget {
  final SportDesktopTypeFilterItem sport;
  final bool isLast;

  const _SportWithLeagues({required this.sport, required this.isLast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagues =
        ref.watch(topLeagueEventsProvider(sport.sportId)).valueOrNull ?? [];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(right: leagues.isNotEmpty || !isLast ? 8 : 0),
          child: _SportTabItem(sport: sport),
        ),
        for (int i = 0; i < leagues.length; i++)
          Container(
            margin: EdgeInsets.only(
              right: (i < leagues.length - 1 || !isLast) ? 8 : 0,
            ),
            child: _LeagueTabItem(
              name: leagues[i].displayName,
              logo: leagues[i].leagueLogo,
              sportId: leagues[i].sportId,
              leagueId: leagues[i].leagueId,
            ),
          ),
      ],
    );
  }
}

class _SportTabItem extends ConsumerWidget {
  final SportDesktopTypeFilterItem sport;

  const _SportTabItem({required this.sport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            ref.read(previousContentProvider.notifier).state =
                MainContentType.home;
            final sportType =
                v2.SportType.fromId(sport.sportId) ?? v2.SportType.soccer;
            ref.read(selectedSportV2Provider.notifier).state = sportType;
            ref
                .read(sportSocketAdapterProvider)
                .subscriptionManager
                .setActiveSport(sport.sportId);
            ref.read(mainContentProvider.notifier).goToSportDetail();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                child: Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252423),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: ImageHelper.load(
                      path: sport.icon,
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sport.name,
                style: AppTextStyles.paragraphXXSmall(
                  color: AppColorStyles.contentPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeagueTabItem extends ConsumerWidget {
  final String name;
  final String logo;
  final int sportId;
  final int leagueId;

  const _LeagueTabItem({
    required this.name,
    required this.logo,
    required this.sportId,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            ref
                .read(selectedLeagueInfoProvider.notifier)
                .state = SelectedLeagueInfo(
              sportId: sportId,
              leagueId: leagueId,
              leagueName: name,
              leagueLogo: logo,
            );
            ref.read(mainContentProvider.notifier).goToLeagueDetail();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                child: Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252423),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: logo.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            color: Colors.white,
                            width: 28,
                            height: 28,
                            child: ImageHelper.load(
                              path: logo,
                              width: 28,
                              height: 28,
                              fit: BoxFit.fill,
                              errorWidget: const SizedBox(width: 28, height: 28),
                            ),
                          ),
                        )
                      : const SizedBox(width: 28, height: 28),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 64,
                child: Text(
                  name,
                  style: AppTextStyles.paragraphXXSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
