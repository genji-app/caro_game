import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

/// Guards against rapid game session creation that causes provider-side
/// session conflicts (e.g., error 1028 from SEXY/AMB).
///
/// ## Problem
/// Game providers issue one active session per player. When the user
/// rapidly opens → backs out → opens a game, the previous session
/// hasn't been released server-side yet, causing the new session request
/// to fail with "1028 Unable to proceed".
///
/// ## Solution
/// This guard enforces a cooldown period between game sessions.
/// After a game session ends (notifier disposed), the guard blocks
/// new game launches for [_cooldown] duration, giving the provider
/// server time to clean up the old session.
///
/// ## Usage
/// ```dart
/// final guard = ref.read(gameSessionGuardProvider);
/// if (!guard.canLaunchGame) {
///   // Show "please wait" feedback
///   return;
/// }
/// guard.onSessionStarted();
/// // Navigate to GamePlayerScreen...
/// ```
class GameSessionGuard with LoggerMixin {
  @override
  String get logTag => 'GameSessionGuard';

  /// Cooldown duration after a game session ends before allowing a new one.
  ///
  /// SEXY/AMB typically needs ~2-3 seconds to fully release a session.
  static const _cooldown = Duration(seconds: 2);

  final Map<String, DateTime> _lastSessionEndedAt = {};
  final Map<String, bool> _isSessionActive = {};

  /// Whether a new game can be launched for this provider right now.
  ///
  /// Returns `false` if:
  /// - A session is currently active (not yet disposed), OR
  /// - The cooldown period hasn't elapsed since the last session ended.
  bool canLaunchGame(String providerId) {
    if (_isSessionActive[providerId] == true) {
      logWarning('Game launch blocked: session still active for $providerId');
      return false;
    }

    final lastEndedAt = _lastSessionEndedAt[providerId];
    if (lastEndedAt != null) {
      final elapsed = DateTime.now().difference(lastEndedAt);
      if (elapsed < _cooldown) {
        final remaining = _cooldown - elapsed;
        logWarning(
          'Game launch blocked: cooldown active for $providerId '
          '(${remaining.inMilliseconds}ms remaining)',
        );
        return false;
      }
    }

    return true;
  }

  /// The remaining cooldown time before a new game can be launched for a provider.
  /// Returns [Duration.zero] if no cooldown is active.
  Duration remainingCooldown(String providerId) {
    final lastEndedAt = _lastSessionEndedAt[providerId];
    if (lastEndedAt == null) return Duration.zero;
    final elapsed = DateTime.now().difference(lastEndedAt);
    if (elapsed >= _cooldown) return Duration.zero;
    return _cooldown - elapsed;
  }

  /// Mark a game session as started.
  ///
  /// Call this when navigating to [GamePlayerScreen] or in [GamePlayerNotifier].
  void onSessionStarted(String providerId) {
    _isSessionActive[providerId] = true;
    _lastSessionEndedAt.remove(providerId);
    logInfo('Game session started for $providerId');
  }

  /// Mark a game session as ended and start the cooldown timer.
  ///
  /// Call this when [GamePlayerNotifier] is disposed.
  void onSessionEnded(String providerId) {
    _isSessionActive[providerId] = false;
    _lastSessionEndedAt[providerId] = DateTime.now();
    logInfo(
      'Game session ended for $providerId, cooldown started (${_cooldown.inSeconds}s)',
    );
  }
}
