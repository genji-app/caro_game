import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trạng thái khởi tạo app
enum AppInitStatus {
  /// Đang khởi tạo - hiển thị shimmer
  initializing,

  /// Đã khởi tạo xong - hiển thị nội dung
  ready,

  /// Có lỗi khi khởi tạo - sẽ clear data và logout
  error,
}

/// State chứa thông tin về quá trình khởi tạo app
class AppInitState {
  final AppInitStatus status;
  final String? errorMessage;

  const AppInitState({
    this.status = AppInitStatus.initializing,
    this.errorMessage,
  });

  bool get isInitializing => status == AppInitStatus.initializing;
  bool get isReady => status == AppInitStatus.ready;
  bool get hasError => status == AppInitStatus.error;

  AppInitState copyWith({AppInitStatus? status, String? errorMessage}) =>
      AppInitState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

/// Notifier để quản lý trạng thái khởi tạo app
class AppInitNotifier extends StateNotifier<AppInitState> {
  AppInitNotifier() : super(const AppInitState());

  /// Đánh dấu bắt đầu khởi tạo
  void startInitializing() {
    state = const AppInitState(status: AppInitStatus.initializing);
  }

  /// Đánh dấu khởi tạo thành công
  void setReady() {
    state = const AppInitState(status: AppInitStatus.ready);
  }

  /// Đánh dấu có lỗi khi khởi tạo
  void setError([String? message]) {
    state = AppInitState(status: AppInitStatus.error, errorMessage: message);
  }

  /// Reset về trạng thái ban đầu (dùng khi logout)
  void reset() {
    state = const AppInitState(status: AppInitStatus.ready);
  }
}

/// Provider cho trạng thái khởi tạo app
final appInitProvider = StateNotifierProvider<AppInitNotifier, AppInitState>(
  (ref) => AppInitNotifier(),
);

/// Convenience provider để check nhanh trạng thái
final isAppInitializingProvider = Provider<bool>(
  (ref) => ref.watch(appInitProvider).isInitializing,
);

final isAppReadyProvider = Provider<bool>(
  (ref) => ref.watch(appInitProvider).isReady,
);
