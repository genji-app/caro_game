import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart'
    show SportType;
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/hint_bubble/hint_bubble.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_explanation/bet_explanation.dart';

// ✅ Constants for UI dimensions
class _UIDimensions {
  static const double iconSize = 18.0;
  static const double iconPadding = 4.0;
  static const double sportIconSize = 20.0;
  static const double horizontalPadding = 12.0;
  static const double spacing = 8.0;
}

// ✅ Helper class for extracting bet data
class BetCardMatchData {
  const BetCardMatchData({
    required this.matchName,
    required this.leagueName,
    required this.marketName,
    required this.displayOdds,
    required this.oddsName,
    required this.cls,
    required this.matchDateText,
    required this.matchType,
    required this.isLive,
    required this.sport,
  });

  /// Create from BetSlip model
  factory BetCardMatchData.fromBetSlip(BetSlip bet) {
    return BetCardMatchData(
      matchName: bet.fullMatchNameWithScore,
      leagueName: bet.leagueName,
      marketName: bet.displayMarketName,
      displayOdds: bet.displayOdds,
      oddsName: bet.oddsName,
      cls: bet.cls,
      matchDateText: DateFormat(dateTimeFormat).format(bet.startDate),
      matchType: bet.matchTypeEnum,
      isLive: bet.isMatchLive,
      sport: bet.sport,
    );
  }

  /// Create from ChildBet model
  factory BetCardMatchData.fromChildBet(ChildBet subBet) {
    return BetCardMatchData(
      matchName: subBet.fullMatchNameWithScore,
      leagueName: subBet.leagueName,
      marketName: subBet.displayMarketName,
      displayOdds: subBet.displayOdds,
      oddsName: subBet.oddsName,
      cls: subBet.cls,
      matchDateText: DateFormat(dateTimeFormat).format(subBet.startDate),
      matchType: subBet.matchTypeEnum,
      isLive: subBet.isMatchLive,
      sport: subBet.sport,
    );
  }

  final String matchName;
  final String leagueName;
  final String marketName;
  final String displayOdds;
  final String oddsName;
  final String cls;
  final String matchDateText;
  final MatchType matchType;
  final bool isLive;
  final SportType? sport;

  // --- Date & Time Formats ---
  static const String dateTimeFormat = 'HH:mm - dd/MM/yyyy';
}

/// Pure presentation component for displaying bet slip match information
///
/// This widget is stateless and contains no business logic.
/// All data is passed as primitive props, and actions are handled via callbacks.
class BetSlipCardMatch extends StatelessWidget {
  const BetSlipCardMatch({
    required this.betData,
    required this.hintData,
    super.key,
  });

  /// Factory constructor to create from ChildBet model
  BetSlipCardMatch.fromBetSlip({
    required BetSlip bet,
    required HintData hintData,
    Key? key,
  }) : this(
         key: key,
         betData: BetCardMatchData.fromBetSlip(bet),
         hintData: hintData,
       );

  /// Factory constructor to create from ChildBet model
  BetSlipCardMatch.fromChildBet({
    required ChildBet subBet,
    required HintData hintData,
    Key? key,
  }) : this(
         key: key,
         betData: BetCardMatchData.fromChildBet(subBet),
         hintData: hintData,
       );

  /// Factory constructor to create with separate params
  BetSlipCardMatch.fromData({
    required String leagueName,
    required String matchName,
    required String matchDateText,
    required String marketName,
    required String oddsName,
    required String displayOdds,
    required String cls,
    required MatchType matchType,
    required bool isLive,
    required SportType sport,
    required HintData hintData,
    Key? key,
  }) : this(
         key: key,
         hintData: hintData,
         betData: BetCardMatchData(
           leagueName: leagueName,
           matchName: matchName,
           matchDateText: matchDateText,
           marketName: marketName,
           oddsName: oddsName,
           displayOdds: displayOdds,
           cls: cls,
           matchType: matchType,
           isLive: isLive,
           sport: sport,
         ),
       );

  // ✅ Model containing bet details
  final BetCardMatchData betData;

  // ✅ HintData for tooltip content
  final HintData hintData;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsetsDirectional.symmetric(
      horizontal: _UIDimensions.horizontalPadding,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeagueName(betData.leagueName, horizontalPadding),
        const Gap(_UIDimensions.spacing),
        _buildMatchName(
          betData.matchName,
          betData.matchType,
          betData.sport,
          horizontalPadding,
        ),
        const Gap(_UIDimensions.spacing),
        _buildMatchTime(
          betData.matchDateText,
          betData.matchType,
          betData.isLive,
          horizontalPadding,
        ),
        _buildMarketInfo(betData.marketName, horizontalPadding),
        _buildOddsInfo(
          betData.oddsName,
          betData.displayOdds,
          betData.cls,
          horizontalPadding,
        ),
      ],
    );
  }

  Widget _buildLeagueName(String leagueName, EdgeInsetsDirectional padding) {
    return Padding(
      padding: padding,
      child: Text(
        leagueName,
        style: AppTextStyles.paragraphXSmall(
          color: AppColorStyles.contentSecondary,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget? _buildSportIcon(SportType sport) {
    return switch (sport) {
      SportType.soccer => SizedBox.square(
        dimension: _UIDimensions.sportIconSize,
        child: ImageHelper.load(
          path: AppIcons.iconFootballSelected,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      SportType.basketball => SizedBox.square(
        dimension: _UIDimensions.sportIconSize,
        child: ImageHelper.load(
          path: AppIcons.iconBasketballSelected,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      SportType.tennis => SizedBox.square(
        dimension: _UIDimensions.sportIconSize,
        child: ImageHelper.load(
          path: AppIcons.iconTennisSelected,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      SportType.volleyball => SizedBox.square(
        dimension: _UIDimensions.sportIconSize,
        child: ImageHelper.load(
          path: AppIcons.iconVolleyballSelected,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      SportType.tableTennis => SizedBox.square(
        dimension: _UIDimensions.sportIconSize,
        child: ImageHelper.load(
          path: AppIcons.iconTableTennisSelected,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      SportType.badminton => SizedBox.square(
        dimension: _UIDimensions.sportIconSize,
        child: ImageHelper.load(
          path: AppIcons.iconBadmintonSelected,
          color: AppColorStyles.contentSecondary,
        ),
      ),
      _ => null,
    };
  }

  Widget _buildMatchName(
    String matchName,
    MatchType? matchType,
    SportType? sport,
    EdgeInsetsDirectional padding,
  ) {
    final isLeagueBetting = matchType == MatchType.leagueBetting;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          _buildSportIcon(sport ?? SportType.soccer) ?? const SizedBox.shrink(),

          const Gap(4),

          Expanded(
            child: Text(
              matchName,
              style: AppTextStyles.labelSmall(
                color: AppColorStyles.contentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          if (!isLeagueBetting) ...[
            const Gap(4),
            SizedBox.square(
              dimension: 20,
              child: ImageHelper.load(path: AppIcons.icScore),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchTime(
    String matchDateText,
    MatchType matchType,
    bool isLive,
    EdgeInsetsDirectional padding,
  ) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (isLive && matchType != MatchType.leagueBetting) ...[
            const MatchLiveIcon(),
            const Gap(_UIDimensions.spacing),
          ],
          Text(
            matchDateText,
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInfo(String marketName, EdgeInsetsDirectional padding) {
    return Padding(
      padding: padding.copyWith(end: _UIDimensions.spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              marketName,
              style: AppTextStyles.paragraphMedium(
                color: AppColorStyles.contentSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildTooltipTrigger(),
        ],
      ),
    );
  }

  Widget _buildTooltipTrigger() {
    return BetExplanationTooltip.icon(
      hintData: hintData,
      iconColor: AppColorStyles.contentSecondary,
      iconSize: _UIDimensions.iconSize,
      config: const BetTooltipConfig(
        rootOverlay: false, // Use nearest overlay for bet slip cards
        triggerPadding: EdgeInsets.all(_UIDimensions.iconPadding),
        offset: Offset(8, 0),
      ),
    );
  }

  Widget _buildOddsInfo(
    String oddsName,
    String displayOdds,
    String cls,
    EdgeInsetsDirectional padding,
  ) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '$oddsName ($cls)',
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            displayOdds,
            style: AppTextStyles.labelMedium(color: const Color(0xFFACDC79)),
          ),
        ],
      ),
    );
  }
}

class MatchLiveIcon extends StatelessWidget {
  const MatchLiveIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.red500,
      ),
      child: Text(
        'Trực tiếp',
        style: AppTextStyles.labelXXSmall(
          color: AppColorStyles.contentPrimary,
        ).copyWith(fontWeight: FontWeight.w600, height: 1.50, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
