import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';

/// Data cho một event đang live - chỉ chứa thông tin realtime
///
/// Tách riêng khỏi LeagueEventData để tránh rebuild toàn bộ leagues
/// khi score/time thay đổi.
@immutable
class EventLiveData {
  final int eventId;
  final int homeScore;
  final int awayScore;

  /// Minutes elapsed — dùng cho Soccer display ("45'")
  final int gameTime;

  /// Raw milliseconds từ server — dùng cho Basketball countdown
  final int gameTimeMs;

  final int gamePart;
  final String? status;

  /// Sport ID — để UI format time/score đúng theo môn
  final int sportId;

  final DateTime lastUpdated;

  const EventLiveData({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
    this.gameTime = 0,
    this.gameTimeMs = 0,
    this.gamePart = 0,
    this.status,
    this.sportId = 0,
    required this.lastUpdated,
  });

  EventLiveData copyWith({
    int? homeScore,
    int? awayScore,
    int? gameTime,
    int? gameTimeMs,
    int? gamePart,
    String? status,
    int? sportId,
    DateTime? lastUpdated,
  }) {
    return EventLiveData(
      eventId: eventId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      gameTime: gameTime ?? this.gameTime,
      gameTimeMs: gameTimeMs ?? this.gameTimeMs,
      gamePart: gamePart ?? this.gamePart,
      status: status ?? this.status,
      sportId: sportId ?? this.sportId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Format game time display (e.g., "45'", "90+3'")
  String get gameTimeDisplay {
    if (gameTime <= 0) return '';
    return "$gameTime'";
  }

  /// Format live status (e.g., "HT", "1H 45'", "2H 60'")
  /// Uses GamePart enum values: firstHalf=2, halfTime=4, secondHalf=8, etc.
  String get liveStatusDisplay {
    switch (gamePart) {
      case 2: // firstHalf
        return gameTime > 0 ? "1H $gameTime'" : '1H';
      case 4: // halfTime
        return 'HT';
      case 8: // secondHalf
        return gameTime > 0 ? "2H $gameTime'" : '2H';
      case 16: // finished
        return 'FT';
      case 32: // regulaTimeFinished
        return "90'";
      case 64: // firstHalfExtraTime
        return gameTime > 0 ? "ET1 $gameTime'" : 'ET1';
      case 128: // halfTimeOfExtraTime
        return 'ET-HT';
      case 256: // secondHalfExtraTime
        return gameTime > 0 ? "ET2 $gameTime'" : 'ET2';
      case 512: // extraTimeFinished
        return 'AET';
      case 1024: // penalties
        return 'PEN';
      default:
        // Unknown gamePart - infer period from gameTime for football
        if (gameTime > 0) {
          if (gameTime <= 45) return "1H $gameTime'";
          if (gameTime <= 90) return "2H $gameTime'";
          return "ET $gameTime'";
        }
        return '';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventLiveData &&
        other.eventId == eventId &&
        other.homeScore == homeScore &&
        other.awayScore == awayScore &&
        other.gameTime == gameTime &&
        other.gameTimeMs == gameTimeMs &&
        other.gamePart == gamePart &&
        other.status == status &&
        other.sportId == sportId;
  }

  @override
  int get hashCode {
    return Object.hash(
      eventId,
      homeScore,
      awayScore,
      gameTime,
      gameTimeMs,
      gamePart,
      status,
      sportId,
    );
  }
}

/// State cho EventLiveProvider
///
/// Sử dụng Map để O(1) lookup theo eventId
@immutable
class EventLiveState {
  final Map<int, EventLiveData> events;

  const EventLiveState({this.events = const {}});

  EventLiveState copyWith({Map<int, EventLiveData>? events}) {
    return EventLiveState(events: events ?? this.events);
  }

  /// Get event data by ID
  EventLiveData? getEvent(int eventId) => events[eventId];

  /// Get score tuple (home, away) or null if not found
  (int, int)? getScore(int eventId) {
    final event = events[eventId];
    if (event == null) return null;
    return (event.homeScore, event.awayScore);
  }

  /// Get game time string or null if not found
  String? getGameTime(int eventId) {
    final event = events[eventId];
    return event?.gameTimeDisplay;
  }

  /// Get live status string or null if not found
  String? getLiveStatus(int eventId) {
    final event = events[eventId];
    return event?.liveStatusDisplay;
  }

  /// Get raw game time in milliseconds (for basketball countdown)
  int? getGameTimeMs(int eventId) {
    final event = events[eventId];
    return event?.gameTimeMs;
  }

  /// Get sport ID for an event
  int? getSportId(int eventId) {
    final event = events[eventId];
    return event?.sportId;
  }
}

/// Notifier quản lý live event data từ WebSocket
///
/// Subscribe vào onEventStatusUpdate stream để cập nhật score/time realtime.
/// Tách riêng khỏi LeagueProvider để widget chỉ rebuild khi
/// event cụ thể thay đổi.
class EventLiveNotifier extends StateNotifier<EventLiveState> {
  final Ref _ref;
  StreamSubscription<socket.EventStatusData>? _eventStatusSubscription;

  EventLiveNotifier(this._ref) : super(const EventLiveState()) {
    // print('[EventLiveProvider] 🚀 EventLiveNotifier CREATED');
    _listenToEventStatusUpdates();
  }

  /// Listen to event status updates from sport_socket library
  void _listenToEventStatusUpdates() {
    // print('[EventLiveProvider] 👂 Subscribing to onEventStatusUpdate...');
    final adapter = _ref.read(sportSocketAdapterProvider);
    _eventStatusSubscription = adapter.onEventStatusUpdate.listen((data) {
      // print('[EventLiveProvider] 🎯 onEventStatusUpdate received: eventId=${data.eventId}');
      _handleEventStatusUpdate(data);
    });
    // print('[EventLiveProvider] ✅ Subscribed to onEventStatusUpdate');
  }

  /// Handle event status update from sport_socket library
  /// Contains score, gameTime, gamePart, and status
  void _handleEventStatusUpdate(socket.EventStatusData data) {
    if (data.eventId == 0) return;

    // DEBUG: Trace raw values from socket
    // print('[EventLiveProvider] 📥 RAW: eventId=${data.eventId}, gameTime=${data.gameTime}, gamePart=${data.gamePart}, status=${data.status}');

    final existing = state.events[data.eventId];
    final now = DateTime.now();

    // Convert gameTime from milliseconds to minutes if needed
    final gameTimeMinutes = data.gameTime != null
        ? (data.gameTime! ~/ 60000) // Convert ms to minutes
        : existing?.gameTime ?? 0;

    // Raw milliseconds — for basketball countdown timer
    final gameTimeMs = data.gameTime ?? existing?.gameTimeMs ?? 0;

    // Update all available fields
    final newData =
        existing?.copyWith(
          homeScore: data.homeScore ?? existing.homeScore,
          awayScore: data.awayScore ?? existing.awayScore,
          gameTime: gameTimeMinutes,
          gameTimeMs: gameTimeMs,
          gamePart: data.gamePart ?? existing.gamePart,
          status: data.status ?? existing.status,
          sportId: data.sportId,
          lastUpdated: now,
        ) ??
        EventLiveData(
          eventId: data.eventId,
          homeScore: data.homeScore ?? 0,
          awayScore: data.awayScore ?? 0,
          gameTime: gameTimeMinutes,
          gameTimeMs: gameTimeMs,
          gamePart: data.gamePart ?? 0,
          status: data.status,
          sportId: data.sportId,
          lastUpdated: now,
        );

    // Only update if any field changed
    if (existing == null ||
        existing.homeScore != newData.homeScore ||
        existing.awayScore != newData.awayScore ||
        existing.gameTime != newData.gameTime ||
        existing.gameTimeMs != newData.gameTimeMs ||
        existing.gamePart != newData.gamePart ||
        existing.status != newData.status) {
      final newEvents = Map<int, EventLiveData>.from(state.events);
      newEvents[data.eventId] = newData;
      state = state.copyWith(events: newEvents);
      // print('[EventLiveProvider] ✅ UPDATED eventId=${data.eventId}: gameTimeMs=${data.gameTime} → gameTimeMin=${newData.gameTime}, part=${newData.gamePart}, display="${newData.liveStatusDisplay}"');
    } else {
      // print('[EventLiveProvider] ⏭️ No change for eventId=${data.eventId}');
    }
  }

  /// Update event status (gameTime, gamePart, status)
  /// Called from event_up WebSocket message
  void updateEventStatus({
    required int eventId,
    int? gameTime,
    int? gamePart,
    String? status,
    int? homeScore,
    int? awayScore,
  }) {
    final existing = state.events[eventId];
    final now = DateTime.now();

    final newData =
        existing?.copyWith(
          gameTime: gameTime,
          gamePart: gamePart,
          status: status,
          homeScore: homeScore,
          awayScore: awayScore,
          lastUpdated: now,
        ) ??
        EventLiveData(
          eventId: eventId,
          homeScore: homeScore ?? 0,
          awayScore: awayScore ?? 0,
          gameTime: gameTime ?? 0,
          gamePart: gamePart ?? 0,
          status: status,
          lastUpdated: now,
        );

    // Only update if changed
    if (existing != newData) {
      final newEvents = Map<int, EventLiveData>.from(state.events);
      newEvents[eventId] = newData;
      state = state.copyWith(events: newEvents);
    }
  }

  /// Initialize event data from API response
  /// Call this when loading events from LeagueProvider
  void initializeFromEvent({
    required int eventId,
    required int homeScore,
    required int awayScore,
    int gameTime = 0,
    int gamePart = 0,
    String? status,
  }) {
    // Don't overwrite if already have realtime data
    if (state.events.containsKey(eventId)) return;

    final newData = EventLiveData(
      eventId: eventId,
      homeScore: homeScore,
      awayScore: awayScore,
      gameTime: gameTime,
      gamePart: gamePart,
      status: status,
      lastUpdated: DateTime.now(),
    );

    final newEvents = Map<int, EventLiveData>.from(state.events);
    newEvents[eventId] = newData;
    state = state.copyWith(events: newEvents);
  }

  /// Remove event (when event ends or is removed)
  void removeEvent(int eventId) {
    if (!state.events.containsKey(eventId)) return;

    final newEvents = Map<int, EventLiveData>.from(state.events);
    newEvents.remove(eventId);
    state = state.copyWith(events: newEvents);
  }

  /// Clear all events (when changing sport or refreshing)
  void clear() {
    state = const EventLiveState();
  }

  @override
  void dispose() {
    _eventStatusSubscription?.cancel();
    super.dispose();
  }
}

// ===== PROVIDERS =====

/// Main provider for live event data
final eventLiveProvider =
    StateNotifierProvider<EventLiveNotifier, EventLiveState>((ref) {
      return EventLiveNotifier(ref);
    });

// ===== SELECTOR PROVIDERS =====
// These providers use select() to only rebuild when specific data changes

/// Provider to get score for a specific event
/// Returns (homeScore, awayScore) or null if not found
///
/// Usage:
/// ```dart
/// Consumer(builder: (context, ref, _) {
///   final score = ref.watch(eventScoreProvider(eventId));
///   return Text('${score?.$1 ?? 0} - ${score?.$2 ?? 0}');
/// })
/// ```
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final eventScoreProvider = Provider.autoDispose.family<(int, int)?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getScore(eventId)),
  );
});

/// Provider to get game time display for a specific event
/// Returns formatted string like "45'" or null if not found
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final eventGameTimeProvider = Provider.autoDispose.family<String?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getGameTime(eventId)),
  );
});

/// Provider to get live status display for a specific event
/// Returns formatted string like "1H 45'", "HT", etc. or null if not found
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final eventLiveStatusProvider = Provider.autoDispose.family<String?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getLiveStatus(eventId)),
  );
});

/// Provider to get raw game time in milliseconds (for basketball countdown)
final eventGameTimeMsProvider = Provider.autoDispose.family<int?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getGameTimeMs(eventId)),
  );
});

/// Provider to get full event live data
/// Use this when you need multiple fields at once
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final eventLiveDataProvider = Provider.autoDispose.family<EventLiveData?, int>((
  ref,
  eventId,
) {
  return ref.watch(
    eventLiveProvider.select((state) => state.getEvent(eventId)),
  );
});
