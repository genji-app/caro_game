import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Only2 Mobile Layout Widget
///
/// Displays 2 columns: [Home, Away] or [Lẻ, Chẵn] etc.
///
/// Used for: To Qualify, Which Team Kick Off, Penalty Winner,
///           Odd/Even, Draw No Bet, Corner Odd/Even, Last Corner, Clean Sheet
class Only2MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const Only2MobileLayout({
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

    final headers = customHeaders ?? _getDefaultHeaders();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(headers),
          const SizedBox(height: 6),
          // Content
          _buildContent(),
        ],
      ),
    );
  }

  List<String> _getDefaultHeaders() {
    final firstMarketId = markets.isNotEmpty ? markets.first.marketId : 0;

    // Odd/Even (including Corner Odd/Even)
    if ([8, 9, 56, 57, 76, 77, 86].contains(firstMarketId)) {
      return ['Lẻ', 'Chẵn'];
    }

    // Clean Sheet
    if ([83, 84].contains(firstMarketId)) {
      return ['Có', 'Không'];
    }

    // Last Corner, To Qualify, Penalty Winner, etc.
    return ['Nhà', 'Khách'];
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

  Widget _buildContent() {
    final market = markets.first;
    if (market.odds.isEmpty) {
      return Row(
        children: const [
          Expanded(child: SizedBox(height: 36)),
          SizedBox(width: 6),
          Expanded(child: SizedBox(height: 36)),
        ],
      );
    }

    final odds = market.odds.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home
        Expanded(
          child: _buildCell(
            odds.oddsHome,
            odds.selectionHomeId,
            market,
            odds,
            OddsType.home,
          ),
        ),
        const SizedBox(width: 6),
        // Away
        Expanded(
          child: _buildCell(
            odds.oddsAway,
            odds.selectionAwayId,
            market,
            odds,
            OddsType.away,
          ),
        ),
      ],
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
      label: '',
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
