import 'package:co_caro_flame/s88/core/services/models/league_model.dart';

/// Type of flat item for virtualized list
enum FlatItemType {
  /// League header row
  leagueHeader,

  /// Event/match row
  eventRow,
}

/// Flat item for virtualized sliver list
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
class FlatItem {
  final FlatItemType type;
  final LeagueData league;
  final LeagueEventData? event;
  final int leagueIndex;
  final bool isLastEventInLeague;

  /// Private constructor
  const FlatItem._({
    required this.type,
    required this.league,
    this.event,
    required this.leagueIndex,
    required this.isLastEventInLeague,
  });

  /// Create a league header item
  factory FlatItem.header(LeagueData league, {required int leagueIndex}) =>
      FlatItem._(
        type: FlatItemType.leagueHeader,
        league: league,
        leagueIndex: leagueIndex,
        isLastEventInLeague: false,
      );

  /// Create an event row item
  factory FlatItem.event(
    LeagueEventData event,
    LeagueData league, {
    required int leagueIndex,
    required bool isLastEventInLeague,
  }) => FlatItem._(
    type: FlatItemType.eventRow,
    league: league,
    event: event,
    leagueIndex: leagueIndex,
    isLastEventInLeague: isLastEventInLeague,
  );

  /// Unique key for efficient diffing (findChildIndexCallback)
  String get key {
    switch (type) {
      case FlatItemType.leagueHeader:
        return 'league_${league.leagueId}';
      case FlatItemType.eventRow:
        return 'event_${event!.eventId}';
    }
  }

  /// Item height for SliverFixedExtentList optimization
  /// Returns height based on item type and platform
  ///
  /// Note: LeagueHeader includes margin (4px desktop, 2px mobile)
  double getHeight({required bool isDesktop}) {
    switch (type) {
      case FlatItemType.leagueHeader:
        // Container height (48/40) + margin bottom (4/2)
        return isDesktop ? 52.0 : 42.0;
      case FlatItemType.eventRow:
        return isDesktop ? 205.0 : 220.0;
    }
  }
}

/// Build flat items list from nested leagues data
///
/// Features:
/// - Skips empty leagues
/// - Respects expanded state per league
/// - Returns immutable snapshot for safe iteration during build
List<FlatItem> buildFlatItems(
  List<LeagueData> leagues, {
  Set<int>? collapsedLeagueIds,
}) {
  final items = <FlatItem>[];
  var visibleLeagueIndex = 0;

  for (final league in leagues) {
    // Skip empty leagues
    if (league.events.isEmpty) continue;
    final leagueIndex = visibleLeagueIndex;

    // Always add league header
    items.add(FlatItem.header(league, leagueIndex: leagueIndex));

    // Add events if league is expanded (not in collapsed set)
    final isCollapsed = collapsedLeagueIds?.contains(league.leagueId) ?? false;
    if (!isCollapsed) {
      for (var i = 0; i < league.events.length; i++) {
        final event = league.events[i];
        final isLastEventInLeague = i == league.events.length - 1;
        items.add(
          FlatItem.event(
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
