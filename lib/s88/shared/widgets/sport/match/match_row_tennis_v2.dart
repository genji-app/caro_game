import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/score_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/providers/events_v2_filter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/teams/team_display.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row_shared_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/score/tennis_score_section.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/score_header_config.dart';

/// Tennis match row — vertical stacked layout:
/// Header:  [Live] Set 3 | 0-2    S1 | S2 | S3 | S4 | S5 | PTS | Tổng
/// Score:   Teams                   scores per set + PTS + total
/// Odds:    Đội thắng | Chấp | Tài/Xỉu (independent section)
/// Footer:  shared
class MatchRowTennisV2 extends ConsumerWidget {
  final EventModelV2 event;
  final LeagueModelV2? league;
  final bool isDesktop;

  const MatchRowTennisV2({
    required this.event,
    this.league,
    this.isDesktop = false,
    super.key,
  });

  static final _config = ScoreHeaderConfig.forSport(4);

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
          NonSoccerHeader(
            config: _config,
            isLive: isLive,
            isDesktop: isDesktop,
            minute: minute,
            period: period,
            eventId: event.eventId,
            sportId: event.sportId,
            // Tennis: set score shown in score grid prefix column, not in time display
          ),

          // Score row: teams + score grid
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildTeams(ref)),
                TennisScoreSection(event: event, isDesktop: isDesktop),
              ],
            ),
          ),

          // Odds section (independent)
          NonSoccerOddsSection(
            sportId: oddsSportId,
            event: event,
            league: league,
            columns: betColumns,
            isDesktop: isDesktop,
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

  Widget _buildTeams(WidgetRef ref) {
    return InkWell(
      onTap: () => navigateToBetDetail(ref, event, league),
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
    );
  }
}
