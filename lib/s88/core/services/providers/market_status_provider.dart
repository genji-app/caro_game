import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart'
    as socket
    show MarketStatus, MarketStatusData;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/utils/vibrating_odds/vibrating_odds_checker.dart';
import 'package:co_caro_flame/s88/features/sport/presentation/providers/vibrating_odds_provider.dart';

// Re-export for local use
typedef MarketStatus = socket.MarketStatus;

/// Key for market identification: "eventId_marketId"
typedef MarketKey = String;

/// Helper to create market key
MarketKey createMarketKey(int eventId, int marketId) => '${eventId}_$marketId';

/// Parse market key back to (eventId, marketId)
(int, int)? parseMarketKey(MarketKey key) {
  final parts = key.split('_');
  if (parts.length != 2) return null;
  final eventId = int.tryParse(parts[0]);
  final marketId = int.tryParse(parts[1]);
  if (eventId == null || marketId == null) return null;
  return (eventId, marketId);
}

/// Data cho market status (renamed to avoid conflict with ws.MarketStatusData)
@immutable
class MarketStatusInfo {
  final int eventId;
  final int marketId;
  final DateTime lastUpdated;

  /// Market status enum: Active, Suspended, Hidden, AutoSuspended, AutoHidden
  final MarketStatus status;

  const MarketStatusInfo({
    required this.eventId,
    required this.marketId,
    required this.lastUpdated,
    this.status = MarketStatus.active,
  });

  MarketKey get key => createMarketKey(eventId, marketId);

  MarketStatusInfo copyWith({DateTime? lastUpdated, MarketStatus? status}) {
    return MarketStatusInfo(
      eventId: eventId,
      marketId: marketId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }

  // Convenience getters (delegate to enum)

  /// Status code: 0-4
  int get statusCode => status.code;

  /// Whether market is suspended (any non-active status)
  bool get isSuspended => status.isSuspended;

  /// Whether market is active
  bool get isActive => status == MarketStatus.active;

  /// Whether market should be hidden from UI
  bool get isHidden => !status.isVisible;

  /// Market is available for betting when not suspended and active
  bool get isAvailable => status.canBet;

  /// Market should be visible in UI
  bool get isVisible => status.isVisible;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarketStatusInfo &&
        other.eventId == eventId &&
        other.marketId == marketId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(eventId, marketId, status);
  }
}

/// State for MarketStatusProvider
@immutable
class MarketStatusState {
  /// Map of market key to status data
  final Map<MarketKey, MarketStatusInfo> markets;

  /// Set of suspended event IDs (all markets suspended)
  final Set<int> suspendedEvents;

  const MarketStatusState({
    this.markets = const {},
    this.suspendedEvents = const {},
  });

  MarketStatusState copyWith({
    Map<MarketKey, MarketStatusInfo>? markets,
    Set<int>? suspendedEvents,
  }) {
    return MarketStatusState(
      markets: markets ?? this.markets,
      suspendedEvents: suspendedEvents ?? this.suspendedEvents,
    );
  }

  /// Check if a specific market is suspended
  bool isMarketSuspended(int eventId, int marketId) {
    // First check if entire event is suspended
    if (suspendedEvents.contains(eventId)) return true;

    // Then check specific market
    final key = createMarketKey(eventId, marketId);
    return markets[key]?.isSuspended ?? false;
  }

  /// Check if a specific market is available for betting
  bool isMarketAvailable(int eventId, int marketId) {
    // If event is suspended, all markets are unavailable
    if (suspendedEvents.contains(eventId)) return false;

    final key = createMarketKey(eventId, marketId);
    return markets[key]?.isAvailable ?? true;
  }

  /// Check if entire event is suspended
  bool isEventSuspended(int eventId) {
    return suspendedEvents.contains(eventId);
  }

  /// Get market status data
  MarketStatusInfo? getMarketStatus(int eventId, int marketId) {
    final key = createMarketKey(eventId, marketId);
    return markets[key];
  }
}

/// Notifier quản lý market status từ WebSocket
///
/// Subscribe vào onMarketStatusChange stream để cập nhật trạng thái suspended.
/// Tách riêng khỏi LeagueProvider để widget chỉ rebuild khi
/// market cụ thể thay đổi.
class MarketStatusNotifier extends StateNotifier<MarketStatusState> {
  final Ref _ref;
  StreamSubscription<socket.MarketStatusData>? _marketSubscription;

  MarketStatusNotifier(this._ref) : super(const MarketStatusState()) {
    _listenToMarketUpdates();
  }

  /// Listen to market status updates from sport_socket library
  void _listenToMarketUpdates() {
    final adapter = _ref.read(sportSocketAdapterProvider);
    _marketSubscription = adapter.onMarketStatusChange.listen(
      _handleMarketUpdate,
    );
  }

  /// Handle market status update from sport_socket library
  void _handleMarketUpdate(socket.MarketStatusData data) {
    if (data.eventId == 0) return;

    // DEBUG: Uncomment to verify stream is working
    print(
      '[MarketStatusProvider] 📥 Received: eventId=${data.eventId}, marketId=${data.marketId}, status=${data.status}',
    );

    final key = createMarketKey(data.eventId, data.marketId);
    final existing = state.markets[key];
    final now = DateTime.now();

    final newData = MarketStatusInfo(
      eventId: data.eventId,
      marketId: data.marketId,
      lastUpdated: now,
      status: data.status,
    );

    // Only update if changed
    if (existing == null || existing.status != newData.status) {
      final newMarkets = Map<MarketKey, MarketStatusInfo>.from(state.markets);
      newMarkets[key] = newData;
      state = state.copyWith(markets: newMarkets);

      // BUG #6 FIX: Cleanup vibrating when O/U market becomes suspended
      if (data.isSuspended &&
          VibratingOddsChecker.overUnderMarketIds.contains(data.marketId)) {
        _ref
            .read(vibratingOddsProvider.notifier)
            .removeVibratingByEvent(data.eventId);
      }
    }
  }

  /// Set specific market as suspended
  void setMarketSuspended(int eventId, int marketId, bool suspended) {
    final key = createMarketKey(eventId, marketId);
    final existing = state.markets[key];
    final now = DateTime.now();

    // Convert boolean to status enum
    final newStatus = suspended ? MarketStatus.suspended : MarketStatus.active;

    final newData =
        existing?.copyWith(status: newStatus, lastUpdated: now) ??
        MarketStatusInfo(
          eventId: eventId,
          marketId: marketId,
          status: newStatus,
          lastUpdated: now,
        );

    if (existing?.status != newStatus) {
      final newMarkets = Map<MarketKey, MarketStatusInfo>.from(state.markets);
      newMarkets[key] = newData;
      state = state.copyWith(markets: newMarkets);
    }
  }

  /// Remove market status (when event ends)
  void removeEvent(int eventId) {
    // Remove all markets for this event
    final newMarkets = Map<MarketKey, MarketStatusInfo>.from(state.markets);
    newMarkets.removeWhere((key, _) {
      final parsed = parseMarketKey(key);
      return parsed?.$1 == eventId;
    });

    // Remove from suspended events
    final newSuspended = Set<int>.from(state.suspendedEvents)..remove(eventId);

    state = state.copyWith(markets: newMarkets, suspendedEvents: newSuspended);
  }

  /// Clear all market statuses (when changing sport)
  void clear() {
    state = const MarketStatusState();
  }

  @override
  void dispose() {
    _marketSubscription?.cancel();
    super.dispose();
  }
}

// ===== PROVIDERS =====

/// Main provider for market status
final marketStatusProvider =
    StateNotifierProvider<MarketStatusNotifier, MarketStatusState>((ref) {
      return MarketStatusNotifier(ref);
    });

// ===== SELECTOR PROVIDERS =====

/// Provider to check if a specific market is suspended
///
/// Usage:
/// ```dart
/// Consumer(builder: (context, ref, _) {
///   final isSuspended = ref.watch(isMarketSuspendedProvider((eventId, marketId)));
///   return Opacity(
///     opacity: isSuspended ? 0.5 : 1.0,
///     child: OddsButton(...),
///   );
/// })
/// ```
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final isMarketSuspendedProvider = Provider.autoDispose.family<bool, (int, int)>(
  (ref, params) {
    final (eventId, marketId) = params;
    return ref.watch(
      marketStatusProvider.select(
        (state) => state.isMarketSuspended(eventId, marketId),
      ),
    );
  },
);

/// Provider to check if a specific market is available for betting
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final isMarketAvailableProvider = Provider.autoDispose.family<bool, (int, int)>(
  (ref, params) {
    final (eventId, marketId) = params;
    return ref.watch(
      marketStatusProvider.select(
        (state) => state.isMarketAvailable(eventId, marketId),
      ),
    );
  },
);

/// Provider to check if entire event is suspended
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final isEventSuspendedProvider = Provider.autoDispose.family<bool, int>((
  ref,
  eventId,
) {
  return ref.watch(
    marketStatusProvider.select((state) => state.isEventSuspended(eventId)),
  );
});

/// Provider to get full market status data
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final marketStatusDataProvider = Provider.autoDispose
    .family<MarketStatusInfo?, (int, int)>((ref, params) {
      final (eventId, marketId) = params;
      return ref.watch(
        marketStatusProvider.select(
          (state) => state.getMarketStatus(eventId, marketId),
        ),
      );
    });
