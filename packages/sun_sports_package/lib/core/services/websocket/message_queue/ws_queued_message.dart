/// Queued WebSocket Message
///
/// Wraps a WsMessage with metadata for queue processing:
/// - sportId: The sport this message belongs to (for filtering)
/// - enqueuedAt: Timestamp when message entered the queue (for latency tracking)
///
/// Used by the message queue system to track and filter messages.

import '../websocket_messages.dart';

/// A WebSocket message wrapped with queue metadata
class WsQueuedMessage {
  /// The original WebSocket message
  final WsMessage message;

  /// Sport ID this message belongs to (extracted from message data)
  /// null if message doesn't have sport info (e.g., balance_up, heartbeat)
  final int? sportId;

  /// Timestamp when this message was added to the queue
  final DateTime enqueuedAt;

  WsQueuedMessage({required this.message, this.sportId, DateTime? enqueuedAt})
    : enqueuedAt = enqueuedAt ?? DateTime.now();

  /// Age of this message in milliseconds (time since enqueue)
  int get ageMs => DateTime.now().difference(enqueuedAt).inMilliseconds;

  /// Message type (convenience accessor)
  WsMessageType get type => message.type;

  /// Raw data (convenience accessor)
  Map<String, dynamic> get data => message.data;

  /// Extract eventId from message data if available
  int? get eventId {
    final d = data['d'] as Map<String, dynamic>?;
    if (d != null) {
      return d['eventId'] as int? ??
          d['domainEventId'] as int? ??
          d['ei'] as int?;
    }
    return data['eventId'] as int?;
  }

  /// Extract marketId from message data if available
  int? get marketId {
    final d = data['d'] as Map<String, dynamic>?;
    if (d != null) {
      return d['marketId'] as int? ??
          d['domainMarketId'] as int? ??
          d['mi'] as int?;
    }
    return data['marketId'] as int?;
  }

  /// Create from WsMessage with auto-extracted sportId
  factory WsQueuedMessage.fromMessage(WsMessage message) {
    final sportId = _extractSportId(message);
    return WsQueuedMessage(message: message, sportId: sportId);
  }

  /// Extract sportId from message data
  /// Message format: {"s":1,"t":"odds_up","d":{...}}
  static int? _extractSportId(WsMessage message) {
    // Try to get 's' field from root data
    final sportId = message.data['s'] as int?;
    if (sportId != null) return sportId;

    // Try nested data
    final d = message.data['d'] as Map<String, dynamic>?;
    if (d != null) {
      return d['sportId'] as int? ?? d['s'] as int?;
    }

    return null;
  }

  @override
  String toString() {
    return 'WsQueuedMessage(type: ${message.type.name}, sportId: $sportId, ageMs: $ageMs)';
  }
}
