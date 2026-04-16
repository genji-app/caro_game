import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// Hot Match Card Widget
///
/// Displays a single hot match with:
/// - League header
/// - Team info with logos
/// - Match time
/// - Handicap and Over/Under odds
class HotMatchCard extends ConsumerWidget {
  final HotMatchEventV2 match;
  final VoidCallback? onTap;
  final void Function(LeagueOddsData odds, bool isHome, int marketId)?
  onOddsTap;

  const HotMatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onOddsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ═══════════════════════════════════════════════════════════════════════════
    // PERFORMANCE: Use .select() to only rebuild when specific fields change
    // ═══════════════════════════════════════════════════════════════════════════
    final sportId = ref.watch(leagueProvider.select((s) => s.currentSportId));
    final oddsStyle = ref.watch(leagueProvider.select((s) => s.oddsStyle));

    final handicapMarket = match.getHandicapMarket(sportId);
    final overUnderMarket = match.getOverUnderMarket(sportId);
    final handicapOdds = handicapMarket?.mainLineOdds?.toLegacy();
    final overUnderOdds = overUnderMarket?.mainLineOdds?.toLegacy();

    return GestureDetector(
      onTap: onTap,
      child: InnerShadowCard(
        borderRadius: 12,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColorStyles.backgroundTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // League header
              _buildLeagueHeader(),

              // Teams and time section
              // _buildTeamsSection(),
              const Gap(8),

              // Odds section
              _buildOddsSection(
                handicapOdds: handicapOdds,
                overUnderOdds: overUnderOdds,
                oddsStyle: oddsStyle,
                handicapMarketId: handicapMarket?.marketId ?? 5,
                overUnderMarketId: overUnderMarket?.marketId ?? 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build league header
  Widget _buildLeagueHeader() => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Row(
      children: [
        // League logo
        if (match.leagueLogo.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ImageHelper.getNetworkImage(
              imageUrl: match.leagueLogo,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          )
        else
          ImageHelper.load(path: AppIcons.iconSoccer, width: 20, height: 20),
        const Gap(6),
        // League name
        Expanded(
          child: Text(
            match.leagueName,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  /// Build teams and time section
  Widget _buildTeamsSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Row(
      children: [
        // Home team
        Expanded(
          child: _buildTeamInfo(
            name: match.homeName,
            logo: match.homeLogo,
            isHome: true,
          ),
        ),

        // Time/Score column
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildTimeOrScore(),
        ),

        // Away team
        Expanded(
          child: _buildTeamInfo(
            name: match.awayName,
            logo: match.awayLogo,
            isHome: false,
          ),
        ),
      ],
    ),
  );

  /// Build team info (logo + name)
  Widget _buildTeamInfo({
    required String name,
    required String logo,
    required bool isHome,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Team logo
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundQuaternary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: logo.isNotEmpty
              ? ImageHelper.getNetworkImage(
                  imageUrl: logo,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                )
              : Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.labelMedium(
                      color: AppColorStyles.contentSecondary,
                    ),
                  ),
                ),
        ),
      ),
      const Gap(4),
      // Team name - constrained width to prevent overflow
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 80),
        child: Text(
          name,
          style: AppTextStyles.labelXSmall(
            color: AppColorStyles.contentPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );

  /// Build time or score display
  Widget _buildTimeOrScore() {
    if (match.isLive) {
      // Live match - show score
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5172).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5172),
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(4),
                Text(
                  'Live',
                  style: AppTextStyles.paragraphXXSmall(
                    color: const Color(0xFFFF5172),
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          // Score
          Text(
            match.scoreString,
            style: AppTextStyles.labelLarge(
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      );
    } else {
      // Upcoming match - show time
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            match.formattedTime.split(' - ').first, // Time only
            style: AppTextStyles.labelSmall(
              color: AppColorStyles.contentPrimary,
            ),
          ),
          const Gap(2),
          Text(
            match.formattedDate,
            style: AppTextStyles.paragraphXXSmall(
              color: AppColorStyles.contentTertiary,
            ),
          ),
        ],
      );
    }
  }

  /// Build odds section with Handicap and Over/Under
  Widget _buildOddsSection({
    required LeagueOddsData? handicapOdds,
    required LeagueOddsData? overUnderOdds,
    required OddsStyle oddsStyle,
    required int handicapMarketId,
    required int overUnderMarketId,
  }) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundQuaternary.withValues(alpha: 0.5),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
    child: Row(
      children: [
        // Handicap column
        Expanded(
          child: _buildOddsColumn(
            title: 'Kèo chấp',
            odds: handicapOdds,
            oddsStyle: oddsStyle,
            marketId: handicapMarketId,
          ),
        ),
        Container(width: 1, height: 50, color: AppColorStyles.borderSecondary),
        // Over/Under column
        Expanded(
          child: _buildOddsColumn(
            title: 'Tài Xỉu',
            odds: overUnderOdds,
            oddsStyle: oddsStyle,
            marketId: overUnderMarketId,
            isOverUnder: true,
          ),
        ),
      ],
    ),
  );

  /// Build single odds column
  Widget _buildOddsColumn({
    required String title,
    required LeagueOddsData? odds,
    required OddsStyle oddsStyle,
    required int marketId,
    bool isOverUnder = false,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Title
      Text(
        title,
        style: AppTextStyles.paragraphXXSmall(
          color: AppColorStyles.contentTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const Gap(4),
      if (odds != null) ...[
        // Points/Handicap value
        Text(
          PointsFormatter.format(odds.points),
          style: AppTextStyles.labelXSmall(
            color: AppColorStyles.contentSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(4),
        // Odds row
        // API sends: home = Over odds, away = Under odds
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Home odds (for Handicap/1X2) or Over odds (for O/U)
            Flexible(
              child: _buildOddsButton(
                value: odds.getHomeOdds(oddsStyle),
                label: isOverUnder ? 'T' : null,
                onTap: () => onOddsTap?.call(odds, true, marketId),
              ),
            ),
            const Gap(4),
            // Away odds (for Handicap/1X2) or Under odds (for O/U)
            Flexible(
              child: _buildOddsButton(
                value: odds.getAwayOdds(oddsStyle),
                label: isOverUnder ? 'X' : null,
                onTap: () => onOddsTap?.call(odds, false, marketId),
              ),
            ),
          ],
        ),
      ] else
        Text(
          '-',
          style: AppTextStyles.labelSmall(
            color: AppColorStyles.contentTertiary,
          ),
        ),
    ],
  );

  /// Build clickable odds button
  Widget _buildOddsButton({
    required double value,
    String? label,
    VoidCallback? onTap,
  }) {
    final isValid = value != -100 && value != 0;
    final isNegative = value < 0;

    return GestureDetector(
      onTap: isValid ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColorStyles.backgroundTertiary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColorStyles.borderSecondary, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label,
                style: AppTextStyles.paragraphXXSmall(
                  color: AppColorStyles.contentTertiary,
                ),
              ),
              const Gap(2),
            ],
            Text(
              isValid ? value.toStringAsFixed(2) : '-',
              style: AppTextStyles.labelXSmall(
                color: isNegative
                    ? const Color(0xFFFF5172)
                    : AppColorStyles.contentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
