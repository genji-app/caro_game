import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/features/game/game.dart';

part 'game_filter_provider.freezed.dart';

// ============================================================================
// GameViewMode
// ============================================================================

/// Explicit view mode for the game screen.
///
/// - [lobby] — default state: no query, no category selected → show SDUI lobby
/// - [filter] — active state: query or category selected → show filtered grid
enum GameViewMode { lobby, filter }

// ============================================================================
// GameFilterStatus
// ============================================================================

enum GameFilterStatus {
  /// Initial state before the first search has run.
  initial,

  /// A search is in progress.
  loading,

  /// The last search completed successfully.
  success,

  /// The last search failed with an error.
  failure;

  bool get isInitial => this == GameFilterStatus.initial;
  bool get isLoading => this == GameFilterStatus.loading;
  bool get isSuccess => this == GameFilterStatus.success;
  bool get isFailure => this == GameFilterStatus.failure;
}

// ============================================================================
// GameFilterState
// ============================================================================

/// Unified state for game search, category filtering, pagination, and results.
///
/// [results] contains the already-filtered [GameBlock] list from the repository.
@freezed
sealed class GameFilterState with _$GameFilterState {
  const factory GameFilterState({
    @Default('') String searchQuery,
    @Default(GameCategorySelection()) GameCategorySelection categorySelection,
    @Default([]) List<GameBlock> results,
    @Default(GameFilterStatus.initial) GameFilterStatus status,
  }) = _GameFilterState;
}

// ============================================================================
// GameFilterState extension
// ============================================================================

extension GameFilterStateX on GameFilterState {
  /// Computed view mode — single source of truth for lobby vs filter switching.
  GameViewMode get viewMode => searchQuery.isEmpty && categorySelection.isEmpty
      ? GameViewMode.lobby
      : GameViewMode.filter;
}

// ============================================================================
// GameFilterNotifier
// ============================================================================

/// Manages game search, category filtering, pagination and result state.
///
/// **Single source of truth** for game filtering across all consumers:
/// - [GameFilterView]'s grid (search + category + pagination)
/// - Search dialog/screen's casino tab (text search only)
///
/// Filter execution is delegated to [CaxiloRepository.getGames] which reads
/// from the internal cache — no direct dependency on [allGamesProvider].
///
/// **Usage:**
/// ```dart
/// // Read results (paginated)
/// final state = ref.watch(gameFilterProvider);
/// GameGridView(games: state.paginatedResults, hasMore: state.hasMore);
///
/// // Set query (search dialog passes its own query)
/// ref.read(gameFilterProvider.notifier).setSearchQuery('baccarat');
///
/// // Set category (GameFilterView category selector)
/// ref.read(gameFilterProvider.notifier).setCategorySelection(selection);
/// ```
class GameFilterNotifier extends StateNotifier<GameFilterState>
    with LoggerMixin {
  GameFilterNotifier({required CaxiloRepository repository})
    : _repository = repository,
      super(const GameFilterState()) {
    // Load initial results (empty query, no filter → all games)
    _runSearch();
  }

  final CaxiloRepository _repository;

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 400);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Set search query with debounce; resets pagination.
  void setSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (state.searchQuery == query) return;
      state = state.copyWith(searchQuery: query);
      _runSearch();
    });
  }

  /// Set category selection; resets pagination immediately.
  void setCategorySelection(GameCategorySelection selection) {
    if (state.categorySelection == selection) return;
    state = state.copyWith(categorySelection: selection);
    _runSearch();
    logInfo('Category selection changed: ${selection.label}');
  }

  /// Reset all state (query, category, pagination, results).
  Future<void> reset() async {
    state = const GameFilterState();
    await _runSearch();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _runSearch() async {
    if (state.viewMode == GameViewMode.lobby) return;

    state = state.copyWith(status: GameFilterStatus.loading);
    try {
      final results = await _repository.getGames(
        query: state.searchQuery.isEmpty ? null : state.searchQuery,
        filter: state.categorySelection.toFilter(),
      );
      state = state.copyWith(
        results: results,
        status: GameFilterStatus.success,
      );
    } catch (e) {
      logError('GameFilterNotifier: search failed: $e');
      state = state.copyWith(results: [], status: GameFilterStatus.failure);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// ============================================================================
// Provider
// ============================================================================

/// **GameFilterView provider** — full-featured: query + category selection + pagination.
///
/// Lifecycle: created when `GameFilterView` mounts, disposed when it unmounts
/// (`.autoDispose`). Shared only within the game tab widget subtree.
///
/// ⚠️ Do NOT use this from `SearchBody` or the search dialog — it would
/// contaminate `GameFilterView`'s state if both are visible simultaneously (desktop).
/// Use [casinoSearchByQueryProvider] instead for the search context.
final gameFilterProvider =
    StateNotifierProvider.autoDispose<GameFilterNotifier, GameFilterState>((
      ref,
    ) {
      return GameFilterNotifier(repository: ref.read(caxiloRepositoryProvider));
    });
