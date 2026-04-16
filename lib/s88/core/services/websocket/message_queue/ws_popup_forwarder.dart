/// WebSocket Popup Forwarder
///
/// Forwards critical messages to an active popup IMMEDIATELY, bypassing the queue.
/// This ensures users see real-time odds changes when placing bets.
///
/// Critical message types:
/// - odds_up: Odds changed - user needs to see latest odds
/// - odds_rmv: Odds removed - selection may no longer be available
/// - market_up: Market status changed - may be suspended
/// - event_rm: Event removed - betting may no longer be possible

import 'dart:async';

import '../websocket_messages.dart';
import 'ws_queued_message.dart';

/// Forwards priority messages to popup
class WsPopupForwarder {
  /// Event ID of the currently active popup (null = no popup open)
  int? _activePopupEventId;

  /// Stream controller for popup messages
  final _popupStreamController = StreamController<WsQueuedMessage>.broadcast();

  /// Number of messages forwarded to popup
  int _forwardedCount = 0;

  /// Critical message types that should be forwarded to popup
  static const Set<WsMessageType> _criticalTypes = {
    WsMessageType.oddsUpdate,
    WsMessageType.oddsRemove,
    WsMessageType.oddsInsert,
    WsMessageType.marketStatus,
    WsMessageType.eventRemove,
    WsMessageType.eventStatus,
  };

  /// Stream for popup to listen to priority messages
  Stream<WsQueuedMessage> get popupMessageStream =>
      _popupStreamController.stream;

  /// Current active popup event ID
  int? get activePopupEventId => _activePopupEventId;

  /// Number of messages forwarded
  int get forwardedCount => _forwardedCount;

  /// Register a popup for an event
  ///
  /// Messages for this event will be forwarded immediately.
  void registerPopup(int eventId) {
    _activePopupEventId = eventId;
  }

  /// Unregister the popup
  void unregisterPopup() {
    _activePopupEventId = null;
  }

  /// Check if popup is currently registered
  bool get hasActivePopup => _activePopupEventId != null;

  /// Check if a message should be forwarded to popup
  ///
  /// Returns true if:
  /// - A popup is registered
  /// - Message type is critical
  /// - Message is for the active popup's event
  bool shouldForwardToPopup(WsQueuedMessage message) {
    // No popup registered
    if (_activePopupEventId == null) return false;

    // Not a critical type
    if (!_isCriticalType(message.type)) return false;

    // Check if message is for the active event
    return _isForActiveEvent(message);
  }

  /// Forward message to popup if applicable
  ///
  /// Returns true if message was forwarded.
  bool tryForward(WsQueuedMessage message) {
    if (!shouldForwardToPopup(message)) return false;

    _popupStreamController.add(message);
    _forwardedCount++;
    return true;
  }

  /// Check if message type is critical
  bool _isCriticalType(WsMessageType type) {
    return _criticalTypes.contains(type);
  }

  /// Check if message is for the active popup event
  bool _isForActiveEvent(WsQueuedMessage message) {
    final messageEventId = message.eventId;
    if (messageEventId == null) return false;

    return messageEventId == _activePopupEventId;
  }

  /// Reset statistics
  void resetStats() {
    _forwardedCount = 0;
  }

  /// Get forwarder statistics
  WsPopupForwarderStats get stats => WsPopupForwarderStats(
    activePopupEventId: _activePopupEventId,
    forwardedCount: _forwardedCount,
  );

  /// Dispose resources
  void dispose() {
    _popupStreamController.close();
  }

  @override
  String toString() {
    return 'WsPopupForwarder(eventId: $_activePopupEventId, forwarded: $_forwardedCount)';
  }
}

/// Popup forwarder statistics snapshot
class WsPopupForwarderStats {
  final int? activePopupEventId;
  final int forwardedCount;

  const WsPopupForwarderStats({
    required this.activePopupEventId,
    required this.forwardedCount,
  });

  bool get hasActivePopup => activePopupEventId != null;

  @override
  String toString() {
    return 'PopupForwarderStats(eventId: $activePopupEventId, forwarded: $forwardedCount)';
  }
}
