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

/// Valid sport IDs — matches SportType in sport_constants.dart
class SportIds {
  static const int football = 1;
  static const int basketball = 2;
  static const int boxing = 3;
  static const int tennis = 4;
  static const int volleyball = 5;
  static const int tableTennis = 6;
  static const int badminton = 7;

  static const List<int> all = [
    football,
    basketball,
    boxing,
    tennis,
    volleyball,
    tableTennis,
    badminton,
  ];

  static bool isValid(int id) => all.contains(id);
}
