import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';

/// Type of flat item for virtualized list
enum FlatItemTypeV2 {
  /// League header row
  leagueHeader,

  /// Event/match row
  eventRow,
}

/// Flat item for virtualized sliver list (V2 Version)
/// Uses LeagueModelV2 and EventModelV2 directly without legacy conversion
///
/// Converts nested structure (leagues → events) into flat list for true virtualization
///
/// Example:
/// ```
/// NESTED:                    FLAT:
/// League A                   [0] League A Header
///   ├─ Event 1               [1] Event 1
///   └─ Event 2               [2] Event 2
/// League B                   [3] League B Header
///   └─ Event 3               [4] Event 3
/// ```
class FlatItemV2 {
  final FlatItemTypeV2 type;
  final LeagueModelV2 league;
  final EventModelV2? event;
  final int leagueIndex;
  final bool isLastEventInLeague;

  /// Private constructor
  const FlatItemV2._({
    required this.type,
    required this.league,
    this.event,
    required this.leagueIndex,
    required this.isLastEventInLeague,
  });

  /// Create a league header item
  factory FlatItemV2.header(LeagueModelV2 league, {required int leagueIndex}) =>
      FlatItemV2._(
        type: FlatItemTypeV2.leagueHeader,
        league: league,
        leagueIndex: leagueIndex,
        isLastEventInLeague: false,
      );

  /// Create an event row item
  factory FlatItemV2.event(
    EventModelV2 event,
    LeagueModelV2 league, {
    required int leagueIndex,
    required bool isLastEventInLeague,
  }) => FlatItemV2._(
    type: FlatItemTypeV2.eventRow,
    league: league,
    event: event,
    leagueIndex: leagueIndex,
    isLastEventInLeague: isLastEventInLeague,
  );

  /// Unique key for efficient diffing (findChildIndexCallback)
  String get key {
    switch (type) {
      case FlatItemTypeV2.leagueHeader:
        return 'league_${league.leagueId}';
      case FlatItemTypeV2.eventRow:
        return 'event_${event!.eventId}';
    }
  }

  /// Item height for SliverFixedExtentList optimization
  /// Returns height based on item type, platform, and sport
  ///
  /// Note: LeagueHeader includes margin (4px desktop, 2px mobile)
  /// Non-soccer sports use taller rows (stacked score + odds layout)
  double getHeight({required bool isDesktop}) {
    switch (type) {
      case FlatItemTypeV2.leagueHeader:
        // Container height (48/40) + margin bottom (4/2)
        return isDesktop ? 52.0 : 42.0;
      case FlatItemTypeV2.eventRow:
        final isSoccer = event?.sportId == 1 || event?.sportId == null;
        return isSoccer
            ? (isDesktop ? 205.0 : 220.0)
            : (isDesktop ? 250.0 : 270.0);
    }
  }
}

/// Build flat items list from nested V2 leagues data
///
/// Features:
/// - When [includeEmptyLeagues] is false (default): skips leagues with no events
/// - When [includeEmptyLeagues] is true: shows league header only for empty leagues (no event rows)
/// - Respects expanded state per league
/// - Returns immutable snapshot for safe iteration during build
List<FlatItemV2> buildFlatItemsV2(
  List<LeagueModelV2> leagues, {
  Set<int>? collapsedLeagueIds,
  bool includeEmptyLeagues = false,
}) {
  final items = <FlatItemV2>[];
  var visibleLeagueIndex = 0;

  for (final league in leagues) {
    if (league.events.isEmpty && !includeEmptyLeagues) continue;
    final leagueIndex = visibleLeagueIndex;

    // Always add league header (name only when empty and includeEmptyLeagues)
    items.add(FlatItemV2.header(league, leagueIndex: leagueIndex));

    // Add events if league is expanded (not in collapsed set)
    final isCollapsed = collapsedLeagueIds?.contains(league.leagueId) ?? false;
    if (!isCollapsed && league.events.isNotEmpty) {
      for (var i = 0; i < league.events.length; i++) {
        final event = league.events[i];
        final isLastEventInLeague = i == league.events.length - 1;
        items.add(
          FlatItemV2.event(
            event,
            league,
            leagueIndex: leagueIndex,
            isLastEventInLeague: isLastEventInLeague,
          ),
        );
      }
    }

    visibleLeagueIndex++;
  }

  return items;
}
