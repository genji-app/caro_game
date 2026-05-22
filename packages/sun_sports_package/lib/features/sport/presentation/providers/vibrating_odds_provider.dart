import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for vibrating odds.
///
/// Tracks which selections are currently in "Kèo Rung" (vibrating) state.
/// Uses reverse indexes for O(1) league/event lookups.
class VibratingOddsState {
  /// Set of selectionIds currently vibrating
  final Set<String> activeSelections;

  /// Map from selectionId to leagueId for league-level tracking
  final Map<String, int> selectionLeagueMap;

  /// Map from selectionId to eventId for event-level tracking
  final Map<String, int> selectionEventMap;

  /// Reverse index: leagueId → set of vibrating selectionIds
  final Map<int, Set<String>> leagueSelectionsMap;

  /// Reverse index: eventId → set of vibrating selectionIds
  final Map<int, Set<String>> eventSelectionsMap;

  const VibratingOddsState({
    this.activeSelections = const {},
    this.selectionLeagueMap = const {},
    this.selectionEventMap = const {},
    this.leagueSelectionsMap = const {},
    this.eventSelectionsMap = const {},
  });

  /// Check if a selection is currently vibrating
  bool isVibrating(String selectionId) {
    return activeSelections.contains(selectionId);
  }

  /// Check if a league has any vibrating selections — O(1)
  bool hasVibratingInLeague(int leagueId) {
    return leagueSelectionsMap[leagueId]?.isNotEmpty ?? false;
  }

  VibratingOddsState copyWith({
    Set<String>? activeSelections,
    Map<String, int>? selectionLeagueMap,
    Map<String, int>? selectionEventMap,
    Map<int, Set<String>>? leagueSelectionsMap,
    Map<int, Set<String>>? eventSelectionsMap,
  }) {
    return VibratingOddsState(
      activeSelections: activeSelections ?? this.activeSelections,
      selectionLeagueMap: selectionLeagueMap ?? this.selectionLeagueMap,
      selectionEventMap: selectionEventMap ?? this.selectionEventMap,
      leagueSelectionsMap: leagueSelectionsMap ?? this.leagueSelectionsMap,
      eventSelectionsMap: eventSelectionsMap ?? this.eventSelectionsMap,
    );
  }
}

/// Notifier to manage vibrating odds state.
///
/// Vibrating odds are triggered when odds reach "dangerous" levels
/// for live football Over/Under markets.
class VibratingOddsNotifier extends StateNotifier<VibratingOddsState> {
  VibratingOddsNotifier() : super(const VibratingOddsState());

  /// Add selection to vibrating state.
  ///
  /// Updates mapping even if selection already active (Bug #5 fix).
  /// Only skips if already active AND mapping unchanged.
  void setVibrating(String selectionId, {int leagueId = 0, int eventId = 0}) {
    final alreadyActive = state.activeSelections.contains(selectionId);

    // Skip if already active AND mapping unchanged
    if (alreadyActive &&
        state.selectionLeagueMap[selectionId] == leagueId &&
        state.selectionEventMap[selectionId] == eventId) {
      return;
    }

    // Update league reverse index
    final newLeagueSelectionsMap = _copyIndex(state.leagueSelectionsMap);
    final oldLeagueId = state.selectionLeagueMap[selectionId];
    if (oldLeagueId != null && oldLeagueId != leagueId) {
      _removeFromIndex(newLeagueSelectionsMap, oldLeagueId, selectionId);
    }
    _addToIndex(newLeagueSelectionsMap, leagueId, selectionId);

    // Update event reverse index
    final newEventSelectionsMap = _copyIndex(state.eventSelectionsMap);
    final oldEventId = state.selectionEventMap[selectionId];
    if (oldEventId != null && oldEventId != eventId) {
      _removeFromIndex(newEventSelectionsMap, oldEventId, selectionId);
    }
    _addToIndex(newEventSelectionsMap, eventId, selectionId);

    state = state.copyWith(
      activeSelections: alreadyActive
          ? state.activeSelections
          : {...state.activeSelections, selectionId},
      selectionLeagueMap: {...state.selectionLeagueMap, selectionId: leagueId},
      selectionEventMap: {...state.selectionEventMap, selectionId: eventId},
      leagueSelectionsMap: newLeagueSelectionsMap,
      eventSelectionsMap: newEventSelectionsMap,
    );
  }

  /// Remove selection from vibrating state.
  ///
  /// Called when:
  /// - Odds no longer meet the threshold
  /// - Odds are suspended
  void removeVibrating(String selectionId) {
    if (!state.activeSelections.contains(selectionId)) return;

    final leagueId = state.selectionLeagueMap[selectionId];
    final eventId = state.selectionEventMap[selectionId];

    final updatedSelections = Set<String>.from(state.activeSelections)
      ..remove(selectionId);
    final updatedLeagueMap = Map<String, int>.from(state.selectionLeagueMap)
      ..remove(selectionId);
    final updatedEventMap = Map<String, int>.from(state.selectionEventMap)
      ..remove(selectionId);

    final updatedLeagueSelections = _copyIndex(state.leagueSelectionsMap);
    if (leagueId != null) {
      _removeFromIndex(updatedLeagueSelections, leagueId, selectionId);
    }

    final updatedEventSelections = _copyIndex(state.eventSelectionsMap);
    if (eventId != null) {
      _removeFromIndex(updatedEventSelections, eventId, selectionId);
    }

    state = state.copyWith(
      activeSelections: updatedSelections,
      selectionLeagueMap: updatedLeagueMap,
      selectionEventMap: updatedEventMap,
      leagueSelectionsMap: updatedLeagueSelections,
      eventSelectionsMap: updatedEventSelections,
    );
  }

  /// Remove all vibrating selections for a given eventId.
  ///
  /// Called when:
  /// - Event removed (event_rm)
  /// - Score changes (line may no longer match)
  /// - O/U market suspended
  void removeVibratingByEvent(int eventId) {
    final affected = state.eventSelectionsMap[eventId]; // O(1) lookup
    if (affected == null || affected.isEmpty) return;

    final updatedSelections = Set<String>.from(state.activeSelections);
    final updatedLeagueMap = Map<String, int>.from(state.selectionLeagueMap);
    final updatedEventMap = Map<String, int>.from(state.selectionEventMap);
    final updatedLeagueSelections = _copyIndex(state.leagueSelectionsMap);

    for (final selId in affected) {
      updatedSelections.remove(selId);
      final leagueId = updatedLeagueMap.remove(selId);
      updatedEventMap.remove(selId);
      if (leagueId != null) {
        _removeFromIndex(updatedLeagueSelections, leagueId, selId);
      }
    }

    final updatedEventSelections = _copyIndex(state.eventSelectionsMap)
      ..remove(eventId);

    state = state.copyWith(
      activeSelections: updatedSelections,
      selectionLeagueMap: updatedLeagueMap,
      selectionEventMap: updatedEventMap,
      leagueSelectionsMap: updatedLeagueSelections,
      eventSelectionsMap: updatedEventSelections,
    );
  }

  /// Clear all vibrating state.
  ///
  /// Called when:
  /// - User changes sport
  /// - User changes tab (Live → Prematch)
  void clearAll() {
    if (state.activeSelections.isEmpty) return;
    state = const VibratingOddsState();
  }

  // ── Index helpers ──

  static Map<int, Set<String>> _copyIndex(Map<int, Set<String>> src) =>
      src.map((k, v) => MapEntry(k, Set<String>.from(v)));

  static void _addToIndex(Map<int, Set<String>> map, int key, String value) {
    (map[key] ??= <String>{}).add(value);
  }

  static void _removeFromIndex(
    Map<int, Set<String>> map,
    int key,
    String value,
  ) {
    map[key]?.remove(value);
    if (map[key]?.isEmpty == true) map.remove(key);
  }
}

/// Main provider for vibrating odds state
final vibratingOddsProvider =
    StateNotifierProvider<VibratingOddsNotifier, VibratingOddsState>(
      (ref) => VibratingOddsNotifier(),
    );

/// Selector provider for a single selection.
///
/// Optimized to only rebuild when this specific selection's vibrating state changes.
/// Uses .select() to avoid rebuilding when other selections change.
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final isVibratingProvider = Provider.autoDispose.family<bool, String>((
  ref,
  selectionId,
) {
  return ref.watch(
    vibratingOddsProvider.select((state) => state.isVibrating(selectionId)),
  );
});

/// Selector provider for league-level vibrating state.
///
/// Returns true if any selection in the league is currently vibrating.
/// Uses .select() to only rebuild when this league's vibrating state changes.
/// O(1) lookup via leagueSelectionsMap reverse index.
final hasVibratingInLeagueProvider = Provider.autoDispose.family<bool, int>((
  ref,
  leagueId,
) {
  return ref.watch(
    vibratingOddsProvider.select(
      (state) => state.hasVibratingInLeague(leagueId),
    ),
  );
});
