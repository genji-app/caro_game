import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/models_v2.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_detail_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// League header widget for virtualized sliver list (V2 Version)
///
/// Uses LeagueModelV2 directly without legacy conversion.
///
/// Features:
/// - Displays league logo and name
/// - Expand/collapse toggle with animation
/// - Platform-aware sizing (desktop/mobile)
class LeagueHeaderWidgetV2 extends ConsumerWidget {
  final LeagueModelV2 league;
  final bool isDesktop;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final bool showFavorite;

  const LeagueHeaderWidgetV2({
    super.key,
    required this.league,
    this.isDesktop = false,
    this.isExpanded = true,
    this.onToggleExpand,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportIdForLeague = league.sportId != 0
        ? league.sportId
        : ref.watch(selectedSportV2Provider).id;

    final favoriteState = ref.watch(favoriteProvider);
    final hasFavoriteBucket =
        favoriteState.favoritesBySport.containsKey(sportIdForLeague);
    final isLeagueFavorited = hasFavoriteBucket
        ? favoriteState.isLeagueFavorite(sportIdForLeague, league.leagueId)
        : league.isFavorited;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: isDesktop ? 48 : 40,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundQuaternary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isExpanded ? 0 : 12),
              bottomRight: Radius.circular(isExpanded ? 0 : 12),
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -0.65),
                blurRadius: 0.5,
                spreadRadius: 0.05,
                blurStyle: BlurStyle.inner,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // League logo (fallback to sport icon if empty or error)
                    _buildLeagueLogo(sportIdForLeague),
                    const SizedBox(width: 8),
                    // League name
                    Expanded(
                      child: Text(
                        league.displayName,
                        style: AppTextStyles.textStyle(
                          fontSize: isDesktop ? 14 : 13,
                          fontWeight: FontWeight.w400,
                          color: AppColorStyles.contentPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (showFavorite) ...[
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final notifier = ref.read(favoriteProvider.notifier);
                      final fav = ref.read(favoriteProvider);
                      final sid = league.sportId != 0
                          ? league.sportId
                          : ref.read(selectedSportV2Provider).id;
                      final wasFavorited = fav.favoritesBySport.containsKey(sid)
                          ? fav.isLeagueFavorite(sid, league.leagueId)
                          : league.isFavorited;
                      final success = wasFavorited
                          ? await notifier.removeFavoriteLeague(
                              sportId: sid,
                              leagueId: league.leagueId,
                            )
                          : await notifier.addFavoriteLeague(
                              sportId: sid,
                              leagueId: league.leagueId,
                            );
                      if (success) {
                        final info = ref.read(selectedLeagueInfoProvider);
                        if (info != null && info.leagueId == league.leagueId) {
                          ref.invalidate(leagueDetailEventsProvider(info));
                        }
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
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: RepaintBoundary(
                        child: ImageHelper.load(
                          path: isLeagueFavorited
                              ? AppIcons.iconFavoriteSelected
                              : AppIcons.iconUnFavorite,
                          width: isDesktop ? 26 : 24,
                          height: isDesktop ? 26 : 24,
                          fit: BoxFit.contain,
                          color: isLeagueFavorited
                              ? null
                              : const Color(0xB3FFFCDB),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Chevron toggle
              if (onToggleExpand != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onToggleExpand,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isExpanded ? 0 : 0.5,
                          child: RepaintBoundary(
                            child: ImageHelper.load(
                              path: AppIcons.chevronUp,
                              width: isDesktop ? 22 : 20,
                              height: isDesktop ? 22 : 20,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Rung stroke SVG - only visible when league has vibrating selections
        _buildRungStrokeConsumer(),
      ],
    );
  }

  /// Consumer for rung stroke SVG - only rebuilds when this league's vibrating state changes.
  /// Lock/suspension is handled at source: MarketStatusNotifier.setEventSuspended()
  /// calls removeVibratingByEvent() to cleanup, so hasVibrating is always accurate.
  Widget _buildRungStrokeConsumer() {
    return Consumer(
      builder: (context, ref, _) {
        final hasVibrating = ref.watch(
          hasVibratingInLeagueProvider(league.leagueId),
        );

        if (!hasVibrating) return const SizedBox.shrink();

        return Positioned(
          left: 0,
          right: 0,
          top: 3,
          child: ImageHelper.load(path: AppIcons.rungStoke, fit: BoxFit.fill),
        );
      },
    );
  }

  static const _logoDecoration = BoxDecoration(
    color: Color(0xFFE0E0E0),
    // borderRadius: BorderRadius.all(Radius.circular(6)),
    // shape: BoxShape.circle,
  );

  Widget _buildLeagueLogo(int currentSportId) {
    if (league.leagueLogo.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: Container(
          width: isDesktop ? 28 : 26,
          height: isDesktop ? 28 : 26,
          decoration: _logoDecoration,
          padding: const EdgeInsets.all(2),
          child: ImageHelper.getNetworkImage(
            imageUrl: league.leagueLogo,
            width: isDesktop ? 24 : 22,
            height: isDesktop ? 24 : 22,
            fit: BoxFit.contain,
            errorWidget: RepaintBoundary(
              child: ImageHelper.load(
                path: SportType.fromId(currentSportId)?.iconPath ?? '',
                width: isDesktop ? 24 : 22,
                height: isDesktop ? 24 : 22,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            placeholder: const SizedBox.shrink(),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: ImageHelper.load(
        path: SportType.fromId(currentSportId)?.iconPath ?? '',
        width: isDesktop ? 26 : 24,
        height: isDesktop ? 26 : 24,
        fit: BoxFit.contain,
        color: const Color(0xB3FFFCDB),
      ),
    );
  }
}
