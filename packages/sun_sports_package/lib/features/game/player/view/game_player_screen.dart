import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

/// Screen to play games in a WebView.
///
/// This is the entry point for the Game Player feature. It handles:
/// 1. Navigation & Routing (Push/Pop logic)
/// 2. Lifecycle (Initialization/Events)
/// 3. Orientation Guard & Mismatch Debouncing
/// 4. Session Guard Cooldown logic
class GamePlayerScreen extends ConsumerStatefulWidget {
  const GamePlayerScreen({required this.game, super.key});

  final GameBlock game;

  /// Returns the [Route] for [GamePlayerScreen].
  ///
  /// Callers own the navigation decision; this widget only provides the route.
  ///
  /// Usage:
  /// ```dart
  /// Navigator.of(context).push(GamePlayerScreen.route(game: myGame));
  /// ```
  static Route<void> route({required GameBlock game}) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, __, ___) => GamePlayerScreen(game: game),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  /// Navigates to [GamePlayerScreen], optionally showing a toast instead of
  /// pushing when a session cooldown is active.
  ///
  /// Prefer using [route] directly when the caller owns the full navigation
  /// decision. Use [push] only when the built-in cooldown toast behavior is
  /// desired.
  static void push(
    BuildContext context,
    WidgetRef ref, {
    required GameBlock game,
    bool showToastIfCooldown = false,
  }) {
    if (showToastIfCooldown && game.requiresSessionGuard) {
      final guard = ref.read(gameSessionGuardProvider);
      if (!guard.canLaunchGame(game.providerId)) {
        final remaining = guard.remainingCooldown(game.providerId).inSeconds;
        unawaited(
          AppToast.showError(
            context,
            message: 'Vui lòng chờ $remaining giây trước khi mở game mới',
          ),
        );
        return;
      }
    }

    Navigator.of(context).push(GamePlayerScreen.route(game: game));
  }

  @override
  ConsumerState<GamePlayerScreen> createState() => _GamePlayerScreenState();
}

class _GamePlayerScreenState extends ConsumerState<GamePlayerScreen> {
  late final String _webViewId;
  bool _hasInitialized = false;
  bool _isExiting = false;
  StreamSubscription<GamePlayerEvent>? _eventSubscription;

  // Manual Mismatch management (Matches orientation_guard example)
  final ValueNotifier<bool> _isMismatched = ValueNotifier<bool>(false);
  bool _lastRawMismatch = false;
  Timer? _mismatchTimer;

  // Captured once in didChangeDependencies — stable for the entire screen lifecycle.
  OrientationController? _capturedController;
  OrientationPolicy? _capturedPreviousPolicy;

  GameBlock get game => widget.game;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _webViewId =
        'game-webview-${game.gameCode.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Event subscription belongs in initState — not in build().
    _eventSubscription = ref
        .read(gamePlayerProvider(game).notifier)
        .events
        .listen(_handleEvent);
  }

  /// Context-dependent initialization belongs here — not in build().
  ///
  /// [didChangeDependencies] is guaranteed to run before the first [build]
  /// and has access to [context], making it the correct place to capture
  /// inherited widget references like [OrientationScope].
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      _hasInitialized = true;

      // Capture the previous policy before any game orientation is applied.
      // This allows restoring the correct orientation (e.g. AppDefaultPortrait) on exit.
      _capturedController = OrientationScope.of(context);
      _capturedPreviousPolicy = OrientationScope.maybePolicyOf(context);

      debugPrint(
        '[GamePlayerScreen] Captured previousPolicy: ${_capturedPreviousPolicy?.debugLabel}',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final policy = ref
            .read(gameOrientationResolverProvider)
            .resolve(context, game);

        ref
            .read(gamePlayerProvider(game).notifier)
            .initializePlayer(
              orientationController: _capturedController!,
              previousPolicy: _capturedPreviousPolicy,
              gamePolicy: policy,
            );
      });
    }
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    _isMismatched.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  void _handleEvent(GamePlayerEvent event) {
    switch (event) {
      case GamePlayerExitEvent():
        if (mounted && !_isExiting) {
          _isExiting = true;
          final navigator = Navigator.of(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) navigator.pop();
          });
        }
    }
  }

  @visibleForTesting
  void handleMismatch(bool mismatched) {
    if (!mounted) return;
    _lastRawMismatch = mismatched;
    _syncMismatchState();
  }

  void _syncMismatchState() {
    _mismatchTimer?.cancel();
    if (!mounted) return;
    final state = ref.read(gamePlayerProvider(game));

    final bool shouldHideMismatch = state.maybeMap(
      initial: (_) => true,
      exiting: (_) => true,
      orElse: () => false,
    );

    if (_lastRawMismatch) {
      // Don't show mismatch during sensitive transitions.
      if (shouldHideMismatch) {
        _isMismatched.value = false;
        return;
      }

      // Already showing — skip debounce.
      if (_isMismatched.value) return;

      // 1s debounce to prevent flicker during normal rotations/transitions.
      _mismatchTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) _isMismatched.value = true;
      });
    } else {
      _isMismatched.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Build — pure widget construction only
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final OrientationPolicy policy = ref
        .watch(gameOrientationResolverProvider)
        .resolve(context, game);

    final notifier = ref.read(gamePlayerProvider(game).notifier);
    final canPop = ref.watch(gamePlayerProvider(game).select((s) => s.canPop));

    // Sync mismatch state when the player transitions in/out of sensitive stages.
    ref.listen(
      gamePlayerProvider(game).select(
        (s) => s.maybeMap(
          initial: (_) => true,
          exiting: (_) => true,
          orElse: () => false,
        ),
      ),
      (_, __) => _syncMismatchState(),
    );

    return Material(
      color: Colors.black,
      child: PopScope(
        canPop: _isExiting || canPop,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          notifier.requestExit();
        },
        child: OrientationGuard(
          policy: policy,
          blockOnMismatch: false,
          onMismatchChanged: handleMismatch,
          // Screen composes: content View + system-level mismatch overlay.
          child: Stack(
            children: [
              GamePlayerView(game: game, webViewId: _webViewId),

              // Orientation mismatch notice — web only.
              // Lives here because Screen owns both the state (_isMismatched)
              // and the logic (handleMismatch / _syncMismatchState).
              if (kIsWeb)
                ValueListenableBuilder<bool>(
                  valueListenable: _isMismatched,
                  builder: (_, isMismatch, __) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isMismatch
                        ? GamePlayerOrientationNotice(
                            key: const ValueKey('mismatch-overlay'),
                            policy: policy,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
