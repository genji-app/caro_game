import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/wallet/inner_shadow.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

class MatchStatsTable extends StatelessWidget {
  final BettingPopupData? data;
  final bool isVibrating;

  const MatchStatsTable({super.key, this.data, this.isVibrating = false});

  @override
  Widget build(BuildContext context) {
    // Early return if no data
    if (data == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats table
        InnerShadow(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColorStyles.backgroundTertiary,
              ),
              child: Column(
                children: [
                  // const SizedBox(height: 8),
                  Container(
                    // padding: isVibrating
                    //     ? EdgeInsets.zero
                    //     : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: isVibrating
                        ? null
                        : BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                    child: Text(
                      data?.leagueData?.leagueName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.paragraphXSmall(
                        color: AppColorStyles.contentSecondary,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 8),
                  ImageHelper.load(
                    path: AppIcons.hr,
                    width: double.infinity,
                    height: 2,
                    fit: BoxFit.fill,
                  ),
                  // const SizedBox(height: 8),
                  Row(
                    children: [
                      // Team column
                      Flexible(
                        child: Column(
                          children: [
                            // Header row
                            Container(
                              // height: 40,
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Live indicator - only show if live
                                  if (data?.isLive == true) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: AppColors.red500,
                                      ),
                                      child: Text(
                                        'Trực tiếp',
                                        style:
                                            AppTextStyles.labelXXSmall(
                                              color:
                                                  AppColorStyles.contentPrimary,
                                            ).copyWith(
                                              fontWeight: FontWeight.w600,
                                              height: 1.50,
                                              fontSize: 12,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "${data?.gameTime ?? 0}'",
                                      style: AppTextStyles.paragraphXSmall(
                                        color: AppColorStyles.contentPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _getGamePartText(data?.gamePart ?? 0),
                                      style: AppTextStyles.paragraphXSmall(
                                        color: AppColorStyles.contentSecondary,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      'Trận đấu',
                                      style: AppTextStyles.paragraphSmall(
                                        color: AppColorStyles.contentSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Team 1 row (Home)
                            _buildTeamRow(
                              teamName: data?.getHomeName() ?? 'Home',
                              logoPath: data?.homeLogo,
                              stats: [
                                data?.cornersHome ?? 0,
                                data?.yellowCardsHome ?? 0,
                                data?.redCardsHome ?? 0,
                                data?.eventData.homeScore ?? 0,
                              ],
                            ),
                            // Team 2 row (Away)
                            _buildTeamRow(
                              teamName: data?.getAwayName() ?? 'Away',
                              logoPath: data?.awayLogo,
                              stats: [
                                data?.cornersAway ?? 0,
                                data?.yellowCardsAway ?? 0,
                                data?.redCardsAway ?? 0,
                                data?.eventData.awayScore ?? 0,
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Corner kicks column
                      Flexible(
                        child: Row(
                          children: [
                            _buildStatColumn(
                              icon: _buildCornerKickIcon(),
                              values: [
                                data?.cornersHome ?? 0,
                                data?.cornersAway ?? 0,
                              ],
                            ),
                            // Yellow cards column
                            _buildStatColumn(
                              icon: _buildYellowCardIcon(),
                              values: [
                                data?.yellowCardsHome ?? 0,
                                data?.yellowCardsAway ?? 0,
                              ],
                            ),
                            // Red cards column
                            _buildStatColumn(
                              icon: _buildRedCardIcon(),
                              values: [
                                data?.redCardsHome ?? 0,
                                data?.redCardsAway ?? 0,
                              ],
                            ),
                            // Goals column
                            _buildStatColumn(
                              icon: _buildFootballIcon(),
                              values: [
                                data?.eventData.homeScore ?? 0,
                                data?.eventData.awayScore ?? 0,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getGamePartText(int gamePart) {
    // Game part values: firstHalf=2, halfTime=4, secondHalf=8
    if (gamePart == 2) return 'Hiệp 1';
    if (gamePart == 4) return 'Nghỉ giữa hiệp';
    if (gamePart == 8) return 'Hiệp 2';
    return 'Trận đấu';
  }

  Widget _buildTeamRow({
    required String teamName,
    String? logoPath,
    required List<int> stats,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: AppColorStyles.backgroundQuaternary),
    child: Row(
      children: [
        // Team logo
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: logoPath != null && logoPath.isNotEmpty
              ? ImageHelper.getNetworkImage(
                  imageUrl: logoPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                )
              : const SizedBox(width: 28, height: 28),
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
    required List<int> values,
  }) => Expanded(
    child: Container(
      color: AppColorStyles.backgroundTertiary,
      child: Column(
        children: [
          // Header with icon
          Container(
            // height: 40,
            padding: const EdgeInsets.all(12),
            child: Center(child: icon),
          ),
          // Team 1 value
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '${values[0]}',
                style: AppTextStyles.labelSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ),
          // Team 2 value
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundQuaternary,
            ),
            child: Center(
              child: Text(
                '${values[1]}',
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

  Widget _buildCornerKickIcon() =>
      ImageHelper.load(path: AppIcons.phatGoc, width: 20, height: 20);

  Widget _buildYellowCardIcon() =>
      ImageHelper.load(path: AppIcons.iconYellowCard, width: 20, height: 20);

  Widget _buildRedCardIcon() =>
      ImageHelper.load(path: AppIcons.iconRedCard, width: 20, height: 20);

  Widget _buildFootballIcon() =>
      ImageHelper.getSVG(path: AppIcons.iconSoccer, width: 20, height: 20);
}
