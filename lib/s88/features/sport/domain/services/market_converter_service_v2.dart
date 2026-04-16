import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/market_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart'
    show PointsFormatter, MarketHelper;
import 'package:co_caro_flame/s88/shared/widgets/sport/models/bet_column_v2.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Market Converter Service for V2 Models
///
/// Domain service for converting V2 market data to UI-compatible formats.
class MarketConverterServiceV2 {
  /// Convert markets from event to BetColumnsV2 for UI
  ///
  /// Maps market types to BetColumnType:
  /// - Handicap markets → handicap / handicapH1
  /// - Over/Under markets → overUnder / overUnderH1
  /// - 1X2/MoneyLine markets → matchResult / matchResultH1
  ///
  /// [oddsFormat] - The odds format to use (default: Decimal for best compatibility)
  static List<BetColumnV2> marketsToBetColumns(
    List<MarketModelV2> markets, {
    OddsFormatV2 oddsFormat = OddsFormatV2.decimal,
  }) {
    final columns = <BetColumnV2>[];

    for (final market in markets) {
      final columnType = _getColumnType(market);

      if (columnType == null) continue;

      // For markets with odds, create items
      if (market.oddsList.isNotEmpty) {
        final firstOdds = market.mainLineOdds ?? market.oddsList.first;

        // Format points using PointsFormatter for Quarter Ball display
        final formattedPoints = PointsFormatter.format(firstOdds.points);

        // Determine effective odds format
        // 1X2 and Money Line markets should always use Decimal
        final effectiveFormat = MarketHelper.isAlwaysDecimal(market.marketId)
            ? OddsFormatV2.decimal
            : oddsFormat;

        if (columnType == BetColumnType.matchResult ||
            columnType == BetColumnType.matchResultH1) {
          // 1X2 market: Home, Draw, Away (always use Decimal)
          // Standard order: 1 (Home), X (Draw), 2 (Away)
          columns.add(
            BetColumnV2(
              type: columnType,
              items: [
                BetItemV2(
                  label: '1',
                  value: firstOdds.formatHomeOdds(effectiveFormat),
                  selectionId: firstOdds.selectionHomeId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                if (firstOdds.isThreeWay)
                  BetItemV2(
                    label: 'X',
                    value: firstOdds.formatDrawOdds(effectiveFormat),
                    selectionId: firstOdds.selectionDrawId,
                    oddsData: firstOdds,
                    marketData: market,
                    oddsType: OddsType.draw,
                  ),
                BetItemV2(
                  label: '2',
                  value: firstOdds.formatAwayOdds(effectiveFormat),
                  selectionId: firstOdds.selectionAwayId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away,
                ),
              ],
            ),
          );
        } else if (columnType == BetColumnType.overUnder ||
            columnType == BetColumnType.overUnderH1) {
          // Over/Under: Over, Under with formatted points
          // API sends: home = Over odds, away = Under odds
          columns.add(
            BetColumnV2(
              type: columnType,
              items: [
                BetItemV2(
                  label: formattedPoints,
                  value: firstOdds.formatHomeOdds(effectiveFormat),
                  selectionId: firstOdds.selectionHomeId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home, // Over uses home odds
                ),
                BetItemV2(
                  label: 'U',
                  value: firstOdds.formatAwayOdds(effectiveFormat),
                  selectionId: firstOdds.selectionAwayId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away, // Under uses away odds
                ),
              ],
            ),
          );
        } else {
          // Handicap: Show points on the team receiving handicap
          final pointsValue = firstOdds.pointsValue;
          final homeLabel = pointsValue <= 0 ? formattedPoints : '';
          final awayLabel = pointsValue > 0 ? formattedPoints : '';

          columns.add(
            BetColumnV2(
              type: columnType,
              items: [
                BetItemV2(
                  label: homeLabel,
                  value: firstOdds.formatHomeOdds(effectiveFormat),
                  selectionId: firstOdds.selectionHomeId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                BetItemV2(
                  label: awayLabel,
                  value: firstOdds.formatAwayOdds(effectiveFormat),
                  selectionId: firstOdds.selectionAwayId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away,
                ),
              ],
            ),
          );
        }
      }
    }

    // Sort and ensure we have the right order
    return _sortColumns(columns);
  }

  /// Get BetColumnType from V2 market data
  static BetColumnType? _getColumnType(MarketModelV2 market) {
    final id = market.marketId;
    final type = market.marketType;

    // Check by market type enum first
    switch (type) {
      case MarketTypeV2.handicap:
        return BetColumnType.handicap;
      case MarketTypeV2.handicapFirstHalf:
        return BetColumnType.handicapH1;
      case MarketTypeV2.overUnder:
        return BetColumnType.overUnder;
      case MarketTypeV2.overUnderFirstHalf:
        return BetColumnType.overUnderH1;
      case MarketTypeV2.fullTime1X2:
        return BetColumnType.matchResult;
      case MarketTypeV2.firstHalf1X2:
        return BetColumnType.matchResultH1;
      case MarketTypeV2.unknown:
        // Fall through to ID-based detection
        break;
    }

    // Check by marketId based on Flutter_Event_Market_Odds_Guide.md
    // Football markets
    if (id == 5) return BetColumnType.handicap;
    if (id == 6) return BetColumnType.handicapH1;
    if (id == 3) return BetColumnType.overUnder;
    if (id == 4) return BetColumnType.overUnderH1;
    if (id == 1) return BetColumnType.matchResult;
    if (id == 2) return BetColumnType.matchResultH1;

    // Basketball markets
    if (id == 201) return BetColumnType.handicap;
    if (id == 203) return BetColumnType.handicapH1;
    if (id == 202) return BetColumnType.overUnder;
    if (id == 204) return BetColumnType.overUnderH1;
    if (id == 200) return BetColumnType.matchResult;
    if (id == 205) return BetColumnType.matchResultH1;

    // Tennis markets
    if (id == 402) return BetColumnType.handicap;
    if (id == 401) return BetColumnType.overUnder;
    if (id == 400) return BetColumnType.matchResult;

    // Volleyball markets
    if (id == 509) return BetColumnType.handicap;
    if (id == 510) return BetColumnType.overUnder;
    if (id == 500) return BetColumnType.matchResult;

    // Badminton markets
    if (id == 709) return BetColumnType.handicap;
    if (id == 710) return BetColumnType.overUnder;
    if (id == 700) return BetColumnType.matchResult;

    // Table Tennis markets
    if (id == 609) return BetColumnType.handicap;
    if (id == 610) return BetColumnType.overUnder;
    if (id == 600) return BetColumnType.matchResult;

    return null;
  }

  /// Sort columns in display order
  static List<BetColumnV2> _sortColumns(List<BetColumnV2> columns) {
    final order = [
      BetColumnType.handicap,
      BetColumnType.overUnder,
      BetColumnType.matchResult,
      BetColumnType.handicapH1,
      BetColumnType.overUnderH1,
      BetColumnType.matchResultH1,
    ];

    columns.sort((a, b) {
      final indexA = order.indexOf(a.type);
      final indexB = order.indexOf(b.type);
      return indexA.compareTo(indexB);
    });

    return columns;
  }

  /// Create default empty columns (for loading state)
  static List<BetColumnV2> emptyColumns({bool includeH1 = true}) {
    final columns = [
      const BetColumnV2(type: BetColumnType.handicap),
      const BetColumnV2(type: BetColumnType.overUnder),
      const BetColumnV2(type: BetColumnType.matchResult),
    ];

    if (includeH1) {
      columns.addAll([
        const BetColumnV2(type: BetColumnType.handicapH1),
        const BetColumnV2(type: BetColumnType.overUnderH1),
        const BetColumnV2(type: BetColumnType.matchResultH1),
      ]);
    }

    return columns;
  }
}

/// Extension on EventModelV2 for easy conversion
extension EventModelV2UIConverter on EventModelV2 {
  /// Convert event markets to BetColumnsV2
  List<BetColumnV2> toBetColumnsV2({
    OddsFormatV2 oddsFormat = OddsFormatV2.decimal,
  }) => MarketConverterServiceV2.marketsToBetColumns(
    markets,
    oddsFormat: oddsFormat,
  );
}
