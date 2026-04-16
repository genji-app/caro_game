import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';

/// League Detail desktop screen – hiển thị tất cả events của 1 league cụ thể.
/// Cùng cấp với TopLeagueDesktopScreen, cùng folder.
class LeagueDetailDesktopScreen extends ConsumerWidget {
  const LeagueDetailDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueInfo = ref.watch(selectedLeagueInfoProvider);

    if (leagueInfo == null) {
      return const Expanded(child: SportEmptyPage());
    }

    return Expanded(
      child: Container(
        color: AppColorStyles.backgroundSecondary,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingStyles.space800,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140, minWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeagueDetailHeader(leagueInfo: leagueInfo),
              const Gap(12),
              Expanded(
                child: RepaintBoundary(
                  child: _LeagueDetailContent(leagueInfo: leagueInfo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header for league detail with conditional back button.
/// Shows back icon when navigated from sport page (previousContentProvider != null),
/// hides it when navigated from sidebar menu (previousContentProvider == null).
class _LeagueDetailHeader extends ConsumerWidget {
  final SelectedLeagueInfo leagueInfo;

  const _LeagueDetailHeader({required this.leagueInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previousContent = ref.watch(previousContentProvider);
    final showBack = previousContent != null;

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        children: [
          if (showBack) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(mainContentProvider.notifier)
                      .switchTo(previousContent);
                  ref.read(previousContentProvider.notifier).state = null;
                },
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
          ],
          if (leagueInfo.leagueLogo.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: Container(
                color: Colors.white,
                width: 28,
                height: 28,
                child: ImageHelper.load(
                  path: leagueInfo.leagueLogo,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorWidget: const SizedBox(width: 28),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              leagueInfo.leagueName,
              style: AppTextStyles.headingXSmall(
                color: AppColorStyles.contentPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content for league detail: fetch all events by leagueId.
class _LeagueDetailContent extends ConsumerWidget {
  final SelectedLeagueInfo leagueInfo;

  const _LeagueDetailContent({required this.leagueInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeagues = ref.watch(leagueDetailEventsProvider(leagueInfo));

    return asyncLeagues.when(
      data: (leagues) {
        if (leagues.isEmpty) {
          return const SportEmptyPage();
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              LeagueEventsSliverV2(
                leagues: leagues,
                isDesktop: true,
                includeEmptyLeagues: false,
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: 80 + MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SportShimmerLoading(isDesktop: true),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            err.toString(),
            style: AppTextStyles.textStyle(
              fontSize: 14,
              color: AppColorStyles.contentTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
