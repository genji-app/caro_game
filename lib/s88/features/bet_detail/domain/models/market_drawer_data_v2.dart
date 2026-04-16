import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/enums/market_filter.dart';

/// Market Drawer Data V2 Model
///
/// New design: Each market type is a separate drawer with its own card.
/// Header format: "{Period} - {Market Type}" (e.g., "Toàn trận - Kèo chấp")
///
/// Layout types:
/// - handicap: 2 columns with team names, multiple rows
/// - overUnder: 2 columns (Tài/Xỉu), multiple rows
/// - oneXTwo: 3 horizontal cells (1, X, 2)
/// - oddEven: 2 horizontal cells (Lẻ, Chẵn)
/// - doubleChance: 3 horizontal cells (1X, X2, 12)
/// - drawNoBet: 2 horizontal cells with team names
/// - cleanSheet: 2 columns with team names, Yes/No rows
/// - teamOverUnder: 2 columns (Tài/Xỉu) with team name in header
class MarketDrawerDataV2 {
  /// Drawer display name (e.g., "Toàn trận - Kèo chấp")
  final String name;

  /// Filter category this drawer belongs to
  final MarketFilter filter;

  /// Layout type for rendering
  final MarketLayoutTypeV2 layoutType;

  /// Single market data (most drawers have single market)
  final LeagueMarketData? market;

  /// Multiple markets (used for Clean Sheet which has Home + Away markets)
  final List<LeagueMarketData> markets;

  /// Whether drawer is expanded
  final bool isExpanded;

  /// Market ID (for identifying market type)
  final int marketId;

  const MarketDrawerDataV2({
    required this.name,
    required this.filter,
    required this.layoutType,
    this.market,
    this.markets = const [],
    this.isExpanded = true,
    this.marketId = 0,
  });

  /// Check if drawer has any valid markets with odds
  bool get hasValidMarkets {
    if (market != null && market!.odds.isNotEmpty) return true;
    return markets.any((m) => m.odds.isNotEmpty);
  }

  /// Check if drawer is empty
  bool get isEmpty => !hasValidMarkets;

  /// Copy with new values
  MarketDrawerDataV2 copyWith({
    String? name,
    MarketFilter? filter,
    MarketLayoutTypeV2? layoutType,
    LeagueMarketData? market,
    List<LeagueMarketData>? markets,
    bool? isExpanded,
    int? marketId,
  }) {
    return MarketDrawerDataV2(
      name: name ?? this.name,
      filter: filter ?? this.filter,
      layoutType: layoutType ?? this.layoutType,
      market: market ?? this.market,
      markets: markets ?? this.markets,
      isExpanded: isExpanded ?? this.isExpanded,
      marketId: marketId ?? this.marketId,
    );
  }
}

/// Market Layout Type V2 - Layout type for different market types
enum MarketLayoutTypeV2 {
  /// 2 columns with team names, multiple rows (Handicap)
  handicap,

  /// 2 columns (Tài/Xỉu), multiple rows (Over/Under)
  overUnder,

  /// 3 horizontal cells (1, X, 2)
  oneXTwo,

  /// 2 horizontal cells (Lẻ, Chẵn)
  oddEven,

  /// 3 horizontal cells (1X, X2, 12)
  doubleChance,

  /// 2 horizontal cells with team names
  drawNoBet,

  /// 2 columns with team names, Yes/No rows
  cleanSheet,

  /// 2 columns (Tài/Xỉu) - for team-specific O/U
  teamOverUnder,

  /// 2 horizontal cells with team names (To Qualify, Penalty Winner, etc.)
  teamWinner,

  /// 3 horizontal cells (Home, No Goal, Away) - Next/Last Goal
  nextLastGoal,

  /// 2x2 grid (Which Team To Score)
  whichTeamToScore,

  /// Correct Score grid (3 columns: Home wins, Draw, Away wins)
  correctScore,

  /// Vertical list with points (Total Score)
  totalScore,
}

/// Market Drawer V2 Builder
///
/// Builds separate drawers for each market type.
/// Each drawer is a separate expandable card.
///
/// Tab structure:
/// - "Chính" (Main): All main markets (Handicap, O/U, 1X2 for all periods)
/// - "Toàn trận" (Full Time): FT markets
/// - "Hiệp 1" (First Half): HT markets
/// - "Hiệp 2" (Second Half): SH markets
/// - "Hiệp phụ" (Extra Time): Extra time markets
/// - "Phạt góc" (Corner): Corner markets
/// - "Tỷ số" (Score): Score markets
/// - "Thẻ phạt" (Booking): Booking markets
class MarketDrawerV2Builder {
  MarketDrawerV2Builder._();

  /// Build all drawers from event markets
  ///
  /// Creates separate drawers for each market type.
  /// Header format: "{Period} - {Market Type}"
  static List<MarketDrawerDataV2> buildDrawers(
    List<LeagueMarketData> markets, {
    int sportId = 1,
    int currentSet = 1,
  }) {
    // Dispatch to sport-specific builder
    switch (sportId) {
      case 2:
        return _buildBasketballDrawers(markets);
      case 3:
        return _buildCombatDrawers(markets);
      case 4:
        return _buildTennisDrawers(markets);
      case 5:
        return _buildVolleyballDrawers(markets);
      case 6:
        return _buildTableTennisDrawers(markets);
      case 7:
        return _buildBadmintonDrawers(markets, currentSet: currentSet);
    }

    // Default: Soccer
    final drawers = <MarketDrawerDataV2>[];

    // ===== MAIN + FULL TIME (Toàn trận) =====

    // Handicap FT (5) - belongs to both main and fullTime
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 5,
      name: 'Toàn trận - Kèo chấp',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Over/Under FT (3)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 3,
      name: 'Toàn trận - Tài xỉu',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // 1X2 FT (1)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 1,
      name: 'Toàn trận - 1X2',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Odd/Even FT (8)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 8,
      name: 'Toàn trận - Chẵn lẻ',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    // Double Chance FT (12)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 12,
      name: 'Toàn trận - Cơ hội kép',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.doubleChance,
    );

    // Draw No Bet FT (16)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 16,
      name: 'Toàn trận - Hòa hoàn tiền',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.drawNoBet,
    );

    // Home O/U (101)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 101,
      name: 'Toàn trận - Tài/Xỉu đội nhà',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    // Away O/U (102)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 102,
      name: 'Toàn trận - Tài/Xỉu đội khách',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    // Clean Sheet - Home (83) + Away (84)
    final homeCleanSheet = _findMarket(markets, 83);
    final awayCleanSheet = _findMarket(markets, 84);
    if (homeCleanSheet != null || awayCleanSheet != null) {
      drawers.add(
        MarketDrawerDataV2(
          name: 'Toàn trận - Giữ sạch lưới',
          filter: MarketFilter.fullTime,
          layoutType: MarketLayoutTypeV2.cleanSheet,
          markets: [
            if (homeCleanSheet != null) homeCleanSheet,
            if (awayCleanSheet != null) awayCleanSheet,
          ],
        ),
      );
    }

    // Next Goal (7)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 7,
      name: 'Toàn trận - Bàn tiếp theo',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
    );

    // Last Goal (97)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 97,
      name: 'Toàn trận - Bàn cuối cùng',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.nextLastGoal,
    );

    // Which Team To Score (103)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 103,
      name: 'Toàn trận - Đội ghi bàn',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.whichTeamToScore,
    );

    // To Qualify (58)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 58,
      name: 'Toàn trận - Đội vào vòng trong',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    // Which Team Kick Off (59)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 59,
      name: 'Toàn trận - Đội giao bóng trước',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    // Penalty Shootout Winner (129)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 129,
      name: 'Toàn trận - Đội thắng Penalty',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    // Penalty Shootout Total (130)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 130,
      name: 'Toàn trận - Tài/Xỉu Penalty',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    // Home/Away Odd/Even (76, 77)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 76,
      name: 'Toàn trận - Chẵn lẻ đội nhà',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 77,
      name: 'Toàn trận - Chẵn lẻ đội khách',
      filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    // ===== FIRST HALF (Hiệp 1) =====

    // Handicap HT (6)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 6,
      name: 'Hiệp 1 - Kèo chấp',
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Over/Under HT (4)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 4,
      name: 'Hiệp 1 - Tài xỉu',
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // 1X2 HT (2)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 2,
      name: 'Hiệp 1 - 1X2',
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Odd/Even HT (9)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 9,
      name: 'Hiệp 1 - Chẵn lẻ',
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    // Double Chance HT (13)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 13,
      name: 'Hiệp 1 - Cơ hội kép',
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.doubleChance,
    );

    // Draw No Bet HT (75)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 75,
      name: 'Hiệp 1 - Hòa hoàn tiền',
      filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.drawNoBet,
    );

    // ===== SECOND HALF (Hiệp 2) =====

    // Handicap SH (85)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 85,
      name: 'Hiệp 2 - Kèo chấp',
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Over/Under SH (80)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 80,
      name: 'Hiệp 2 - Tài xỉu',
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // 1X2 SH (89)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 89,
      name: 'Hiệp 2 - 1X2',
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Odd/Even SH (86)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 86,
      name: 'Hiệp 2 - Chẵn lẻ',
      filter: MarketFilter.secondHalf,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    // ===== SCORE CATEGORY =====

    // Correct Score FT (10)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 10,
      name: 'Tỷ số chính xác',
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    // Correct Score HT (11)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 11,
      name: 'Tỷ số chính xác hiệp 1',
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.correctScore,
    );

    // Total Score FT (14)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 14,
      name: 'Tổng bàn thắng',
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    // Total Score HT (15)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 15,
      name: 'Tổng bàn thắng hiệp 1',
      filter: MarketFilter.score,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    // ===== CORNER CATEGORY =====

    // Corner Handicap FT (19)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 19,
      name: 'Phạt góc - Kèo chấp',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Corner O/U FT (21)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 21,
      name: 'Phạt góc - Tài xỉu',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // Corner 1X2 FT (17)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 17,
      name: 'Phạt góc - 1X2',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Corner Handicap HT (20)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 20,
      name: 'Phạt góc H1 - Kèo chấp',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Corner O/U HT (22)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 22,
      name: 'Phạt góc H1 - Tài xỉu',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // Corner 1X2 HT (18)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 18,
      name: 'Phạt góc H1 - 1X2',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Corner Odd/Even FT (56)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 56,
      name: 'Phạt góc chẵn lẻ',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    // Corner Odd/Even HT (57)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 57,
      name: 'Phạt góc chẵn lẻ H1',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.oddEven,
    );

    // Last Corner FT (66)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 66,
      name: 'Phạt góc cuối cùng',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    // Last Corner HT (67)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 67,
      name: 'Phạt góc cuối cùng H1',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamWinner,
    );

    // Corner O/U Home FT (61)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 61,
      name: 'Phạt góc Tài/Xỉu đội nhà',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    // Corner O/U Away FT (63)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 63,
      name: 'Phạt góc Tài/Xỉu đội khách',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.teamOverUnder,
    );

    // Corner Range FT (131)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 131,
      name: 'Tổng phạt góc trận đấu',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    // Corner Range HT (136)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 136,
      name: 'Tổng phạt góc hiệp 1',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    // Home Corner Range (134)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 134,
      name: 'Tổng phạt góc đội nhà',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    // Away Corner Range (135)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 135,
      name: 'Tổng phạt góc đội khách',
      filter: MarketFilter.corner,
      layoutType: MarketLayoutTypeV2.totalScore,
    );

    // ===== CORNER TIME RANGE (15 phút) =====
    _addCornerTimeRangeDrawers(markets, drawers);

    // ===== BOOKING CATEGORY =====

    // Booking Handicap FT (33)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 33,
      name: 'Thẻ phạt - Kèo chấp',
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Booking O/U FT (31)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 31,
      name: 'Thẻ phạt - Tài xỉu',
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // Booking 1X2 FT (29)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 29,
      name: 'Thẻ phạt - 1X2',
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Booking Handicap HT (34)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 34,
      name: 'Thẻ phạt H1 - Kèo chấp',
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    // Booking O/U HT (32)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 32,
      name: 'Thẻ phạt H1 - Tài xỉu',
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    // Booking 1X2 HT (30)
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 30,
      name: 'Thẻ phạt H1 - 1X2',
      filter: MarketFilter.booking,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // ===== TIME RANGE =====
    _addTimeRangeDrawers(markets, drawers);

    // ===== EXTRA TIME =====
    _addExtraTimeDrawers(markets, drawers);

    return drawers;
  }

  /// Add a single market drawer
  static void _addSingleMarketDrawer({
    required List<MarketDrawerDataV2> drawers,
    required List<LeagueMarketData> markets,
    required int marketId,
    required String name,
    required MarketFilter filter,
    required MarketLayoutTypeV2 layoutType,
  }) {
    final market = _findMarket(markets, marketId);
    if (market != null && market.odds.isNotEmpty) {
      drawers.add(
        MarketDrawerDataV2(
          name: name,
          filter: filter,
          layoutType: layoutType,
          market: market,
          marketId: marketId,
        ),
      );
    }
  }

  /// Add Time Range drawers
  static void _addTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers,
  ) {
    // Time Range Market IDs: [Handicap, O/U, 1X2]
    // Format từ JS team: "XX:XX - XX:XX"
    const timeRanges = [
      {'name': '00:00 - 14:59', 'hdp': 44, 'ou': 38, '1x2': 50},
      {'name': '15:00 - 29:59', 'hdp': 45, 'ou': 39, '1x2': 51},
      {'name': '30:00 - 44:59', 'hdp': 46, 'ou': 40, '1x2': 52},
      {'name': '45:00 - 59:59', 'hdp': 47, 'ou': 41, '1x2': 53},
      {'name': '60:00 - 74:59', 'hdp': 48, 'ou': 42, '1x2': 54},
      {'name': '75:00 - 90:00', 'hdp': 49, 'ou': 43, '1x2': 55},
    ];

    for (final range in timeRanges) {
      final rangeName = range['name'] as String;

      // Handicap
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['hdp'] as int,
        name: 'Kèo chấp $rangeName',
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.handicap,
      );

      // O/U
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['ou'] as int,
        name: 'Tài/Xỉu $rangeName',
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.overUnder,
      );

      // 1X2
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['1x2'] as int,
        name: '1X2 $rangeName',
        filter: MarketFilter.fullTime,
        layoutType: MarketLayoutTypeV2.oneXTwo,
      );
    }
  }

  /// Add Extra Time drawers
  static void _addExtraTimeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers,
  ) {
    // Extra Time FT: [27, 25, 23] - Handicap, O/U, 1X2
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 27,
      name: 'Hiệp phụ - Kèo chấp',
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 25,
      name: 'Hiệp phụ - Tài xỉu',
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 23,
      name: 'Hiệp phụ - 1X2',
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );

    // Extra Time HT: [28, 26, 24]
    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 28,
      name: 'Hiệp phụ H1 - Kèo chấp',
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.handicap,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 26,
      name: 'Hiệp phụ H1 - Tài xỉu',
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.overUnder,
    );

    _addSingleMarketDrawer(
      drawers: drawers,
      markets: markets,
      marketId: 24,
      name: 'Hiệp phụ H1 - 1X2',
      filter: MarketFilter.extraTime,
      layoutType: MarketLayoutTypeV2.oneXTwo,
    );
  }

  /// Add Corner Time Range drawers (15 phút intervals)
  /// Market IDs: 92-96 (CornerOverUnder0015 to CornerOverUnder6075)
  static void _addCornerTimeRangeDrawers(
    List<LeagueMarketData> markets,
    List<MarketDrawerDataV2> drawers,
  ) {
    // Corner O/U Time Range Market IDs (15 phút intervals)
    const cornerTimeRanges = [
      {'name': 'Phạt góc 0-15 phút', 'id': 92},
      {'name': 'Phạt góc 15-30 phút', 'id': 93},
      {'name': 'Phạt góc 30-45 phút', 'id': 94},
      {'name': 'Phạt góc 45-60 phút', 'id': 95},
      {'name': 'Phạt góc 60-75 phút', 'id': 96},
    ];

    for (final range in cornerTimeRanges) {
      _addSingleMarketDrawer(
        drawers: drawers,
        markets: markets,
        marketId: range['id'] as int,
        name: range['name'] as String,
        filter: MarketFilter.corner,
        layoutType: MarketLayoutTypeV2.overUnder,
      );
    }
  }

  // ===== BASKETBALL (sportId = 2) =====

  static List<MarketDrawerDataV2> _buildBasketballDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    // Full Time
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 200,
      name: 'Toàn trận - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 201,
      name: 'Toàn trận - Kèo chấp', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 202,
      name: 'Toàn trận - Tài xỉu', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    // First Half (Hiệp 1)
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 203,
      name: 'Hiệp 1 - Kèo chấp', filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 204,
      name: 'Hiệp 1 - Tài xỉu', filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 205,
      name: 'Hiệp 1 - Đội thắng', filter: MarketFilter.firstHalf,
      layoutType: MarketLayoutTypeV2.teamWinner);

    // Quarter 1
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 206,
      name: 'Q1 - Đội thắng', filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 210,
      name: 'Q1 - Kèo chấp', filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 214,
      name: 'Q1 - Tài xỉu', filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Quarter 2
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 207,
      name: 'Q2 - Đội thắng', filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 211,
      name: 'Q2 - Kèo chấp', filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 215,
      name: 'Q2 - Tài xỉu', filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Quarter 3
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 208,
      name: 'Q3 - Đội thắng', filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 212,
      name: 'Q3 - Kèo chấp', filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 216,
      name: 'Q3 - Tài xỉu', filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Quarter 4
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 209,
      name: 'Q4 - Đội thắng', filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 213,
      name: 'Q4 - Kèo chấp', filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 217,
      name: 'Q4 - Tài xỉu', filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.overUnder);

    return drawers;
  }

  // ===== COMBAT / BOXING (sportId = 3) =====

  static List<MarketDrawerDataV2> _buildCombatDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    // Boxing
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 300,
      name: 'Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 301,
      name: 'Tài xỉu Rounds', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 308,
      name: 'Kèo chấp', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);

    // MMA / UFC (MU)
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 304,
      name: 'Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 305,
      name: 'Tài xỉu Rounds', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 310,
      name: 'Kèo chấp', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);

    // BOX
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 306,
      name: 'Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 307,
      name: 'Tài xỉu Rounds', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 309,
      name: 'Kèo chấp', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);

    return drawers;
  }

  // ===== TENNIS (sportId = 4) =====

  static List<MarketDrawerDataV2> _buildTennisDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    // Full Time
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 400,
      name: 'Toàn trận - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 401,
      name: 'Toàn trận - Tài xỉu Games', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 402,
      name: 'Toàn trận - Kèo chấp Games', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 403,
      name: 'Toàn trận - Game Winner', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);

    // Set Winners
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 404,
      name: 'Set 1 - Đội thắng', filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 405,
      name: 'Set 2 - Đội thắng', filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 406,
      name: 'Set 3 - Đội thắng', filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 407,
      name: 'Set 4 - Đội thắng', filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  // ===== VOLLEYBALL (sportId = 5) =====

  static List<MarketDrawerDataV2> _buildVolleyballDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    // Full Time
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 500,
      name: 'Toàn trận - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 509,
      name: 'Toàn trận - Kèo chấp Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 510,
      name: 'Toàn trận - Tài xỉu Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Set Winners
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 504,
      name: 'Set 1 - Đội thắng', filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 505,
      name: 'Set 2 - Đội thắng', filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 506,
      name: 'Set 3 - Đội thắng', filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 507,
      name: 'Set 4 - Đội thắng', filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 508,
      name: 'Set 5 - Đội thắng', filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  // ===== TABLE TENNIS (sportId = 6) =====

  static List<MarketDrawerDataV2> _buildTableTennisDrawers(
    List<LeagueMarketData> markets,
  ) {
    final drawers = <MarketDrawerDataV2>[];

    // Full Time
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 600,
      name: 'Toàn trận - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 609,
      name: 'Toàn trận - Kèo chấp Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 610,
      name: 'Toàn trận - Tài xỉu Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Ván Winners
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 602,
      name: 'Ván 1 - Đội thắng', filter: MarketFilter.set1,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 603,
      name: 'Ván 2 - Đội thắng', filter: MarketFilter.set2,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 604,
      name: 'Ván 3 - Đội thắng', filter: MarketFilter.set3,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 605,
      name: 'Ván 4 - Đội thắng', filter: MarketFilter.set4,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 606,
      name: 'Ván 5 - Đội thắng', filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 607,
      name: 'Ván 6 - Đội thắng', filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 608,
      name: 'Ván 7 - Đội thắng', filter: MarketFilter.set5,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  // ===== BADMINTON (sportId = 7) =====

  static List<MarketDrawerDataV2> _buildBadmintonDrawers(
    List<LeagueMarketData> markets, {
    int currentSet = 1,
  }) {
    final drawers = <MarketDrawerDataV2>[];
    final currentGame = 'Game $currentSet';
    final nextGame = 'Game ${currentSet + 1}';

    // FT markets
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 700,
      name: 'Toàn trận - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 709,
      name: 'Toàn trận - Kèo chấp Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 710,
      name: 'Toàn trận - Tài xỉu Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Current game markets — label động theo gamePart
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 705,
      name: '$currentGame - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 701,
      name: '$currentGame - Tài xỉu', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 702,
      name: '$currentGame - Kèo chấp', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 711,
      name: '$currentGame - Kèo chấp Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.handicap);
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 712,
      name: '$currentGame - Tài xỉu Point', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.overUnder);

    // Advance market — ván tiếp theo (tự skip nếu server không trả)
    _addSingleMarketDrawer(drawers: drawers, markets: markets, marketId: 704,
      name: '$nextGame - Đội thắng', filter: MarketFilter.fullTime,
      layoutType: MarketLayoutTypeV2.teamWinner);

    return drawers;
  }

  /// Find a single market by ID
  static LeagueMarketData? _findMarket(
    List<LeagueMarketData> markets,
    int marketId,
  ) {
    return markets.where((m) => m.marketId == marketId).firstOrNull;
  }
}
