import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/core/utils/vibrating_odds/vibrating_odds_checker.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/vibrating_odds_provider.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Thời gian hiển thị indicator (5 giây)
const Duration kIndicatorDisplayDuration = Duration(seconds: 5);

/// Giá trị mặc định khi chưa có data
const double kDefaultOddsValue = -999999;

/// Data class lưu trữ thông tin odds thay đổi
class OddsChangeData {
  final String selectionId;
  final double previousValue;
  final double currentValue;
  final OddsChangeDirection direction;
  final DateTime? lastChangeTime;

  /// All odds styles từ WebSocket
  final OddsStyleValues? oddsValues;

  const OddsChangeData({
    required this.selectionId,
    this.previousValue = kDefaultOddsValue,
    this.currentValue = kDefaultOddsValue,
    this.direction = OddsChangeDirection.none,
    this.lastChangeTime,
    this.oddsValues,
  });

  /// Kiểm tra có phải lần đầu nhận data không
  bool get isFirstTime => previousValue == kDefaultOddsValue;

  /// Kiểm tra indicator có đang active không (trong 5 giây)
  bool get isIndicatorActive {
    if (lastChangeTime == null) return false;
    final elapsed = DateTime.now().difference(lastChangeTime!);
    return elapsed < kIndicatorDisplayDuration;
  }

  /// Lấy giá trị odds theo style index (0=malay, 1=indo, 2=decimal, 3=hk)
  /// Trả về giá trị odds theo style, hoặc 0 nếu style không available
  /// KHÔNG fallback về decimal - để UI có thể dùng giá trị từ API
  double getValueByStyleIndex(int styleIndex) {
    if (oddsValues != null && oddsValues!.isValid) {
      return oddsValues!.getByStyleIndex(styleIndex);
    }
    return currentValue; // Fallback to stored value
  }

  OddsChangeData copyWith({
    String? selectionId,
    double? previousValue,
    double? currentValue,
    OddsChangeDirection? direction,
    DateTime? lastChangeTime,
    OddsStyleValues? oddsValues,
  }) {
    return OddsChangeData(
      selectionId: selectionId ?? this.selectionId,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      direction: direction ?? this.direction,
      lastChangeTime: lastChangeTime ?? this.lastChangeTime,
      oddsValues: oddsValues ?? this.oddsValues,
    );
  }
}

/// State class cho OddsChangeNotifier
class OddsChangeState {
  /// Map lưu trữ thay đổi odds theo selectionId
  final Map<String, OddsChangeData> changes;

  const OddsChangeState({this.changes = const {}});

  OddsChangeState copyWith({Map<String, OddsChangeData>? changes}) {
    return OddsChangeState(changes: changes ?? this.changes);
  }

  /// Lấy direction cho một selection
  OddsChangeDirection getDirection(String selectionId) {
    final data = changes[selectionId];
    if (data == null || !data.isIndicatorActive) {
      return OddsChangeDirection.none;
    }
    return data.direction;
  }

  /// Kiểm tra một selection có đang hiển thị indicator không
  bool isShowingIndicator(String selectionId) {
    final data = changes[selectionId];
    return data != null && data.isIndicatorActive;
  }
}

/// Notifier quản lý state thay đổi odds
class OddsChangeNotifier extends StateNotifier<OddsChangeState> {
  final Ref _ref;
  StreamSubscription<socket.OddsChangeData>? _oddsSubscription;
  StreamSubscription<SportSocketUpdate>? _updateSubscription;
  StreamSubscription<socket.ScoreUpdateData>? _scoreSubscription;
  final Map<String, Timer> _resetTimers = {};

  /// Periodic cleanup timer to prevent memory leak from accumulated entries
  Timer? _cleanupTimer;

  /// Cleanup interval - remove stale entries every 30 seconds
  static const Duration _cleanupInterval = Duration(seconds: 30);

  /// Max age for entries without active indicator - entries older than this will be removed
  static const Duration _maxEntryAge = Duration(seconds: 15);

  /// Debug counters
  int _totalUpdatesReceived = 0;
  int _indicatorsTriggered = 0;

  OddsChangeNotifier(this._ref) : super(const OddsChangeState()) {
    _listenToOddsUpdates();
    _listenToEventRemovals();
    _listenToScoreChanges();
    _startPeriodicCleanup();
  }

  /// Start periodic cleanup to prevent memory leak from accumulated entries
  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(
      _cleanupInterval,
      (_) => _cleanupStaleEntries(),
    );
  }

  /// Remove entries that are no longer needed:
  /// - Entries with direction == none AND no recent update (older than _maxEntryAge)
  /// This prevents the changes map from growing indefinitely
  ///
  /// Safety: Only runs cleanup if map has more than 100 entries (to avoid
  /// unnecessary work when map is small)
  void _cleanupStaleEntries() {
    final changes = state.changes;

    // Skip cleanup if map is small enough - no memory pressure
    if (changes.length < 100) return;

    final now = DateTime.now();

    // Find entries to remove
    final keysToRemove = <String>[];
    for (final entry in changes.entries) {
      final data = entry.value;

      // Keep entries that:
      // 1. Have active indicator (direction != none AND isIndicatorActive)
      // 2. Were recently updated (within _maxEntryAge)
      final hasActiveIndicator =
          data.direction != OddsChangeDirection.none && data.isIndicatorActive;
      final isRecent =
          data.lastChangeTime != null &&
          now.difference(data.lastChangeTime!) < _maxEntryAge;

      // Remove if no active indicator AND not recent
      if (!hasActiveIndicator && !isRecent) {
        keysToRemove.add(entry.key);
      }
    }

    // Only update state if there are entries to remove
    if (keysToRemove.isNotEmpty) {
      final newChanges = Map<String, OddsChangeData>.from(changes);
      for (final key in keysToRemove) {
        newChanges.remove(key);
        _resetTimers[key]?.cancel();
        _resetTimers.remove(key);
      }
      state = state.copyWith(changes: newChanges);

      if (kDebugMode) {
        // debugPrint('[OddsChangeProvider] Cleaned up ${keysToRemove.length} stale entries. Remaining: ${newChanges.length}');
      }
    }
  }

  /// Cleanup vibrating state when events are removed (event_rm from WebSocket).
  void _listenToEventRemovals() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _updateSubscription = adapter.onUpdate.listen((update) {
      if (update.removedEventIds.isNotEmpty) {
        final notifier = _ref.read(vibratingOddsProvider.notifier);
        for (final eventId in update.removedEventIds) {
          notifier.removeVibratingByEvent(eventId);
        }
      }
    });
  }

  /// BUG #4: Khi score thay đổi → clear vibrating cho event đó.
  /// Line check (score+0.5) có thể không còn đúng.
  /// Odds update tiếp theo sẽ re-evaluate với score mới.
  void _listenToScoreChanges() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _scoreSubscription = adapter.onScoreUpdate.listen((scoreUpdate) {
      _ref.read(vibratingOddsProvider.notifier)
          .removeVibratingByEvent(scoreUpdate.eventId);
    });
  }

  /// Lắng nghe odds updates từ sport_socket library
  void _listenToOddsUpdates() {
    // print('[OddsChangeProvider] 👂 Subscribing to onOddsChange...');
    final adapter = _ref.read(sportSocketAdapterProvider);
    _oddsSubscription = adapter.onOddsChange.listen(
      _handleOddsUpdate,
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('[OddsChangeProvider] Stream error: $error');
        }
      },
    );
    // print('[OddsChangeProvider] ✅ Subscribed to onOddsChange');
  }

  /// Xử lý khi có odds update từ library
  void _handleOddsUpdate(socket.OddsChangeData update) {
    final selectionId = update.selectionId;
    _totalUpdatesReceived++;

    // DEBUG: Uncomment to verify stream is working
    // print('[OddsChangeProvider] 📥 Received: selectionId=$selectionId, prev=${update.previousValue}, curr=${update.currentValue}, dir=${update.direction}');

    if (selectionId.isEmpty) {
      return;
    }

    final newValue = update.currentValue;
    if (newValue == 0.0) {
      return;
    }

    // Lấy data cũ hoặc tạo mới
    final existingData = state.changes[selectionId];

    // Map library direction to local direction
    final direction = _mapDirection(update.direction);

    // Xác định direction và lastChangeTime cuối cùng
    OddsChangeDirection finalDirection;
    DateTime? finalLastChangeTime;

    if (direction != OddsChangeDirection.none) {
      // Có thay đổi thực sự -> cập nhật direction mới và reset timer
      finalDirection = direction;
      finalLastChangeTime = DateTime.now();
    } else if (existingData != null && existingData.isIndicatorActive) {
      // Không có thay đổi nhưng indicator vẫn đang active -> giữ nguyên
      finalDirection = existingData.direction;
      finalLastChangeTime = existingData.lastChangeTime;
    } else {
      // Không có thay đổi và không có indicator active
      finalDirection = OddsChangeDirection.none;
      finalLastChangeTime = null;
    }

    // Convert library OddsStyleValues to local OddsStyleValues
    final localOddsValues = _convertStyleValues(update.styleValues);

    // Cập nhật state (bao gồm tất cả odds styles từ library)
    final newData = OddsChangeData(
      selectionId: selectionId,
      previousValue: update.previousValue,
      currentValue: newValue,
      direction: finalDirection,
      lastChangeTime: finalLastChangeTime,
      oddsValues: localOddsValues,
    );

    final newChanges = Map<String, OddsChangeData>.from(state.changes);
    newChanges[selectionId] = newData;
    state = state.copyWith(changes: newChanges);

    // Schedule reset timer nếu có thay đổi thực sự
    if (direction != OddsChangeDirection.none) {
      _indicatorsTriggered++;
      // print('[OddsChangeProvider] ✅ INDICATOR TRIGGERED: $selectionId (${direction == OddsChangeDirection.up ? "UP" : "DOWN"})');
      _scheduleReset(selectionId);
    }

    // Check vibrating odds (Kèo Rung)
    _checkVibratingOdds(update);
  }

  /// Check and update vibrating odds state (Kèo Rung).
  ///
  /// This is called for every odds update to check if the odds meet
  /// the "dangerous" threshold for live football Over/Under markets.
  void _checkVibratingOdds(socket.OddsChangeData update) {
    final marketId = update.marketId;
    final selectionId = update.selectionId;

    // 1. Filter early - only Over/Under markets (O(1) lookup)
    if (!VibratingOddsChecker.overUnderMarketIds.contains(marketId)) return;

    // 2. Skip if no selectionId
    if (selectionId.isEmpty) return;

    // 3. Lookup event to get sportId, isLive
    final adapter = _ref.read(sportSocketAdapterProvider);
    final event = adapter.getEventData(update.eventId);
    if (event == null) return;

    // 4. Lookup OddsData to get points and isSuspended
    final oddsData = adapter.getOdds(update.eventId, marketId, update.offerId);
    final points = oddsData?.points ?? '';
    final isSuspended = oddsData?.isSuspended ?? false;

    // 5. If suspended → remove vibrating and return
    if (isSuspended) {
      _ref.read(vibratingOddsProvider.notifier).removeVibrating(selectionId);
      return;
    }

    // 6. Get current odds format from user settings
    final currentFormat = _ref.read(oddsStyleProvider);

    // 7. Get odds value for current format
    final oddsValue = _getOddsValueByFormat(update.styleValues, currentFormat);
    if (oddsValue == null) return;

    // 8. Check threshold + line matching
    final isVibrating = VibratingOddsChecker.isVibrating(
      sportId: event.sportId,
      isLive: event.isLive,
      marketId: marketId,
      points: points,
      oddsValue: oddsValue,
      oddsFormat: currentFormat,
      homeScore: event.homeScore ?? 0,
      awayScore: event.awayScore ?? 0,
      cornersHome: event.cornersHome ?? 0,
      cornersAway: event.cornersAway ?? 0,
    );

    // 9. Set or remove vibrating state
    final notifier = _ref.read(vibratingOddsProvider.notifier);
    if (isVibrating) {
      notifier.setVibrating(
        selectionId,
        leagueId: event.leagueId,
        eventId: event.eventId,
      );
    } else {
      notifier.removeVibrating(selectionId);
    }
  }

  /// Get odds value for the current user format.
  double? _getOddsValueByFormat(
    socket.OddsStyleValues? styleValues,
    OddsStyle format,
  ) {
    if (styleValues == null) return null;

    return switch (format) {
      OddsStyle.malay => double.tryParse(styleValues.malay ?? ''),
      OddsStyle.decimal => styleValues.decimal,
      OddsStyle.indo => double.tryParse(styleValues.indo ?? ''),
      OddsStyle.hongKong => double.tryParse(styleValues.hk ?? ''),
    };
  }

  /// Map library OddsDirection to local OddsChangeDirection
  OddsChangeDirection _mapDirection(socket.OddsDirection direction) {
    switch (direction) {
      case socket.OddsDirection.up:
        return OddsChangeDirection.up;
      case socket.OddsDirection.down:
        return OddsChangeDirection.down;
      case socket.OddsDirection.none:
        return OddsChangeDirection.none;
    }
  }

  /// Convert library OddsStyleValues to local OddsStyleValues
  OddsStyleValues? _convertStyleValues(socket.OddsStyleValues? styleValues) {
    if (styleValues == null) return null;
    return OddsStyleValues(
      decimal: styleValues.decimal,
      malay: double.tryParse(styleValues.malay ?? '') ?? 0,
      indo: double.tryParse(styleValues.indo ?? '') ?? 0,
      hk: double.tryParse(styleValues.hk ?? '') ?? 0,
    );
  }

  /// Schedule timer để reset indicator sau 5 giây
  void _scheduleReset(String selectionId) {
    // Cancel timer cũ nếu có
    _resetTimers[selectionId]?.cancel();

    // Tạo timer mới
    _resetTimers[selectionId] = Timer(kIndicatorDisplayDuration, () {
      _resetIndicator(selectionId);
    });
  }

  /// Reset indicator cho một selection
  void _resetIndicator(String selectionId) {
    final existingData = state.changes[selectionId];
    if (existingData == null) return;

    final newChanges = Map<String, OddsChangeData>.from(state.changes);
    newChanges[selectionId] = existingData.copyWith(
      direction: OddsChangeDirection.none,
      lastChangeTime: null,
    );
    state = state.copyWith(changes: newChanges);
  }

  /// Cập nhật odds thủ công (dùng khi nhận data từ API lần đầu)
  void initializeOdds(String selectionId, double value) {
    final existingData = state.changes[selectionId];

    // Chỉ khởi tạo nếu chưa có data
    if (existingData != null) return;

    final newChanges = Map<String, OddsChangeData>.from(state.changes);
    newChanges[selectionId] = OddsChangeData(
      selectionId: selectionId,
      previousValue: kDefaultOddsValue,
      currentValue: value,
      direction: OddsChangeDirection.none,
    );
    state = state.copyWith(changes: newChanges);
  }

  /// Lấy direction cho một selection
  OddsChangeDirection getDirection(String selectionId) {
    return state.getDirection(selectionId);
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _oddsSubscription?.cancel();
    _updateSubscription?.cancel();
    _scoreSubscription?.cancel();
    for (final timer in _resetTimers.values) {
      timer.cancel();
    }
    _resetTimers.clear();
    super.dispose();
  }
}

/// Provider instance
final oddsChangeProvider =
    StateNotifierProvider<OddsChangeNotifier, OddsChangeState>(
      (ref) => OddsChangeNotifier(ref),
    );

/// Provider để lấy direction cho một selection cụ thể
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
/// 🔧 PERFORMANCE FIX: Sử dụng .select() để chỉ watch entry cụ thể, không watch toàn bộ state
final oddsDirectionProvider = Provider.autoDispose
    .family<OddsChangeDirection, String>((ref, selectionId) {
      if (selectionId.isEmpty) return OddsChangeDirection.none;

      // ✅ Chỉ watch entry của selection này - không rebuild khi selection khác thay đổi
      final data = ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );

      if (data == null || !data.isIndicatorActive) {
        return OddsChangeDirection.none;
      }
      return data.direction;
    });

/// Provider để kiểm tra có đang hiển thị indicator không
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
/// 🔧 PERFORMANCE FIX: Sử dụng .select() để chỉ watch entry cụ thể
final isShowingOddsIndicatorProvider = Provider.autoDispose
    .family<bool, String>((ref, selectionId) {
      if (selectionId.isEmpty) return false;

      final data = ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );
      return data != null && data.isIndicatorActive;
    });

/// Provider để lấy giá trị odds hiện tại từ WebSocket
/// Trả về null CHỈ KHI chưa nhận được data từ WebSocket
/// Luôn trả về stored value nếu đã có data
/// Tự động chọn đúng odds style theo setting của user
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
/// 🔧 PERFORMANCE FIX: Sử dụng .select() để chỉ watch entry cụ thể
final oddsValueProvider = Provider.autoDispose.family<String?, String>((
  ref,
  selectionId,
) {
  if (selectionId.isEmpty) return null;

  // ✅ Chỉ watch entry của selection này - không rebuild khi selection khác thay đổi
  final data = ref.watch(
    oddsChangeProvider.select((state) => state.changes[selectionId]),
  );
  final oddsStyle = ref.watch(oddsStyleProvider);

  // Chưa có data từ WebSocket, dùng giá trị từ API
  if (data == null || data.currentValue == kDefaultOddsValue) {
    return null;
  }

  // Lấy giá trị theo style: 0=malay, 1=indo, 2=decimal, 3=hk
  final value = data.getValueByStyleIndex(oddsStyle.index);

  // Nếu style có giá trị, dùng nó
  // Nếu không, fallback về currentValue (decimal)
  if (value != 0) {
    return value.toStringAsFixed(2);
  }

  // Fallback: dùng currentValue nếu specific style không available
  return data.currentValue.toStringAsFixed(2);
});

/// Provider để lấy OddsChangeData cho một selectionId cụ thể
/// Chỉ rebuild khi odds của selection này thay đổi (không rebuild khi selection khác thay đổi)
///
/// 🔧 PERFORMANCE FIX: Sử dụng .select() để chỉ watch một selection trong map
final oddsChangeDataProvider = Provider.autoDispose
    .family<OddsChangeData?, String>((ref, selectionId) {
      if (selectionId.isEmpty) return null;
      return ref.watch(
        oddsChangeProvider.select((state) => state.changes[selectionId]),
      );
    });

// NOTE: isSelectionValidProvider đã được remove
// FULL LIST behavior giờ được xử lý trực tiếp trong LeagueProvider
// thông qua oddsFullListListenerProvider (xem league_provider.dart)
