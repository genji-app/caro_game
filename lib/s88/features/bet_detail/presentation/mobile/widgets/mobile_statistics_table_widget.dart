import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/live/live_consumers.dart';

/// Mobile Statistics Table Widget
///
/// Reusable widget for displaying match statistics table.
/// Can be used in both MatchHeaderMobileWidget and sticky headers.
class MobileStatisticsTableWidget extends StatelessWidget {
  final LeagueEventData eventData;
  final Animation<double>?
  pulseAnimation; // Optional pulse animation for live indicator
  final bool hideBottomBorderRadius; // Bỏ borderRadius ở bottom khi sticky

  const MobileStatisticsTableWidget({
    super.key,
    required this.eventData,
    this.pulseAnimation,
    this.hideBottomBorderRadius = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = hideBottomBorderRadius
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        : BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AppColorStyles.backgroundTertiary,
          border: Border(
            top: BorderSide(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            // Team column with live indicator
            Flexible(
              child: Column(
                children: [
                  // Header row with live indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Live indicator dot with pulsing effect (if animation provided)
                        if (eventData.isLive && pulseAnimation != null)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer pulsing ring
                                AnimatedBuilder(
                                  animation: pulseAnimation!,
                                  builder: (context, child) {
                                    return Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5172)
                                            .withOpacity(
                                              0.12 * pulseAnimation!.value,
                                            ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                                // Middle pulsing ring
                                AnimatedBuilder(
                                  animation: pulseAnimation!,
                                  builder: (context, child) {
                                    return Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5172)
                                            .withOpacity(
                                              0.12 * pulseAnimation!.value,
                                            ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                                // Inner solid dot
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
                          )
                        else if (eventData.isLive)
                          // Simple live indicator without animation
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5172),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (eventData.isLive) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: LiveMatchTimeDisplay(
                              eventId: eventData.eventId,
                              initialMinute: eventData.minuteString.isNotEmpty
                                  ? eventData.minuteString
                                  : null,
                              initialPeriod: eventData.gamePartEnum.displayName,
                              style: AppTextStyles.paragraphSmall(
                                color: AppColorStyles.contentSecondary,
                              ),
                              separator: const SizedBox(width: 12),
                            ),
                          ),
                        ],
                        if (!eventData.isLive) ...[
                          Text(
                            eventData.formattedTime,
                            style: AppTextStyles.paragraphSmall(
                              color: AppColorStyles.contentSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Home team row
                  _buildTeamRow(
                    teamName: eventData.homeName,
                    logoUrl:
                        eventData.homeLogoFirst ?? eventData.homeLogoLast ?? '',
                  ),
                  // Away team row
                  _buildTeamRow(
                    teamName: eventData.awayName,
                    logoUrl:
                        eventData.awayLogoFirst ?? eventData.awayLogoLast ?? '',
                  ),
                ],
              ),
            ),
            // Statistics columns
            Flexible(
              child: Row(
                children: [
                  // Corner kicks column
                  _buildStatColumn(
                    icon: ImageHelper.load(
                      path: AppIcons.phatGoc,
                      width: 20,
                      height: 20,
                    ),
                    homeValue: eventData.cornersHome,
                    awayValue: eventData.cornersAway,
                  ),
                  // Yellow cards column
                  _buildStatColumn(
                    icon: ImageHelper.load(
                      path: AppIcons.iconYellowCard,
                      width: 20,
                      height: 20,
                    ),
                    homeValue: eventData.yellowCardsHome,
                    awayValue: eventData.yellowCardsAway,
                  ),
                  // Red cards column
                  _buildStatColumn(
                    icon: ImageHelper.load(
                      path: AppIcons.iconRedCard,
                      width: 20,
                      height: 20,
                    ),
                    homeValue: eventData.redCardsHome,
                    awayValue: eventData.redCardsAway,
                  ),
                  // 2nd half goals column
                  _buildStatColumn(
                    icon: Text(
                      'H2',
                      style: AppTextStyles.labelXSmall(
                        color: AppColorStyles.contentPrimary,
                      ),
                    ),
                    homeValue: 0, // TODO: Get from API when available
                    awayValue: 0, // TODO: Get from API when available
                  ),
                  // Total goals column
                  _buildStatColumn(
                    icon: ImageHelper.load(
                      path: AppIcons.iconSoccer,
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                    ),
                    homeValue: eventData.homeScore,
                    awayValue: eventData.awayScore,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow({required String teamName, required String logoUrl}) =>
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
        child: Row(
          children: [
            // Team logo
            if (logoUrl.isNotEmpty)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ImageHelper.getSmallLogo(imageUrl: logoUrl, size: 28),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 20,
                  color: AppColorStyles.contentSecondary,
                ),
              ),
            const SizedBox(width: 8),
            // Team name
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

  Widget _buildStatColumn({
    required Widget icon,
    required int homeValue,
    required int awayValue,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Column(
        children: [
          // Header with icon
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: icon),
          ),
          // Home team value
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '$homeValue',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
          // Away team value
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '$awayValue',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
