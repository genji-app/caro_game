/// Status của quá trình chuyển sport
enum SportSwitchStatus {
  /// Không có gì đang xảy ra
  idle,

  /// User vừa tap, đang đợi debounce
  preparing,

  /// Đang unsubscribe và clear data
  switching,

  /// Đang gọi API
  loading,

  /// Hoàn thành
  ready,

  /// Có lỗi xảy ra
  error,
}

/// State class cho sport switching process
class SportSwitchState {
  /// Current status
  final SportSwitchStatus status;

  /// Sport ID hiện tại (data đã load xong)
  final int currentSportId;

  /// Sport ID đích (user muốn switch tới)
  final int? targetSportId;

  /// Version của request hiện tại (để detect stale response)
  final int requestVersion;

  /// Error message nếu status là error
  final String? errorMessage;

  /// Timestamp khi switch bắt đầu
  final DateTime? startedAt;

  const SportSwitchState({
    this.status = SportSwitchStatus.idle,
    this.currentSportId = 1,
    this.targetSportId,
    this.requestVersion = 0,
    this.errorMessage,
    this.startedAt,
  });

  /// Factory cho initial state
  factory SportSwitchState.initial({int sportId = 1}) =>
      SportSwitchState(status: SportSwitchStatus.idle, currentSportId: sportId);

  // ============================================
  // Computed Properties
  // ============================================

  /// Đang trong quá trình switching?
  bool get isSwitching =>
      status == SportSwitchStatus.preparing ||
      status == SportSwitchStatus.switching ||
      status == SportSwitchStatus.loading;

  /// Data đã ready để hiển thị?
  bool get isReady =>
      status == SportSwitchStatus.ready || status == SportSwitchStatus.idle;

  /// Có lỗi?
  bool get hasError => status == SportSwitchStatus.error;

  /// Sport ID để hiển thị trên UI (target nếu đang switch, còn lại là current)
  int get displaySportId => targetSportId ?? currentSportId;

  // ============================================
  // Copy Methods
  // ============================================

  SportSwitchState copyWith({
    SportSwitchStatus? status,
    int? currentSportId,
    int? targetSportId,
    int? requestVersion,
    String? errorMessage,
    DateTime? startedAt,
    bool clearTarget = false,
    bool clearError = false,
  }) {
    return SportSwitchState(
      status: status ?? this.status,
      currentSportId: currentSportId ?? this.currentSportId,
      targetSportId: clearTarget ? null : (targetSportId ?? this.targetSportId),
      requestVersion: requestVersion ?? this.requestVersion,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      startedAt: startedAt ?? this.startedAt,
    );
  }

  // ============================================
  // State Transition Helpers
  // ============================================

  /// Transition to preparing state
  SportSwitchState toPreparing(int targetSportId) => copyWith(
    status: SportSwitchStatus.preparing,
    targetSportId: targetSportId,
    clearError: true,
  );

  /// Transition to switching state
  SportSwitchState toSwitching(int newVersion) => copyWith(
    status: SportSwitchStatus.switching,
    requestVersion: newVersion,
    startedAt: DateTime.now(),
  );

  /// Transition to loading state
  SportSwitchState toLoading() => copyWith(status: SportSwitchStatus.loading);

  /// Transition to ready state
  SportSwitchState toReady(int sportId) => SportSwitchState(
    status: SportSwitchStatus.ready,
    currentSportId: sportId,
    requestVersion: requestVersion,
  );

  /// Transition to error state
  SportSwitchState toError(String message) => copyWith(
    status: SportSwitchStatus.error,
    errorMessage: message,
    clearTarget: true,
  );

  /// Reset to idle
  SportSwitchState toIdle() => copyWith(
    status: SportSwitchStatus.idle,
    clearTarget: true,
    clearError: true,
  );

  @override
  String toString() {
    return 'SportSwitchState(status: $status, current: $currentSportId, '
        'target: $targetSportId, version: $requestVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SportSwitchState &&
        other.status == status &&
        other.currentSportId == currentSportId &&
        other.targetSportId == targetSportId &&
        other.requestVersion == requestVersion &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      currentSportId,
      targetSportId,
      requestVersion,
      errorMessage,
    );
  }
}
