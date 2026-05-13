import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:game_engine/game_engine.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import 'package:co_caro_flame/s88/core/utils/web_browser_detect/web_browser_detect.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/shared/widgets/orientation/app_orientation_provider.dart';
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
    this.game = const GameBlock.liveStream(
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

  /// Cached reference to the nearest [FullscreenGuardController].
  /// Stored here because [FullscreenGuard.of] must not be called in [dispose]
  /// (element is already unmounted at that point).
  // ignore: unused_field
  FullscreenGuardController? _fullscreenGuard;

  GameBlock get game => widget.game;

  @override
  void initState() {
    super.initState();
    _webViewId =
        'game-webview-${game.gameCode.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    /*
    if (kIsWeb) {
      // Request fullscreen via FullscreenGuard gate (user must tap to satisfy browser gesture).
      // Store controller reference here — calling FullscreenGuard.of in dispose() is unsafe
      // because the element is already unmounted at that point.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fullscreenGuard = FullscreenGuard.of(context);
        _fullscreenGuard!.request(
          const FullscreenGateRequest(
            tag: 'gamePlayer',
            // On iOS Safari, show the swipe-up gate instead of auto-satisfying.
            // The scroll trick (Minimal UI) is more reliable when triggered
            // from within the user gesture context (swipe up on the overlay).
            requiresGestureOnIosSafari: true,
          ),
        );
      });
    }
    */
  }

  @override
  void dispose() {
    /*
    if (kIsWeb) {
      _fullscreenGuard?.clear();
    }
    */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve policy for the current game
    final OrientationPolicy policy = ref
        .watch(gameBlockOrientationResolverProvider)
        .resolve(context, game);

    // BƯỚC QUAN TRỌNG: Đăng ký policy này với Global Stack thông qua Declarative Provider.
    // Việc push và pop tự động được Riverpod quản lý theo vòng đời của Widget này.
    ref.watch(appOrientationLifecycleProvider(policy));

    final canPop = ref.watch(gamePlayerProvider(game).select((s) => s.canPop));

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
      switch (widget.game) {
        case final InHouseGameBlock i:
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
            enableHostMessage: i.enableHostMessage,
            loadStopDebounce: i.loadStopDebounce,
          );
        case final LiveStreamGameBlock t:
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
            loadStopDebounce: t.loadStopDebounce,
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

    Widget webViewContent;
    switch (widget.game) {
      case final InHouseGameBlock i:
        webViewContent = IHRunner(
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
          enableHostMessage: i.enableHostMessage,
          loadStopDebounce: i.loadStopDebounce,
        );
      case final LiveStreamGameBlock t:
        webViewContent = PLRunner(
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
          loadStopDebounce: t.loadStopDebounce,
        );
    }

    return AnimatedOpacity(
      opacity: showWebView ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 777),
      curve: Curves.slowMiddle,
      child: webViewContent,
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

/// Full-screen error overlay.
///
/// Rebuilds when [GamePlayerState.status], [GamePlayerState.errorType],
/// or [GamePlayerState.errorMessage] change.
class _ErrorOverlay extends ConsumerWidget {
  const _ErrorOverlay({required this.game});

  final GameBlock game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamePlayerProvider(game));

    if (state.status == GamePlayerStatus.maintenance) {
      return Positioned.fill(
        child: Center(
          child: GamePlayerMaintenance(
            onGoHomePressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      );
    }

    if (state.status != GamePlayerStatus.failure) {
      return const SizedBox.shrink();
    }

    final errorType = state.errorType;
    final errorMessage = state.errorMessage;
    final notifier = ref.read(gamePlayerProvider(game).notifier);
    void goBack() => Navigator.of(context).maybePop();
    void retry() => notifier.retry();

    final Widget child = switch (errorType) {
      GamePlayerErrorType.network => GamePlayerFailure(
        message: const Text('Không có kết nối mạng'),
        secondaryMessage: const Text('Kiểm tra kết nối và thử lại'),
        onRetry: state.isRetryable ? retry : null,
        onGoBack: goBack,
      ),
      GamePlayerErrorType.sessionExpired => GamePlayerFailure(
        message: const Text('Phiên đăng nhập hết hạn'),
        secondaryMessage: const Text('Vui lòng đăng nhập lại để tiếp tục'),
        onGoBack: goBack,
      ),
      GamePlayerErrorType.comingSoon => GamePlayerFailure(
        message: const Text('Game sắp ra mắt'),
        secondaryMessage: const Text('Nội dung này chưa được phát hành'),
        onGoBack: goBack,
      ),
      GamePlayerErrorType.unavailable => GamePlayerFailure(
        message: const Text('Game không khả dụng'),
        secondaryMessage: const Text(
          'Game này hiện đang tạm dừng hoặc đang phát triển',
        ),
        onGoBack: goBack,
      ),
      GamePlayerErrorType.serverError => GamePlayerFailure(
        message: const Text('Lỗi máy chủ'),
        secondaryMessage: const Text('Máy chủ gặp sự cố, vui lòng thử lại'),
        onRetry: state.isRetryable ? retry : null,
        onGoBack: goBack,
      ),
      GamePlayerErrorType.unknown || null => GamePlayerFailure(
        message: Text(errorMessage ?? I18n.msgSomethingWentWrong),
        onRetry: state.isRetryable ? retry : null,
        onGoBack: goBack,
      ),
    };

    return Positioned.fill(child: Center(child: child));
  }
}
