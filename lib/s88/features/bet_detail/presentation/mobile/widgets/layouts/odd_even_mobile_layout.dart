import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Odd/Even Mobile Layout Widget
///
/// Displays 2 horizontal cells:
/// [Lẻ + odds] | [Chẵn + odds]
///
/// Each cell shows label and odds value together.
///
/// Used for: Odd/Even FT, Odd/Even HT, Corner Odd/Even, Home/Away Odd/Even
/// Note: Odd/Even markets always use Decimal odds format.
class OddEvenMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const OddEvenMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (market.odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: _buildOddsRow(market.odds.first),
    );
  }

  Widget _buildOddsRow(LeagueOddsData odds) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Lẻ (Odd) - Home
      Expanded(
        child: _buildCell(
          label: 'Lẻ',
          oddsValue: odds.oddsHome,
          odds: odds,
          oddsType: OddsType.home,
          selectionId: odds.selectionHomeId,
        ),
      ),
      const SizedBox(width: 6),
      // Chẵn (Even) - Away
      Expanded(
        child: _buildCell(
          label: 'Chẵn',
          oddsValue: odds.oddsAway,
          odds: odds,
          oddsType: OddsType.away,
          selectionId: odds.selectionAwayId,
        ),
      ),
    ],
  );

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
