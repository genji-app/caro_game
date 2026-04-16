import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';

/// Soccer-specific live score section: yellow cards + red cards + score column.
///
/// Extracted from MatchRowV2._TeamsSectionV2 for sport-specific dispatch.
class SoccerScoreSection extends StatelessWidget {
  final EventModelV2 event;

  const SoccerScoreSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Yellow cards
        _CardsColumn(
          homeCount: event.yellowCardsHome,
          awayCount: event.yellowCardsAway,
          color: const Color(0xFFD4A017),
          textColor: const Color(0xFF1A1A1A),
        ),
        const SizedBox(width: 4),
        // Red cards
        _CardsColumn(
          homeCount: event.redCardsHome,
          awayCount: event.redCardsAway,
          color: const Color(0xFFCC3333),
          textColor: const Color(0xFFFFFEF5),
        ),
        const SizedBox(width: 4),
        // Score container
        _ScoreColumn(
          eventId: event.eventId,
          homeScore: event.homeScoreInt,
          awayScore: event.awayScoreInt,
        ),
      ],
    );
  }
}

/// Cards column (yellow/red)
class _CardsColumn extends StatelessWidget {
  final int homeCount;
  final int awayCount;
  final Color color;
  final Color textColor;

  const _CardsColumn({
    required this.homeCount,
    required this.awayCount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Column(
        children: [
          _CardCell(count: homeCount, color: color, textColor: textColor),
          _CardCell(count: awayCount, color: color, textColor: textColor),
        ],
      ),
    );
  }
}

class _CardCell extends StatelessWidget {
  final int count;
  final Color color;
  final Color textColor;

  const _CardCell({
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: count > 0
          ? Container(
              width: 16,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: AppTextStyles.textStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Score column with live updates
class _ScoreColumn extends StatelessWidget {
  final int eventId;
  final int homeScore;
  final int awayScore;

  const _ScoreColumn({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        border: Border.all(color: const Color(0xFF393836)),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(top: 5.5),
      child: Column(
        children: [
          Container(
            height: 25.5,
            alignment: Alignment.center,
            child: LiveSingleScoreDisplay(
              eventId: eventId,
              isHome: true,
              initialValue: homeScore,
            ),
          ),
          Container(
            height: 25.5,
            alignment: Alignment.center,
            child: LiveSingleScoreDisplay(
              eventId: eventId,
              isHome: false,
              initialValue: awayScore,
            ),
          ),
        ],
      ),
    );
  }
}
