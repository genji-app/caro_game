import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/bet_card.dart';

/// Only2x2 Layout Widget
///
/// Displays 4 columns in 2x2 grid pattern:
/// [FT Home, FT Away, HT Home, HT Away]
///
/// Used for: Odd/Even, Draw No Bet, Last Corner, Clean Sheet
class Only2x2Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const Only2x2Layout({
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

    // Determine headers based on market type
    final headers = customHeaders ?? _getDefaultHeaders();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(headers),
          const SizedBox(height: 8),
          // Content
          _buildContent(),
        ],
      ),
    );
  }

  List<String> _getDefaultHeaders() {
    // Check market type
    final firstMarketId = markets.isNotEmpty ? markets.first.marketId : 0;

    // Odd/Even
    if ([8, 9].contains(firstMarketId)) {
      return ['Lẻ', 'Chẵn', 'Lẻ H1', 'Chẵn H1'];
    }

    // Draw No Bet
    if ([16, 17, 35].contains(firstMarketId)) {
      return ['Nhà', 'Khách', 'Nhà H1', 'Khách H1'];
    }

    // Last Corner
    if ([54, 55].contains(firstMarketId)) {
      return ['Nhà', 'Khách', 'Nhà H1', 'Khách H1'];
    }

    // Clean Sheet
    if ([56, 57].contains(firstMarketId)) {
      return ['Có', 'Không', 'Có H1', 'Không H1'];
    }

    // Default
    return ['Nhà', 'Khách', 'Nhà H1', 'Khách H1'];
  }

  Widget _buildHeaderRow(List<String> headers) => Row(
    children: headers.take(4).map((title) {
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

  Widget _buildContent() {
    // Get FT and HT markets
    final ftMarket = _getFTMarket();
    final htMarket = _getHTMarket();

    // Build 4 cells
    final cells = <Widget>[];

    // FT Home
    cells.add(_buildCell(ftMarket, true));
    // FT Away
    cells.add(_buildCell(ftMarket, false));
    // HT Home
    cells.add(_buildCell(htMarket, true));
    // HT Away
    cells.add(_buildCell(htMarket, false));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cells.map((cell) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: cell,
          ),
        );
      }).toList(),
    );
  }

  LeagueMarketData? _getFTMarket() {
    // Odd/Even FT
    final oddEvenFT = markets.where((m) => m.marketId == 8).firstOrNull;
    if (oddEvenFT != null) return oddEvenFT;

    // Draw No Bet FT
    final dnbFT = markets.where((m) => m.marketId == 16).firstOrNull;
    if (dnbFT != null) return dnbFT;

    // Return first market as fallback
    return markets.isNotEmpty ? markets.first : null;
  }

  LeagueMarketData? _getHTMarket() {
    // Odd/Even HT
    final oddEvenHT = markets.where((m) => m.marketId == 9).firstOrNull;
    if (oddEvenHT != null) return oddEvenHT;

    // Draw No Bet HT
    final dnbHT = markets
        .where((m) => [17, 35].contains(m.marketId))
        .firstOrNull;
    if (dnbHT != null) return dnbHT;

    // Return second market as fallback
    return markets.length > 1 ? markets[1] : null;
  }

  Widget _buildCell(LeagueMarketData? market, bool isHome) {
    if (market == null || market.odds.isEmpty) {
      return const SizedBox(height: 36);
    }

    final odds = market.odds.first;
    final oddsValue = isHome ? odds.oddsHome : odds.oddsAway;
    final selectionId = isHome ? odds.selectionHomeId : odds.selectionAwayId;
    final oddsType = isHome ? OddsType.home : OddsType.away;

    if (!_hasValidOdds(oddsValue)) {
      return const SizedBox(height: 36);
    }

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

    return BetCard(
      label: '',
      value: _getOddsValue(oddsValue),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;

  String _getOddsValue(OddsValue oddsValue) {
    switch (oddsStyle) {
      case OddsStyle.malay:
        return oddsValue.malay.toStringAsFixed(2);
      case OddsStyle.indo:
        return oddsValue.indo.toStringAsFixed(2);
      case OddsStyle.decimal:
        return oddsValue.decimal.toStringAsFixed(2);
      case OddsStyle.hongKong:
        return oddsValue.hongKong.toStringAsFixed(2);
    }
  }
}
