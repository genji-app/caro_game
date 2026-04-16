import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Market2 Mobile Layout Widget
///
/// Displays 2 columns with vertical Over/Under lists:
/// [Over, Under]
///
/// Used for: Home O/U, Away O/U, Corner O/U by time period, Penalty O/U
class Market2MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const Market2MobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.customHeaders,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final headers = customHeaders ?? ['Over', 'Under'];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(headers),
          const SizedBox(height: 6),
          // Content - each market gets a row
          ..._buildMarketRows(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(List<String> headers) => Row(
    children: headers.take(2).map((title) {
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

  List<Widget> _buildMarketRows() {
    final rows = <Widget>[];

    for (final market in markets) {
      // Add market name if multiple markets
      if (markets.length > 1 && market.marketName.isNotEmpty) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              market.marketName,
              style: AppTextStyles.textStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xB3FFFCDB),
              ),
            ),
          ),
        );
      }

      // Build O/U pairs for each odds line
      for (final odds in market.odds) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildOddsRow(odds, market),
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildOddsRow(LeagueOddsData odds, LeagueMarketData market) {
    final formattedPoints = PointsFormatter.format(odds.points);

    // API sends: home = Over odds, away = Under odds
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Over (uses home odds from API)
        Expanded(
          child: _buildCell(
            label: 'O $formattedPoints',
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            market: market,
            odds: odds,
            oddsType: OddsType.home,
          ),
        ),
        const SizedBox(width: 6),
        // Under (uses away odds from API)
        Expanded(
          child: _buildCell(
            label: 'U $formattedPoints',
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            market: market,
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
    String? selectionId,
    required LeagueMarketData market,
    required LeagueOddsData odds,
    required OddsType oddsType,
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
