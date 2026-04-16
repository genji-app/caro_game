import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Only4 Mobile Layout Widget
///
/// Displays 4 columns in 2x2 grid on mobile:
/// Row 1: [Không có, Đội Nhà]
/// Row 2: [Đội Khách, Cả 2 Đội]
///
/// Used for: Which Team To Score (Both Teams To Score)
/// Note: This market always uses Decimal odds.
class Only4MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const Only4MobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Row 1: Không có, Đội Nhà
          _buildRow(['Không có', 'Đội Nhà'], [0, 1]),
          const SizedBox(height: 6),
          // Row 2: Đội Khách, Cả 2 Đội
          _buildRow(['Đội Khách', 'Cả 2 Đội'], [2, 3]),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> headers, List<int> indices) {
    final market = markets.first;

    return Column(
      children: [
        // Header row
        Row(
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
        ),
        const SizedBox(height: 4),
        // Content row
        Row(
          children: indices.map((index) {
            if (market.odds.isEmpty || index >= market.odds.length) {
              return const Expanded(child: SizedBox(height: 36));
            }
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == indices.first ? 3 : 0,
                  left: index == indices.last ? 3 : 0,
                ),
                child: _buildCell(market.odds[index], market),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCell(LeagueOddsData odds, LeagueMarketData market) {
    final oddsValue = _hasValidOdds(odds.oddsHome)
        ? odds.oddsHome
        : odds.oddsAway;
    final selectionId = odds.selectionHomeId ?? odds.selectionAwayId ?? '';
    final oddsType = _hasValidOdds(odds.oddsHome)
        ? OddsType.home
        : OddsType.away;

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
      label: '', // Labels are in headers
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market.marketId,
        oddsStyle,
      ),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
