import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/bet_card.dart';

/// Main6 Layout Widget
///
/// Displays 6 columns for main markets:
/// [Kèo Chấp FT, Tài Xỉu FT, 1X2 FT, Kèo Chấp HT, Tài Xỉu HT, 1X2 HT]
///
/// Row grouping logic (from JS team Q&A):
/// - All odds with same `points` value are in the same row
/// - For Handicap/O/U: keep API order (don't sort)
/// - Separator line: only for Handicap/O/U, only after Away, not on last row
///
/// Cell structure:
/// - Handicap/O/U: Home (top) + Away (bottom)
/// - 1X2: 1, X, 2 stacked vertically
class Main6Layout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  /// Market ID order for columns
  /// FT: Handicap(5), O/U(3), 1X2(1)
  /// HT: Handicap(6), O/U(4), 1X2(2)
  static const ftMarketIds = [5, 3, 1];
  static const htMarketIds = [6, 4, 2];

  /// Corner market IDs
  /// FT: 19 (Handicap), 21 (O/U), 17 (1X2)
  /// HT: 20 (Handicap), 22 (O/U), 18 (1X2)
  static const cornerFtIds = [19, 21, 17];
  static const cornerHtIds = [20, 22, 18];

  /// Booking market IDs
  /// Based on SbMarketItem.ts:1327-1332 and SbEventDetail.ts:450
  /// Order: [Handicap, O/U, 1X2]
  /// FT: 33 (Handicap), 31 (O/U), 29 (1X2)
  /// HT: 34 (Handicap), 32 (O/U), 30 (1X2)
  static const bookingFtIds = [33, 31, 29];
  static const bookingHtIds = [34, 32, 30];

  const Main6Layout({
    super.key,
    required this.markets,
    required this.oddsStyle,
    this.eventData,
    this.leagueData,
  });

  @override
  Widget build(BuildContext context) {
    final marketType = _detectMarketType();
    final (ftIds, htIds) = _getMarketIds(marketType);

    // Get market for each column position
    final columnMarkets = <LeagueMarketData?>[];
    for (final id in [...ftIds, ...htIds]) {
      final market = markets.where((m) => m.marketId == id).firstOrNull;
      columnMarkets.add(market);
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          // Build by columns, not rows
          _buildColumnsLayout(columnMarkets),
        ],
      ),
    );
  }

  /// Detect market type (match, corner, booking)
  _MarketType _detectMarketType() {
    for (final m in markets) {
      if (ftMarketIds.contains(m.marketId) ||
          htMarketIds.contains(m.marketId)) {
        return _MarketType.match;
      }
      if (cornerFtIds.contains(m.marketId) ||
          cornerHtIds.contains(m.marketId)) {
        return _MarketType.corner;
      }
      if (bookingFtIds.contains(m.marketId) ||
          bookingHtIds.contains(m.marketId)) {
        return _MarketType.booking;
      }
    }
    return _MarketType.match;
  }

  /// Get market IDs based on type
  (List<int>, List<int>) _getMarketIds(_MarketType type) {
    switch (type) {
      case _MarketType.match:
        return (ftMarketIds, htMarketIds);
      case _MarketType.corner:
        return (cornerFtIds, cornerHtIds);
      case _MarketType.booking:
        return (bookingFtIds, bookingHtIds);
    }
  }

  /// Build header row
  Widget _buildHeaderRow() {
    final headers = ['Kèo', 'Tài/Xỉu', '1X2', 'Kèo H1', 'T/X H1', '1X2 H1'];

    return Row(
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
  }

  /// Build layout by columns
  ///
  /// Each column is a separate market, displaying its odds vertically
  /// This prevents gaps when markets have different number of odds
  Widget _buildColumnsLayout(List<LeagueMarketData?> columnMarkets) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(6, (colIndex) {
        // Column type: 0,3 = Handicap, 1,4 = O/U, 2,5 = 1X2
        final colType = colIndex % 3;
        final market = columnMarkets[colIndex];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildSingleColumn(market, colType),
          ),
        );
      }),
    );
  }

  /// Build a single column (one market)
  Widget _buildSingleColumn(LeagueMarketData? market, int colType) {
    if (market == null || market.odds.isEmpty) {
      return const SizedBox.shrink();
    }

    // For 1X2 markets (colType 2), build vertically stacked 1/X/2
    if (colType == 2) {
      return _build1X2Column(market);
    }

    // For Handicap/O/U markets (colType 0, 1), build pairs with separators
    return _buildHandicapOUColumn(market, colType);
  }

  /// Build column for 1X2 market
  /// Structure: 1, X, 2 stacked vertically for each odds row
  Widget _build1X2Column(LeagueMarketData market) {
    final widgets = <Widget>[];

    for (final odds in market.odds) {
      // 1 (Home)
      if (_hasValidOdds(odds.oddsHome)) {
        widgets.add(
          _buildBetCard(
            label: '1',
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      widgets.add(const SizedBox(height: 2));

      // X (Draw)
      if (_hasValidOdds(odds.oddsDraw)) {
        widgets.add(
          _buildBetCard(
            label: 'X',
            oddsValue: odds.oddsDraw,
            selectionId: odds.selectionDrawId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.draw,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      widgets.add(const SizedBox(height: 2));

      // 2 (Away)
      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: '2',
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      // Add spacing between odds groups (if more than one)
      if (market.odds.length > 1 && odds != market.odds.last) {
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  /// Build column for Handicap/O/U market
  /// Structure: Home (top) + Away (bottom) + separator line
  ///
  /// Label display logic (from JS team Q&A section 0.17 & 0.18):
  /// - Handicap (colType 0): Depends on points sign
  ///   - points <= 0: Home shows points, Away blank (Home team cho kèo)
  ///   - points > 0: Home blank, Away shows points (Away team cho kèo)
  /// - O/U (colType 1): Home (Over) shows formattedPoints, Away (Under) shows "U"
  Widget _buildHandicapOUColumn(LeagueMarketData market, int colType) {
    final widgets = <Widget>[];
    final isOverUnder = colType == 1;
    final isHandicap = colType == 0;

    for (int i = 0; i < market.odds.length; i++) {
      final odds = market.odds[i];
      final isLastOdds = i == market.odds.length - 1;

      // Format points using PointsFormatter for Quarter Ball display (0.25 → "0-0.5")
      // For Handicap, always use absolute value for display
      final pointsValue = odds.pointsValue; // Convert String to double
      final formattedPoints = PointsFormatter.format(pointsValue.abs());

      // Calculate labels based on market type and points sign
      String homeLabel;
      String awayLabel;

      if (isHandicap) {
        // Handicap: label depends on points sign
        if (pointsValue <= 0) {
          // Home team is giving handicap
          homeLabel = formattedPoints;
          awayLabel = '';
        } else {
          // Away team is giving handicap
          homeLabel = '';
          awayLabel = formattedPoints;
        }
      } else if (isOverUnder) {
        // O/U: Over shows points, Under shows "U"
        homeLabel = formattedPoints;
        awayLabel = 'U';
      } else {
        // Fallback (shouldn't reach here for Main6)
        homeLabel = formattedPoints;
        awayLabel = formattedPoints;
      }

      // Home on top (Over for O/U markets)
      if (_hasValidOdds(odds.oddsHome)) {
        widgets.add(
          _buildBetCard(
            label: homeLabel,
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      widgets.add(const SizedBox(height: 4));

      // Away on bottom (Under for O/U markets)
      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: awayLabel,
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 32));
      }

      // Separator line after Away (not on last odds)
      if (!isLastOdds) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Divider(height: 1, thickness: 1, color: AppColors.yellow300),
          ),
        );
      } else {
        // Last item spacing
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildBetCard({
    required String label,
    required OddsValue oddsValue,
    String? selectionId,
    LeagueMarketData? marketData,
    LeagueOddsData? oddsData,
    OddsType? oddsType,
  }) {
    BettingPopupData? bettingData;
    if (oddsData != null &&
        marketData != null &&
        oddsType != null &&
        eventData != null) {
      bettingData = BettingPopupData(
        oddsData: oddsData,
        marketData: marketData,
        eventData: eventData!,
        oddsType: oddsType,
        leagueData: leagueData,
        oddsStyle: oddsStyle,
      );
    }

    return BetCard(
      label: label,
      value: _getOddsValue(oddsValue),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) {
    return oddsValue.decimal > 0 || oddsValue.malay != -100;
  }

  String _getOddsValue(OddsValue oddsValue) {
    // Always use decimal for main markets (fallback when other styles are -100)
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}

enum _MarketType { match, corner, booking }
