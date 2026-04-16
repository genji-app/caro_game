import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/models/bet_column_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';
import 'package:co_caro_flame/s88/shared/widgets/teams/team_display.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row_shared_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/score/soccer_score_section.dart';

/// Soccer match row — horizontal layout:
/// Header: [Live] time | period     Chấp | Tài/Xỉu | 1X2
/// Body:   Teams+Score | Odds (3 columns side by side)
/// Footer: shared
class MatchRowSoccerV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool isDesktop;

  const MatchRowSoccerV2({
    required this.event,
    this.league,
    this.isDesktop = false,
    super.key,
  });

  bool get _canShowStats => event.eventStatsId > 0;
  bool get _canShowTracker => event.eventStatsId > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const oddsFormat = OddsFormatV2.decimal;
    final oddsSportId = sportIdForFavoriteEvent(
      event,
      league,
      ref.read(selectedSportV2Provider).id,
    );
    final betColumns = getBetColumnsV2(event, oddsFormat);
    final isLive = event.isLive;
    final matchTime = isLive ? event.liveStatusDisplay : event.formattedTime;
    final (minute, period) = parseMatchTime(matchTime);

    return Container(
      color: AppColorStyles.backgroundQuaternary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _MatchHeaderSoccerV2(
            columns: betColumns,
            isLive: isLive,
            minute: minute,
            period: period,
            eventId: event.eventId,
          ),

          // Teams and bets section
          Expanded(
            child: Container(
              color: AppColorStyles.backgroundQuaternary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teams column with score
                  _TeamsSectionSoccerV2(
                    event: event,
                    isLive: isLive,
                    isDesktop: isDesktop,
                    onTap: () => navigateToBetDetail(ref, event, league),
                  ),

                  const SizedBox(width: 24),

                  // Bet columns
                  _OddsSectionSoccerV2(
                    sportId: oddsSportId,
                    event: event,
                    league: league,
                    columns: betColumns,
                    isDesktop: isDesktop,
                  ),
                ],
              ),
            ),
          ),

          // Footer
          MatchFooterV2(
            event: event,
            league: league,
            canShowStats: _canShowStats,
            canShowTracker: _canShowTracker,
            onNavigate: () => navigateToBetDetail(ref, event, league),
            onFavoriteTap: () =>
                toggleFavoriteEvent(context, ref, event, league: league),
          ),
        ],
      ),
    );
  }
}

/// Soccer header — left: live+time, right: Chấp/Tài-Xỉu/1X2 labels
class _MatchHeaderSoccerV2 extends StatelessWidget {
  final List<BetColumnV2?> columns;
  final bool isLive;
  final String? minute;
  final String? period;
  final int eventId;

  const _MatchHeaderSoccerV2({
    required this.columns,
    required this.isLive,
    required this.eventId,
    this.minute,
    this.period,
  });

  String _getDefaultTitle(int index) {
    switch (index) {
      case 0:
        return 'Kèo chấp';
      case 1:
        return 'Tài xỉu';
      case 2:
        return '1X2';
      default:
        return '';
    }
  }

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
          // Live indicator and time
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
                      sportId: 1,
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

          const SizedBox(width: 16),

          // Bet type tabs
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < columns.length; i++)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        columns[i]?.title ?? _getDefaultTitle(i),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelXSmall(
                          color: const Color(0xFF9C9B95),
                        ),
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

/// Soccer teams section with cards and scores
class _TeamsSectionSoccerV2 extends StatelessWidget {
  final EventModelV2 event;
  final bool isLive;
  final bool isDesktop;
  final VoidCallback? onTap;

  const _TeamsSectionSoccerV2({
    required this.event,
    required this.isLive,
    required this.isDesktop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teams column
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TeamDisplay(
                            teamName: event.homeName,
                            teamLogo: event.homeLogo,
                            isHome: true,
                          ),
                        ),
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TeamDisplay(
                            teamName: event.awayName,
                            teamLogo: event.awayLogo,
                            isHome: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Soccer score display for live matches
                if (isLive) ...[
                  SoccerScoreSection(event: event),
                ],
              ],
            ),

            // Livestream badge
            if (isLive && event.isLiveStream == true)
              SizedBox(
                height: 50,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: onTap,
                      child: SizedBox(
                        width: 40,
                        height: 26,
                        child: ImageHelper.getNetworkImage(
                          imageUrl: AppImages.live,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Soccer odds section with bet columns
class _OddsSectionSoccerV2 extends StatelessWidget {
  final int sportId;
  final EventModelV2 event;
  final LeagueModelV2? league;
  final List<BetColumnV2?> columns;
  final bool isDesktop;

  const _OddsSectionSoccerV2({
    required this.sportId,
    required this.event,
    required this.columns,
    required this.isDesktop,
    this.league,
  });

  bool _is1X2Column(BetColumnV2 column) {
    return column.type == BetColumnType.matchResult;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 130,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              Expanded(
                child: Column(children: _buildColumnItems(columns[i], i)),
              ),
              if (i != columns.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildColumnItems(BetColumnV2? column, int columnIndex) {
    if (column == null || column.items.isEmpty) {
      return _buildLockedPlaceholder(columnIndex);
    }

    final items = column.items;
    final is1X2 = _is1X2Column(column);
    final itemCount = is1X2 ? 3 : 2;

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
                isVertical: true,
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

  List<Widget> _buildLockedPlaceholder(int columnIndex) {
    final itemCount = columnIndex == 2 ? 3 : 2;

    return List.generate(itemCount, (index) {
      final isLast = index == itemCount - 1;

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
