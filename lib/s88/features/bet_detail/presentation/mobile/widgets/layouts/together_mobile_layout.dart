import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Together Mobile Layout Widget
///
/// Displays different layouts based on market type:
/// - Corner Range (131, 134, 135, 136): 3-column grid (no FT/HT split)
/// - Total Score (14, 15): 2 columns with FT/HT headers
class TogetherMobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;
  final List<String>? customHeaders;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  const TogetherMobileLayout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.customHeaders,
    this.eventData,
    this.leagueData,
  });

  /// Check if first market is Corner Range
  bool get _isCornerRange {
    if (markets.isEmpty) return false;
    return MarketLayoutHelper.isCornerRange(markets.first.marketId);
  }

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) return const SizedBox.shrink();

    // Corner Range uses 3-column grid without headers
    if (_isCornerRange) {
      return _buildCornerRangeGrid();
    }

    // Total Score uses 2-column FT/HT layout
    return _buildTotalScoreLayout();
  }

  /// Build 3-column grid for Corner Range markets
  /// Points format: "0-8", "9-11", "12+" displayed as-is
  Widget _buildCornerRangeGrid() {
    final market = markets.first;
    final odds = market.odds;

    if (odds.isEmpty) return const SizedBox.shrink();

    // Sort odds by range (e.g., "0-4" < "5-6" < "7+")
    final sortedOdds = List<LeagueOddsData>.from(odds)
      ..sort(
        (a, b) =>
            _parseRangeStart(a.points).compareTo(_parseRangeStart(b.points)),
      );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - 8) / 3; // 3 columns with 4px spacing
          final itemHeight = 32.0;

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sortedOdds.map((odd) {
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _buildOddsCard(odd, market),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// Parse the starting number from range string
  /// "0-8" → 0, "9-11" → 9, "12+" → 12
  int _parseRangeStart(String range) {
    final cleaned = range.replaceAll('+', '').split('-').first;
    return int.tryParse(cleaned) ?? 0;
  }

  /// Build 2-column FT/HT layout for Total Score markets
  Widget _buildTotalScoreLayout() {
    final headers = customHeaders ?? ['FT', 'HT'];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(headers),
          const SizedBox(height: 6),
          // Content
          _build2ColumnContent(),
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

  Widget _build2ColumnContent() {
    // Get FT and HT markets
    final ftMarket =
        markets.where((m) => [14].contains(m.marketId)).firstOrNull ??
        (markets.isNotEmpty ? markets.first : null);
    final htMarket =
        markets.where((m) => [15].contains(m.marketId)).firstOrNull ??
        (markets.length > 1 ? markets[1] : null);

    // Find max rows
    final ftOdds = ftMarket?.odds ?? [];
    final htOdds = htMarket?.odds ?? [];
    final maxRows = [
      ftOdds.length,
      htOdds.length,
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FT column
        Expanded(child: _buildOddsColumn(ftOdds, maxRows, ftMarket)),
        const SizedBox(width: 6),
        // HT column
        Expanded(child: _buildOddsColumn(htOdds, maxRows, htMarket)),
      ],
    );
  }

  Widget _buildOddsColumn(
    List<LeagueOddsData> odds,
    int maxRows,
    LeagueMarketData? market,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(maxRows, (index) {
        if (index >= odds.length) {
          return const SizedBox(height: 36);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildOddsCard(odds[index], market),
        );
      }),
    );
  }

  Widget _buildOddsCard(LeagueOddsData odds, LeagueMarketData? market) {
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

    // Corner Range markets (131, 134, 135, 136) display points as-is from API
    // Points format: "0-8", "9-11", "12+" - should NOT be formatted
    final marketId = market?.marketId ?? 0;
    final formattedPoints = MarketLayoutHelper.isCornerRange(marketId)
        ? odds.points
        : PointsFormatter.format(odds.points);

    // Build BettingPopupData if we have all required data
    BettingPopupData? bettingData;
    if (eventData != null && market != null) {
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
      label: formattedPoints,
      value: MarketLayoutHelper.getOddsValue(
        oddsValue,
        market?.marketId ?? 14,
        oddsStyle,
      ),
      selectionId: selectionId,
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) =>
      oddsValue.decimal > 0 || oddsValue.malay != -100;
}
