import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_notifier.dart';
import 'package:co_caro_flame/s88/core/services/repositories/user_repository/user_repository.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_manager.dart';

export 'user_notifier.dart';

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final repository = UserRepository(
    http: SbHttpManager.instance,
    wsManager: WebSocketManager.instance,
  );
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// User Provider
final userProvider = StateNotifierProvider.autoDispose<UserNotifier, UserState>(
  (ref) {
    final repository = ref.read(userRepositoryProvider);
    final notifier = UserNotifier(repository: repository);

    // Sync initial auth state
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      notifier.fetchUserInfo();
    }

    // Listen to auth changes
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        notifier.fetchUserInfo();
      } else if (next.status == AuthStatus.unauthenticated) {
        notifier.clear();
      }
    });

    return notifier;
  },
);

final balanceInVNDProvider = Provider.autoDispose<double>(
  (ref) => ref.watch(userProvider).user?.balanceInVND ?? 0.0,
);

/// Display name provider (backward compatible wrapper)
///
/// Note: This now delegates to userProvider for consistency
final userDisplayNameProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(userProvider).user?.displayName ?? 'Guest';
});

/// Avatar URL provider (backward compatible wrapper)
///
/// Note: This now delegates to userProvider for consistency
final userAvatarUrlProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(userProvider).user?.avatarUrl ?? '';
});

final userInfoProvider = Provider.autoDispose<User?>((ref) {
  return ref.watch(userProvider).user;
});
