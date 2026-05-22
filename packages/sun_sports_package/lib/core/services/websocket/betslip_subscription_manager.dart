import 'dart:async';
import 'dart:math';

import 'subscription_manager.dart';

/// Manages WebSocket subscriptions for betslip events.
///
/// Features:
/// - Reference counting: Multiple bets from same event share one subscription
/// - Debounce: 300ms delay to batch rapid add/remove operations
/// - Retry logic: Exponential backoff (1s → 2s → 4s) for failed subscriptions
/// - Max subscriptions: 50 events to prevent memory bloat
/// - Language change handling: Resubscribe with new language when changed
///
/// Usage:
/// ```dart
/// // When bet is added
/// BetslipSubscriptionManager.instance?.onBetAdded(eventId);
///
/// // When bet is removed
/// BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
///
/// // On app startup, restore from saved bets
/// BetslipSubscriptionManager.instance?.restoreSubscriptions(savedEventIds);
/// ```
class BetslipSubscriptionManager {
  /// Global instance for easy access from non-Riverpod contexts (e.g., ParlayStateNotifier)
  static BetslipSubscriptionManager? _instance;
  static BetslipSubscriptionManager? get instance => _instance;
  static const _source = 'betslip';
  static const _debounceDelay = Duration(milliseconds: 300);
  static const _maxRetries = 3;
  static const _maxSubscriptions = 50;

  final SubscriptionManager _subscriptionManager;
  String _language;

  // State
  final Map<int, int> _eventRefCount = {}; // eventId → bet count
  final Set<int> _subscribedEvents = {}; // Currently subscribed eventIds

  // Debounce
  Timer? _debounceTimer;
  final Set<int> _pendingSubscribe = {};
  final Set<int> _pendingUnsubscribe = {};

  // Retry
  final Map<int, int> _retryCount = {};
  final Set<Timer> _retryTimers = {};
  bool _isDisposed = false;

  BetslipSubscriptionManager({
    required SubscriptionManager subscriptionManager,
    required String language,
  }) : _subscriptionManager = subscriptionManager,
       _language = language {
    // Set global instance for easy access from non-Riverpod contexts
    _instance = this;
  }

  /// Get current subscribed event count (for debugging/monitoring).
  int get subscribedEventCount => _subscribedEvents.length;

  /// Get current language.
  String get language => _language;

  /// Called when a bet is added to the betslip.
  ///
  /// Increments reference count for the event.
  /// If this is the first bet for this event, schedules subscription.
  void onBetAdded(int eventId) {
    if (_isDisposed) return;

    _eventRefCount[eventId] = (_eventRefCount[eventId] ?? 0) + 1;
    _pendingUnsubscribe.remove(eventId);

    if (!_subscribedEvents.contains(eventId)) {
      if (_subscribedEvents.length >= _maxSubscriptions) {
        _logDebug(
          '⚠️ Max subscriptions reached ($_maxSubscriptions), skipping $eventId',
        );
        return;
      }
      _pendingSubscribe.add(eventId);
    }

    _scheduleFlush();
  }

  /// Called when a bet is removed from the betslip.
  ///
  /// Decrements reference count for the event.
  /// If this was the last bet for this event, schedules unsubscription.
  void onBetRemoved(int eventId) {
    if (_isDisposed) return;

    final count = _eventRefCount[eventId] ?? 0;
    if (count <= 1) {
      _eventRefCount.remove(eventId);
      _pendingSubscribe.remove(eventId);
      if (_subscribedEvents.contains(eventId)) {
        _pendingUnsubscribe.add(eventId);
      }
    } else {
      _eventRefCount[eventId] = count - 1;
    }

    _scheduleFlush();
  }

  /// Called when all bets are cleared from the betslip.
  void onBetsCleared() {
    if (_isDisposed) return;

    _pendingSubscribe.clear();
    _pendingUnsubscribe.addAll(_subscribedEvents);
    _eventRefCount.clear();

    _scheduleFlush();
  }

  /// Called on app startup to restore subscriptions from saved bets.
  ///
  /// [eventIds] - List of event IDs from saved bets (may contain duplicates).
  void restoreSubscriptions(List<int> eventIds) {
    if (_isDisposed) return;

    for (final eventId in eventIds) {
      _eventRefCount[eventId] = (_eventRefCount[eventId] ?? 0) + 1;
      if (!_subscribedEvents.contains(eventId)) {
        _pendingSubscribe.add(eventId);
      }
    }

    // Flush immediately for restore (no debounce)
    _flush();
  }

  /// Called when WebSocket reconnects.
  ///
  /// Note: SubscriptionManager handles resubscription via _channelSources,
  /// so this is mainly for logging/monitoring.
  void onReconnected() {
    _logDebug(
      '🔄 Reconnected, ${_subscribedEvents.length} betslip events tracked',
    );
  }

  /// Called when app language changes.
  ///
  /// Unsubscribes from old language channels and resubscribes with new language.
  void onLanguageChanged(String newLang) {
    if (_language == newLang || _isDisposed) return;

    final oldLang = _language;
    _language = newLang;

    // Unsubscribe all with old language, resubscribe with new
    for (final eventId in _subscribedEvents.toList()) {
      _subscriptionManager.unsubscribeMatchDetailWithLang(
        eventId,
        lang: oldLang,
        source: _source,
      );
      _subscriptionManager.subscribeMatchDetail(eventId, source: _source);
    }
    _logDebug(
      '🌐 Language changed: $oldLang → $newLang, resubscribed ${_subscribedEvents.length} events',
    );
  }

  /// Schedule a flush operation with debounce.
  void _scheduleFlush() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, _flush);
  }

  /// Execute pending subscribe/unsubscribe operations.
  void _flush() {
    if (_isDisposed) return;

    // Process pending subscriptions
    for (final eventId in _pendingSubscribe.toList()) {
      _subscribeWithRetry(eventId);
    }
    _pendingSubscribe.clear();

    // Process pending unsubscriptions
    for (final eventId in _pendingUnsubscribe.toList()) {
      _unsubscribeEvent(eventId);
    }
    _pendingUnsubscribe.clear();
  }

  /// Subscribe to an event with retry logic.
  void _subscribeWithRetry(int eventId) {
    if (_isDisposed) return;

    try {
      _subscribeEvent(eventId);
      _retryCount.remove(eventId);
    } catch (e) {
      final count = _retryCount[eventId] ?? 0;
      if (count >= _maxRetries) {
        _logDebug('❌ Max retries reached for event $eventId');
        _retryCount.remove(eventId);
        return;
      }

      _retryCount[eventId] = count + 1;
      final delay = Duration(seconds: pow(2, count).toInt()); // 1s, 2s, 4s

      late final Timer timer;
      timer = Timer(delay, () {
        _retryTimers.remove(timer);
        if (!_isDisposed && _eventRefCount.containsKey(eventId)) {
          _subscribeWithRetry(eventId);
        }
      });
      _retryTimers.add(timer);

      _logDebug(
        '⏳ Retry ${count + 1}/$_maxRetries for event $eventId in ${delay.inSeconds}s',
      );
    }
  }

  /// Subscribe to an event.
  void _subscribeEvent(int eventId) {
    _subscribedEvents.add(eventId);
    _subscriptionManager.subscribeMatchDetail(eventId, source: _source);
    _logDebug(
      '📺 Subscribed event $eventId (total: ${_subscribedEvents.length})',
    );
  }

  /// Unsubscribe from an event.
  void _unsubscribeEvent(int eventId) {
    _subscribedEvents.remove(eventId);
    _subscriptionManager.unsubscribeMatchDetail(eventId, source: _source);
    _logDebug(
      '📴 Unsubscribed event $eventId (total: ${_subscribedEvents.length})',
    );
  }

  /// Clean up resources.
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();

    // Cancel all retry timers
    for (final timer in _retryTimers) {
      timer.cancel();
    }
    _retryTimers.clear();

    // Unsubscribe all betslip events
    for (final eventId in _subscribedEvents.toList()) {
      _subscriptionManager.unsubscribeMatchDetail(eventId, source: _source);
    }

    _eventRefCount.clear();
    _subscribedEvents.clear();
    _pendingSubscribe.clear();
    _pendingUnsubscribe.clear();
    _retryCount.clear();

    // Clear global instance
    if (_instance == this) {
      _instance = null;
    }

    _logDebug('🗑️ Disposed');
  }

  void _logDebug(String message) {
    print('[BetslipSubManager] $message');
  }
}
