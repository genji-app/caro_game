import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Only3 Mobile Layout Widget
///
/// Displays 3 columns: [Home, Draw/X, Away] or [1X, X2, 12]
///
/// Used for: Double Chance, Next Goal, Last Goal
/// Note: Double Chance always uses Decimal odds.
class Only3MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const Only3MobileLayout({
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

    // Double Chance: 1X (Nhà hoặc Hòa), X2 (Khách hoặc Hòa), 12 (Nhà hoặc Khách)
    if ([12, 13].contains(firstMarketId)) {
      return ['1X', 'X2', '12'];
    }

    // Next Goal / Last Goal
    if ([7, 97].contains(firstMarketId)) {
      return ['Nhà', 'Không có', 'Khách'];
    }

    return ['Nhà', 'Hoà', 'Khách'];
  }

  Widget _buildHeaderRow(List<String> headers) => Row(
    children: headers.take(3).map((title) {
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
          SizedBox(width: 6),
          Expanded(child: SizedBox(height: 36)),
        ],
      );
    }

    final odds = market.odds.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home / 1X
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
        // Draw / X2
        Expanded(
          child: _buildCell(
            odds.oddsDraw,
            odds.selectionDrawId,
            market,
            odds,
            OddsType.draw,
          ),
        ),
        const SizedBox(width: 6),
        // Away / 12
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
