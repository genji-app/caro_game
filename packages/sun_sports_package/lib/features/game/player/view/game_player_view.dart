import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:sun_sports/features/game/game.dart';

/// The primary UI View for the Game Player feature.
///
/// Follows VGV View pattern: receives game data from [GamePlayerScreen]
/// and renders the game content layer (WebView + Loading/Failure overlays).
///
/// System-level overlays (orientation mismatch notice) are intentionally
/// excluded — they are owned and rendered by [GamePlayerScreen] which holds
/// the corresponding mismatch state and logic.
///
/// [GamePlayerScreen] (Page) → [GamePlayerView] (View) → child widgets (Dumb)
class GamePlayerView extends StatelessWidget {
  const GamePlayerView({
    required this.game,
    required this.webViewId,
    super.key,
  });

  final GameBlock game;
  final String webViewId;

  @override
  Widget build(BuildContext context) {
    return GamePlayerBackground(
      child: Stack(
        children: [
          // Layer 1: WebView (isolated to prevent unnecessary rebuilds)
          _GameWebViewLayer(game: game, webViewId: webViewId),

          // Layer 2: Loading / Failure overlay (content state)
          _StatusOverlay(game: game),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GameWebViewLayer — Isolated WebView rendering layer
// ---------------------------------------------------------------------------

/// Isolated layer for the WebView to prevent unnecessary rebuilds of sibling layers.
class _GameWebViewLayer extends ConsumerWidget {
  const _GameWebViewLayer({required this.game, required this.webViewId});

  final GameBlock game;
  final String webViewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameUrl = ref.watch(
      gamePlayerProvider(game).select((s) => s.gameUrl),
    );
    final isNewTabOpened = ref.watch(
      gamePlayerProvider(game).select((s) {
        return s.maybeMap(
          playing: (s) => s.isNewTabOpened,
          orElse: () => false,
        );
      }),
    );
    final notifier = ref.read(gamePlayerProvider(game).notifier);

    return Positioned.fill(
      child: GamePlayerScaffold(
        showControls: !game.isInHouseGame,
        onGoBack: notifier.requestExit,
        child: _buildContent(context, gameUrl, isNewTabOpened, notifier),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String? gameUrl,
    bool isNewTabOpened,
    GamePlayerNotifier notifier,
  ) {
    if (gameUrl == null) return const SizedBox.shrink();

    // iOS Safari memory workaround: open game in a new browser tab instead
    // of embedding it in a WebView that would exceed Safari's memory limit.
    if (isIOSSafariWeb && game.openInNewTabOnIOSSafariWeb) {
      return GamePlayerNewTabPlaceholder(
        game: game,
        gameUrl: gameUrl,
        alreadyOpened: isNewTabOpened,
        onOpened: notifier.onNewTabOpened,
        onClose: notifier.requestExit,
      );
    }

    return GameRunnerView(
      key: ValueKey('runner-$webViewId'),
      game: game,
      gameUrl: gameUrl,
      webViewId: webViewId,
      controller: notifier.runnerController,
    );
  }
}

// ---------------------------------------------------------------------------
// _StatusOverlay — Loading / Failure overlay layer
// ---------------------------------------------------------------------------

/// Isolated layer for Status messages (Loading / Failure).
///
/// Colocated with [GamePlayerView] since it is part of the View's visual stack.
class _StatusOverlay extends ConsumerWidget {
  const _StatusOverlay({required this.game});

  final GameBlock game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLoading = ref.watch(
      gamePlayerProvider(game).select((s) => s.showLoading),
    );
    final failureState = ref.watch(
      gamePlayerProvider(
        game,
      ).select((s) => s.maybeMap(failure: (f) => f, orElse: () => null)),
    );

    if (!showLoading && failureState == null) return const SizedBox.shrink();

    final notifier = ref.read(gamePlayerProvider(game).notifier);

    // ColoredBox ensures the overlay is fully opaque at the Flutter layer.
    // Platform views (WebViews) render above Flutter in Z-order on mobile/web,
    // so making the native view transparent (see inapp_runner_view.dart) is the
    // primary fix. This ColoredBox is a belt-and-suspenders fallback so that the
    // failure view (which has no background) also blocks the WebView.
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: showLoading
              ? const Center(
                  key: ValueKey('loading'),
                  child: GamePlayerLoadingView(),
                )
              : Center(
                  key: const ValueKey('failure'),
                  child: GamePlayerFailureView(
                    failureState: failureState!,
                    onClose: notifier.requestExit,
                    onRetry: notifier.retry,
                  ),
                ),
        ),
      ),
    );
  }
}
