import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Clean Sheet Mobile Layout Widget
///
/// Displays 2 columns with team names:
/// [Home Team Name] | [Away Team Name]
///
/// Each column has 2 rows:
/// - Có (Yes)
/// - Không (No)
///
/// Used for: Home Clean Sheet (83), Away Clean Sheet (84)
/// Note: Clean Sheet markets always use Decimal odds format.
class CleanSheetMobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  /// Home team name
  final String homeTeamName;

  /// Away team name
  final String awayTeamName;

  const CleanSheetMobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    required this.homeTeamName,
    required this.awayTeamName,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    // Find Home and Away clean sheet markets
    final homeMarket = markets.where((m) => m.marketId == 83).firstOrNull;
    final awayMarket = markets.where((m) => m.marketId == 84).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header row with team names
          _buildHeaderRow(),
          const SizedBox(height: 6),
          // Yes row (Có)
          _buildOddsRow('Có', homeMarket, awayMarket, isYes: true),
          const SizedBox(height: 4),
          // No row (Không)
          _buildOddsRow('Không', homeMarket, awayMarket, isYes: false),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            homeTeamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            awayTeamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOddsRow(
    String label,
    LeagueMarketData? homeMarket,
    LeagueMarketData? awayMarket, {
    required bool isYes,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home team column
        Expanded(
          child: _buildCell(label: label, market: homeMarket, isYes: isYes),
        ),
        const SizedBox(width: 6),
        // Away team column
        Expanded(
          child: _buildCell(label: label, market: awayMarket, isYes: isYes),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String label,
    LeagueMarketData? market,
    required bool isYes,
  }) {
    if (market == null || market.odds.isEmpty) {
      return const SizedBox(height: 36);
    }

    final odds = market.odds.first;
    // Yes = oddsHome, No = oddsAway
    final oddsValue = isYes ? odds.oddsHome : odds.oddsAway;
    final selectionId = isYes ? odds.selectionHomeId : odds.selectionAwayId;
    final oddsType = isYes ? OddsType.home : OddsType.away;

    if (!_hasValidOdds(oddsValue)) {
      return const SizedBox(height: 36);
    }

    // Build BettingPopupData if we have all required data
    BettingPopupData? bettingData;
    if (eventData != null) {
      bettingData = BettingPopupData(
        oddsData: odds,
        marketData: market,
        eventData: eventData!,
        oddsType: oddsType,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCardMobile(
      label: label,
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market.marketId,
        oddsStyle,
      ),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
