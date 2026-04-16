import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/features/sport/domain/services/market_converter_service_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/score_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/favorite_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/score_header_config.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/models/bet_column_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/stats/stats_dialog.dart';
import 'package:co_caro_flame/s88/shared/widgets/tooltip/parlay_tooltip.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';
import 'package:co_caro_flame/s88/shared/widgets/tracker/tracker_popup_dialog.dart';

// ─── Helper functions ───────────────────────────────────────────────

int sportIdForFavoriteEvent(
  EventModelV2 event,
  LeagueModelV2? league,
  int selectedSportId,
) {
  if (event.sportId > 0) return event.sportId;
  if (league != null && league.sportId != 0) return league.sportId;
  return selectedSportId;
}

bool isEventFavoriteDisplayed(
  FavoriteState fav,
  int sportId,
  EventModelV2 event,
  LeagueModelV2? league,
) {
  final hasBucket = fav.favoritesBySport.containsKey(sportId);
  if (!hasBucket) {
    return event.isFavorited || (league?.isFavorited ?? false);
  }
  final byEvent = fav.isEventFavorite(sportId, event.eventId);
  final byLeague =
      league != null && fav.isLeagueFavorite(sportId, league.leagueId);
  return byEvent || byLeague;
}

/// Navigate to bet detail page
void navigateToBetDetail(
  WidgetRef ref,
  EventModelV2 event,
  LeagueModelV2? league,
) {
  if (league == null) return;
  ref.read(selectedEventV2Provider.notifier).state = event;
  ref.read(selectedLeagueV2Provider.notifier).state = league;
  ref.read(mainContentProvider.notifier).goToBetDetail();
}

/// Toggle favorite event (or league when UI shows league-only favorite).
Future<void> toggleFavoriteEvent(
  BuildContext context,
  WidgetRef ref,
  EventModelV2 event, {
  LeagueModelV2? league,
}) async {
  final selectedId = ref.read(selectedSportV2Provider).id;
  final sportId = sportIdForFavoriteEvent(event, league, selectedId);
  final notifier = ref.read(favoriteProvider.notifier);
  final fav = ref.read(favoriteProvider);
  final filled = isEventFavoriteDisplayed(fav, sportId, event, league);

  late final bool success;
  late final String message;
  if (!filled) {
    success = await notifier.addFavoriteEvent(
      sportId: sportId,
      eventId: event.eventId,
    );
    message = 'Đã thêm trận đấu vào yêu thích';
  } else {
    final hasBucket = fav.favoritesBySport.containsKey(sportId);
    if (hasBucket && fav.isEventFavorite(sportId, event.eventId)) {
      success = await notifier.removeFavoriteEvent(
        sportId: sportId,
        eventId: event.eventId,
      );
      message = 'Đã xoá trận đấu khỏi yêu thích';
    } else if (hasBucket &&
        league != null &&
        fav.isLeagueFavorite(sportId, league.leagueId)) {
      success = await notifier.removeFavoriteLeague(
        sportId: sportId,
        leagueId: league.leagueId,
      );
      message = 'Đã xoá giải đấu khỏi yêu thích';
    } else {
      success = await notifier.removeFavoriteEvent(
        sportId: sportId,
        eventId: event.eventId,
      );
      message = 'Đã xoá trận đấu khỏi yêu thích';
    }
  }
  if (success && context.mounted) {
    AppToast.showSuccess(context, message: message);
  }
}

/// Get 3 bet columns for an event: [handicap, overUnder, matchResult]
List<BetColumnV2?> getBetColumnsV2(
  EventModelV2 event,
  OddsFormatV2 oddsFormat,
) {
  final allBetColumns = event.toBetColumnsV2(oddsFormat: oddsFormat);

  BetColumnV2? handicapCol;
  BetColumnV2? overUnderCol;
  BetColumnV2? matchResultCol;

  for (final col in allBetColumns) {
    switch (col.type) {
      case BetColumnType.handicap:
        handicapCol ??= col;
      case BetColumnType.overUnder:
        overUnderCol ??= col;
      case BetColumnType.matchResult:
        matchResultCol ??= col;
      default:
        break;
    }
  }

  return [handicapCol, overUnderCol, matchResultCol];
}

/// Parse match time string "minute | period" into tuple
(String? minute, String? period) parseMatchTime(String? matchTime) {
  if (matchTime == null) return (null, null);
  final parts = matchTime.split(RegExp(r'\s*\|\s*'));
  if (parts.length >= 2) {
    return (parts[0].trim(), parts[1].trim());
  }
  return (matchTime, null);
}

/// Extract current set/game number for set-based sports
/// Volleyball (field 506), Badminton (field 706), Table Tennis (field 606)
int? extractCurrentSet(EventModelV2 event) {
  final score = event.score;
  if (score is VolleyballScoreModelV2) {
    return score.currentSet > 0 ? score.currentSet : null;
  }
  if (score is BadmintonScoreModelV2) {
    return score.currentSet > 0 ? score.currentSet : null;
  }
  if (score is TableTennisScoreModelV2) {
    return score.currentSet > 0 ? score.currentSet : null;
  }
  return null;
}

/// Extract set/game wins for set-based sports
(int, int)? extractSetScore(EventModelV2 event) {
  final score = event.score;
  if (score is VolleyballScoreModelV2) {
    return (score.homeSetScore, score.awaySetScore);
  }
  if (score is BadmintonScoreModelV2) {
    return (score.homeGameScore, score.awayGameScore);
  }
  if (score is TennisScoreModelV2) {
    return (score.homeSetScore, score.awaySetScore);
  }
  return null;
}

/// More markets count for footer
int? getMoreMarketsCount(EventModelV2 event) {
  final totalMarkets = event.marketCount;
  const displayedMarkets = 3;
  return totalMarkets > displayedMarkets
      ? totalMarkets - displayedMarkets
      : null;
}

// ─── Shared Footer ──────────────────────────────────────────────────

/// Footer with action icons and more markets — identical across all sports
class MatchFooterV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool canShowStats;
  final bool canShowTracker;
  final VoidCallback? onNavigate;
  final VoidCallback? onFavoriteTap;

  const MatchFooterV2({
    required this.event,
    required this.canShowStats,
    required this.canShowTracker,
    this.league,
    this.onNavigate,
    this.onFavoriteTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moreMarketsCount = getMoreMarketsCount(event);
    final selectedId = ref.watch(selectedSportV2Provider).id;
    final sportId = sportIdForFavoriteEvent(event, league, selectedId);
    final fav = ref.watch(favoriteProvider);
    final isEventFavorited =
        isEventFavoriteDisplayed(fav, sportId, event, league);

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Action icons
          Row(
            children: [
              // Favorite icon
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  behavior: HitTestBehavior.opaque,
                  child: RepaintBoundary(
                    child: ImageHelper.load(
                      path: isEventFavorited
                          ? AppIcons.iconFavoriteSelected
                          : AppIcons.iconUnFavorite,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: isEventFavorited ? null : const Color(0xB3FFFCDB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: canShowStats ? () => _showStatsDialog(context) : null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: ImageHelper.load(
                      path: AppIcons.iconBarChart,
                      color: canShowStats
                          ? AppColorStyles.contentSecondary
                          : AppColorStyles.contentSecondary.withValues(
                              alpha: 0.3,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: canShowTracker
                      ? () => _showTrackerPopup(context)
                      : null,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: ImageHelper.load(
                      path: AppIcons.iconChart,
                      color: canShowTracker
                          ? AppColorStyles.contentSecondary
                          : AppColorStyles.contentSecondary.withValues(
                              alpha: 0.3,
                            ),
                    ),
                  ),
                ),
              ),
              if (event.isParlay) ...[
                const SizedBox(width: 20),
                const ParlayIconButtonV2(),
              ],
            ],
          ),
          const Spacer(),
          // More markets count
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onNavigate,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (moreMarketsCount != null)
                    Text(
                      '+$moreMarketsCount',
                      style: AppTextStyles.textStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFFEF5),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFFFFFEF5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    StatsDialog.showForMatch(
      context: context,
      eventStatsId: event.eventStatsId,
      homeName: event.homeName,
      awayName: event.awayName,
      config: StatsDialogConfig.mobile,
      width: MediaQuery.of(context).size.width,
    );
  }

  void _showTrackerPopup(BuildContext context) {
    TrackerPopupDialog.show(
      context: context,
      eventStatsId: event.eventStatsId,
      homeName: event.homeName,
      awayName: event.awayName,
    );
  }
}

/// Parlay icon button with tooltip
class ParlayIconButtonV2 extends StatefulWidget {
  const ParlayIconButtonV2({super.key});

  @override
  State<ParlayIconButtonV2> createState() => _ParlayIconButtonV2State();
}

class _ParlayIconButtonV2State extends State<ParlayIconButtonV2> {
  final GlobalKey _iconKey = GlobalKey();

  void _showTooltip() {
    ParlayTooltip.show(
      context: context,
      targetKey: _iconKey,
      message: 'Trận này chưa thêm vào cược xiên',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _showTooltip,
        child: SizedBox(
          key: _iconKey,
          width: 20,
          height: 20,
          child: ImageHelper.load(
            path: AppIcons.iconParlay,
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Non-Soccer Odds Section ────────────────────────────────────────

/// Shared odds section for all non-soccer sports.
///
/// Layout:
/// ```
/// Header: Đội thắng | Chấp | Tài/Xỉu   (3 × Expanded, equal)
/// Body:   [odds]     [odds] [odds]       (3 × Expanded, equal)
///         [odds]     [odds] [odds]
/// ```
class NonSoccerOddsSection extends StatelessWidget {
  final int sportId;
  final EventModelV2 event;
  final LeagueModelV2? league;
  final List<BetColumnV2?> columns;
  final bool isDesktop;

  const NonSoccerOddsSection({
    required this.sportId,
    required this.event,
    required this.columns,
    required this.isDesktop,
    this.league,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Odds header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x0FACDC79),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Chấp',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.paragraphXSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tài/Xỉu',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.paragraphXSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đội thắng',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.paragraphXSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Odds body — 3 columns × 2 rows
          SizedBox(
            height: isDesktop ? 76 : 94,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  Expanded(
                    child: Column(children: _buildColumnItems(columns[i])),
                  ),
                  if (i != columns.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildColumnItems(BetColumnV2? column) {
    if (column == null || column.items.isEmpty) {
      return _buildLockedPlaceholder();
    }

    final items = column.items;
    // Non-soccer always shows 2 items (home/away), no 1X2
    const itemCount = 2;

    return List.generate(itemCount, (index) {
      final isLast = index == itemCount - 1;

      if (index < items.length) {
        final item = items[index];

        BettingPopupDataV2? bettingData;
        if (item.oddsData != null &&
            item.marketData != null &&
            item.oddsType != null) {
          bettingData = BettingPopupDataV2(
            sportId: sportId,
            oddsData: item.oddsData!,
            marketData: item.marketData!,
            eventData: event,
            oddsType: item.oddsType!,
            leagueData: league,
            oddsFormat: OddsFormatV2.decimal,
          );
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
            child: SizedBox.expand(
              child: BetCardMobileV2(
                label: item.label,
                value: item.value,
                selectionId: item.selectionId,
                bettingPopupData: bettingData,
                isVertical: !isDesktop || column.type == BetColumnType.matchResult,
                isDesktop: isDesktop,
                isSetHeightOdds: true,
              ),
            ),
          ),
        );
      }

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
          child: const SizedBox.expand(),
        ),
      );
    });
  }

  List<Widget> _buildLockedPlaceholder() {
    return List.generate(2, (index) {
      final isLast = index == 1;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
          child: SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock, size: 16, color: Colors.white54),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Non-Soccer Header ──────────────────────────────────────────────

/// Shared non-soccer header — used by all non-soccer match rows.
/// Left: live indicator + time/period (Expanded)
/// Right: score column headers with fixed-width columns (28px each, 16px gap)
class NonSoccerHeader extends StatelessWidget {
  final ScoreHeaderConfig config;
  final bool isLive;
  final String? minute;
  final String? period;
  final int eventId;
  final int sportId;
  final bool isDesktop;
  final int? initialCurrentSet;
  final (int, int)? initialSetScore;

  const NonSoccerHeader({
    required this.config,
    required this.isLive,
    required this.eventId,
    this.isDesktop = false,
    this.sportId = 0,
    this.minute,
    this.period,
    this.initialCurrentSet,
    this.initialSetScore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
        ),
      ),
      child: Row(
        children: [
          // Left: live indicator + time (fills remaining space)
          Expanded(
            child: Row(
              children: [
                if (isLive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.red500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Trực tiếp',
                      style: AppTextStyles.textStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFFFEF5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (isLive)
                  Expanded(
                    child: LiveMatchTimeDisplay(
                      eventId: eventId,
                      initialMinute: minute,
                      initialPeriod: period,
                      sportId: sportId,
                      initialCurrentSet: initialCurrentSet,
                      initialSetScore: initialSetScore,
                    ),
                  )
                else ...[
                  if (minute != null)
                    Text(
                      minute!,
                      style: AppTextStyles.textStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFFFFEF5),
                      ),
                    ),
                  if (minute != null && period != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (period != null)
                    Flexible(
                      child: Text(
                        period!,
                        style: AppTextStyles.textStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFFFFEF5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Right: score column headers (fixed-width)
          SizedBox(
            width: config.totalWidth(isDesktop: isDesktop),
            child: Row(
              children: [
                // Prefix column (e.g. "Set" for tennis)
                if (config.prefixColumn != null) ...[
                  SizedBox(
                    width: ScoreHeaderConfig.columnWidth,
                    child: Text(
                      config.prefixColumn!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelXXSmall(
                        color: const Color(0xFF9C9B95),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop
                        ? ScoreHeaderConfig.columnGapDesktop
                        : ScoreHeaderConfig.columnGap,
                  ),
                ],
                // Set/quarter columns
                for (var i = 0; i < config.columns.length; i++) ...[
                  SizedBox(
                    width: ScoreHeaderConfig.columnWidth,
                    child: Text(
                      config.columns[i],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelXXSmall(
                        color: const Color(0xFF9C9B95),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop
                        ? ScoreHeaderConfig.columnGapDesktop
                        : ScoreHeaderConfig.columnGap,
                  ),
                ],
                if (config.hasPts) ...[
                  SizedBox(
                    width: ScoreHeaderConfig.columnWidth,
                    child: Text(
                      'PTS',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelXXSmall(
                        color: const Color(0xFF9C9B95),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop
                        ? ScoreHeaderConfig.columnGapDesktop
                        : ScoreHeaderConfig.columnGap,
                  ),
                ],
                SizedBox(
                  width: ScoreHeaderConfig.columnWidth,
                  child: Text(
                    config.totalLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelXXSmall(
                      color: const Color(0xFF9C9B95),
                    ),
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
