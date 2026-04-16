import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// 1X2 Mobile Layout Widget
///
/// Displays 3 horizontal cells:
/// [HomeTeam + odds] | [Hòa + odds] | [AwayTeam + odds]
///
/// Each cell shows label and odds value together.
///
/// Used for: 1X2 FT, 1X2 HT, 1X2 SH, Corner 1X2, Booking 1X2
/// Note: 1X2 markets always use Decimal odds format.
class OneXTwoMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  /// Home team name
  final String homeTeamName;

  /// Away team name
  final String awayTeamName;

  const OneXTwoMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
    this.homeTeamName = 'Nhà',
    this.awayTeamName = 'Khách',
  });

  @override
  Widget build(BuildContext context) {
    if (market.odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: _buildOddsRow(market.odds.first),
    );
  }

  Widget _buildOddsRow(LeagueOddsData odds) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1 (Home)
        Expanded(
          child: _buildCell(
            label: homeTeamName,
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            odds: odds,
            oddsType: OddsType.home,
          ),
        ),
        const SizedBox(width: 6),
        // X (Draw)
        Expanded(
          child: _buildCell(
            label: 'Hòa',
            oddsValue: odds.oddsDraw,
            selectionId: odds.selectionDrawId,
            odds: odds,
            oddsType: OddsType.draw,
          ),
        ),
        const SizedBox(width: 6),
        // 2 (Away)
        Expanded(
          child: _buildCell(
            label: awayTeamName,
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            odds: odds,
            oddsType: OddsType.away,
          ),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String label,
    required OddsValue oddsValue,
    required LeagueOddsData odds,
    required OddsType oddsType,
    String? selectionId,
  }) {
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
