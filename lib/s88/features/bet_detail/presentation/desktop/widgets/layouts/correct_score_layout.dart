import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/bet_card.dart';

/// Correct Score Layout Widget
///
/// Displays correct score markets in 3 or 6 columns:
/// - 3 columns: [Đội Nhà, Hoà, Đội Khách]
/// - 6 columns: [Nhà FT, Hoà FT, Khách FT, Nhà HT, Hoà HT, Khách HT]
///
/// Logic based on SbEventDrawer.ts:200-224:
/// - Home wins: scores like 1-0, 2-0, 2-1 (home > away)
/// - Draw: scores like 0-0, 1-1, 2-2 (home == away)
/// - Away wins: scores like 0-1, 0-2, 1-2 (home < away)
class CorrectScoreLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final bool is6Columns;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const CorrectScoreLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.is6Columns = false,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    // Get FT and HT markets
    final ftMarket = markets.where((m) => m.marketId == 10).firstOrNull;
    final htMarket = markets.where((m) => m.marketId == 11).firstOrNull;

    // Group odds for each market
    final ftGroups = ftMarket != null
        ? CorrectScoreHelper.groupOdds(ftMarket.odds)
        : null;
    final htGroups = htMarket != null
        ? CorrectScoreHelper.groupOdds(htMarket.odds)
        : null;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(),
          const SizedBox(height: 8),
          // Content
          _buildContent(ftGroups, htGroups, ftMarket, htMarket),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    // Headers based on screenshot from original JS project
    final headers = is6Columns
        ? [
            'Đội Nhà',
            'Hoà',
            'Đội Khách',
            'Đội Nhà H1',
            'Hoà H1',
            'Đội Khách H1',
          ]
        : ['Đội Nhà', 'Hoà', 'Đội Khách'];

    return Row(
      children: headers.map((title) {
        return Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent(
    CorrectScoreGroups? ftGroups,
    CorrectScoreGroups? htGroups,
    LeagueMarketData? ftMarket,
    LeagueMarketData? htMarket,
  ) {
    if (is6Columns && ftGroups != null && htGroups != null) {
      return _build6ColumnContent(ftGroups, htGroups, ftMarket, htMarket);
    }

    // 3 columns - use FT or HT
    final groups = ftGroups ?? htGroups;
    final market = ftMarket ?? htMarket;
    if (groups == null) return const SizedBox.shrink();

    return _build3ColumnContent(groups, market);
  }

  /// Build 3-column layout
  Widget _build3ColumnContent(
    CorrectScoreGroups groups,
    LeagueMarketData? market,
  ) {
    final maxRows = groups.maxRows;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home column
        Expanded(child: _buildColumn(groups.home, maxRows, market)),
        const SizedBox(width: 8),
        // Draw column
        Expanded(child: _buildColumn(groups.draw, maxRows, market)),
        const SizedBox(width: 8),
        // Away column
        Expanded(child: _buildColumn(groups.away, maxRows, market)),
      ],
    );
  }

  /// Build 6-column layout
  Widget _build6ColumnContent(
    CorrectScoreGroups ftGroups,
    CorrectScoreGroups htGroups,
    LeagueMarketData? ftMarket,
    LeagueMarketData? htMarket,
  ) {
    final maxRows = [
      ftGroups.maxRows,
      htGroups.maxRows,
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FT Home
        Expanded(child: _buildColumn(ftGroups.home, maxRows, ftMarket)),
        const SizedBox(width: 4),
        // FT Draw
        Expanded(child: _buildColumn(ftGroups.draw, maxRows, ftMarket)),
        const SizedBox(width: 4),
        // FT Away
        Expanded(child: _buildColumn(ftGroups.away, maxRows, ftMarket)),
        const SizedBox(width: 8),
        // HT Home
        Expanded(child: _buildColumn(htGroups.home, maxRows, htMarket)),
        const SizedBox(width: 4),
        // HT Draw
        Expanded(child: _buildColumn(htGroups.draw, maxRows, htMarket)),
        const SizedBox(width: 4),
        // HT Away
        Expanded(child: _buildColumn(htGroups.away, maxRows, htMarket)),
      ],
    );
  }

  /// Build a single column of odds
  Widget _buildColumn(
    List<LeagueOddsData> odds,
    int maxRows,
    LeagueMarketData? market,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(maxRows, (index) {
        if (index >= odds.length) {
          return const SizedBox(height: 40);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildScoreCard(odds[index], market),
        );
      }),
    );
  }

  /// Build a single score card
  ///
  /// For Correct Score market:
  /// - API returns points as "X:Y" (colon separator)
  /// - Display shows "X-Y" (dash separator) or "AOS" for "9:9"
  /// - Only oddsHome (oh) field contains the odds value
  /// - Only selectionHomeId (shi) is used for betting
  Widget _buildScoreCard(LeagueOddsData odds, LeagueMarketData? market) {
    // Correct Score only uses oddsHome (oh field)
    // oddsAway and oddsDraw are empty for this market type
    final oddsValue = odds.oddsHome;

    // Only selectionHomeId is used for Correct Score
    final selectionId = odds.selectionHomeId ?? '';

    // Convert points to display text: "1:0" → "1-0", "9:9" → "AOS"
    final displayLabel = CorrectScoreHelper.getDisplayText(odds.points);

    BettingPopupData? bettingData;
    if (eventData != null && market != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: OddsType.home,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCard(
      label: displayLabel,
      value: _getOddsValue(oddsValue),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  String _getOddsValue(OddsValue oddsValue) {
    // Correct Score always uses Decimal odds
    if (oddsValue.decimal > 0 && oddsValue.decimal != -100) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}
