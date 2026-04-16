import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/bet_card.dart';

/// Only3x2 Layout Widget
///
/// Displays 6 columns in 3x2 grid pattern:
/// [1X FT, X2 FT, 12 FT, 1X HT, X2 HT, 12 HT]
///
/// Used for: Double Chance (FT + HT)
class Only3x2Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const Only3x2Layout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    final headers = ['1X', 'X2', '12', '1X H1', 'X2 H1', '12 H1'];

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

  Widget _buildHeaderRow(List<String> headers) => Row(
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

  Widget _buildContent() {
    // Get FT and HT markets
    final ftMarket = markets.where((m) => m.marketId == 12).firstOrNull;
    final htMarket = markets.where((m) => m.marketId == 13).firstOrNull;

    // Double Chance: 1X (Home+Draw), X2 (Draw+Away), 12 (Home+Away)
    // In API: home = 1X, draw = X2, away = 12
    final cells = <Widget>[];

    // FT
    if (ftMarket != null && ftMarket.odds.isNotEmpty) {
      final odds = ftMarket.odds.first;
      cells.add(
        _buildCell(
          odds.oddsHome,
          odds.selectionHomeId,
          ftMarket,
          odds,
          OddsType.home,
        ),
      ); // 1X
      cells.add(
        _buildCell(
          odds.oddsDraw,
          odds.selectionDrawId,
          ftMarket,
          odds,
          OddsType.draw,
        ),
      ); // X2
      cells.add(
        _buildCell(
          odds.oddsAway,
          odds.selectionAwayId,
          ftMarket,
          odds,
          OddsType.away,
        ),
      ); // 12
    } else {
      cells.addAll([
        const SizedBox(height: 36),
        const SizedBox(height: 36),
        const SizedBox(height: 36),
      ]);
    }

    // HT
    if (htMarket != null && htMarket.odds.isNotEmpty) {
      final odds = htMarket.odds.first;
      cells.add(
        _buildCell(
          odds.oddsHome,
          odds.selectionHomeId,
          htMarket,
          odds,
          OddsType.home,
        ),
      ); // 1X
      cells.add(
        _buildCell(
          odds.oddsDraw,
          odds.selectionDrawId,
          htMarket,
          odds,
          OddsType.draw,
        ),
      ); // X2
      cells.add(
        _buildCell(
          odds.oddsAway,
          odds.selectionAwayId,
          htMarket,
          odds,
          OddsType.away,
        ),
      ); // 12
    } else {
      cells.addAll([
        const SizedBox(height: 36),
        const SizedBox(height: 36),
        const SizedBox(height: 36),
      ]);
    }

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

  Widget _buildCell(
    OddsValue oddsValue,
    String? selectionId,
    LeagueMarketData market,
    LeagueOddsData odds,
    OddsType oddsType,
  ) {
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
    // Double Chance always uses Decimal
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}
