import 'package:co_caro_flame/s88/core/services/models/api_v2/sport_constants.dart';

/// Configuration cho sport switching behavior
class SportSwitchingConfig {
  /// Thời gian debounce trước khi thực hiện switch
  final Duration debounceDuration;

  /// Timeout cho API call
  final Duration apiTimeout;

  /// Số lần retry khi lỗi
  final int maxRetries;

  /// Delay giữa các lần retry
  final Duration retryDelay;

  /// Bật/tắt debounce (tắt cho testing)
  final bool enableDebounce;

  /// Bật/tắt version check
  final bool enableVersionCheck;

  /// Bật/tắt cancel token
  final bool enableCancelToken;

  /// Bật/tắt logging
  final bool logEnabled;

  const SportSwitchingConfig({
    this.debounceDuration = const Duration(milliseconds: 250),
    this.apiTimeout = const Duration(seconds: 15),
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
    this.enableDebounce = true,
    this.enableVersionCheck = true,
    this.enableCancelToken = true,
    this.logEnabled = true,
  });

  /// Config mặc định
  static const defaultConfig = SportSwitchingConfig();

  /// Config cho testing (không debounce)
  static const testConfig = SportSwitchingConfig(
    debounceDuration: Duration.zero,
    enableDebounce: false,
    apiTimeout: Duration(seconds: 5),
  );

  /// Copy with modifications
  SportSwitchingConfig copyWith({
    Duration? debounceDuration,
    Duration? apiTimeout,
    int? maxRetries,
    Duration? retryDelay,
    bool? enableDebounce,
    bool? enableVersionCheck,
    bool? enableCancelToken,
    bool? logEnabled,
  }) {
    return SportSwitchingConfig(
      debounceDuration: debounceDuration ?? this.debounceDuration,
      apiTimeout: apiTimeout ?? this.apiTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      enableDebounce: enableDebounce ?? this.enableDebounce,
      enableVersionCheck: enableVersionCheck ?? this.enableVersionCheck,
      enableCancelToken: enableCancelToken ?? this.enableCancelToken,
      logEnabled: logEnabled ?? this.logEnabled,
    );
  }
}

/// Helper extension cho SportType validation
extension SportTypeValidation on SportType {
  /// Kiểm tra sport ID có valid không
  static bool isValidId(int id) {
    return SportType.values.any((e) => e.id == id);
  }

  /// Danh sách tất cả sport IDs
  static List<int> get allIds => SportType.values.map((e) => e.id).toList();
}
