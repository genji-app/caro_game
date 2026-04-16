import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/core/providers/scroll_controller_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/widgets/sport_live_chat.dart';
import 'package:co_caro_flame/s88/shared/widgets/empty_page/sport_empty_page.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/league/league_events_sliver_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/loading/sport_shimmer_loading.dart';

/// Màn League Detail trên mobile – hiển thị tất cả events của 1 league cụ thể.
/// Cùng cấp với TopLeagueMobileScreen, cùng folder.
class LeagueDetailMobileScreen extends ConsumerWidget {
  const LeagueDetailMobileScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: _LeagueDetailMobileContent(onBackPressed: onBackPressed),
    );
  }
}

class _LeagueDetailMobileContent extends ConsumerStatefulWidget {
  const _LeagueDetailMobileContent({this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  ConsumerState<_LeagueDetailMobileContent> createState() =>
      _LeagueDetailMobileContentState();
}

class _LeagueDetailMobileContentState
    extends ConsumerState<_LeagueDetailMobileContent> {
  static const double _collapsedHeight = 100.0;
  static const double _expandedHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(mainScrollControllerProvider);
    final isExpanded = ref.watch(liveChatExpandedProvider);
    final liveChatHeight = isExpanded ? _expandedHeight : _collapsedHeight;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final leagueInfo = ref.watch(selectedLeagueInfoProvider);
    final onBackPressed = widget.onBackPressed;

    return GestureDetector(
      onTap: () {
        if (isExpanded) {
          FocusScope.of(context).unfocus();
          ref.read(liveChatExpandedProvider.notifier).state = false;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            if (isAuthenticated)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyLiveChatDelegate(
                  minHeight: liveChatHeight,
                  maxHeight: liveChatHeight,
                  onStickyChanged: (isSticky) {
                    ref.read(liveChatStickyProvider.notifier).state = isSticky;
                  },
                ),
              ),
            const SliverToBoxAdapter(child: Gap(16)),
            SliverToBoxAdapter(
              child: _buildTitleRow(context, ref, onBackPressed, leagueInfo),
            ),
            const SliverToBoxAdapter(child: Gap(12)),
            if (leagueInfo != null) ..._buildLeagueSlivers(ref, leagueInfo),
            SliverToBoxAdapter(
              child: Gap(80 + MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    WidgetRef ref,
    VoidCallback? onBackPressed,
    SelectedLeagueInfo? leagueInfo,
  ) {
    if (leagueInfo == null) {
      return const SizedBox.shrink();
    }

    final asyncLeagues = ref.watch(leagueDetailEventsProvider(leagueInfo));
    final leaguesList = asyncLeagues.valueOrNull;
    final modelFav = leaguesList != null &&
        leaguesList.isNotEmpty &&
        leaguesList.first.isFavorited;
    final favoriteState = ref.watch(favoriteProvider);
    final sid = leagueInfo.sportId;
    final hasBucket = favoriteState.favoritesBySport.containsKey(sid);
    final isLeagueFav = hasBucket
        ? favoriteState.isLeagueFavorite(sid, leagueInfo.leagueId)
        : modelFav;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (onBackPressed != null) ...[
            Material(
              color: AppColorStyles.backgroundQuaternary,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onBackPressed,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ImageHelper.load(
                    path: AppIcons.icBack,
                    width: 20,
                    height: 20,
                    color: const Color(0xFFFFFCDB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          InkWell(
            onTap: () async {
              final notifier = ref.read(favoriteProvider.notifier);
              final fav = ref.read(favoriteProvider);
              final snap = ref.read(leagueDetailEventsProvider(leagueInfo));
              final list = snap.valueOrNull;
              final mf = list != null && list.isNotEmpty
                  ? list.first.isFavorited
                  : false;
              final wasFavorited = fav.favoritesBySport.containsKey(sid)
                  ? fav.isLeagueFavorite(sid, leagueInfo.leagueId)
                  : mf;
              final success = wasFavorited
                  ? await notifier.removeFavoriteLeague(
                      sportId: sid,
                      leagueId: leagueInfo.leagueId,
                    )
                  : await notifier.addFavoriteLeague(
                      sportId: sid,
                      leagueId: leagueInfo.leagueId,
                    );
              if (success) {
                ref.invalidate(leagueDetailEventsProvider(leagueInfo));
                if (context.mounted) {
                  AppToast.showSuccess(
                    context,
                    message: wasFavorited
                        ? 'Đã xoá giải đấu khỏi yêu thích'
                        : 'Đã thêm giải đấu vào yêu thích',
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ImageHelper.load(
                path: isLeagueFav
                    ? AppIcons.iconFavoriteSelected
                    : AppIcons.iconUnFavorite,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                color: isLeagueFav ? null : const Color(0xB3FFFCDB),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (leagueInfo.leagueLogo.isNotEmpty)
            ClipRRect(
              key: ValueKey(leagueInfo.leagueId),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: Container(
                color: Colors.white,
                width: 24,
                height: 24,
                child: ImageHelper.load(
                  path: leagueInfo.leagueLogo,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorWidget: const SizedBox(width: 24),
                ),
              ),
            )
          else
            const SizedBox(width: 24),
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

  List<Widget> _buildLeagueSlivers(
    WidgetRef ref,
    SelectedLeagueInfo leagueInfo,
  ) {
    final asyncLeagues = ref.watch(leagueDetailEventsProvider(leagueInfo));

    return asyncLeagues.when(
      data: (leagues) {
        if (leagues.isEmpty) {
          return [
            const SliverToBoxAdapter(child: SportEmptyPage()),
          ];
        }
        return [
          LeagueEventsSliverV2(
            leagues: leagues,
            isDesktop: false,
            includeEmptyLeagues: false,
            showLeagueFavorite: false,
          ),
        ];
      },
      loading: () => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SportShimmerLoading(isDesktop: false),
          ),
        ),
      ],
      error: (err, _) => [
        SliverToBoxAdapter(
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
      ],
    );
  }
}

/// Delegate cho sticky live chat header.
class _StickyLiveChatDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final ValueChanged<bool>? onStickyChanged;
  bool _lastStickyState = false;

  _StickyLiveChatDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.onStickyChanged,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isSticky = overlapsContent || shrinkOffset > 0;

    if (isSticky != _lastStickyState) {
      _lastStickyState = isSticky;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onStickyChanged?.call(isSticky);
      });
    }

    return SizedBox(
      height: maxHeight,
      child: Stack(
        children: [
          const RepaintBoundary(child: SportLiveChat(isMobile: true)),
          if (isSticky)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyLiveChatDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        onStickyChanged != oldDelegate.onStickyChanged;
  }
}
