import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Handicap Mobile Layout Widget
///
/// Displays 2 columns with team names as headers:
/// [Home Team Name] | [Away Team Name]
///
/// Each row shows:
/// - Points value (positive for weaker team, empty for stronger team)
/// - Odds value
///
/// Used for: Handicap FT, Handicap HT, Handicap SH, Corner Handicap, Booking Handicap
class HandicapMobileLayout extends StatelessWidget {
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

  const HandicapMobileLayout({
    super.key,
    required this.market,
    required this.oddsStyle,
    required this.homeTeamName,
    required this.awayTeamName,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    if (market.odds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Header row with team names
          _buildHeaderRow(),
          const SizedBox(height: 6),
          // Odds rows
          ..._buildOddsRows(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            homeTeamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            awayTeamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _buildOddsRows() {
    final rows = <Widget>[];

    for (final odds in market.odds) {
      final pointsValue = odds.pointsValue;
      // Always show POSITIVE points (absolute value)
      final formattedPoints = PointsFormatter.format(pointsValue.abs());

      // Handicap logic from JS Team:
      // - points <= 0: Home is ĐƯỢC CHẤP (weaker) → show positive point
      // - points > 0: Away is ĐƯỢC CHẤP (weaker) → show positive point
      // - The stronger team (CHẤP) shows nothing
      String homeLabel;
      String awayLabel;

      if (pointsValue <= 0) {
        homeLabel = formattedPoints; // Home được chấp, hiện điểm DƯƠNG
        awayLabel = ''; // Away chấp, để trống
      } else {
        homeLabel = ''; // Home chấp, để trống
        awayLabel = formattedPoints; // Away được chấp, hiện điểm DƯƠNG
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Home
              Expanded(
                child: _buildCell(
                  label: homeLabel,
                  oddsValue: odds.oddsHome,
                  selectionId: odds.selectionHomeId,
                  odds: odds,
                  oddsType: OddsType.home,
                ),
              ),
              const SizedBox(width: 6),
              // Away
              Expanded(
                child: _buildCell(
                  label: awayLabel,
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
