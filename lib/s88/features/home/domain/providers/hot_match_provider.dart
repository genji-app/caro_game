import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/reconnect_aware.dart';
import 'package:co_caro_flame/s88/core/services/providers/reconnect_coordinator.dart';
import 'package:co_caro_flame/s88/core/services/websocket/sb_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_manager.dart';
import 'package:co_caro_flame/s88/features/home/data/datasources/hot_match_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/home/data/repositories/hot_match_repository_impl.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/score_model_v2.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/repositories/hot_match_repository.dart';
import 'package:co_caro_flame/s88/features/home/domain/usecases/fetch_hot_matches_usecase.dart';
import 'package:co_caro_flame/s88/features/home/domain/usecases/stream_hot_match_statistics_usecase.dart';
import 'package:co_caro_flame/s88/features/home/domain/usecases/subscribe_match_updates_usecase.dart';

// ===== DATA LAYER PROVIDERS =====

/// Remote Data Source Provider
final hotMatchRemoteDataSourceProvider = Provider<HotMatchRemoteDataSource>((
  ref,
) {
  final httpManager = ref.read(sbHttpManagerProvider);
  return HotMatchRemoteDataSourceImpl(httpManager);
});

/// WebSocket Provider
final sbWebSocketProvider = Provider<SbWebSocket>((ref) {
  return WebSocketManager.instance.sportbook;
});

/// Repository Provider
final hotMatchRepositoryProvider = Provider<HotMatchRepository>((ref) {
  final remoteDataSource = ref.read(hotMatchRemoteDataSourceProvider);
  final websocket = ref.read(sbWebSocketProvider);
  return HotMatchRepositoryImpl(remoteDataSource, websocket);
});

// ===== USE CASE PROVIDERS =====

/// Fetch Hot Matches Use Case Provider
final fetchHotMatchesUseCaseProvider = Provider<FetchHotMatchesUseCase>((ref) {
  final repository = ref.read(hotMatchRepositoryProvider);
  return FetchHotMatchesUseCase(repository);
});

/// Subscribe Match Updates Use Case Provider
final subscribeMatchUpdatesUseCaseProvider =
    Provider<SubscribeMatchUpdatesUseCase>((ref) {
      final repository = ref.read(hotMatchRepositoryProvider);
      return SubscribeMatchUpdatesUseCase(repository);
    });

/// Stream Hot Match Statistics Use Case Provider
final streamHotMatchStatisticsUseCaseProvider =
    Provider<StreamHotMatchStatisticsUseCase>((ref) {
      final repository = ref.read(hotMatchRepositoryProvider);
      return StreamHotMatchStatisticsUseCase(repository);
    });

// ===== STATE NOTIFIER =====

/// Hot Match Notifier
///
/// Manages hot match state using Clean Architecture.
/// Uses use cases for business logic instead of direct repository access.
///
/// ## Statistics Loading Strategy (Semaphore + Progressive Stream)
///
/// Sau khi [getHotMatches] trả về, toàn bộ matches được schedule **đồng thời**
/// thông qua [StreamHotMatchStatisticsUseCase]. Mỗi match gọi song song cả hai
/// API (/simple + /users) với semaphore giới hạn maxConcurrent connections.
///
/// Kết quả được emit ngay khi từng match hoàn thành → state.eventStatistics
/// được cập nhật progressive → UI hiển thị thông tin cược **từng item một**
/// khi data về, không phải chờ cả batch.
///
/// Khi user scroll nhanh sang item chưa load xong:
///   - `state.pendingStatisticsIds.contains(eventId)` = true → UI hiển thị shimmer.
///   - Khi stream emit kết quả cho eventId đó, shimmer tự biến mất.
class HotMatchNotifier extends StateNotifier<HotMatchState>
    implements ReconnectAware {
  final FetchHotMatchesUseCase _fetchHotMatchesUseCase;
  final StreamHotMatchStatisticsUseCase _streamHotMatchStatisticsUseCase;
  final SubscribeMatchUpdatesUseCase _subscribeMatchUpdatesUseCase;

  /// WebSocket subscriptions
  StreamSubscription<OddsUpdateEvent>? _oddsSubscription;
  StreamSubscription<ScoreUpdateEvent>? _scoreSubscription;

  /// Statistics stream subscription — cancel khi fetch mới bắt đầu.
  StreamSubscription<MapEntry<int, HotMatchEventStatistics>>?
  _statisticsStreamSub;

  /// Auto refresh timer
  Timer? _refreshTimer;

  /// Current sport ID
  int _currentSportId = 1;

  HotMatchNotifier(
    this._fetchHotMatchesUseCase,
    this._streamHotMatchStatisticsUseCase,
    this._subscribeMatchUpdatesUseCase,
  ) : super(const HotMatchState());

  /// Dữ liệu còn "mới" trong 2 phút — bỏ qua fetch khi back từ màn khác.
  static const Duration _cacheValidDuration = Duration(minutes: 2);

  @override
  void refreshOnReconnect() => fetchHotMatches(forceRefresh: true);

  /// Initialize and fetch hot matches
  Future<void> initialize({int? sportId}) async {
    _currentSportId = sportId ?? 1;
    _setupWebSocketListeners();
    _startAutoRefresh();
  }

  /// Fetch hot matches (V2 live events) rồi stream statistics đồng thời.
  ///
  /// [forceRefresh]: true = luôn gọi API; false = dùng cache 2 phút.
  Future<void> fetchHotMatches({
    int? sportId,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;

    if (!forceRefresh &&
        state.leagues.isNotEmpty &&
        state.lastUpdated != null) {
      final age = DateTime.now().difference(state.lastUpdated!);
      if (age < _cacheValidDuration) return;
    }

    // Hủy stream statistics cũ nếu đang chạy (vd. forceRefresh giữa chừng).
    await _statisticsStreamSub?.cancel();
    _statisticsStreamSub = null;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _fetchHotMatchesUseCase();

    result.fold(
      (failure) {
        debugPrint(
          '❌ HotMatchNotifier: Error fetching hot matches: ${failure.message}',
        );
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (leagues) {
        // Subscribe WebSocket cho tất cả eventIds.
        final eventIds = [
          for (final l in leagues)
            for (final e in l.events) e.eventId,
        ];
        _subscribeMatchUpdatesUseCase.subscribe(eventIds);

        final matches = flattenLeaguesToHotMatches(leagues);

        // ── Bước 1: Hiển thị list ngay lập tức (không chờ statistics) ──────
        // pendingStatisticsIds = tất cả eventId → UI biết item nào đang load.
        state = state.copyWith(
          leagues: leagues,
          eventStatistics: const {},
          pendingStatisticsIds: eventIds.toSet(),
          isLoading: false,
          lastUpdated: DateTime.now(),
          currentPageIndex: 0,
          rightSidebarPageIndex: 0,
        );

        if (matches.isEmpty) return;

        // ── Bước 2: Stream statistics — emit từng item khi hoàn thành ────────
        // Cả hai API (/simple + /users) được gọi song song cho mỗi match.
        // Semaphore (maxConcurrent=10) đảm bảo không quá 10 match cùng lúc.
        _statisticsStreamSub = _streamHotMatchStatisticsUseCase(
          matches,
          _currentSportId,
        ).listen(
          (entry) {
            if (!mounted) return;
            // Progressive update: merge kết quả từng match vào map hiện tại.
            final updatedStats = {
              ...state.eventStatistics,
              entry.key: entry.value,
            };
            // Xóa khỏi pending → UI tắt shimmer cho item này.
            final updatedPending = {...state.pendingStatisticsIds}
              ..remove(entry.key);
            state = state.copyWith(
              eventStatistics: updatedStats,
              pendingStatisticsIds: updatedPending,
            );
          },
          onError: (Object _) {/* stream tự handle lỗi từng event */},
          cancelOnError: false, // Một event lỗi không dừng stream.
        );
      },
    );
  }

  /// Setup WebSocket listeners
  void _setupWebSocketListeners() {
    _oddsSubscription = _subscribeMatchUpdatesUseCase.oddsUpdates.listen(
      _handleOddsUpdate,
    );
    _scoreSubscription = _subscribeMatchUpdatesUseCase.scoreUpdates.listen(
      _handleScoreUpdate,
    );
  }

  /// Handle odds update from WebSocket (V2: no in-place update; next fetch refreshes)
  void _handleOddsUpdate(OddsUpdateEvent data) {
    // With EventModelV2, in-place odds update would require mapping markets/oddsList.
    // Rely on periodic fetch or user pull-to-refresh for updated odds.
  }

  /// Handle score update from WebSocket
  void _handleScoreUpdate(ScoreUpdateEvent data) {
    final newLeagues = <LeagueModelV2>[];
    for (final league in state.leagues) {
      final eventIndex = league.events.indexWhere(
        (e) => e.eventId == data.eventId,
      );
      if (eventIndex == -1) {
        newLeagues.add(league);
        continue;
      }
      final event = league.events[eventIndex];
      final newScore = GenericScoreModelV2(
        homeScoreValue: data.homeScore.toString(),
        awayScoreValue: data.awayScore.toString(),
      );
      final updatedEvent = event.copyWith(score: newScore, isLive: true);
      final updatedEvents = List.of(league.events)..[eventIndex] = updatedEvent;
      newLeagues.add(league.copyWith(events: updatedEvents));
    }
    if (newLeagues.length == state.leagues.length) {
      state = state.copyWith(leagues: newLeagues);
    }
  }

  /// Start auto refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      // fetchHotMatches();
    });
  }

  /// Update current page index (khi user swipe carousel).
  void setPageIndex(int index) {
    state = state.copyWith(currentPageIndex: index);
  }

  void setRightSidebarPageIndex(int index) {
    state = state.copyWith(rightSidebarPageIndex: index);
  }

  /// Change sport and refresh
  Future<void> changeSport(int sportId) async {
    if (_currentSportId == sportId) return;

    final oldEventIds = [
      for (final l in state.leagues)
        for (final e in l.events) e.eventId,
    ];
    _subscribeMatchUpdatesUseCase.unsubscribe(oldEventIds);
    _currentSportId = sportId;
  }

  /// Refresh hot matches
  Future<void> refresh() async {
    // await fetchHotMatches();
  }

  @override
  void dispose() {
    _statisticsStreamSub?.cancel();
    _oddsSubscription?.cancel();
    _scoreSubscription?.cancel();
    _refreshTimer?.cancel();

    final eventIds = [
      for (final l in state.leagues)
        for (final e in l.events) e.eventId,
    ];
    _subscribeMatchUpdatesUseCase.unsubscribe(eventIds);

    super.dispose();
  }
}

// ===== MAIN PROVIDER =====

/// Hot Match Provider. Type explicit to break self-reference in reconnect callback.
final StateNotifierProvider<HotMatchNotifier, HotMatchState> hotMatchProvider =
    StateNotifierProvider<HotMatchNotifier, HotMatchState>((ref) {
      final fetchHotMatchesUseCase = ref.read(fetchHotMatchesUseCaseProvider);
      final streamHotMatchStatisticsUseCase = ref.read(
        streamHotMatchStatisticsUseCaseProvider,
      );
      final subscribeMatchUpdatesUseCase = ref.read(
        subscribeMatchUpdatesUseCaseProvider,
      );

      final notifier = HotMatchNotifier(
        fetchHotMatchesUseCase,
        streamHotMatchStatisticsUseCase,
        subscribeMatchUpdatesUseCase,
      );

      notifier.initialize();

      final coordinator = ref.read(reconnectCoordinatorProvider);
      final reconnectCb = () =>
          ref.read(hotMatchProvider.notifier).refreshOnReconnect();
      coordinator.register(reconnectCb);

      ref.onDispose(() {
        coordinator.unregister(reconnectCb);
        debugPrint('🗑️ HotMatchNotifier disposed');
      });

      return notifier;
    });

// ===== DERIVED PROVIDERS =====

/// Hot matches list provider (V2) — flatten leagues to one item per event for carousel.
/// Enriched with bettingTrend and totalUsers.
///
/// Lọc bỏ item không có odds: chỉ giữ match có ít nhất một trong hai market
/// (handicap hoặc over/under) có [mainLineOdds] khác null cho sport hiện tại.
/// Item không có odds sẽ hiển thị card trống → không có giá trị với người dùng.
final hotMatchesProvider = Provider<List<HotMatchEventV2>>((ref) {
  final state = ref.watch(hotMatchProvider);
  final sportId = ref.watch(leagueProvider.select((s) => s.currentSportId));

  final list = flattenLeaguesToHotMatches(
    state.leagues,
    eventStatistics: state.eventStatistics,
  );

  return list.where((match) {
    final hasHandicap = match.getHandicapMarket(sportId)?.mainLineOdds != null;
    final hasOverUnder =
        match.getOverUnderMarket(sportId)?.mainLineOdds != null;
    return hasHandicap || hasOverUnder;
  }).toList();
});

/// Hot match loading state provider
final hotMatchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(hotMatchProvider).isLoading;
});

/// Hot match error provider
final hotMatchErrorProvider = Provider<String?>((ref) {
  return ref.watch(hotMatchProvider).error;
});

/// Hot match has data provider
final hotMatchHasDataProvider = Provider<bool>((ref) {
  return ref.watch(hotMatchProvider).hasData;
});

/// Current page index provider
final hotMatchPageIndexProvider = Provider<int>((ref) {
  return ref.watch(hotMatchProvider).currentPageIndex;
});
