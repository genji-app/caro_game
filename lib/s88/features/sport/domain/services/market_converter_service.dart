import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/models/bet_column.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Market Converter Service
///
/// Domain service for converting league market data to UI-compatible formats.
/// This separates business logic from presentation layer.
///
/// Maps API response data (LeagueMarketData, LeagueOddsData) to
/// BetColumn/BetItem for display in MatchCard widgets.
class MarketConverterService {
  /// Convert markets from event to BetColumns for UI
  ///
  /// Maps market types to BetColumnType:
  /// - marketId 1 or name contains 'Handicap' → handicap
  /// - marketId 2 or name contains 'Over/Under' → overUnder
  /// - marketId 3 or name contains '1x2' → matchResult
  ///
  /// [oddsStyle] - The odds format to use (default: Decimal for best compatibility)
  static List<BetColumn> marketsToBetColumns(
    List<LeagueMarketData> markets, {
    OddsStyle oddsStyle = OddsStyle.decimal,
  }) {
    final columns = <BetColumn>[];

    // Debug: Log all markets received
    // if (kDebugMode) {
    //   debugPrint('[MarketConverter] ==============================');
    //   debugPrint('[MarketConverter] Received ${markets.length} markets:');
    //   for (final m in markets) {
    //     debugPrint('  - marketId=${m.marketId}, name=${m.marketName}, type=${m.marketType}, oddsCount=${m.odds.length}');
    //   }
    //   // Check specifically for 1X2 markets
    //   final has1X2 = markets.any((m) => m.marketId == 1 || m.marketId == 2);
    //   debugPrint('[MarketConverter] Has 1X2 (marketId 1 or 2): $has1X2');
    //   debugPrint('[MarketConverter] ==============================');
    // }

    for (final market in markets) {
      final columnType = _getColumnType(market);

      // Debug: Log column type detection
      // if (kDebugMode) {
      //   debugPrint('[MarketConverter] marketId=${market.marketId} -> columnType=$columnType');
      // }

      if (columnType == null) continue;

      // For markets with home/away odds, create separate items
      if (market.odds.isNotEmpty) {
        final firstOdds = market.odds.first;

        // Format points using PointsFormatter for Quarter Ball display
        final formattedPoints = PointsFormatter.format(firstOdds.points);

        // Determine effective odds style
        // 1X2 and Money Line markets should always use Decimal
        final effectiveOddsStyle = MarketHelper.isAlwaysDecimal(market.marketId)
            ? OddsStyle.decimal
            : oddsStyle;

        if (columnType == BetColumnType.matchResult ||
            columnType == BetColumnType.matchResultH1) {
          // Debug 1X2 market data
          // if (kDebugMode) {
          //   debugPrint('[MarketConverter] 1X2 Market Debug:');
          //   debugPrint('  - marketId=${market.marketId}');
          //   debugPrint('  - oddsHome.isValid=${firstOdds.oddsHome.isValid}');
          //   debugPrint('  - oddsHome.decimal=${firstOdds.oddsHome.decimal}');
          //   debugPrint('  - oddsAway.decimal=${firstOdds.oddsAway.decimal}');
          //   debugPrint('  - oddsDraw.decimal=${firstOdds.oddsDraw.decimal}');
          //   debugPrint('  - homeOddsLegacy=${firstOdds.homeOddsLegacy}');
          //   debugPrint('  - awayOddsLegacy=${firstOdds.awayOddsLegacy}');
          //   debugPrint('  - drawOddsLegacy=${firstOdds.drawOddsLegacy}');
          //   debugPrint('  - formattedHome=${firstOdds.formattedHomeOdds(effectiveOddsStyle)}');
          //   debugPrint('  - formattedAway=${firstOdds.formattedAwayOdds(effectiveOddsStyle)}');
          //   debugPrint('  - formattedDraw=${firstOdds.formattedDrawOdds(effectiveOddsStyle)}');
          //   debugPrint('  - selectionHomeId=${firstOdds.effectiveHomeSelectionId}');
          //   debugPrint('  - selectionAwayId=${firstOdds.effectiveAwaySelectionId}');
          //   debugPrint('  - selectionDrawId=${firstOdds.effectiveDrawSelectionId}');
          // }

          // 1X2 market: Home, Draw, Away (always use Decimal)
          // Standard order: 1 (Home), X (Draw), 2 (Away)
          columns.add(
            BetColumn(
              type: columnType,
              items: [
                BetItem(
                  label: '1',
                  value: firstOdds.formattedHomeOdds(effectiveOddsStyle),
                  selectionId: firstOdds.effectiveHomeSelectionId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                if (firstOdds.hasDrawOdds)
                  BetItem(
                    label: 'X',
                    value: firstOdds.formattedDrawOdds(effectiveOddsStyle),
                    selectionId: firstOdds.effectiveDrawSelectionId,
                    oddsData: firstOdds,
                    marketData: market,
                    oddsType: OddsType.draw,
                  ),
                BetItem(
                  label: '2',
                  value: firstOdds.formattedAwayOdds(effectiveOddsStyle),
                  selectionId: firstOdds.effectiveAwaySelectionId,
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
            BetColumn(
              type: columnType,
              items: [
                BetItem(
                  label: formattedPoints,
                  value: firstOdds.formattedHomeOdds(effectiveOddsStyle),
                  selectionId: firstOdds.effectiveHomeSelectionId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home, // Over uses home odds
                ),
                BetItem(
                  label: 'U',
                  value: firstOdds.formattedAwayOdds(effectiveOddsStyle),
                  selectionId: firstOdds.effectiveAwaySelectionId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away, // Under uses away odds
                ),
              ],
            ),
          );
        } else {
          // Handicap: Show points on the team receiving handicap
          final pointsValue = double.tryParse(firstOdds.points) ?? 0;
          final homeLabel = pointsValue <= 0 ? formattedPoints : '';
          final awayLabel = pointsValue > 0 ? formattedPoints : '';

          columns.add(
            BetColumn(
              type: columnType,
              items: [
                BetItem(
                  label: homeLabel,
                  value: firstOdds.formattedHomeOdds(effectiveOddsStyle),
                  selectionId: firstOdds.effectiveHomeSelectionId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.home,
                ),
                BetItem(
                  label: awayLabel,
                  value: firstOdds.formattedAwayOdds(effectiveOddsStyle),
                  selectionId: firstOdds.effectiveAwaySelectionId,
                  oddsData: firstOdds,
                  marketData: market,
                  oddsType: OddsType.away,
                ),
              ],
            ),
          );
        }
      }
      // Note: Nếu market.odds.isEmpty (market bị suspended/hidden)
      // → Không tạo column, để UI layer tự render placeholder widget
    }

    // Sort and ensure we have the right order
    final sortedColumns = _sortColumns(columns);

    // Debug: Log final columns
    // if (kDebugMode) {
    //   debugPrint('[MarketConverter] Generated ${sortedColumns.length} columns:');
    //   for (final c in sortedColumns) {
    //     debugPrint('  - ${c.type}: ${c.items.length} items');
    //   }
    // }

    return sortedColumns;
  }

  /// Get BetColumnType from market data
  static BetColumnType? _getColumnType(LeagueMarketData market) {
    final name = market.marketName.toLowerCase();
    final type = market.marketType?.toLowerCase() ?? '';
    final id = market.marketId;

    // Check by market type first
    if (type.contains('ah') || type.contains('handicap')) {
      return type.contains('h1') || type.contains('1h')
          ? BetColumnType.handicapH1
          : BetColumnType.handicap;
    }

    if (type.contains('ou') ||
        type.contains('over') ||
        type.contains('under')) {
      return type.contains('h1') || type.contains('1h')
          ? BetColumnType.overUnderH1
          : BetColumnType.overUnder;
    }

    if (type.contains('1x2') ||
        type.contains('ml') ||
        type.contains('winner')) {
      return type.contains('h1') || type.contains('1h')
          ? BetColumnType.matchResultH1
          : BetColumnType.matchResult;
    }

    // Check by market name
    if (name.contains('handicap') || name.contains('kèo chấp')) {
      return name.contains('h1') || name.contains('hiệp 1')
          ? BetColumnType.handicapH1
          : BetColumnType.handicap;
    }

    if (name.contains('over') ||
        name.contains('under') ||
        name.contains('tài') ||
        name.contains('xỉu')) {
      return name.contains('h1') || name.contains('hiệp 1')
          ? BetColumnType.overUnderH1
          : BetColumnType.overUnder;
    }

    if (name.contains('1x2') ||
        name.contains('winner') ||
        name.contains('result')) {
      return name.contains('h1') || name.contains('hiệp 1')
          ? BetColumnType.matchResultH1
          : BetColumnType.matchResult;
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

    return null;
  }

  /// Sort columns in display order
  static List<BetColumn> _sortColumns(List<BetColumn> columns) {
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
  static List<BetColumn> emptyColumns({bool includeH1 = true}) {
    final columns = [
      const BetColumn(type: BetColumnType.handicap),
      const BetColumn(type: BetColumnType.overUnder),
      const BetColumn(type: BetColumnType.matchResult),
    ];

    if (includeH1) {
      columns.addAll([
        const BetColumn(type: BetColumnType.handicapH1),
        const BetColumn(type: BetColumnType.overUnderH1),
        const BetColumn(type: BetColumnType.matchResultH1),
      ]);
    }

    return columns;
  }
}

/// Extension on LeagueEventData for easy conversion
extension LeagueEventDataUIExtension on LeagueEventData {
  /// Convert event markets to BetColumns
  List<BetColumn> toBetColumns({OddsStyle oddsStyle = OddsStyle.decimal}) =>
      MarketConverterService.marketsToBetColumns(markets, oddsStyle: oddsStyle);
}
