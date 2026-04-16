import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import '../models/favorite_data.dart';
import '../network/sb_http_manager.dart';
import 'league_provider.dart';
import 'reconnect_aware.dart';
import 'reconnect_coordinator.dart';

// ============================================================================
// FAVORITE STATE
// ============================================================================

/// Favorite state
class FavoriteState {
  final Map<int, FavoriteData> favoritesBySport; // sportId -> FavoriteData
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  /// Cached favorite events leagues per sport (from GET /api/app/favorite/events).
  /// Used by Favorites tab only; invalidated on add/remove favorite.
  final Map<int, List<LeagueModelV2>> favoriteEventsLeaguesBySport;
  final Map<int, bool> favoriteEventsLoadingBySport;
  final Map<int, String?> favoriteEventsErrorBySport;

  const FavoriteState({
    this.favoritesBySport = const {},
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.favoriteEventsLeaguesBySport = const {},
    this.favoriteEventsLoadingBySport = const {},
    this.favoriteEventsErrorBySport = const {},
  });

  /// Get favorite data for a sport
  FavoriteData? getFavoriteData(int sportId) => favoritesBySport[sportId];

  /// Get favorite events leagues for a sport (Favorites tab).
  /// Null if not yet loaded; empty list if loaded and no favorites.
  List<LeagueModelV2>? getFavoriteEventsLeagues(int sportId) =>
      favoriteEventsLeaguesBySport[sportId];

  /// Whether favorite events are currently loading for a sport
  bool isFavoriteEventsLoading(int sportId) =>
      favoriteEventsLoadingBySport[sportId] == true;

  /// Get favorite events error for a sport
  String? getFavoriteEventsError(int sportId) =>
      favoriteEventsErrorBySport[sportId];

  /// Check if league is favorite
  bool isLeagueFavorite(int sportId, int leagueId) {
    final data = getFavoriteData(sportId);
    return data?.isLeagueFavorite(leagueId) ?? false;
  }

  /// Check if event is favorite
  bool isEventFavorite(int sportId, int eventId) {
    final data = getFavoriteData(sportId);
    return data?.isEventFavorite(eventId) ?? false;
  }

  FavoriteState copyWith({
    Map<int, FavoriteData>? favoritesBySport,
    bool? isLoading,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
    Map<int, List<LeagueModelV2>>? favoriteEventsLeaguesBySport,
    Map<int, bool>? favoriteEventsLoadingBySport,
    Map<int, String?>? favoriteEventsErrorBySport,
  }) {
    return FavoriteState(
      favoritesBySport: favoritesBySport ?? this.favoritesBySport,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      favoriteEventsLeaguesBySport:
          favoriteEventsLeaguesBySport ?? this.favoriteEventsLeaguesBySport,
      favoriteEventsLoadingBySport:
          favoriteEventsLoadingBySport ?? this.favoriteEventsLoadingBySport,
      favoriteEventsErrorBySport:
          favoriteEventsErrorBySport ?? this.favoriteEventsErrorBySport,
    );
  }
}

// ============================================================================
// FAVORITE NOTIFIER
// ============================================================================

/// Favorite provider. Type explicit to break self-reference in reconnect callback.
final StateNotifierProvider<FavoriteNotifier, FavoriteState> favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
      final notifier = FavoriteNotifier(ref);
      final coordinator = ref.read(reconnectCoordinatorProvider);
      final reconnectCb = () =>
          ref.read(favoriteProvider.notifier).refreshOnReconnect();
      coordinator.register(reconnectCb);
      ref.onDispose(() => coordinator.unregister(reconnectCb));
      return notifier;
    });

class FavoriteNotifier extends StateNotifier<FavoriteState>
    implements ReconnectAware {
  final Ref _ref;
  final SbHttpManager _httpManager;
  Timer? _refreshTimer;
  CancelToken? _cancelToken;
  CancelToken? _favoriteEventsCancelToken;

  FavoriteNotifier(this._ref)
    : _httpManager = SbHttpManager.instance,
      super(const FavoriteState());

  @override
  void dispose() {
    _cancelToken?.cancel();
    _favoriteEventsCancelToken?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void refreshOnReconnect() {
    final sportId = _ref.read(leagueProvider).currentSportId;
    fetchFavoriteEvents(sportId);
  }

  /// Invalidate cached favorite events for a sport (call after add/remove favorite).
  void invalidateFavoriteEventsCache(int sportId) {
    final updated = Map<int, List<LeagueModelV2>>.from(
      state.favoriteEventsLeaguesBySport,
    )..remove(sportId);
    final updatedError = Map<int, String?>.from(
      state.favoriteEventsErrorBySport,
    )..remove(sportId);
    state = state.copyWith(
      favoriteEventsLeaguesBySport: updated,
      favoriteEventsErrorBySport: updatedError,
    );
  }

  /// Fetch favorite events (List<LeagueModelV2>) for Favorites tab.
  /// Combines:
  /// 1. GET /api/app/favorite/events (no leagueIds)
  /// 2. GET /api/app/events with sportId, leagueIds from getFavorites, timeRange=4;
  ///    then set isFavorited=true on league and events. Result = (1) + (2).
  Future<bool> fetchFavoriteEvents(
    int sportId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.favoriteEventsLeaguesBySport.containsKey(sportId)) {
      return true; // Use cache
    }

    _favoriteEventsCancelToken?.cancel();
    _favoriteEventsCancelToken = CancelToken();

    final loadingBySport = Map<int, bool>.from(
      state.favoriteEventsLoadingBySport,
    );
    loadingBySport[sportId] = true;
    final errorBySport = Map<int, String?>.from(
      state.favoriteEventsErrorBySport,
    );
    errorBySport.remove(sportId);
    state = state.copyWith(
      favoriteEventsLoadingBySport: loadingBySport,
      favoriteEventsErrorBySport: errorBySport,
    );

    try {
      // Ensure we have FavoriteData (leagueIds) – fetch if missing
      var favoriteData = state.getFavoriteData(sportId);
      if (favoriteData == null) {
        await fetchFavorites(sportId);
        favoriteData = state.getFavoriteData(sportId);
      }
      final leagueIds = favoriteData?.leagueIds ?? [];

      // 1. GET /api/app/favorite/events (no leagueIds)
      final favoriteLeagues = await _httpManager.getFavoriteEvents(
        sportId,
        cancelToken: _favoriteEventsCancelToken!,
      );

      // 2. GET /api/app/events with sportId, leagueIds from getFavorites, timeRange=4
      List<LeagueModelV2> eventsApiLeagues = [];
      if (leagueIds.isNotEmpty) {
        final request = EventsRequestModel(
          sportId: sportId,
          timeRange: 4,
          leagueIds: leagueIds,
          sortByTime: false,
        );
        eventsApiLeagues = await _httpManager.getEventsV2(
          request,
          cancelToken: _favoriteEventsCancelToken!,
        );
        // Set isFavorited = true on league and every event
        eventsApiLeagues = eventsApiLeagues
            .map(
              (l) => l.copyWith(
                isFavorited: true,
                events: l.events
                    .map((e) => e.copyWith(isFavorited: true))
                    .toList(),
              ),
            )
            .toList();
      }

      // Result = favorite/events + api/app/events (with isFavorited true)
      final combined = [...favoriteLeagues, ...eventsApiLeagues];

      final leaguesBySport = Map<int, List<LeagueModelV2>>.from(
        state.favoriteEventsLeaguesBySport,
      );
      leaguesBySport[sportId] = combined;
      final loadingBySportAfter = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySportAfter[sportId] = false;
      state = state.copyWith(
        favoriteEventsLeaguesBySport: leaguesBySport,
        favoriteEventsLoadingBySport: loadingBySportAfter,
      );
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return false;
      final loadingBySportAfter = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySportAfter[sportId] = false;
      final errorBySportAfter = Map<int, String?>.from(
        state.favoriteEventsErrorBySport,
      );
      errorBySportAfter[sportId] = 'Failed to load favorites: ${e.message}';
      state = state.copyWith(
        favoriteEventsLoadingBySport: loadingBySportAfter,
        favoriteEventsErrorBySport: errorBySportAfter,
      );
      return false;
    } catch (e) {
      final loadingBySportAfter = Map<int, bool>.from(
        state.favoriteEventsLoadingBySport,
      );
      loadingBySportAfter[sportId] = false;
      final errorBySportAfter = Map<int, String?>.from(
        state.favoriteEventsErrorBySport,
      );
      errorBySportAfter[sportId] = 'An error occurred: $e';
      state = state.copyWith(
        favoriteEventsLoadingBySport: loadingBySportAfter,
        favoriteEventsErrorBySport: errorBySportAfter,
      );
      return false;
    }
  }

  /// Fetch favorites for a sport
  ///
  /// [forceRefresh]: If true, fetch even if data exists in cache
  /// Returns true if data was fetched, false if using cache
  Future<bool> fetchFavorites(int sportId, {bool forceRefresh = false}) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh && state.favoritesBySport.containsKey(sportId)) {
      // Check if cache is fresh (less than 5 minutes old)
      if (state.lastUpdated != null) {
        final age = DateTime.now().difference(state.lastUpdated!);
        if (age.inMinutes < 5) {
          // Use cache
          return false;
        }
      }
    }

    // Cancel previous request
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final favoriteData = await _httpManager.getFavorites(
        sportId,
        cancelToken: _cancelToken!,
      );

      final updatedFavorites = Map<int, FavoriteData>.from(
        state.favoritesBySport,
      );
      updatedFavorites[sportId] = favoriteData;

      state = state.copyWith(
        favoritesBySport: updatedFavorites,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      return true; // Data was fetched
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load favorites: ${e.message}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred: $e');
      return false;
    }
  }

  /// Refresh favorites (pull-to-refresh)
  Future<void> refresh(int sportId) async {
    await fetchFavorites(sportId, forceRefresh: true);
  }

  /// Add league to favorites, then refresh favorite list
  Future<bool> addFavoriteLeague({
    required int sportId,
    required int leagueId,
  }) async {
    try {
      await _httpManager.addFavoriteLeague(
        sportId: sportId,
        leagueId: leagueId,
      );
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to add favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  /// Remove league from favorites, then refresh favorite list
  Future<bool> removeFavoriteLeague({
    required int sportId,
    required int leagueId,
  }) async {
    try {
      await _httpManager.removeFavoriteLeague(
        sportId: sportId,
        leagueId: leagueId,
      );
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to remove favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  /// Add event to favorites, then refresh favorite list
  Future<bool> addFavoriteEvent({
    required int sportId,
    required int eventId,
  }) async {
    try {
      await _httpManager.addFavoriteEvent(sportId: sportId, eventId: eventId);
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to add favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  /// Remove event from favorites, then refresh favorite list
  Future<bool> removeFavoriteEvent({
    required int sportId,
    required int eventId,
  }) async {
    try {
      await _httpManager.removeFavoriteEvent(
        sportId: sportId,
        eventId: eventId,
      );
      await fetchFavorites(sportId, forceRefresh: true);
      invalidateFavoriteEventsCache(sportId);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: 'Failed to remove favorite: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'An error occurred: $e');
      return false;
    }
  }

  /// Start auto-refresh (only when on favorites tab)
  void startAutoRefresh(int sportId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      fetchFavorites(sportId);
    });
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }
}
