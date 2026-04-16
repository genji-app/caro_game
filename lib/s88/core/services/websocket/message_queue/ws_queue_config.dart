/// WebSocket Message Queue Configuration
///
/// Central configuration for all message queue components.
/// These values can be adjusted based on performance testing.

/// Configuration constants for WebSocket message queue
class WsQueueConfig {
  WsQueueConfig._();

  /// Maximum number of messages the queue can hold
  /// When full, oldest messages are dropped
  /// Value: 9999 (same as JS/Cocos implementation)
  static const int maxQueueSize = 9999;

  /// Number of messages to process per tick
  /// At 16ms interval: 10 * (1000/16) = ~625 messages/second capacity
  /// Increase if processing is falling behind
  static const int messagesPerFrame = 10;

  /// Timer tick interval for processing
  /// 16ms ≈ 60fps equivalent
  /// Using Timer instead of Ticker because Ticker only fires during frame render
  static const Duration tickInterval = Duration(milliseconds: 16);

  /// Interval between performance log outputs
  /// Production: 30 seconds
  /// Debug: Can reduce to 10 seconds for more frequent feedback
  static const Duration logInterval = Duration(seconds: 30);

  /// Whether debug mode is enabled by default
  /// Debug mode logs each message individually
  /// Set to true during development/testing
  static const bool debugMode = false;

  /// Warning threshold for dropped messages per interval
  /// Logs a warning if more than this many messages dropped
  static const int dropWarningThreshold = 100;

  /// Queue fill percentage that triggers a warning
  /// Logs a warning if queue exceeds this percentage
  static const double queueFillWarningThreshold = 0.8; // 80%
}
