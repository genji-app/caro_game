import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/repositories/user_repository/user_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

part 'user_notifier.freezed.dart';

/// User status enum
enum UserStatus {
  /// Initial state
  initial,

  /// Loading user data
  loading,

  /// User data loaded successfully
  success,

  /// Refreshing balance
  refreshing,

  /// Error occurred
  failure,
}

/// User State for detailed user operations
@freezed
sealed class UserState with _$UserState {
  const UserState._();

  const factory UserState({
    /// Current status
    @Default(UserStatus.initial) UserStatus status,

    /// Current user data
    User? user,

    /// Error message if status is failure
    String? error,

    /// Last time user data was updated
    DateTime? lastUpdated,
  }) = _UserState;

  /// Whether user data is currently loading
  bool get isLoading => status == UserStatus.loading;

  /// Whether balance is being refreshed
  bool get isRefreshing => status == UserStatus.refreshing;

  /// Whether user is logged in
  bool get isLoggedIn => user?.isLoggedIn ?? false;
}

/// User Notifier
class UserNotifier extends StateNotifier<UserState> with LoggerMixin {
  UserNotifier({required UserRepository repository})
    : _repository = repository,
      super(const UserState()) {
    _listenToDataSources();
  }

  final UserRepository _repository;
  StreamSubscription<User?>? _userSubscription;

  /// Listen to real-time data sources (WebSocket + HTTP)
  void _listenToDataSources() {
    logDebug('Initializing real-time data source listeners from repository');

    _userSubscription = _repository.userStream.listen((user) {
      if (user != null) {
        logInfo('User state updated from repository: ${user.displayName}');
        state = state.copyWith(
          user: user,
          status: UserStatus.success,
          lastUpdated: DateTime.now(),
        );
      }
    });
  }

  /// Fetch user info.
  Future<void> fetchUserInfo() async {
    logInfo('Fetching user info');
    state = state.copyWith(status: UserStatus.loading, error: null);

    try {
      final user = await _repository.getUserInfo();

      state = state.copyWith(
        user: user,
        status: UserStatus.success,
        lastUpdated: DateTime.now(),
      );
    } on GetUserInfoFailure catch (e, stackTrace) {
      logError('Failed to fetch user info', e, stackTrace);
      state = state.copyWith(
        status: UserStatus.failure,
        error: e.errorMessage ?? 'Không thể tải thông tin người dùng',
      );
    }
  }

  /// Refresh balance only.
  Future<void> refreshBalance() async {
    if (state.isRefreshing) return;

    logInfo('Refreshing user balance');
    state = state.copyWith(status: UserStatus.refreshing);

    try {
      await _repository.getBalance();

      logInfo('Balance refresh complete');
      // State (user.balance) is already updated via userStream listener.
      // Flip status back in case the stream hasn't fired yet.
      if (state.status == UserStatus.refreshing) {
        state = state.copyWith(
          status: UserStatus.success,
          lastUpdated: DateTime.now(),
        );
      }
    } on GetBalanceFailure catch (e, stackTrace) {
      logError('Failed to refresh balance', e, stackTrace);
      // Silently recover — balance will auto-update via WebSocket.
      state = state.copyWith(status: UserStatus.success);
    }
  }

  /// Clear user state
  void clear() {
    logDebug('Clearing user state');
    state = const UserState();
  }

  @override
  void dispose() {
    logDebug('Disposing UserNotifier: Cancelling subscriptions');
    _userSubscription?.cancel();
    super.dispose();
  }
}
