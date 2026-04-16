import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/models/market_drawer_data_v2.dart';
import 'package:co_caro_flame/s88/features/bet_detail/presentation/mobile/widgets/layouts/layouts.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Mobile widget for displaying a market drawer V2 (new design)
///
/// New Design Features:
/// - Each market type is a separate expandable card
/// - Header: "{Period} - {Market Type}" + expand/collapse arrow
/// - Body: Different layouts based on market type
///
/// Layout Types:
/// - handicap: 2 columns with team names, multiple rows
/// - overUnder: 2 columns (Tài/Xỉu), multiple rows
/// - oneXTwo: 3 horizontal cells (1, X, 2)
/// - oddEven: 2 horizontal cells (Lẻ, Chẵn)
/// - doubleChance: 3 horizontal cells (1X, X2, 12)
/// - drawNoBet: 2 horizontal cells with team names
/// - cleanSheet: 2 columns with team names, Yes/No rows
/// - teamOverUnder: 2 columns (Tài/Xỉu) with team name in header
class MarketDrawerV2MobileWidget extends StatelessWidget {
  final MarketDrawerDataV2 drawer;
  final OddsStyle oddsStyle;
  final VoidCallback onToggle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const MarketDrawerV2MobileWidget({
    super.key,
    required this.drawer,
    required this.oddsStyle,
    required this.onToggle,
    this.eventData,
    this.leagueData,
  });

  /// Home team name from event data
  String get homeTeamName => eventData?.homeName ?? 'Nhà';

  /// Away team name from event data
  String get awayTeamName => eventData?.awayName ?? 'Khách';

  @override
  Widget build(BuildContext context) {
    return ExpandableMarketCard(
      title: drawer.name,
      isExpanded: drawer.isExpanded,
      onToggle: onToggle,
      child: _buildContent(),
    );
  }

  /// Build content based on layout type
  Widget _buildContent() {
    if (drawer.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (drawer.layoutType) {
      case MarketLayoutTypeV2.handicap:
        return _buildHandicapLayout();

      case MarketLayoutTypeV2.overUnder:
      case MarketLayoutTypeV2.teamOverUnder:
        return _buildOverUnderLayout();

      case MarketLayoutTypeV2.oneXTwo:
        return _buildOneXTwoLayout();

      case MarketLayoutTypeV2.oddEven:
        return _buildOddEvenLayout();

      case MarketLayoutTypeV2.doubleChance:
        return _buildDoubleChanceLayout();

      case MarketLayoutTypeV2.drawNoBet:
        return _buildDrawNoBetLayout();

      case MarketLayoutTypeV2.cleanSheet:
        return _buildCleanSheetLayout();

      case MarketLayoutTypeV2.teamWinner:
        return _buildTeamWinnerLayout();

      case MarketLayoutTypeV2.nextLastGoal:
        return _buildNextLastGoalLayout();

      case MarketLayoutTypeV2.whichTeamToScore:
        return _buildWhichTeamToScoreLayout();

      case MarketLayoutTypeV2.correctScore:
        return _buildCorrectScoreLayout();

      case MarketLayoutTypeV2.totalScore:
        return _buildTotalScoreLayout();
    }
  }

  /// Handicap layout: 2 columns with team names, multiple rows
  Widget _buildHandicapLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return HandicapMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Over/Under layout: 2 columns (Tài/Xỉu), multiple rows
  Widget _buildOverUnderLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OverUnderMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// 1X2 layout: 3 horizontal cells
  Widget _buildOneXTwoLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OneXTwoMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
    );
  }

  /// Odd/Even layout: 2 horizontal cells
  Widget _buildOddEvenLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return OddEvenMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Double Chance layout: 3 horizontal cells
  Widget _buildDoubleChanceLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return DoubleChanceMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Draw No Bet layout: 2 horizontal cells with team names
  Widget _buildDrawNoBetLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return DrawNoBetMobileLayout(
      market: market,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Clean Sheet layout: 2 columns with team names, Yes/No rows
  Widget _buildCleanSheetLayout() {
    if (drawer.markets.isEmpty) return const SizedBox.shrink();

    return CleanSheetMobileLayout(
      markets: drawer.markets,
      oddsStyle: oddsStyle,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Team Winner layout: 2 horizontal cells with team names
  /// Used for: To Qualify, Penalty Winner, Last Corner, etc.
  Widget _buildTeamWinnerLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    // Reuse Only2MobileLayout with team name headers
    return Only2MobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      customHeaders: [homeTeamName, awayTeamName],
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Next/Last Goal layout: 3 horizontal cells (Home, No Goal, Away)
  Widget _buildNextLastGoalLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    // Reuse Only3MobileLayout with appropriate headers
    return Only3MobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      customHeaders: [homeTeamName, 'Không có', awayTeamName],
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Which Team To Score layout: 2x2 grid
  Widget _buildWhichTeamToScoreLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return Only4MobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Correct Score layout: 3 columns grid
  Widget _buildCorrectScoreLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return CorrectScoreMobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }

  /// Total Score layout: Vertical list with points
  Widget _buildTotalScoreLayout() {
    final market = drawer.market;
    if (market == null) return const SizedBox.shrink();

    return TogetherMobileLayout(
      markets: [market],
      oddsStyle: oddsStyle,
      eventData: eventData,
      leagueData: leagueData,
    );
  }
}
