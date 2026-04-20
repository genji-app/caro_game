import 'package:meta/meta.dart';

/// Event emitted when data in the store changes.
///
/// Contains sets of updated/added/removed entity IDs.
/// Used by adapters to efficiently sync with app state.
@immutable
class DataChangeEvent {
  // ===== Updated IDs (existing entities modified) =====

  /// League IDs that were updated
  final Set<int> updatedLeagueIds;

  /// Event IDs that were updated
  final Set<int> updatedEventIds;

  /// Market keys that were updated ("{eventId}_{marketId}")
  final Set<String> updatedMarketKeys;

  /// Odds keys that were updated ("{eventId}_{marketId}_{offerId}")
  final Set<String> updatedOddsKeys;

  // ===== Added IDs (new entities inserted) =====

  /// League IDs that were added
  final List<int> addedLeagueIds;

  /// Event IDs that were added
  final List<int> addedEventIds;

  /// Market keys that were added
  final List<String> addedMarketKeys;

  /// Odds keys that were added
  final List<String> addedOddsKeys;

  // ===== Removed IDs =====

  /// League IDs that were removed
  final List<int> removedLeagueIds;

  /// Event IDs that were removed
  final List<int> removedEventIds;

  // ===== Metadata =====

  /// Timestamp when changes occurred
  final DateTime timestamp;

  /// Number of messages in this batch
  final int batchSize;

  /// How long processing took
  final Duration processingTime;

  const DataChangeEvent({
    this.updatedLeagueIds = const {},
    this.updatedEventIds = const {},
    this.updatedMarketKeys = const {},
    this.updatedOddsKeys = const {},
    this.addedLeagueIds = const [],
    this.addedEventIds = const [],
    this.addedMarketKeys = const [],
    this.addedOddsKeys = const [],
    this.removedLeagueIds = const [],
    this.removedEventIds = const [],
    required this.timestamp,
    this.batchSize = 0,
    this.processingTime = Duration.zero,
  });

  /// Create empty event
  factory DataChangeEvent.empty() => DataChangeEvent(
        timestamp: DateTime.now(),
      );

  // ===== Helper methods =====

  /// Check if event is empty (no changes)
  bool get isEmpty =>
      updatedLeagueIds.isEmpty &&
      updatedEventIds.isEmpty &&
      updatedMarketKeys.isEmpty &&
      updatedOddsKeys.isEmpty &&
      addedLeagueIds.isEmpty &&
      addedEventIds.isEmpty &&
      addedMarketKeys.isEmpty &&
      addedOddsKeys.isEmpty &&
      removedLeagueIds.isEmpty &&
      removedEventIds.isEmpty;

  /// Check if event has any changes
  bool get isNotEmpty => !isEmpty;

  /// Total number of changes
  int get totalChanges =>
      updatedLeagueIds.length +
      updatedEventIds.length +
      updatedMarketKeys.length +
      updatedOddsKeys.length +
      addedLeagueIds.length +
      addedEventIds.length +
      addedMarketKeys.length +
      addedOddsKeys.length +
      removedLeagueIds.length +
      removedEventIds.length;

  /// Check if a specific event is affected
  bool affectsEvent(int eventId) =>
      updatedEventIds.contains(eventId) ||
      addedEventIds.contains(eventId) ||
      removedEventIds.contains(eventId);

  /// Check if a specific league is affected
  bool affectsLeague(int leagueId) =>
      updatedLeagueIds.contains(leagueId) ||
      addedLeagueIds.contains(leagueId) ||
      removedLeagueIds.contains(leagueId);

  /// Check if a specific market is affected
  bool affectsMarket(int eventId, int marketId) {
    final key = '${eventId}_$marketId';
    return updatedMarketKeys.contains(key) || addedMarketKeys.contains(key);
  }

  /// Check if any event in a league is affected
  bool affectsAnyEventInLeague(int leagueId, Set<int> eventIdsInLeague) {
    for (final eventId in eventIdsInLeague) {
      if (affectsEvent(eventId)) return true;
    }
    return false;
  }

  /// Get all affected event IDs (updated + added + removed)
  Set<int> get allAffectedEventIds => {
        ...updatedEventIds,
        ...addedEventIds,
        ...removedEventIds,
      };

  /// Get all affected league IDs
  Set<int> get allAffectedLeagueIds => {
        ...updatedLeagueIds,
        ...addedLeagueIds,
        ...removedLeagueIds,
      };

  /// Check if only odds were updated (no structural changes)
  bool get isOddsOnlyUpdate =>
      updatedOddsKeys.isNotEmpty &&
      addedLeagueIds.isEmpty &&
      addedEventIds.isEmpty &&
      removedLeagueIds.isEmpty &&
      removedEventIds.isEmpty &&
      updatedLeagueIds.isEmpty &&
      addedMarketKeys.isEmpty;

  /// Check if there are structural changes (leagues/events added/removed)
  bool get hasStructuralChanges =>
      addedLeagueIds.isNotEmpty ||
      addedEventIds.isNotEmpty ||
      removedLeagueIds.isNotEmpty ||
      removedEventIds.isNotEmpty;

  @override
  String toString() {
    final parts = <String>[];

    if (addedLeagueIds.isNotEmpty) {
      parts.add('leagues+${addedLeagueIds.length}');
    }
    if (updatedLeagueIds.isNotEmpty) {
      parts.add('leagues~${updatedLeagueIds.length}');
    }
    if (removedLeagueIds.isNotEmpty) {
      parts.add('leagues-${removedLeagueIds.length}');
    }
    if (addedEventIds.isNotEmpty) {
      parts.add('events+${addedEventIds.length}');
    }
    if (updatedEventIds.isNotEmpty) {
      parts.add('events~${updatedEventIds.length}');
    }
    if (removedEventIds.isNotEmpty) {
      parts.add('events-${removedEventIds.length}');
    }
    if (updatedMarketKeys.isNotEmpty || addedMarketKeys.isNotEmpty) {
      parts.add('markets=${updatedMarketKeys.length + addedMarketKeys.length}');
    }
    if (updatedOddsKeys.isNotEmpty || addedOddsKeys.isNotEmpty) {
      parts.add('odds=${updatedOddsKeys.length + addedOddsKeys.length}');
    }

    if (parts.isEmpty) {
      return 'DataChangeEvent(empty)';
    }

    return 'DataChangeEvent(${parts.join(", ")})';
  }

  /// Convert to JSON map for debugging/logging
  Map<String, dynamic> toJson() {
    return {
      'updatedLeagueIds': updatedLeagueIds.toList(),
      'updatedEventIds': updatedEventIds.toList(),
      'updatedMarketKeys': updatedMarketKeys.toList(),
      'updatedOddsKeys': updatedOddsKeys.toList(),
      'addedLeagueIds': addedLeagueIds,
      'addedEventIds': addedEventIds,
      'addedMarketKeys': addedMarketKeys,
      'addedOddsKeys': addedOddsKeys,
      'removedLeagueIds': removedLeagueIds,
      'removedEventIds': removedEventIds,
      'timestamp': timestamp.toIso8601String(),
      'batchSize': batchSize,
      'processingTimeMs': processingTime.inMilliseconds,
      'totalChanges': totalChanges,
    };
  }
}
