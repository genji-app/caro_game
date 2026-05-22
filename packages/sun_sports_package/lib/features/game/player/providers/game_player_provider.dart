import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/services/providers/user_provider/user_provider.dart';
import 'package:sun_sports/features/game/game.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

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
      });

      return GamePlayerNotifier(
        game: game,
        repository: repository,
        sessionGuard: sessionGuard,
        onRefreshBalance: userNotifier.refreshBalance,
        strictOrientationApply: game.isInHouseGame,
      );
    });
