/// Message type constants
abstract class MessageType {
  static const String leagueInsert = 'league_ins';
  static const String eventInsert = 'event_ins';
  static const String eventUpdate = 'event_up';
  static const String eventRemove = 'event_rm';
  static const String marketUpdate = 'market_up';
  static const String oddsUpdate = 'odds_up';
  static const String oddsInsert = 'odds_ins';
  static const String oddsRemove = 'odds_rmv';
  static const String scoreUpdate = 'score_up';
  static const String balanceUpdate = 'balance_up';
  static const String userBalance = 'user_bal';
}

/// Message processing priority (lower = higher priority)
abstract class MessagePriority {
  static const Map<String, int> priorities = {
    MessageType.leagueInsert: 1, // Must exist before events
    MessageType.eventInsert: 2, // Must exist before markets/odds
    MessageType.eventUpdate: 3, // Update existing event
    MessageType.scoreUpdate: 3, // Same priority as event update
    MessageType.marketUpdate: 4, // Market status change
    MessageType.oddsUpdate: 5, // Most frequent
    MessageType.oddsInsert: 5,
    MessageType.oddsRemove: 5,
    MessageType.eventRemove: 6, // Cleanup last
    MessageType.balanceUpdate: 7, // User-specific, lowest priority
    MessageType.userBalance: 7, // User-specific, lowest priority
  };

  static int getPriority(String type) => priorities[type] ?? 99;
}

/// TimeRange values for odds
abstract class TimeRange {
  static const String live = 'LIVE';
  static const String early = 'EARLY';
  static const String today = 'TODAY';
}

/// Default configuration values
abstract class DefaultConfig {
  /// Sampling interval for batch processing (milliseconds)
  static const int sampleIntervalMs = 200;

  /// Maximum messages to parse per sample
  static const int maxParsePerSample = 500;

  /// Maximum pending queue size
  static const int maxPendingQueueSize = 5000;

  /// Pending message expiration time (seconds)
  static const int pendingExpirationSec = 10;

  /// Metrics emission interval (seconds)
  static const int metricsIntervalSec = 30;

  /// Cleanup interval (seconds)
  static const int cleanupIntervalSec = 30;

  /// Reconnect delay (seconds)
  static const int reconnectDelaySec = 3;

  /// Maximum reconnect attempts
  static const int maxReconnectAttempts = 5;

  /// Ping interval (seconds)
  static const int pingIntervalSec = 30;
}

/// JSON field names for fast extraction
abstract class JsonField {
  // Message structure
  static const String type = '"t":"';
  static const String sportId = '"s":';
  static const String data = '"d":';

  // IDs
  static const String leagueId = '"leagueId":';
  static const String eventId = '"eventId":';
  static const String marketId = '"marketId":';
  static const String domainEventId = '"domainEventId":';
  static const String domainMarketId = '"domainMarketId":';

  // Odds specific
  static const String timeRange = '"timeRange":"';
  static const String kafkaOddsList = '"kafkaOddsList":[';
  static const String strOfferId = '"strOfferId":"';
  static const String offerId = '"offerId":';
}
