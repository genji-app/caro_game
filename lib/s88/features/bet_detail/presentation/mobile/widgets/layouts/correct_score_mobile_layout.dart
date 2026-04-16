import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Correct Score Mobile Layout Widget
///
/// Displays correct score markets in 3 columns:
/// [Đội Nhà, Hoà, Đội Khách]
///
/// Logic based on SbEventDrawer.ts:200-224:
/// - Home wins: scores like 1-0, 2-0, 2-1 (home > away)
/// - Draw: scores like 0-0, 1-1, 2-2 (home == away)
/// - Away wins: scores like 0-1, 0-2, 1-2 (home < away)
///
/// On mobile, shows BOTH FT and HT sections (confirmed by JS team).
class CorrectScoreMobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const CorrectScoreMobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    // Get both FT and HT markets
    final ftMarket = markets.where((m) => m.marketId == 10).firstOrNull;
    final htMarket = markets.where((m) => m.marketId == 11).firstOrNull;

    final ftHasOdds = ftMarket != null && ftMarket.odds.isNotEmpty;
    final htHasOdds = htMarket != null && htMarket.odds.isNotEmpty;

    if (!ftHasOdds && !htHasOdds) return const SizedBox.shrink();

    final sections = <Widget>[];

    // FT Section
    if (ftMarket != null && ftMarket.odds.isNotEmpty) {
      sections.add(_buildSection('Toàn trận', ftMarket));
    }

    // HT Section
    if (htMarket != null && htMarket.odds.isNotEmpty) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 16));
      }
      sections.add(_buildSection('Hiệp 1', htMarket));
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  Widget _buildSection(String title, LeagueMarketData market) {
    final groups = CorrectScoreHelper.groupOdds(market.odds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
        // Header row
        _buildHeaderRow(),
        const SizedBox(height: 6),
        // Content
        _build3ColumnContent(groups, market),
      ],
    );
  }

  Widget _buildHeaderRow() {
    const headers = ['Đội Nhà', 'Hoà', 'Đội Khách'];

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

  Widget _build3ColumnContent(
    CorrectScoreGroups groups,
    LeagueMarketData market,
  ) {
    final maxRows = groups.maxRows;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home column
        Expanded(child: _buildColumn(groups.home, maxRows, market)),
        const SizedBox(width: 6),
        // Draw column
        Expanded(child: _buildColumn(groups.draw, maxRows, market)),
        const SizedBox(width: 6),
        // Away column
        Expanded(child: _buildColumn(groups.away, maxRows, market)),
      ],
    );
  }

  Widget _buildColumn(
    List<LeagueOddsData> odds,
    int maxRows,
    LeagueMarketData market,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(maxRows, (index) {
        if (index >= odds.length) {
          return const SizedBox(height: 36);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildScoreCard(odds[index], market),
        );
      }),
    );
  }

  Widget _buildScoreCard(LeagueOddsData odds, LeagueMarketData market) {
    final oddsValue = odds.oddsHome;
    final selectionId = odds.selectionHomeId ?? '';
    final displayLabel = CorrectScoreHelper.getDisplayText(odds.points);

    // Build BettingPopupData if we have all required data
    BettingPopupData? bettingData;
    if (eventData != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: OddsType.home,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCardMobile(
      label: displayLabel,
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market.marketId,
        oddsStyle,
      ),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }
}
