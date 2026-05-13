import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Global singleton provider for [GameSessionGuard].
///
/// Lives for the entire app lifetime — NOT autoDispose.
final gameSessionGuardProvider = Provider<GameSessionGuard>((ref) {
  return GameSessionGuard();
});

/// Provider for [GamePlayerNotifier], scoped per [GameBlock].
///
/// `autoDispose` ensures the notifier is cleaned up when the screen is popped.
/// `family` scopes one notifier instance per game.
final gamePlayerProvider = StateNotifierProvider.autoDispose
    .family<GamePlayerNotifier, GamePlayerState, GameBlock>((ref, game) {
      final repository = ref.read(caxiloRepositoryProvider);
      final userNotifier = ref.read(userProvider.notifier);
      final sessionGuard = ref.read(gameSessionGuardProvider);

      ref.onDispose(() {
        if (game.requiresSessionGuard) {
          sessionGuard.onSessionEnded(game.providerId);
        }

        // Refresh balance after game exit.
        // System UI restoration is handled by FullscreenRequired widget dispose.
        Future.microtask(() {
          userNotifier.refreshBalance();
        });
      });

      return GamePlayerNotifier(
        game: game,
        repository: repository,
        sessionGuard: sessionGuard,
      );
    });
