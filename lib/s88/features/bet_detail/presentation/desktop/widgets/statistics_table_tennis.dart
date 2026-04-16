import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/score_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_v2_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/match_row_shared_v2.dart';

/// Tennis statistics table for bet detail desktop header.
///
/// Layout:
/// ```
/// [Live] Set 3 | 3-2  │Set│S1│S2│S3│S4│S5│PTS│ 🎾 │
/// 🏳 Home              │ 0 │ 2│ 2│ 3│ - │ - │ 30│ [7]│
/// 🏳 Away              │ 0 │ 4│ 4│ 2│ - │ - │ 30│[10]│
/// ```
class StatisticsTableTennis extends ConsumerWidget {
  final LeagueEventData eventData;
  final Animation<double> pulseAnimation;
  final bool isDesktop;

  const StatisticsTableTennis({
    required this.eventData,
    required this.pulseAnimation,
    this.isDesktop = true,
    super.key,
  });

  static const _labels = ['Set', 'S1', 'S2', 'S3', 'S4', 'S5', 'PTS'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventV2 = ref.watch(selectedEventV2Provider);
    final score = eventV2?.score;
    final tennis = score is TennisScoreModelV2 ? score : null;

    // Extract scores
    final homeScores = <String>[];
    final awayScores = <String>[];

    // Set wins
    homeScores.add(tennis?.homeSetScore.toString() ?? '-');
    awayScores.add(tennis?.awaySetScore.toString() ?? '-');

    // S1-S5
    int homeTotal = 0;
    int awayTotal = 0;
    for (var i = 0; i < 5; i++) {
      final s = tennis?.liveScores.elementAtOrNull(i);
      if (s != null && s.homeScore.isNotEmpty) {
        homeScores.add(s.homeScore);
        awayScores.add(s.awayScore);
        homeTotal += s.homeScoreInt;
        awayTotal += s.awayScoreInt;
      } else {
        homeScores.add('-');
        awayScores.add('-');
      }
    }

    // PTS
    final point = tennis?.currentPointDisplay;
    homeScores.add(point?.$1 ?? '-');
    awayScores.add(point?.$2 ?? '-');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColorStyles.backgroundTertiary,
        ),
        child: Row(
          children: [
            // Left: live info + teams
            Flexible(child: _buildLeftColumn(context, eventV2)),
            // Right: score columns
            for (var i = 0; i < _labels.length; i++)
              _buildScoreColumn(
                label: _labels[i],
                homeValue: i < homeScores.length ? homeScores[i] : '-',
                awayValue: i < awayScores.length ? awayScores[i] : '-',
              ),
            // Total column with sport icon + border
            _buildTotalColumn(
              homeValue: homeTotal > 0 ? homeTotal.toString() : '-',
              awayValue: awayTotal > 0 ? awayTotal.toString() : '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context, EventModelV2? eventV2) {
    return Column(
      children: [
        // Header row with live indicator
        Container(
          height: 44,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (eventData.isLive) ...[
                _buildPulsingDot(),
                const SizedBox(width: 12),
                Flexible(
                  child: LiveMatchTimeDisplay(
                    eventId: eventData.eventId,
                    initialMinute: eventData.minuteString.isNotEmpty
                        ? eventData.minuteString
                        : null,
                    initialPeriod: eventData.gamePartEnum.displayName,
                    sportId: 4,
                    initialSetScore: eventV2 != null
                        ? extractSetScore(eventV2)
                        : null,
                    style: AppTextStyles.paragraphSmall(
                      color: AppColorStyles.contentSecondary,
                    ),
                    separator: const SizedBox(width: 12),
                  ),
                ),
              ],
              if (!eventData.isLive)
                Text(
                  eventData.formattedTime,
                  style: AppTextStyles.paragraphSmall(
                    color: AppColorStyles.contentSecondary,
                  ),
                ),
            ],
          ),
        ),
        // Home team
        _buildTeamRow(
          teamName: eventData.homeName,
          logoUrl: eventData.homeLogoFirst ?? eventData.homeLogoLast ?? '',
        ),
        // Away team
        _buildTeamRow(
          teamName: eventData.awayName,
          logoUrl: eventData.awayLogoFirst ?? eventData.awayLogoLast ?? '',
        ),
      ],
    );
  }

  Widget _buildPulsingDot() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) => Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF5172,
                ).withValues(alpha: 0.12 * pulseAnimation.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) => Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF5172,
                ).withValues(alpha: 0.12 * pulseAnimation.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5172),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({required String teamName, required String logoUrl}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
      child: Row(
        children: [
          if (logoUrl.isNotEmpty && logoUrl != '')
            SizedBox(
              width: 28,
              height: 28,
              child: ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 28),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teamName,
              style: AppTextStyles.labelSmall(
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

  Widget _buildScoreColumn({
    required String label,
    required String homeValue,
    required String awayValue,
  }) {
    return SizedBox(
      width: isDesktop ? 40 : 25,
      child: Column(
        children: [
          Container(
            height: 44,
            color: AppColorStyles.backgroundTertiary,
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.paragraphXSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          ),
          Container(
            height: 44,
            color: AppColorStyles.backgroundQuaternary,
            alignment: Alignment.center,
            child: Text(
              homeValue,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
          Container(
            height: 44,
            color: AppColorStyles.backgroundQuaternary,
            alignment: Alignment.center,
            child: Text(
              awayValue,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalColumn({
    required String homeValue,
    required String awayValue,
  }) {
    return SizedBox(
      width: isDesktop ? 44 : 32,
      child: Column(
        children: [
          Container(
            height: 44,
            color: AppColorStyles.backgroundTertiary,
            alignment: Alignment.center,
            child: ImageHelper.load(
              path: AppIcons.iconTennis,
              width: 20,
              height: 20,
            ),
          ),
          // Bordered score area
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 44,
                    color: AppColorStyles.backgroundQuaternary,
                    alignment: Alignment.center,
                    child: Text(
                      homeValue,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ),
                  Container(
                    height: 44,
                    color: AppColorStyles.backgroundQuaternary,
                    alignment: Alignment.center,
                    child: Text(
                      awayValue,
                      style: AppTextStyles.labelSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 4,
                right: 4,
                top: 4,
                bottom: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    border: Border.all(color: AppColors.gray500, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
