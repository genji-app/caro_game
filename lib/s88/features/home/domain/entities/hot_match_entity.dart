import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/market_model_v2.dart';

/// Per-event statistics for hot match enrichment (betting trend, total users).
class HotMatchEventStatistics {
  final String? bettingTrend;
  final int? totalUsers;

  const HotMatchEventStatistics({this.bettingTrend, this.totalUsers});
}

/// Hot Match State Entity
///
/// Holds the current state of hot matches data (V2 leagues from API).
class HotMatchState {
  /// Hot match leagues (V2 API).
  final List<LeagueModelV2> leagues;

  /// Statistics per event (từ /simple + /users). Được populate progressive
  /// qua stream — mỗi entry được thêm vào ngay khi match đó hoàn thành.
  final Map<int, HotMatchEventStatistics> eventStatistics;

  /// Tập hợp eventIds đang chờ statistics load xong.
  ///
  /// - Khi fetchHotMatches hoàn thành: chứa tất cả eventIds.
  /// - Khi stream emit kết quả cho eventId X: X bị xóa khỏi set này.
  /// - Khi set rỗng: toàn bộ statistics đã load xong.
  ///
  /// UI dùng `pendingStatisticsIds.contains(eventId)` để hiển thị shimmer
  /// cho phần bettingTrend/totalUsers của từng card — kể cả khi user
  /// scroll nhanh sang item chưa load xong.
  final Set<int> pendingStatisticsIds;

  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final int currentPageIndex;

  /// Page index riêng cho sidebar phải; tránh đồng bộ với main live section.
  final int rightSidebarPageIndex;

  const HotMatchState({
    this.leagues = const [],
    this.eventStatistics = const {},
    this.pendingStatisticsIds = const <int>{},
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.currentPageIndex = 0,
    this.rightSidebarPageIndex = 0,
  });

  HotMatchState copyWith({
    List<LeagueModelV2>? leagues,
    Map<int, HotMatchEventStatistics>? eventStatistics,
    Set<int>? pendingStatisticsIds,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    int? currentPageIndex,
    int? rightSidebarPageIndex,
  }) {
    return HotMatchState(
      leagues: leagues ?? this.leagues,
      eventStatistics: eventStatistics ?? this.eventStatistics,
      pendingStatisticsIds: pendingStatisticsIds ?? this.pendingStatisticsIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      rightSidebarPageIndex:
          rightSidebarPageIndex ?? this.rightSidebarPageIndex,
    );
  }

  bool get hasData => leagues.isNotEmpty;

  /// True khi tất cả statistics đã load xong (stream đã đóng).
  bool get isStatisticsFullyLoaded => pendingStatisticsIds.isEmpty;

  /// True nếu eventId này đang chờ statistics.
  bool isStatisticsPending(int eventId) =>
      pendingStatisticsIds.contains(eventId);

  int get totalCount => leagues.fold<int>(0, (sum, l) => sum + l.events.length);
}

/// Flatten [LeagueModelV2] list to carousel items (one [HotMatchEventV2] per event).
/// Optionally merge [eventStatistics] (bettingTrend, totalUsers) into each item.
List<HotMatchEventV2> flattenLeaguesToHotMatches(
  List<LeagueModelV2> leagues, {
  Map<int, HotMatchEventStatistics> eventStatistics = const {},
}) {
  final list = <HotMatchEventV2>[];
  for (final league in leagues) {
    for (final event in league.events) {
      final stats = eventStatistics[event.eventId];
      list.add(
        HotMatchEventV2(
          event: event,
          leagueName: league.leagueName,
          leagueLogo: league.leagueLogo,
          leagueId: league.leagueId,
          bettingTrend: stats?.bettingTrend,
          totalUsers: stats?.totalUsers,
        ),
      );
    }
  }
  return list;
}

/// Hot Match Event Item Entity
///
/// Combines event data with its parent league info for display.
/// This is a domain-level entity that presentation layer can use.
class HotMatchEventItem {
  final LeagueEventData event;
  final String leagueName;
  final String leagueLogo;
  final int leagueId;

  /// Betting trend - which team is favored and percentage
  /// Format: "TeamName X%" or null if no data
  final String? bettingTrend;

  /// Total number of users who bet on this match
  final int? totalUsers;

  const HotMatchEventItem({
    required this.event,
    required this.leagueName,
    required this.leagueLogo,
    required this.leagueId,
    this.bettingTrend,
    this.totalUsers,
  });

  /// Create from league data
  factory HotMatchEventItem.fromLeague(
    LeagueData league,
    LeagueEventData event, {
    String? bettingTrend,
    int? totalUsers,
  }) {
    return HotMatchEventItem(
      event: event,
      leagueName: league.leagueName,
      leagueLogo: league.leagueLogo,
      leagueId: league.leagueId,
      bettingTrend: bettingTrend,
      totalUsers: totalUsers,
    );
  }

  /// Create a copy with updated statistics
  HotMatchEventItem copyWith({
    LeagueEventData? event,
    String? leagueName,
    String? leagueLogo,
    int? leagueId,
    String? bettingTrend,
    int? totalUsers,
  }) {
    return HotMatchEventItem(
      event: event ?? this.event,
      leagueName: leagueName ?? this.leagueName,
      leagueLogo: leagueLogo ?? this.leagueLogo,
      leagueId: leagueId ?? this.leagueId,
      bettingTrend: bettingTrend ?? this.bettingTrend,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  /// Get event ID
  int get eventId => event.eventId;

  /// Get home team name
  String get homeName => event.homeName;

  /// Get away team name
  String get awayName => event.awayName;

  /// Get home team logo
  String get homeLogo => event.homeLogo;

  /// Get away team logo
  String get awayLogo => event.awayLogo;

  /// Get formatted time
  String get formattedTime => event.formattedTime;

  /// Get formatted date
  String get formattedDate => event.formattedDate;

  /// Is live match
  bool get isLive => event.isLive;

  /// Get score string
  String get scoreString => event.scoreString;

  /// Get markets
  List<LeagueMarketData> get markets => event.markets;

  /// Get handicap market (mi = 5 for football)
  LeagueMarketData? getHandicapMarket(int sportId) {
    final marketId = _getHandicapMarketId(sportId);
    return event.getMarketById(marketId);
  }

  /// Get over/under market (mi = 3 for football)
  LeagueMarketData? getOverUnderMarket(int sportId) {
    final marketId = _getOverUnderMarketId(sportId);
    return event.getMarketById(marketId);
  }

  /// Get handicap market ID by sport
  int _getHandicapMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 5; // Football
      case 2:
        return 201; // Basketball
      case 4:
        return 402; // Tennis
      case 5:
        return 509; // Volleyball
      default:
        return 5;
    }
  }

  /// Get over/under market ID by sport
  int _getOverUnderMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 3; // Football
      case 2:
        return 202; // Basketball
      case 4:
        return 401; // Tennis
      case 5:
        return 510; // Volleyball
      default:
        return 3;
    }
  }
}

/// Hot Match Event V2
///
/// Wraps [EventModelV2] with league display info for hot match carousel.
/// Used when getHotMatches returns data from V2 API.
class HotMatchEventV2 {
  final EventModelV2 event;
  final String leagueName;
  final String leagueLogo;
  final int leagueId;

  /// Betting trend - e.g. "TeamName 65.5%"
  final String? bettingTrend;

  /// Total users who bet on this match
  final int? totalUsers;

  const HotMatchEventV2({
    required this.event,
    required this.leagueName,
    required this.leagueLogo,
    required this.leagueId,
    this.bettingTrend,
    this.totalUsers,
  });

  HotMatchEventV2 copyWith({
    EventModelV2? event,
    String? leagueName,
    String? leagueLogo,
    int? leagueId,
    String? bettingTrend,
    int? totalUsers,
  }) {
    return HotMatchEventV2(
      event: event ?? this.event,
      leagueName: leagueName ?? this.leagueName,
      leagueLogo: leagueLogo ?? this.leagueLogo,
      leagueId: leagueId ?? this.leagueId,
      bettingTrend: bettingTrend ?? this.bettingTrend,
      totalUsers: totalUsers ?? this.totalUsers,
    );
  }

  int get eventId => event.eventId;
  String get homeName => event.homeName;
  String get awayName => event.awayName;
  String get homeLogo => event.homeLogo;
  String get awayLogo => event.awayLogo;
  bool get isLive => event.isLive;
  String get scoreString => event.scoreDisplay;
  int get startTime => event.startTime;
  String get formattedTime => event.startDateTime.toString();
  String get formattedDate => event.startDate.isNotEmpty
      ? event.startDate
      : (event.startTime > 0
            ? DateTime.fromMillisecondsSinceEpoch(
                event.startTime,
                isUtc: true,
              ).toIso8601String()
            : '');

  /// Handicap market by sport (5=football, 201=basketball, etc.)
  MarketModelV2? getHandicapMarket(int sportId) {
    return event.getMarketById(_handicapMarketId(sportId));
  }

  /// Over/under market by sport (3=football, 202=basketball, etc.)
  MarketModelV2? getOverUnderMarket(int sportId) {
    return event.getMarketById(_overUnderMarketId(sportId));
  }

  static int _handicapMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 5;
      case 2:
        return 201;
      case 4:
        return 402;
      case 5:
        return 509;
      default:
        return 5;
    }
  }

  static int _overUnderMarketId(int sportId) {
    switch (sportId) {
      case 1:
        return 3;
      case 2:
        return 202;
      case 4:
        return 401;
      case 5:
        return 510;
      default:
        return 3;
    }
  }
}
