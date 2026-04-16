import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/providers/main_content_provider.dart';
import 'package:co_caro_flame/s88/core/providers/pending_toast_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/app_init_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/websocket_provider.dart';
import 'package:co_caro_flame/s88/features/auth/domain/providers/auth_providers.dart';
import 'package:co_caro_flame/s88/features/betting/my_bet/my_bet_providers.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/providers/parlay_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/features/profile/withdraw/domain/providers/withdraw_overlay_provider.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';

/// Listens to kick events from WebSocket (LOGIN_ANOTHER_DEVICE)
/// When user is kicked due to logging in from another device:
/// 1. Shows toast notification
/// 2. Closes all overlays
/// 3. Resets navigation to home
/// 4. Logs out the user
class KickEventListener extends ConsumerWidget {
  final Widget child;

  const KickEventListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(kickEventStreamProvider, (previous, next) {
      next.whenData((reason) {
        _handleKickEvent(context, ref, reason);
      });
    });

    return child;
  }

  void _handleKickEvent(BuildContext context, WidgetRef ref, String reason) {
    debugPrint('🔴 KickEventListener: Received kick event - $reason');

    // 1. Store pending toast to be shown on new screen after MaterialApp rebuilds
    // We can't show toast here because MaterialApp will be replaced when auth state changes
    ref.read(pendingToastProvider.notifier).state = const PendingToast(
      message: 'Bạn đã đăng nhập trên thiết bị khác!',
      title: 'Thông báo',
      isError: true,
    );

    // 2. Close all overlays (wrapped in try-catch to prevent errors)
    _closeAllOverlays(context, ref);

    // 3. Pop all dialogs/routes to root
    try {
      if (context.mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error popping routes - $e');
    }

    // 4. Reset navigation to home first
    try {
      ref.read(mainContentProvider.notifier).goToHome();
      debugPrint('🔴 KickEventListener: Reset to home');
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error resetting to home - $e');
    }

    // 5. Logout the user from BOTH auth providers
    // authNotifierProvider - used for login/register flow
    try {
      ref.read(authNotifierProvider.notifier).logout();
      debugPrint('🔴 KickEventListener: authNotifierProvider logout called');
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error during authNotifier logout - $e');
    }

    // authProvider - used by header and UI to check auth state
    try {
      ref.read(authProvider.notifier).logout();
      debugPrint('🔴 KickEventListener: authProvider logout called');
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error during authProvider logout - $e');
    }

    // 6. Schedule UI refresh after current frame to ensure state is cleared
    SchedulerBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔴 KickEventListener: Post frame callback - refreshing UI');

      // Invalidate data providers to force refresh when user logs in again
      try {
        // ref.invalidate(profileProvider);
        ref.invalidate(userInfoProvider);
        ref.invalidate(leagueProvider);
        ref.invalidate(websocketProvider);
        debugPrint('🔴 KickEventListener: Invalidated providers');
      } catch (e) {
        debugPrint('🔴 KickEventListener: Error invalidating providers - $e');
      }

      // Set app to ready state (hides shimmer, shows logged-out home page)
      try {
        ref.read(appInitProvider.notifier).setReady();
        debugPrint('🔴 KickEventListener: Set app to ready');
      } catch (e) {
        debugPrint('🔴 KickEventListener: Error setting ready - $e');
      }
    });
  }

  /// Close all overlay panels
  void _closeAllOverlays(BuildContext context, WidgetRef ref) {
    // Profile overlay
    try {
      ProfileNavigation.maybeOf(context)?.close();
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error closing profile overlay - $e');
    }

    // MyBet overlay (NotifierProvider)
    try {
      ref.read(myBetOverlayVisibleProvider.notifier).close();
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error closing myBet overlay - $e');
    }

    // Deposit overlay (StateProvider)
    try {
      ref.read(depositOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error closing deposit overlay - $e');
    }

    // Codepay transfer overlay (StateProvider)
    try {
      ref.read(codepayTransferOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error closing codepay overlay - $e');
    }

    // Withdraw overlay (StateProvider)
    try {
      ref.read(withdrawOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error closing withdraw overlay - $e');
    }

    // Parlay overlay (StateProvider)
    try {
      ref.read(parlayOverlayVisibleProvider.notifier).state = false;
    } catch (e) {
      debugPrint('🔴 KickEventListener: Error closing parlay overlay - $e');
    }
  }
}
