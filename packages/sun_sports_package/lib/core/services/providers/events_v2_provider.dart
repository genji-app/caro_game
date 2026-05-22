import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/events_v2_remote_datasource.dart';
import '../models/api_v2/event_model_v2.dart';
import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import '../models/api_v2/sport_constants.dart';
import '../models/api_v2/v2_to_legacy_adapter.dart';
import '../models/league_model.dart';
import '../repositories/events_v2_repository.dart';
import '../utils/favorite_applier.dart';
import 'events_v2_filter_provider.dart';
import 'favorite_provider.dart';
import 'reconnect_aware.dart';
import 'reconnect_coordinator.dart';

// ============================================================================
// EVENTS V2 STATE
// ============================================================================

/// State for events V2 data
class EventsV2State {
  final List<LeagueModelV2> leagues;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;

  const EventsV2State({
    this.leagues = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  /// Initial state
  factory EventsV2State.initial() => const EventsV2State();

  /// Loading state
  factory EventsV2State.loading() => const EventsV2State(isLoading: true);

  /// Loaded state with data
  factory EventsV2State.loaded(List<LeagueModelV2> leagues) => EventsV2State(
    leagues: leagues,
    isLoading: false,
    lastUpdated: DateTime.now(),
  );

  /// Error state
  factory EventsV2State.error(String message) =>
      EventsV2State(isLoading: false, error: message);

  /// Check if data is loaded
  bool get isLoaded => !isLoading && error == null && leagues.isNotEmpty;

  /// Check if empty (loaded but no data)
  bool get isEmpty => !isLoading && error == null && leagues.isEmpty;

  /// Get total event count
  int get totalEvents =>
      leagues.fold(0, (sum, league) => sum + league.eventCount);

  /// Get all events across all leagues
  List<EventModelV2> get allEvents =>
      leagues.expand((league) => league.events).toList();

  /// Get all live events across all leagues
  List<EventModelV2> get allLiveEvents =>
      leagues.expand((league) => league.liveEvents).toList();

  /// Get all upcoming events
  List<EventModelV2> get allUpcomingEvents =>
      leagues.expand((league) => league.upcomingEvents).toList();

  EventsV2State copyWith({
    List<LeagueModelV2>? leagues,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return EventsV2State(
      leagues: leagues ?? this.leagues,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'EventsV2State(leagues: ${leagues.length}, isLoading: $isLoading, error: $error)';
}

// ============================================================================
// EVENTS V2 NOTIFIER
// ============================================================================

/// Events V2 state notifier
///
/// Manages events data with:
/// - Auto-fetch on creation
/// - CancelToken for preventing race conditions
/// - Auto-refresh with configurable interval
class EventsV2Notifier extends StateNotifier<EventsV2State>
    implements ReconnectAware {
  final EventsV2Repository _repository;
  final EventFilterV2 _filter;

  CancelToken? _cancelToken;
  Timer? _refreshTimer;

  /// Auto refresh intervals
  static const _liveRefreshInterval = Duration(seconds: 10);
  static const _todayRefreshInterval = Duration(seconds: 30);
  static const _earlyRefreshInterval = Duration(seconds: 60);

  EventsV2Notifier(this._repository, this._filter)
    : super(EventsV2State.initial()) {
    fetchEvents();
  }

  @override
  void refreshOnReconnect() {
    fetchEvents();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Disposed');
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Get refresh interval based on current filter
  Duration get _refreshInterval {
    switch (_filter.timeRange) {
      case EventTimeRange.live:
        return _liveRefreshInterval;
      case EventTimeRange.today:
        return _todayRefreshInterval;
      case EventTimeRange.early:
      case EventTimeRange.todayAndEarly:
        return _earlyRefreshInterval;
    }
  }

  /// Fetch events based on current filter
  Future<void> fetchEvents() async {
    // Cancel previous request
    _cancelToken?.cancel('New request');
    _cancelToken = CancelToken();

    // Cancel previous timer
    _refreshTimer?.cancel();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = EventsRequestModel(
        sportId: _filter.sportId,
        timeRange: _filter.timeRangeValue,
        sportTypeId: _filter.sportTypeId,
        sortByTime: false,
      );

      final leagues = await _repository.getEventsWithCancel(
        request,
        _cancelToken!,
      );

      if (mounted) {
        state = EventsV2State.loaded(leagues);
        _startAutoRefresh();
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // Ignore cancelled requests
        return;
      }
      if (mounted) {
        state = EventsV2State.error('Failed to load events: ${e.message}');
      }
    } on CancelledException {
      // Ignore cancelled requests
      return;
    } catch (e) {
      if (mounted) {
        state = EventsV2State.error('An error occurred: $e');
      }
    }
  }

  /// Refresh events (pull-to-refresh)
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);

    try {
      await fetchEvents();
    } finally {
      if (mounted) {
        state = state.copyWith(isRefreshing: false);
      }
    }
  }

  /// Start auto-refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted) {
        _silentRefresh();
      }
    });

    if (kDebugMode) {
      debugPrint(
        '[EventsV2] Auto-refresh started: ${_refreshInterval.inSeconds}s interval',
      );
    }
  }

  /// Silent refresh without loading state
  Future<void> _silentRefresh() async {
    try {
      final request = EventsRequestModel(
        sportId: _filter.sportId,
        timeRange: _filter.timeRangeValue,
        sportTypeId: _filter.sportTypeId,
        sortByTime: false,
      );

      final leagues = await _repository.getEvents(request);

      if (mounted) {
        state = EventsV2State.loaded(leagues);
      }
    } catch (e) {
      // Ignore errors in silent refresh
      if (kDebugMode) {
        debugPrint('[EventsV2] Silent refresh failed: $e');
      }
    }
  }

  /// Stop auto-refresh (call when leaving screen)
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Resume auto-refresh (call when returning to screen)
  void resumeAutoRefresh() {
    if (_refreshTimer == null && state.isLoaded) {
      _startAutoRefresh();
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Main events V2 provider - automatically reacts to filter changes.
/// Type explicit to break self-reference in reconnect callback.
final AutoDisposeStateNotifierProvider<EventsV2Notifier, EventsV2State>
eventsV2Provider =
    StateNotifierProvider.autoDispose<EventsV2Notifier, EventsV2State>((ref) {
      final repository = ref.watch(eventsV2RepositoryProvider);
      final filter = ref.watch(eventFilterV2Provider);

      final notifier = EventsV2Notifier(repository, filter);

      final coordinator = ref.read(reconnectCoordinatorProvider);
      final reconnectCb = () =>
          ref.read(eventsV2Provider.notifier).refreshOnReconnect();
      coordinator.register(reconnectCb);

      ref.onDispose(() {
        coordinator.unregister(reconnectCb);
        notifier.stopAutoRefresh();
      });

      return notifier;
    });

// ============================================================================
// TAB-SPECIFIC PROVIDERS
// ============================================================================

/// Tab-specific events notifier
class TabEventsV2Notifier extends StateNotifier<EventsV2State> {
  final EventsV2Repository _repository;
  final int sportId;
  final EventTimeRange timeRange;
  final int? sportTypeId;
  final Duration refreshInterval;

  CancelToken? _cancelToken;
  Timer? _refreshTimer;

  TabEventsV2Notifier({
    required EventsV2Repository repository,
    required this.sportId,
    required this.timeRange,
    required this.refreshInterval,
    this.sportTypeId,
  }) : _repository = repository,
       super(EventsV2State.initial()) {
    fetchEvents();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Disposed');
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    _cancelToken?.cancel('New request');
    _cancelToken = CancelToken();
    _refreshTimer?.cancel();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: timeRange.value,
        sportTypeId: sportTypeId,
        sortByTime: false,
      );

      final leagues = await _repository.getEventsWithCancel(
        request,
        _cancelToken!,
      );

      if (mounted) {
        state = EventsV2State.loaded(leagues);
        _startAutoRefresh();
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel && mounted) {
        state = EventsV2State.error('Failed to load: ${e.message}');
      }
    } on CancelledException {
      // Ignore
    } catch (e) {
      if (mounted) {
        state = EventsV2State.error('Error: $e');
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (_) {
      if (mounted) _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    try {
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: timeRange.value,
        sportTypeId: sportTypeId,
        sortByTime: false,
      );

      final leagues = await _repository.getEvents(request);
      if (mounted) {
        state = EventsV2State.loaded(leagues);
      }
    } catch (_) {}
  }

  Future<void> refresh() => fetchEvents();
}

/// Live events V2 provider (10s refresh)
final liveEventsV2Provider =
    StateNotifierProvider.autoDispose<TabEventsV2Notifier, EventsV2State>((
      ref,
    ) {
      final repository = ref.watch(eventsV2RepositoryProvider);
      final sport = ref.watch(selectedSportV2Provider);
      final boxingType = ref.watch(selectedBoxingTypeV2Provider);

      return TabEventsV2Notifier(
        repository: repository,
        sportId: sport.id,
        timeRange: EventTimeRange.live,
        sportTypeId: sport == SportType.boxing ? boxingType?.id : null,
        refreshInterval: const Duration(seconds: 10),
      );
    });

/// Today events V2 provider (30s refresh)
final todayEventsV2Provider =
    StateNotifierProvider.autoDispose<TabEventsV2Notifier, EventsV2State>((
      ref,
    ) {
      final repository = ref.watch(eventsV2RepositoryProvider);
      final sport = ref.watch(selectedSportV2Provider);
      final boxingType = ref.watch(selectedBoxingTypeV2Provider);

      return TabEventsV2Notifier(
        repository: repository,
        sportId: sport.id,
        timeRange: EventTimeRange.today,
        sportTypeId: sport == SportType.boxing ? boxingType?.id : null,
        refreshInterval: const Duration(seconds: 30),
      );
    });

/// Early events V2 provider (60s refresh)
final earlyEventsV2Provider =
    StateNotifierProvider.autoDispose<TabEventsV2Notifier, EventsV2State>((
      ref,
    ) {
      final repository = ref.watch(eventsV2RepositoryProvider);
      final sport = ref.watch(selectedSportV2Provider);
      final boxingType = ref.watch(selectedBoxingTypeV2Provider);

      return TabEventsV2Notifier(
        repository: repository,
        sportId: sport.id,
        timeRange: EventTimeRange.early,
        sportTypeId: sport == SportType.boxing ? boxingType?.id : null,
        refreshInterval: const Duration(seconds: 60),
      );
    });

// ============================================================================
// DERIVED PROVIDERS
// ============================================================================

/// Provider for live event count (for badge)
final liveEventCountV2Provider = Provider.autoDispose<int>((ref) {
  final events = ref.watch(eventsV2Provider);
  return events.allLiveEvents.length;
});

/// Provider to get leagues for current filter (with favorites applied)
final leaguesV2Provider = Provider.autoDispose<List<LeagueModelV2>>((ref) {
  final events = ref.watch(eventsV2Provider);
  final leagues = events.leagues;

  // Get favorite data for current sport
  final sportId = ref.watch(selectedSportV2Provider).id;
  final favoriteData = ref.watch(
    favoriteProvider.select((s) => s.getFavoriteData(sportId)),
  );

  // Trigger pre-fetch if favorite data is not available
  if (favoriteData == null) {
    // Pre-fetch favorites in background (non-blocking)
    Future.microtask(() {
      ref.read(favoriteProvider.notifier).fetchFavorites(sportId);
    });
  }

  // Apply favorites to leagues
  final result = FavoriteApplier.applyFavorites(leagues, favoriteData);

  // Debug: Verify favorites are applied correctly
  if (favoriteData != null && favoriteData.leagueIds.isNotEmpty) {
    final favoriteLeagues = result.where((l) => l.isFavorited).toList();
    final favoriteEvents = result
        .expand((l) => l.events)
        .where((e) => e.isFavorited)
        .toList();
    debugPrint(
      '[leaguesV2Provider] Applied favorites: '
      '${favoriteLeagues.length} leagues, ${favoriteEvents.length} events',
    );
  }

  return result;
});

/// Provider to get total events count
final totalEventsCountV2Provider = Provider.autoDispose<int>((ref) {
  final events = ref.watch(eventsV2Provider);
  return events.totalEvents;
});

/// Provider for loading state
final eventsV2LoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(eventsV2Provider).isLoading;
});

/// Provider for error state
final eventsV2ErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(eventsV2Provider).error;
});

// ============================================================================
// LEGACY COMPATIBILITY PROVIDERS
// ============================================================================

/// Provider that returns leagues in legacy LeagueData format
///
/// Use this for existing widgets that expect LeagueData.
/// Converts LeagueModelV2 -> LeagueData automatically.
final leaguesLegacyProvider = Provider.autoDispose<List<LeagueData>>((ref) {
  final leagues = ref.watch(leaguesV2Provider);
  return leagues.toLegacy();
});

/// Provider for live events in legacy format
final liveEventsLegacyProvider = Provider.autoDispose<List<LeagueData>>((ref) {
  final state = ref.watch(liveEventsV2Provider);
  return state.leagues.toLegacy();
});

/// Provider for today events in legacy format
final todayEventsLegacyProvider = Provider.autoDispose<List<LeagueData>>((ref) {
  final state = ref.watch(todayEventsV2Provider);
  return state.leagues.toLegacy();
});

/// Provider for early events in legacy format
final earlyEventsLegacyProvider = Provider.autoDispose<List<LeagueData>>((ref) {
  final state = ref.watch(earlyEventsV2Provider);
  return state.leagues.toLegacy();
});
