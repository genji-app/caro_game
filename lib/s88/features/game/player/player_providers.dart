import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/services/system_ui/system_ui.dart';
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
      final repository = ref.read(gameRepositoryProvider);
      final userNotifier = ref.read(userProvider.notifier);
      final systemUi = ref.read(systemUiProvider);
      final sessionGuard = ref.read(gameSessionGuardProvider);

      ref.onDispose(() {
        if (game.requiresSessionGuard) {
          sessionGuard.onSessionEnded(game.providerId);
        }

        // Auto restore mobile-specific system UI when the game screen pops
        systemUi.restoreDefaultSystemUI();

        // Refresh balance after exiting the game so the main screen
        // always shows the latest balance without requiring manual pull-to-refresh.
        // We use Future.microtask to defer the call out of the dispose() lifecycle,
        // avoiding Riverpod's "modifying provider while widget tree is disposing" error.
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
