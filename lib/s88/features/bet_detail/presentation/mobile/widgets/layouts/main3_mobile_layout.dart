import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/helpers/market_layout_helper.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/mobile/widgets/bet_card_mobile.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Main3 Mobile Layout Widget
///
/// Displays 3 columns for main markets:
/// [Kèo Chấp, Tài/Xỉu, 1X2]
///
/// For Main6 pool type on mobile, this widget handles both FT and HT markets
/// by displaying them in separate sections (FT first, then HT).
///
/// Cell structure:
/// - Handicap/O/U: Home (top) + Away (bottom)
/// - 1X2: 1, X, 2 stacked vertically
class Main3MobileLayout extends StatelessWidget {
  final List<LeagueMarketData> markets;
  final OddsStyle oddsStyle;

  /// Event data for betting popup
  final LeagueEventData? eventData;

  /// League data for betting popup
  final LeagueData? leagueData;

  /// Match Market ID order for columns
  /// FT: Handicap(5), O/U(3), 1X2(1)
  /// HT: Handicap(6), O/U(4), 1X2(2)
  static const ftMatchIds = [5, 3, 1];
  static const htMatchIds = [6, 4, 2];

  /// Corner market IDs
  /// FT: 19 (Handicap), 21 (O/U), 17 (1X2)
  /// HT: 20 (Handicap), 22 (O/U), 18 (1X2)
  static const ftCornerIds = [19, 21, 17];
  static const htCornerIds = [20, 22, 18];

  /// Booking market IDs
  /// FT: 33 (Handicap), 31 (O/U), 29 (1X2)
  /// HT: 34 (Handicap), 32 (O/U), 30 (1X2)
  static const ftBookingIds = [33, 31, 29];
  static const htBookingIds = [34, 32, 30];

  const Main3MobileLayout({
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

    // Separate FT and HT markets
    final ftMarkets = _findMarketsForIds(ftIds);
    final htMarkets = _findMarketsForIds(htIds);

    final hasFT = ftMarkets.any((m) => m != null);
    final hasHT = htMarkets.any((m) => m != null);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // FT Section
          if (hasFT) ...[_buildSection('Toàn trận', ftMarkets)],
          // HT Section
          if (hasHT) ...[
            if (hasFT) const SizedBox(height: 12),
            _buildSection('Hiệp 1', htMarkets),
          ],
        ],
      ),
    );
  }

  /// Detect market type based on market IDs present
  _MarketType _detectMarketType() {
    for (final m in markets) {
      if (ftMatchIds.contains(m.marketId) || htMatchIds.contains(m.marketId)) {
        return _MarketType.match;
      }
      if (ftCornerIds.contains(m.marketId) ||
          htCornerIds.contains(m.marketId)) {
        return _MarketType.corner;
      }
      if (ftBookingIds.contains(m.marketId) ||
          htBookingIds.contains(m.marketId)) {
        return _MarketType.booking;
      }
    }
    return _MarketType.match;
  }

  /// Get market IDs based on type
  (List<int>, List<int>) _getMarketIds(_MarketType type) {
    switch (type) {
      case _MarketType.match:
        return (ftMatchIds, htMatchIds);
      case _MarketType.corner:
        return (ftCornerIds, htCornerIds);
      case _MarketType.booking:
        return (ftBookingIds, htBookingIds);
    }
  }

  /// Find markets for given IDs, maintaining order
  List<LeagueMarketData?> _findMarketsForIds(List<int> ids) {
    return ids.map((id) {
      return markets.where((m) => m.marketId == id).firstOrNull;
    }).toList();
  }

  /// Build a section (FT or HT)
  Widget _buildSection(String title, List<LeagueMarketData?> sectionMarkets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAAA49B),
            ),
          ),
        ),
        // Header row
        _buildHeaderRow(),
        const SizedBox(height: 6),
        // Columns
        _buildColumnsLayout(sectionMarkets),
      ],
    );
  }

  /// Build header row
  Widget _buildHeaderRow() {
    const headers = ['Kèo', 'Tài/Xỉu', '1X2'];

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

  /// Build 3-column layout
  Widget _buildColumnsLayout(List<LeagueMarketData?> columnMarkets) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (colIndex) {
        final market = colIndex < columnMarkets.length
            ? columnMarkets[colIndex]
            : null;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildSingleColumn(market, colIndex),
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
  /// Labels: "1" (Home), "X" (Draw), "2" (Away)
  /// 1X2 markets always use Decimal odds.
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
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      widgets.add(const SizedBox(height: 2));

      // X (Draw)
      if (_hasValidOdds(odds.oddsDraw)) {
        widgets.add(
          _buildBetCard(
            label: 'X',
            oddsValue: odds.oddsDraw,
            selectionId: odds.selectionDrawId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.draw,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      widgets.add(const SizedBox(height: 2));

      // 2 (Away)
      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: '2',
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      // Add spacing between odds groups
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
  ///
  /// Handicap Points Display Logic (confirmed by JS Team):
  /// - Team ĐƯỢC CHẤP (weaker team): Shows POSITIVE number (e.g., "0.5")
  /// - Team CHẤP (stronger team): Shows EMPTY ""
  ///
  /// Rule:
  /// - When API returns points <= 0: HOME is the team being handicapped → Home shows point, Away empty
  /// - When API returns points > 0: AWAY is the team being handicapped → Away shows point, Home empty
  Widget _buildHandicapOUColumn(LeagueMarketData market, int colType) {
    final widgets = <Widget>[];
    final isOverUnder = colType == 1;
    final isHandicap = colType == 0;

    for (int i = 0; i < market.odds.length; i++) {
      final odds = market.odds[i];
      final isLastOdds = i == market.odds.length - 1;

      final pointsValue = odds.pointsValue;
      // Always show POSITIVE points (absolute value)
      final formattedPoints = PointsFormatter.format(pointsValue.abs());

      String homeLabel;
      String awayLabel;

      if (isHandicap) {
        // Handicap logic from JS Team:
        // - points <= 0: Home is ĐƯỢC CHẤP (weaker) → show positive point
        // - points > 0: Away is ĐƯỢC CHẤP (weaker) → show positive point
        // - The stronger team (CHẤP) shows nothing
        if (pointsValue <= 0) {
          homeLabel = formattedPoints; // Home được chấp, hiện điểm DƯƠNG
          awayLabel = ''; // Away chấp, để trống
        } else {
          homeLabel = ''; // Home chấp, để trống
          awayLabel = formattedPoints; // Away được chấp, hiện điểm DƯƠNG
        }
      } else if (isOverUnder) {
        // Over/Under: Tài (Over) shows point, Xỉu (Under) shows "Xỉu"
        homeLabel = formattedPoints; // Tài + điểm
        awayLabel = 'Xỉu'; // Under label in Vietnamese
      } else {
        homeLabel = formattedPoints;
        awayLabel = formattedPoints;
      }

      // Home on top (Over/Tài for O/U markets)
      if (_hasValidOdds(odds.oddsHome)) {
        widgets.add(
          _buildBetCard(
            label: homeLabel,
            oddsValue: odds.oddsHome,
            selectionId: odds.selectionHomeId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.home,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
      }

      widgets.add(const SizedBox(height: 4));

      // Away on bottom (Under/Xỉu for O/U markets)
      if (_hasValidOdds(odds.oddsAway)) {
        widgets.add(
          _buildBetCard(
            label: awayLabel,
            oddsValue: odds.oddsAway,
            selectionId: odds.selectionAwayId,
            marketId: market.marketId,
            marketData: market,
            oddsData: odds,
            oddsType: OddsType.away,
          ),
        );
      } else {
        widgets.add(const SizedBox(height: 36));
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
    int? marketId,
    LeagueMarketData? marketData,
    LeagueOddsData? oddsData,
    OddsType? oddsType,
  }) {
    // Build BettingPopupData if we have all required data
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

    return BetCardMobile(
      label: label,
      value: _getOddsValue(oddsValue, marketId),
      selectionId: selectionId ?? '',
      bettingPopupData: bettingData,
    );
  }

  bool _hasValidOdds(OddsValue oddsValue) {
    return oddsValue.decimal > 0 || oddsValue.malay != -100;
  }

  /// Get odds value based on effective style for the market.
  /// Uses Decimal for markets that require it (1X2, etc.),
  /// otherwise uses user's selected oddsStyle.
  String _getOddsValue(OddsValue oddsValue, int? marketId) {
    if (marketId != null) {
      return MarketLayoutHelper.getOddsValue(oddsValue, marketId, oddsStyle);
    }
    // Fallback to decimal if no marketId
    if (oddsValue.decimal > 0) {
      return oddsValue.decimal.toStringAsFixed(2);
    }
    return '-';
  }
}

enum _MarketType { match, corner, booking }
