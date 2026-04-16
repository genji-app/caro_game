/// WebSocket Sport Filter
///
/// Filters messages based on the currently viewed sport.
/// Only processes messages for the active sport to reduce unnecessary work.
///
/// Some message types bypass the filter:
/// - balance_up: User balance updates are always relevant
/// - connection: Connection status is always relevant
/// - heartbeat: Keep-alive messages are always relevant

import '../websocket_messages.dart';
import 'ws_queued_message.dart';

/// Filter messages by sport ID
class WsSportFilter {
  /// Current sport ID being viewed (null = process all)
  int? _currentSportId;

  /// Message types that bypass the sport filter
  static const Set<WsMessageType> _bypassTypes = {
    WsMessageType.balanceUpdate,
    WsMessageType.connection,
    WsMessageType.heartbeat,
  };

  /// Messages filtered out count
  int _filteredCount = 0;

  /// Messages passed count
  int _passedCount = 0;

  /// Get current sport ID filter
  int? get currentSportId => _currentSportId;

  /// Set the current sport ID filter
  set currentSportId(int? sportId) {
    _currentSportId = sportId;
  }

  /// Number of messages filtered out
  int get filteredCount => _filteredCount;

  /// Number of messages that passed the filter
  int get passedCount => _passedCount;

  /// Check if a message should be processed
  ///
  /// Returns true if:
  /// - Message type bypasses the filter (balance, connection, heartbeat)
  /// - No sport filter is set (currentSportId is null)
  /// - Message sportId matches currentSportId
  /// - Message has no sportId (unknown sport)
  bool shouldProcess(WsQueuedMessage message) {
    // Bypass types always pass
    if (_isBypassType(message.type)) {
      _passedCount++;
      return true;
    }

    // No filter set - process all
    if (_currentSportId == null) {
      _passedCount++;
      return true;
    }

    // Message has no sport info - process (to be safe)
    if (message.sportId == null) {
      _passedCount++;
      return true;
    }

    // Check if message matches current sport
    if (message.sportId == _currentSportId) {
      _passedCount++;
      return true;
    }

    // Message is for different sport - filter out
    _filteredCount++;
    return false;
  }

  /// Filter a list of messages
  ///
  /// Returns only messages that should be processed.
  List<WsQueuedMessage> filter(List<WsQueuedMessage> messages) {
    return messages.where(shouldProcess).toList();
  }

  /// Check if message type bypasses the filter
  bool _isBypassType(WsMessageType type) {
    return _bypassTypes.contains(type);
  }

  /// Reset statistics
  void resetStats() {
    _filteredCount = 0;
    _passedCount = 0;
  }

  /// Get filter statistics
  WsSportFilterStats get stats => WsSportFilterStats(
    currentSportId: _currentSportId,
    filteredCount: _filteredCount,
    passedCount: _passedCount,
  );

  @override
  String toString() {
    return 'WsSportFilter(sportId: $_currentSportId, filtered: $_filteredCount, passed: $_passedCount)';
  }
}

/// Sport filter statistics snapshot
class WsSportFilterStats {
  final int? currentSportId;
  final int filteredCount;
  final int passedCount;

  const WsSportFilterStats({
    required this.currentSportId,
    required this.filteredCount,
    required this.passedCount,
  });

  /// Total messages processed
  int get totalProcessed => filteredCount + passedCount;

  /// Filter rate (0.0 to 1.0)
  double get filterRate =>
      totalProcessed > 0 ? filteredCount / totalProcessed : 0;

  @override
  String toString() {
    final rate = (filterRate * 100).toStringAsFixed(1);
    return 'SportFilterStats(sportId: $currentSportId, '
        'filtered: $filteredCount, passed: $passedCount, rate: $rate%)';
  }
}
