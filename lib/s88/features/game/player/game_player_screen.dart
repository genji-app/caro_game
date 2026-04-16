import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_engine/game_engine.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import 'package:co_caro_flame/s88/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Screen to play games in a WebView.
///
/// This is a thin UI layer — all business logic is managed by
/// [GamePlayerNotifier] via [gamePlayerProvider].
///
/// ## Widget tree
/// ```
/// PopScope (blocks back while loading)
///   └─ GamePlayerScaffold (background + layout)
///           └─ Stack
///               ├─ _WebViewLayer (WebView + fade-in)
///               ├─ _LoadingOverlay (shimmer + touch blocker)
///               └─ _ErrorOverlay (error + retry)
/// ```
class GamePlayerScreen extends ConsumerStatefulWidget {
  const GamePlayerScreen({required this.game, super.key});

  const GamePlayerScreen.test({
    this.game = const GameBlock(
      providerId: 'amb-vn',
      providerName: 'AMB-VN',
      productId: 'SEXY',
      gameCode: 'MX-LIVE-001',
      gameName: 'Baccarat Classic',
      lang: 'vi',
      lobbyUrl: '',
      cashierUrl: '',
      gameType: GameType.live,
      image: 'amb-vn_MX-LIVE-001_baccarat-classic_thumb.png',
      mobileLogin: false,
      mobileOrientation: GameOrientation.portrait,
      tabletOrientation: GameOrientation.landscape,
      desktopOrientation: GameOrientation.all,
    ),
    super.key,
  });

  final GameBlock game;

  /// Single entry point for all navigation to [GamePlayerScreen].
  ///
  /// By default, it pushes the screen and handles the cooldown inside visually
  /// using a loading overlay. If [showToastIfCooldown] is true, it instead
  /// blocks navigation and shows a toast when a cooldown is active, similar
  /// to the previous implementation.
  ///
  /// Usage:
  /// ```dart
  /// GamePlayerScreen.push(context, ref, game: myGame);
  /// ```
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

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GamePlayerScreen(game: game)),
    );
  }

  @override
  ConsumerState<GamePlayerScreen> createState() => _GamePlayerScreenState();
}

class _GamePlayerScreenState extends ConsumerState<GamePlayerScreen> {
  late final String _webViewId;
  bool _hasInitialized = false;

  GameBlock get game => widget.game;

  @override
  void initState() {
    super.initState();
    _webViewId =
        'game-webview-${game.gameCode.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ref.watch(gamePlayerProvider(game).select((s) => s.canPop));
    final policy = ref
        .watch(gameBlockOrientationResolverProvider)
        .resolve(context, game);

    if (kIsWeb) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(gamePlayerProvider(game).notifier).initializePlayer();
          }
        });
      }
    } else {
      // For mobile: The controller enforces it physically,
      // but waiting for animation frame ensures the layout is correct before load.
      if (!_hasInitialized) {
        _hasInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(gamePlayerProvider(game).notifier).initializePlayer();
          }
        });
      }
    }

    return Material(
      color: Colors.transparent,
      child: OrientationGuard(
        policy: policy,
        child: PopScope(
          canPop: canPop,
          child: GamePlayerBackground(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GamePlayerScaffold(
                    showControls: !game.isInHouseGame,
                    child: _WebViewLayer(game: game, webViewId: _webViewId),
                  ),
                ),
                _LoadingOverlay(game: game),
                _ErrorOverlay(game: game),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layer 1: WebView
// ---------------------------------------------------------------------------

/// Displays the game WebView and controls its fade-in animation.
///
/// Rebuilds only when [GamePlayerState.gameUrl] or
/// [GamePlayerState.showWebView] change.
class _WebViewLayer extends ConsumerStatefulWidget {
  const _WebViewLayer({required this.game, required this.webViewId});

  final GameBlock game;
  final String webViewId;

  @override
  ConsumerState<_WebViewLayer> createState() => _WebViewLayerState();
}

class _WebViewLayerState extends ConsumerState<_WebViewLayer> with LoggerMixin {
  @override
  String get logTag => 'WebViewLayer';

  @override
  Widget build(BuildContext context) {
    final gameUrl = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.gameUrl),
    );
    final isOrientationReady = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.isOrientationReady),
    );

    // Only start building the WebView/Iframe when:
    // 1. Game URL is fetched.
    // 2. Physical orientation change is complete (OrientationGuard applied).
    if (gameUrl == null || !isOrientationReady) return const SizedBox.shrink();

    // ---- Open-in-new-tab strategy (Safari iOS Memory Limit Workaround) ----
    // Because Safari on iPhone enforces extremely strict memory limits on its
    // WebContent process (~1GB), heavy games (containing WebGL, Live Video)
    // sharing the process with Flutter's CanvasKit will eventually trigger a crash.
    //
    // - widget.game.openInNewTabOnIOSSafariWeb: Flag enabled for games carrying this risk.
    // - isIOSSafariWeb: Gatekeeper preventing unnecessary new tabs.
    // Even if openInNewTabOnIOSSafariWeb = true, other OS/browsers (Chrome, Firefox, Android, PC)
    // will fall through and use iframes, as they lack these draconian limits.
    if (isIOSSafariWeb && widget.game.openInNewTabOnIOSSafariWeb) {
      final isNewTabOpened = ref.watch(
        gamePlayerProvider(widget.game).select((s) => s.isNewTabOpened),
      );
      return NewTabGamePlaceholder(
        game: widget.game,
        gameUrl: gameUrl,
        alreadyOpened: isNewTabOpened,
        onOpened: () =>
            ref.read(gamePlayerProvider(widget.game).notifier).onNewTabOpened(),
      );
    }

    final notifier = ref.read(gamePlayerProvider(widget.game).notifier);

    Widget webViewContent;
    if (kIsWeb) {
      if (widget.game.isInHouseGame) {
        webViewContent = IHRunner(
          key: ValueKey('cocos-webview-${widget.webViewId}'),
          gameUrl: gameUrl,
          onLoadStart: notifier.onLoadStart,
          onLoadStop: notifier.onLoadStop,
          onError: notifier.handleError,
          logger: (level, message, {error, stackTrace}) => _onRunnerLog(
            'IH',
            level,
            message,
            error: error,
            stackTrace: stackTrace,
          ),
          onHostMessage: (GameHostEvent event) {
            logDebug('GameHostEvent received: ${event.type}');
            if (event.isCloseWebView) {
              Navigator.of(context).maybePop();
            }
          },
          enableHostMessage: widget.game.enableHostMessage,
          loadStopDebounce: widget.game.loadStopDebounce,
        );
      } else {
        webViewContent = PLRunner(
          key: ValueKey('webview-${widget.webViewId}'),
          gameUrl: gameUrl,
          viewId: widget.webViewId,
          onLoadStart: notifier.onLoadStart,
          onLoadStop: notifier.onLoadStop,
          onError: notifier.handleError,
          logger: (level, message, {error, stackTrace}) => _onRunnerLog(
            'PL',
            level,
            message,
            error: error,
            stackTrace: stackTrace,
          ),
          // forceLandscapeViewport should ONLY be applied on tablet devices when
          // the game's tablet orientation is a landscape variant.
          //
          // Rationale:
          //  - On mobile phones, orientation is handled by the OrientationGuard
          //    locking the system rotation — no viewport injection needed.
          //  - On tablets (iPad), iOS does not rotate screen.width/height, so
          //    games reading those values see portrait dimensions even when fully
          //    in landscape. The JS polyfill patches this, but ONLY needed on tablet.
          //  - If the game's tablet orientation is portrait, we must NOT inject
          //    since the game intentionally shows portrait layout on tablet.
          //
          // Detection: shortestSide ≥ 600 = tablet (matches OrientationResolver logic).
          forceLandscapeViewport: widget.game.shouldForceLandscapeViewport(
            context,
          ),
          loadStopDebounce: widget.game.loadStopDebounce,
        );
      }
    } else {
      webViewContent = _AnimatedWebView(
        game: widget.game,
        webViewId: widget.webViewId,
        gameUrl: gameUrl,
      );
    }

    // Do NOT wrap with Positioned.fill here.
    // _WebViewLayer is a child of AnimatedPositioned inside _AdaptiveGameLayout's
    // Stack, which already constrains its bounds via top/left/right/bottom.
    // Adding another Positioned causes "Competing ParentDataWidgets" error.
    return webViewContent;
  }

  void _onRunnerLog(
    String prefix,
    String level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final fullMessage = '[$prefix] $message';
    switch (level) {
      case 'error':
        logError(fullMessage, error, stackTrace);
      case 'warning':
        logWarning(fullMessage, error, stackTrace);
      case 'info':
        logInfo(fullMessage, error, stackTrace);
      default:
        logDebug(fullMessage, error, stackTrace);
    }
  }
}

/// Wraps a [GameWebView] with a fade-in [AnimatedOpacity].
///
/// Extracted as a separate widget so that changes to [showWebView]
/// only rebuild the opacity wrapper, not the WebView itself.
class _AnimatedWebView extends ConsumerStatefulWidget {
  const _AnimatedWebView({
    required this.game,
    required this.webViewId,
    required this.gameUrl,
  });

  final GameBlock game;
  final String webViewId;
  final String gameUrl;

  @override
  ConsumerState<_AnimatedWebView> createState() => _AnimatedWebViewState();
}

class _AnimatedWebViewState extends ConsumerState<_AnimatedWebView>
    with LoggerMixin {
  @override
  String get logTag => 'AnimatedWebView';

  @override
  Widget build(BuildContext context) {
    final showWebView = ref.watch(
      gamePlayerProvider(widget.game).select((s) => s.showWebView),
    );
    final notifier = ref.read(gamePlayerProvider(widget.game).notifier);

    return AnimatedOpacity(
      opacity: showWebView ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 777),
      curve: Curves.slowMiddle,
      child: widget.game.isInHouseGame
          ? IHRunner(
              key: ValueKey('cocos-webview-${widget.webViewId}'),
              gameUrl: widget.gameUrl,
              onLoadStart: notifier.onLoadStart,
              onLoadStop: notifier.onLoadStop,
              onError: notifier.handleError,
              logger: (level, message, {error, stackTrace}) => _onRunnerLog(
                'IH',
                level,
                message,
                error: error,
                stackTrace: stackTrace,
              ),
              onHostMessage: (GameHostEvent event) {
                logDebug('GameHostEvent received: ${event.type}');
                if (event.isCloseWebView) {
                  Navigator.of(context).maybePop();
                }
              },
              enableHostMessage: widget.game.enableHostMessage,
              loadStopDebounce: widget.game.loadStopDebounce,
            )
          : PLRunner(
              key: ValueKey('webview-${widget.webViewId}'),
              gameUrl: widget.gameUrl,
              viewId: widget.webViewId,
              onLoadStart: notifier.onLoadStart,
              onLoadStop: notifier.onLoadStop,
              onError: notifier.handleError,
              logger: (level, message, {error, stackTrace}) => _onRunnerLog(
                'PL',
                level,
                message,
                error: error,
                stackTrace: stackTrace,
              ),
              // forceLandscapeViewport should ONLY be applied on tablet devices when
              // the game's tablet orientation is a landscape variant.
              //
              // Rationale:
              //  - On mobile phones, orientation is handled by the OrientationGuard
              //    locking the system rotation — no viewport injection needed.
              //  - On tablets (iPad), iOS does not rotate screen.width/height, so
              //    games reading those values see portrait dimensions even when fully
              //    in landscape. The JS polyfill patches this, but ONLY needed on tablet.
              //  - If the game's tablet orientation is portrait, we must NOT inject
              //    since the game intentionally shows portrait layout on tablet.
              //
              // Detection: shortestSide ≥ 600 = tablet (matches OrientationResolver logic).
              forceLandscapeViewport: widget.game.shouldForceLandscapeViewport(
                context,
              ),
              loadStopDebounce: widget.game.loadStopDebounce,
            ),
    );
  }

  void _onRunnerLog(
    String prefix,
    String level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final fullMessage = '[$prefix] $message';
    switch (level) {
      case 'error':
        logError(fullMessage, error, stackTrace);
      case 'warning':
        logWarning(fullMessage, error, stackTrace);
      case 'info':
        logInfo(fullMessage, error, stackTrace);
      default:
        logDebug(fullMessage, error, stackTrace);
    }
  }
}

// ---------------------------------------------------------------------------
// Layer 2: Loading overlay
// ---------------------------------------------------------------------------

/// Full-screen loading overlay that blocks touch and back navigation.
///
/// Rebuilds only when [GamePlayerState.isLoading] changes.
class _LoadingOverlay extends ConsumerWidget {
  const _LoadingOverlay({required this.game});

  final GameBlock game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamePlayerProvider(game));
    // loading is true if:
    // 1. status is loading (fetching URL or WebView loading)
    // 2. AND status is not failure/maintenance
    final isReallyLoading =
        (state.status == GamePlayerStatus.loading || !state.status.isLoaded) &&
        !state.hasError;

    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: isReallyLoading
            ? const AbsorbPointer(child: GamePlayerLoading(progress: null))
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layer 3: Error overlay
// ---------------------------------------------------------------------------

/// Full-screen error overlay with a retry action.
///
/// Rebuilds only when [GamePlayerState.errorMessage] changes.
class _ErrorOverlay extends ConsumerWidget {
  const _ErrorOverlay({required this.game});

  final GameBlock game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamePlayerProvider(game));
    final status = state.status;
    final errorMessage = state.errorMessage;

    if (status == GamePlayerStatus.maintenance) {
      return Positioned.fill(
        child: Center(
          child: GamePlayerMaintenance(
            onGoHomePressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      );
    }

    if (errorMessage == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Center(
        child: GamePlayerFailure(
          // ignore: dead_code, dead_null_aware_expression
          message: Text(errorMessage ?? I18n.msgSomethingWentWrong),
          // secondaryMessage: Text('Xin vui long thu lai'),
          onRetry: () {
            ref.read(gamePlayerProvider(game).notifier).retry();
          },
        ),
      ),
    );
  }
}
