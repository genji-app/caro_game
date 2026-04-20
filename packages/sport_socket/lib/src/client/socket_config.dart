import '../api/auto_refresh_manager.dart';
import '../utils/logger.dart';

/// Configuration for SportSocketClient.
class SocketConfig {
  /// WebSocket URL
  final String url;

  /// Sampling interval for batch processing
  final Duration sampleInterval;

  /// Maximum messages to parse per sample
  final int maxParsePerSample;

  /// Maximum pending queue size
  final int maxPendingQueueSize;

  /// Pending message expiration time
  final Duration pendingExpiration;

  /// Delay before reconnecting
  final Duration reconnectDelay;

  /// Maximum reconnection attempts (0 = infinite)
  final int maxReconnectAttempts;

  /// Whether to auto-reconnect on disconnect
  final bool autoReconnect;

  /// Whether to enable metrics emission
  final bool enableMetrics;

  /// Interval for metrics emission
  final Duration metricsInterval;

  /// Ping interval to keep connection alive
  final Duration pingInterval;

  /// Pong timeout - reconnect if no pong received within this duration
  final Duration pongTimeout;

  /// Logger instance
  final Logger logger;

  /// Auto refresh configuration
  final AutoRefreshConfig autoRefreshConfig;

  /// Callback để refresh token trước khi reconnect
  /// Return userTokenSb mới nếu refresh thành công, null nếu thất bại
  final Future<String?> Function()? onTokenRefresh;

  // ===== V2 Protocol Configuration =====

  /// Whether to use V2 binary Protobuf protocol instead of V1 JSON
  ///
  /// V2 Protocol:
  /// - Binary Protobuf messages from server
  /// - Base64 encoded SUBSCRIBE/UNSUBSCRIBE messages to server
  /// - Channel-based subscriptions (league + match channels)
  /// - 50ms batch interval (faster than V1's 200ms)
  final bool useV2Protocol;

  /// V2: Batch interval for LightBatchProcessor
  final Duration v2BatchInterval;

  /// V2: Maximum batch size before forced flush
  final int v2MaxBatchSize;

  /// V2: Default language for channel subscriptions
  final String v2Language;

  const SocketConfig({
    required this.url,
    this.sampleInterval = const Duration(milliseconds: 200),
    this.maxParsePerSample = 500,
    this.maxPendingQueueSize = 5000,
    this.pendingExpiration = const Duration(seconds: 10),
    this.reconnectDelay = const Duration(seconds: 3),
    this.maxReconnectAttempts = 5,
    this.autoReconnect = true,
    this.enableMetrics = true,
    this.metricsInterval = const Duration(seconds: 30),
    this.pingInterval = const Duration(seconds: 30),
    this.pongTimeout = const Duration(seconds: 10),
    this.logger = const ConsoleLogger(),
    this.autoRefreshConfig = const AutoRefreshConfig(),
    this.onTokenRefresh,
    // V2 defaults
    this.useV2Protocol = false,
    this.v2BatchInterval = const Duration(milliseconds: 50),
    this.v2MaxBatchSize = 1000,
    this.v2Language = 'vi',
  });

  /// Create config for live betting (fast updates)
  factory SocketConfig.liveMode({
    required String url,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
    bool useV2Protocol = false,
    String v2Language = 'vi',
  }) {
    return SocketConfig(
      url: url,
      sampleInterval: const Duration(milliseconds: 100),
      maxParsePerSample: 1000,
      maxPendingQueueSize: 10000,
      pendingExpiration: const Duration(seconds: 5),
      reconnectDelay: const Duration(seconds: 2),
      maxReconnectAttempts: 10,
      autoReconnect: true,
      enableMetrics: true,
      metricsInterval: const Duration(seconds: 30),
      pingInterval: const Duration(seconds: 20),
      pongTimeout: const Duration(seconds: 10),
      logger: logger ?? const ConsoleLogger(),
      autoRefreshConfig: autoRefreshConfig ?? AutoRefreshConfig.live(),
      onTokenRefresh: onTokenRefresh,
      // V2 settings for live mode
      useV2Protocol: useV2Protocol,
      v2BatchInterval: const Duration(milliseconds: 50),
      v2MaxBatchSize: 1000,
      v2Language: v2Language,
    );
  }

  /// Create config for pre-match betting (slower updates)
  factory SocketConfig.preMatchMode({
    required String url,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
    bool useV2Protocol = false,
    String v2Language = 'vi',
  }) {
    return SocketConfig(
      url: url,
      sampleInterval: const Duration(milliseconds: 300),
      maxParsePerSample: 500,
      maxPendingQueueSize: 5000,
      pendingExpiration: const Duration(seconds: 15),
      reconnectDelay: const Duration(seconds: 5),
      maxReconnectAttempts: 5,
      autoReconnect: true,
      enableMetrics: true,
      metricsInterval: const Duration(seconds: 60),
      pingInterval: const Duration(seconds: 30),
      pongTimeout: const Duration(seconds: 10),
      logger: logger ?? const ConsoleLogger(),
      autoRefreshConfig: autoRefreshConfig ?? AutoRefreshConfig.preMatch(),
      onTokenRefresh: onTokenRefresh,
      // V2 settings for pre-match mode
      useV2Protocol: useV2Protocol,
      v2BatchInterval: const Duration(milliseconds: 100),
      v2MaxBatchSize: 500,
      v2Language: v2Language,
    );
  }

  /// Create config for debugging
  factory SocketConfig.debugMode({
    required String url,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
  }) {
    return SocketConfig(
      url: url,
      sampleInterval: const Duration(milliseconds: 500),
      maxParsePerSample: 100,
      maxPendingQueueSize: 1000,
      pendingExpiration: const Duration(seconds: 30),
      reconnectDelay: const Duration(seconds: 1),
      maxReconnectAttempts: 3,
      autoReconnect: true,
      enableMetrics: true,
      metricsInterval: const Duration(seconds: 10),
      pingInterval: const Duration(seconds: 30),
      pongTimeout: const Duration(seconds: 10),
      logger: logger ?? const ConsoleLogger(minLevel: LogLevel.debug),
      autoRefreshConfig: autoRefreshConfig ?? const AutoRefreshConfig(),
      onTokenRefresh: onTokenRefresh,
    );
  }

  /// Create config for testing (no network)
  factory SocketConfig.test({
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
  }) {
    return SocketConfig(
      url: 'ws://localhost:8080',
      sampleInterval: const Duration(milliseconds: 50),
      maxParsePerSample: 100,
      maxPendingQueueSize: 100,
      pendingExpiration: const Duration(seconds: 5),
      reconnectDelay: const Duration(milliseconds: 100),
      maxReconnectAttempts: 0,
      autoReconnect: false,
      enableMetrics: false,
      metricsInterval: const Duration(seconds: 1),
      pingInterval: const Duration(seconds: 10),
      pongTimeout: const Duration(seconds: 5),
      logger: logger ?? const NoOpLogger(),
      autoRefreshConfig: autoRefreshConfig ?? AutoRefreshConfig.disabled(),
      onTokenRefresh: onTokenRefresh,
    );
  }

  /// Create a copy with overrides
  SocketConfig copyWith({
    String? url,
    Duration? sampleInterval,
    int? maxParsePerSample,
    int? maxPendingQueueSize,
    Duration? pendingExpiration,
    Duration? reconnectDelay,
    int? maxReconnectAttempts,
    bool? autoReconnect,
    bool? enableMetrics,
    Duration? metricsInterval,
    Duration? pingInterval,
    Duration? pongTimeout,
    Logger? logger,
    AutoRefreshConfig? autoRefreshConfig,
    Future<String?> Function()? onTokenRefresh,
    // V2 options
    bool? useV2Protocol,
    Duration? v2BatchInterval,
    int? v2MaxBatchSize,
    String? v2Language,
  }) {
    return SocketConfig(
      url: url ?? this.url,
      sampleInterval: sampleInterval ?? this.sampleInterval,
      maxParsePerSample: maxParsePerSample ?? this.maxParsePerSample,
      maxPendingQueueSize: maxPendingQueueSize ?? this.maxPendingQueueSize,
      pendingExpiration: pendingExpiration ?? this.pendingExpiration,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      enableMetrics: enableMetrics ?? this.enableMetrics,
      metricsInterval: metricsInterval ?? this.metricsInterval,
      pingInterval: pingInterval ?? this.pingInterval,
      pongTimeout: pongTimeout ?? this.pongTimeout,
      logger: logger ?? this.logger,
      autoRefreshConfig: autoRefreshConfig ?? this.autoRefreshConfig,
      onTokenRefresh: onTokenRefresh ?? this.onTokenRefresh,
      // V2 options
      useV2Protocol: useV2Protocol ?? this.useV2Protocol,
      v2BatchInterval: v2BatchInterval ?? this.v2BatchInterval,
      v2MaxBatchSize: v2MaxBatchSize ?? this.v2MaxBatchSize,
      v2Language: v2Language ?? this.v2Language,
    );
  }

  @override
  String toString() {
    return 'SocketConfig(url: $url, sampleInterval: ${sampleInterval.inMilliseconds}ms, '
        'maxParsePerSample: $maxParsePerSample, autoReconnect: $autoReconnect, '
        'useV2Protocol: $useV2Protocol)';
  }
}
