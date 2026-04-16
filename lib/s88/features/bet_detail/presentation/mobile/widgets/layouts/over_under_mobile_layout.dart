import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Over/Under Mobile Layout Widget
///
/// Displays 2 columns with "Tài" and "Xỉu" headers:
/// [Tài (Over)] | [Xỉu (Under)]
///
/// Each row shows:
/// - Points value (e.g., "O 2.5", "U 2.5")
/// - Odds value
///
/// Used for: O/U FT, O/U HT, O/U SH, Corner O/U, Booking O/U, Team O/U
class OverUnderMobileLayout extends StatelessWidget {
  final LeagueMarketData market;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  /// Custom headers (default: ['Tài', 'Xỉu'])
  final List<String>? customHeaders;

  const OverUnderMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
    this.customHeaders,
  });

  @override
  Widget build(BuildContext context) {
    if (market.odds.isEmpty) return const SizedBox.shrink();

    final headers = customHeaders ?? ['Tài', 'Xỉu'];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(headers),
          const SizedBox(height: 6),
          // Odds rows
          ..._buildOddsRows(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(List<String> headers) {
    return Row(
      children: headers.take(2).map((title) {
        return Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildOddsRows() {
    final rows = <Widget>[];

    for (final odds in market.odds) {
      final formattedPoints = PointsFormatter.format(odds.points);

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Over (Tài)
              Expanded(
                child: _buildCell(
                  label: formattedPoints,
                  oddsValue: odds.oddsHome,
                  selectionId: odds.selectionHomeId,
                  odds: odds,
                  oddsType: OddsType.home,
                ),
              ),
              const SizedBox(width: 6),
              // Under (Xỉu)
              Expanded(
                child: _buildCell(
                  label: formattedPoints,
                  oddsValue: odds.oddsAway,
                  selectionId: odds.selectionAwayId,
                  odds: odds,
                  oddsType: OddsType.away,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildCell({
    required String label,
    required OddsValue oddsValue,
    String? selectionId,
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
