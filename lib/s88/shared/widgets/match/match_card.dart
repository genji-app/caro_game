import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import '../teams/team_display.dart';
import '../cards/bet_card.dart';

class MatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String? matchTime;
  final bool isLive;
  final String? leagueName;
  final String? leagueLogo;
  final List<String> betTypes;
  final String selectedBetType;
  final void Function(String)? onBetTypeChanged;
  final List<Map<String, String>> bets;
  final int? moreMatchesCount;
  final bool isMobile;

  const MatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.matchTime,
    this.isLive = false,
    this.leagueName,
    this.leagueLogo,
    this.betTypes = const [
      'Kèo chấp',
      'Tài xỉu',
      '1X2',
      'Kèo chấp H1',
      'Tài xỉu H1',
      '1X2 H1',
    ],
    this.selectedBetType = 'Kèo chấp',
    this.onBetTypeChanged,
    this.bets = const [],
    this.moreMatchesCount,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0x0AFFF6E4), // rgba(255,246,230,0.04)
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // League header section
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // League logo
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: leagueLogo != null
                          ? ImageHelper.getNetworkImage(
                              imageUrl: leagueLogo!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // League name
                    Expanded(
                      child: Text(
                        leagueName ?? 'Cúp C1 Châu Âu',
                        style: AppTextStyles.textStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xB3FFFCDB), // opacity-70
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron icon
              ImageHelper.load(
                path: AppIcons.chevronUp,
                width: 20,
                height: 20,
                // colorFilter: const ColorFilter.mode(
                //   Color(0xB3FFFFFF), // opacity-70
                //   BlendMode.srcIn,
                // ),
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
        // Bet type tabs section with gradient background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0),
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Row(
            children: [
              // Live indicator and time
              SizedBox(
                width: 141,
                child: Row(
                  children: [
                    // Live indicator
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Live',
                          style: AppTextStyles.textStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF5172),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 12,
                          height: 12,
                          alignment: Alignment.center,
                          child: ImageHelper.load(
                            path: AppIcons.liveDot,
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Match time
                    if (matchTime != null)
                      Text(
                        matchTime!,
                        style: AppTextStyles.textStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFFFFCDB),
                        ),
                      ),
                  ],
                ),
              ),
              // Bet type tabs - First 3 columns
              Expanded(
                child: Row(
                  children: betTypes
                      .take(3)
                      .map(
                        (type) => Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 0 : 10,
                              vertical: 0,
                            ),
                            child: Center(
                              child: Text(
                                type,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.textStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFAAA49B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              // Bet type tabs - Last 3 columns (H1 variants)
              if (!isMobile)
                Expanded(
                  child: Row(
                    children: betTypes
                        .skip(3)
                        .take(3)
                        .map(
                          (type) => Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: AppTextStyles.textStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFAAA49B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              // Space for +78 indicator
              const SizedBox(width: 24),
            ],
          ),
        ),
        // Teams and bets section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teams column
              SizedBox(
                width: 141,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Home team row
                    TeamDisplay(
                      teamName: homeTeam,
                      teamLogo: homeTeamLogo,
                      isHome: true,
                    ),
                    const SizedBox(height: 8),
                    // Away team row
                    TeamDisplay(
                      teamName: awayTeam,
                      teamLogo: awayTeamLogo,
                      isHome: false,
                    ),
                    const SizedBox(height: 8),
                    // Graph icon
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.centerLeft,
                      child: ImageHelper.load(
                        path: AppIcons.hr,
                        width: 16,
                        height: 16,
                        color: const Color(0xB3FFFFFF), // opacity-70
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // First 3 bet columns (Kèo chấp, Tài xỉu, 1X2)
              Expanded(
                child: Column(
                  children: [
                    // Home team bets row
                    Row(
                      children: List.generate(
                        3,
                        (colIndex) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4, right: 8),
                            child: isMobile
                                ? BetCardMobile(
                                    label: bets.length > colIndex * 3 + 0
                                        ? bets[colIndex * 3 + 0]['label']
                                        : null,
                                    value: bets.length > colIndex * 3 + 0
                                        ? bets[colIndex * 3 + 0]['value']
                                        : null,
                                  )
                                : BetCard(
                                    label: bets.length > colIndex * 3 + 0
                                        ? bets[colIndex * 3 + 0]['label']
                                        : null,
                                    value: bets.length > colIndex * 3 + 0
                                        ? bets[colIndex * 3 + 0]['value']
                                        : null,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Away team bets row
                    Row(
                      children: List.generate(
                        3,
                        (colIndex) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4, right: 8),
                            child: isMobile
                                ? BetCardMobile(
                                    label: bets.length > colIndex * 3 + 1
                                        ? bets[colIndex * 3 + 1]['label']
                                        : null,
                                    value: bets.length > colIndex * 3 + 1
                                        ? bets[colIndex * 3 + 1]['value']
                                        : null,
                                  )
                                : BetCard(
                                    label: bets.length > colIndex * 3 + 1
                                        ? bets[colIndex * 3 + 1]['label']
                                        : null,
                                    value: bets.length > colIndex * 3 + 1
                                        ? bets[colIndex * 3 + 1]['value']
                                        : null,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Draw/X row (only in 1X2 column - column index 2)
                    Row(
                      children: List.generate(3, (colIndex) {
                        if (colIndex == 2) {
                          // Show Draw/X bet in 1X2 column
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4,
                                right: 8,
                              ),
                              child: isMobile
                                  ? BetCardMobile(
                                      label: bets.length > colIndex * 3 + 2
                                          ? bets[colIndex * 3 + 2]['label']
                                          : 'X',
                                      value: bets.length > colIndex * 3 + 2
                                          ? bets[colIndex * 3 + 2]['value']
                                          : null,
                                    )
                                  : BetCard(
                                      label: bets.length > colIndex * 3 + 2
                                          ? bets[colIndex * 3 + 2]['label']
                                          : 'X',
                                      value: bets.length > colIndex * 3 + 2
                                          ? bets[colIndex * 3 + 2]['value']
                                          : null,
                                    ),
                            ),
                          );
                        } else {
                          // Empty space for other columns
                          return const Expanded(child: SizedBox());
                        }
                      }),
                    ),
                  ],
                ),
              ),
              // Second 3 bet columns (Kèo chấp H1, Tài xỉu H1, 1X2 H1)
              if (!isMobile)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // Home team bets row (H1)
                            Row(
                              children: List.generate(
                                3,
                                (colIndex) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 4,
                                      right: 8,
                                    ),
                                    child: BetCard(
                                      label: bets.length > 9 + colIndex * 3 + 0
                                          ? bets[9 + colIndex * 3 + 0]['label']
                                          : null,
                                      value: bets.length > 9 + colIndex * 3 + 0
                                          ? bets[9 + colIndex * 3 + 0]['value']
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Away team bets row (H1)
                            Row(
                              children: List.generate(
                                3,
                                (colIndex) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 4,
                                      right: 8,
                                    ),
                                    child: BetCard(
                                      label: bets.length > 9 + colIndex * 3 + 1
                                          ? bets[9 + colIndex * 3 + 1]['label']
                                          : null,
                                      value: bets.length > 9 + colIndex * 3 + 1
                                          ? bets[9 + colIndex * 3 + 1]['value']
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Draw/X row (H1) - only in 1X2 H1 column (column index 2)
                            Row(
                              children: List.generate(3, (colIndex) {
                                if (colIndex == 2) {
                                  // Show Draw/X bet in 1X2 H1 column
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4,
                                        right: 8,
                                      ),
                                      child: BetCard(
                                        label:
                                            bets.length > 9 + colIndex * 3 + 2
                                            ? bets[9 +
                                                  colIndex * 3 +
                                                  2]['label']
                                            : 'X',
                                        value:
                                            bets.length > 9 + colIndex * 3 + 2
                                            ? bets[9 +
                                                  colIndex * 3 +
                                                  2]['value']
                                            : null,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Empty space for other columns
                                  return const Expanded(child: SizedBox());
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                      // More matches count (+78) - aligned with away team row
                      if (moreMatchesCount != null)
                        Container(
                          width: 24,
                          padding: const EdgeInsets.only(
                            bottom: 8,
                          ), // Align with away team row
                          alignment: Alignment.center,
                          child: Text(
                            '+$moreMatchesCount',
                            style: AppTextStyles.textStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xB3FFFCDB), // opacity-70
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
