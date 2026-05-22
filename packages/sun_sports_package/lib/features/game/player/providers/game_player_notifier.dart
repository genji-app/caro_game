import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:sun_sports/core/utils/extensions/log_helper.dart';
import 'package:sun_sports/features/game/game.dart';

part 'game_player_notifier.freezed.dart';
part 'game_player_state.dart';

/// Sealed event for 1-way UI notifications (e.g., navigation side-effects).
sealed class GamePlayerEvent {
  const GamePlayerEvent();
}

final class GamePlayerExitEvent extends GamePlayerEvent {
  const GamePlayerExitEvent();
}

// ---------------------------------------------------------------------------
// Process (Notifier)
// ---------------------------------------------------------------------------

/// Manages the full lifecycle and business logic for a Game session.
///
/// Responsibilities:
/// - Manage orientation lifecycle (active control)
/// - Fetch game URL from repository
/// - Track WebView lifecycle events (load start/stop/error)
/// - Manage loading timeouts and retries
/// - Handle session guard cooldowns
///
/// The UI layer ([GamePlayerScreen]) should only read state via `ref.watch`
/// and delegate all mutations to this process.
class GamePlayerNotifier extends StateNotifier<GamePlayerState>
    with LoggerMixin {
  GamePlayerNotifier({
    required GameBlock game,
    required CaxiloRepository repository,
    required GameSessionGuard sessionGuard,
    this.onRefreshBalance,
    this.finishLoadDelay = const Duration(milliseconds: 777),
    this.strictOrientationApply = false,
  }) : _game = game,
       _repository = repository,
       _sessionGuard = sessionGuard,
       super(const GamePlayerState.initial()) {
    logInfo('GamePlayerNotifier created for ${game.gameName}');
    _runnerEventSub = _runnerController.events.listen(_handleRunnerEvent);
  }

  final GameBlock _game;
  final CaxiloRepository _repository;
  final GameSessionGuard _sessionGuard;

  /// Optional callback to refresh the user's balance upon exit.
  final VoidCallback? onRefreshBalance;

  /// If true, a failure to apply orientation via [initializePlayer]
  /// is treated as fatal and prevents game load.
  /// If false, failure is logged and the game loads in current orientation.
  final bool strictOrientationApply;

  /// Injected during [initializePlayer]
  OrientationController? _orientationController;
  OrientationPolicy? _previousPolicy;

  final _eventsController = StreamController<GamePlayerEvent>.broadcast();

  /// Stream of one-off events for the UI (e.g., Exit).
  Stream<GamePlayerEvent> get events => _eventsController.stream;

  /// Additional delay after WebView finishes loading before hiding the overlay.
  /// This ensures that the game engine has enough time to render its initial frame.
  final Duration finishLoadDelay;

  /// Timeout duration before considering the WebView load as failed.
  static const _loadTimeout = Duration(seconds: 30);

  /// Maximum number of retries for getting the game URL.
  static const _maxRetryCount = 3;

  /// Delay to allow page transitions to complete before rotation.
  static const _entryDelay = Duration(milliseconds: 500);

  /// Delay after orientation restore to allow visual settling before pop.
  static const _exitDelay = Duration(milliseconds: 500);

  Timer? _timeoutTimer;
  Timer? _finishLoadTimer;
  Timer? _fallbackLoadTimer;
  bool _isDisposed = false;

  // Runner event bus — owned by this notifier, passed to View via [runnerController].
  final _runnerController = GameRunnerController();
  StreamSubscription<GameRunnerEvent>? _runnerEventSub;

  @override
  GamePlayerState get state => super.state;

  @override
  String get logTag => 'GamePlayer';

  /// Event bus for the active game runner widget.
  ///
  /// The View passes this to [GameRunnerView], which forwards it to the
  /// runner widget (IH or PL). The runner emits [GameRunnerEvent]s; this
  /// notifier processes them via [_handleRunnerEvent].
  GameRunnerController get runnerController => _runnerController;

  void _cancelAllTimers() {
    _timeoutTimer?.cancel();
    _finishLoadTimer?.cancel();
    _fallbackLoadTimer?.cancel();
  }

  // ---- Runner Event Handler ----

  /// Routes incoming [GameRunnerEvent]s from [GameRunnerController] to the
  /// appropriate internal handler.
  ///
  /// This is the single point of entry for all runner signals — no runner
  /// callbacks appear anywhere in the View layer.
  void _handleRunnerEvent(GameRunnerEvent event) {
    switch (event) {
      case RunnerLoadStarted():
        _onLoadStart();
      case RunnerLoadStopped():
        _onLoadStop();
      case RunnerErrorOccurred(:final message):
        _handleError(message: message);
      case RunnerLogEmitted(
        :final prefix,
        :final level,
        :final message,
        :final error,
        :final stackTrace,
      ):
        _logRunnerMessage(
          prefix,
          level,
          message,
          error: error,
          stackTrace: stackTrace,
        );
      case RunnerHostMessageReceived(:final hostEvent):
        _handleHostMessage(hostEvent);
    }
  }

  void _handleHostMessage(GameHostEvent hostEvent) {
    if (hostEvent.isCloseWebView) requestExit();
  }

  /// Transitions the state to a new loading stage.
  /// Ignores the transition if the state is already playing, exiting, or disposed.
  void _transitionToLoading(GamePlayerLoadingStage newStage) {
    if (_isDisposed) return;

    // Do NOT revert state if we are already playing or exiting.
    // This prevents late fetching/orientation callbacks from resetting the UI.
    if (state.isPlaying || state.isExiting) {
      logDebug('Ignoring $newStage: state is ${state.runtimeType}');
      return;
    }

    // Don't revert from loadingAssets back to connecting.
    // WebView may have already started loading while URL fetch was in flight.
    if (state.currentStage == GamePlayerLoadingStage.loadingAssets &&
        newStage == GamePlayerLoadingStage.connecting) {
      logInfo('Ignoring connecting: assets already loading');
      return;
    }

    state = GamePlayerState.loading(
      stage: newStage,
      retryCount: state.retryCount,
      gameUrl: state.gameUrl,
    );
  }

  // ---- Public API (called by UI) ----

  bool _isInitCalled = false;

  /// Call this from the UI once to trigger required startup behaviors.
  /// 1. Set orientation (settingUp)
  /// 2. Check cooldowns
  /// 3. Fetch URL (connecting)
  Future<void> initializePlayer({
    required OrientationController orientationController,
    required OrientationPolicy? previousPolicy,
    required OrientationPolicy gamePolicy,
    bool? isMobileLogin,
  }) async {
    if (_isInitCalled || _isDisposed) return;
    _isInitCalled = true;

    _orientationController = orientationController;
    _previousPolicy = previousPolicy;

    // 1. Setting up orientation
    _transitionToLoading(GamePlayerLoadingStage.settingUp);

    // Cinematic delay: wait for page transition to complete
    await Future<void>.delayed(_entryDelay);
    if (_isDisposed) return;

    // [1] Orientation — severity controlled by strictOrientationApply
    try {
      await orientationController.apply(gamePolicy);
    } catch (e, st) {
      if (strictOrientationApply) {
        logError(
          'Fatal: orientation apply failed for ${gamePolicy.debugLabel}',
          e,
          st,
        );
        state = GamePlayerState.failure(
          failureType: GamePlayerErrorType.orientationSetupFailed,
          isRetryable: false,
          retryCount: state.retryCount,
        );
        return;
      }
      logError('Non-fatal: orientation apply failed, continuing', e, st);
    }
    if (_isDisposed) return;

    // Proceed to load the game URL after orientation is locked (or failed)
    _transitionToLoading(GamePlayerLoadingStage.connecting);

    // [2] Session Guard — luôn best-effort, không block game load
    try {
      if (_game.requiresSessionGuard) {
        final remaining = _sessionGuard.remainingCooldown(_game.providerId);
        if (remaining > Duration.zero) {
          logInfo(
            'Cooldown active. Waiting ${remaining.inSeconds}s before starting session.',
          );
          await Future<void>.delayed(remaining);
          if (_isDisposed) return;
        }
        _sessionGuard.onSessionStarted(_game.providerId);
      }
    } catch (e, st) {
      logError('Session guard check failed (non-fatal)', e, st);
    }

    // 3. Fetch Game URL (Connecting)
    if (_isDisposed) return;
    await loadGameUrl(isMobileLogin: isMobileLogin);
  }

  /// Fetches the game URL from the server and triggers the loading flow.
  Future<void> loadGameUrl({bool? isMobileLogin}) async {
    if (_isDisposed) return;

    logInfo(
      'Fetching game URL: '
      'provider=${_game.providerId}, '
      'product=${_game.productId}, '
      'game=${_game.gameCode}',
    );

    // Clear any previous error and enter connecting stage
    _transitionToLoading(GamePlayerLoadingStage.connecting);

    try {
      final url = await _repository.getGameUrl(
        providerId: _game.providerId,
        productId: _game.productId,
        gameCode: _game.gameCode,
        lang: _game.lang,
        isMobileLogin: isMobileLogin,
      );

      if (_isDisposed) return;

      logInfo('Game URL fetched successfully');
      // Always stay at connecting — WebView hasn't started loading yet.
      // _transitionToLoading guards against reverting if onLoadStart fired first.
      state = GamePlayerState.loading(
        stage: state.currentStage == GamePlayerLoadingStage.loadingAssets
            ? GamePlayerLoadingStage.loadingAssets
            : GamePlayerLoadingStage.connecting,
        gameUrl: url,
        retryCount: state.retryCount,
      );

      // Start the timeout timer immediately once we have the URL
      _startTimeoutTimer();
      _startFallbackLoadTimer(Uri.tryParse(url));
    } catch (e, stackTrace) {
      _handleLoadGameUrlError(e, stackTrace);
    }
  }

  /// Initiates the smooth exit sequence:
  /// 1. Lock state to exiting (chặn interaction)
  /// 2. Restore orientation (Xoay về Portrait)
  /// 3. Send Exit event to UI
  Future<void> requestExit() async {
    if (state.isExiting || _isDisposed) return;

    logInfo('Requesting smooth exit for game: ${_game.gameName}');

    // 1. Mark as exiting and hide WebView immediately to prevent visual glitches
    state = const GamePlayerState.exiting(showWebView: false);

    // 2. Restore orientation
    if (_orientationController != null) {
      await _orientationController!.restore(_previousPolicy);
    }

    if (_isDisposed) return;

    // 3. Cleanup and Notify UI to pop
    _cancelAllTimers();

    // Trigger balance refresh BEFORE exiting.
    try {
      onRefreshBalance?.call();
    } catch (e, st) {
      logError('Failed to trigger balance refresh on exit', e, st);
    }

    // Small delay to allow the orientation restoration to settle visually
    await Future<void>.delayed(_exitDelay);
    if (_isDisposed) return;

    _eventsController.add(const GamePlayerExitEvent());
  }

  /// Categorizes and handles errors occurring during the game URL fetch process.
  void _handleLoadGameUrlError(Object e, StackTrace stackTrace) {
    if (_isDisposed) return;

    final failure = e is CaxiloFailure ? e : mapToCaxiloFailure(e);
    logError(
      'Game URL fetch failed: ${failure.runtimeType}',
      failure.source ?? failure,
      stackTrace,
    );
    _applyFailureState(failure);
  }

  /// Maps a [CaxiloFailure] to the correct [GamePlayerState] fields.
  void _applyFailureState(CaxiloFailure failure) {
    if (_isDisposed) return;

    var failureType = GamePlayerErrorType.unknown;
    var isRetryable = false;
    final retryCount = state.retryCount;

    // Đọc message trực tiếp từ failure — không kế thừa từ state trước
    final failureMessage = failure.message;

    switch (failure) {
      case CaxiloMaintenanceFailure():
        failureType = GamePlayerErrorType.maintenance;

      case CaxiloNetworkFailure():
        failureType = GamePlayerErrorType.network;
        isRetryable = failure.isRetryable;

      case CaxiloAuthFailure():
        failureType = GamePlayerErrorType.sessionExpired;

      case CaxiloComingSoonFailure():
        failureType = GamePlayerErrorType.comingSoon;

      case CaxiloDisabledFailure() || CaxiloUnderDevelopmentFailure():
        failureType = GamePlayerErrorType.unavailable;

      case CaxiloBusinessFailure():
        failureType = GamePlayerErrorType.unknown;

      case CaxiloServerFailure():
        failureType = GamePlayerErrorType.serverError;
        isRetryable = failure.isRetryable;

      case CaxiloUnknownFailure():
        failureType = GamePlayerErrorType.unknown;
    }

    state = GamePlayerState.failure(
      failureType: failureType,
      failureMessage: failureMessage,
      isRetryable: isRetryable,
      retryCount: retryCount,
      gameUrl: state.gameUrl,
    );
  }

  @override
  void dispose() {
    logInfo('Disposing GamePlayerNotifier for ${_game.gameName}');
    _isDisposed = true;
    _cancelAllTimers();
    _runnerEventSub?.cancel();
    _runnerController.dispose();
    _eventsController.close();
    super.dispose();
  }

  /// Retries the last game URL request.
  void retry() {
    if (_isDisposed) return;

    final nextRetryCount = state.retryCount + 1;
    logInfo('Retrying game URL request (attempt $nextRetryCount)');

    if (nextRetryCount >= GamePlayerNotifier._maxRetryCount) {
      logError('Max retry count ($nextRetryCount) reached. Stopping retries.');
      state = GamePlayerState.failure(
        failureType: state.failureType ?? GamePlayerErrorType.serverError,
        isRetryable: false,
        retryCount: nextRetryCount,
        gameUrl: state.gameUrl,
      );
      return;
    }

    state = GamePlayerState.loading(
      stage: GamePlayerLoadingStage.connecting,
      retryCount: nextRetryCount,
      gameUrl: state.gameUrl,
    );
    loadGameUrl();
  }

  // ---- Private Runner Handlers ----

  /// Logs a technical message from a game runner (e.g., IH or PL).
  void _logRunnerMessage(
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

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(GamePlayerNotifier._loadTimeout, () {
      if (!_isDisposed && state.isLoading) {
        logError(
          'WebView load timeout after ${GamePlayerNotifier._loadTimeout.inSeconds}s '
          '(stage: ${state.currentStage?.name ?? state.runtimeType})',
        );
        _handleError(failureType: GamePlayerErrorType.loadTimeout);
      }
    });
  }

  void _startFallbackLoadTimer([Uri? url]) {
    _fallbackLoadTimer?.cancel();
    if (kIsWeb) {
      _fallbackLoadTimer = Timer(const Duration(seconds: 10), () {
        if (!_isDisposed && state.isLoading) {
          logWarning(
            'Web failsafe triggered: onLoadStop was not called after 10s. Forcing play stage.',
          );
          _onLoadStop(url);
        }
      });
    }
  }

  void _onLoadStart([Uri? url]) {
    if (_isDisposed || state.isExiting) return;

    // Already stably playing — no state change needed.
    if (state.isPlaying && state.showWebView) {
      logInfo('Already playing, ignoring onLoadStart');
      return;
    }

    // Page reloaded during the finish-load grace period.
    // Cancel the pending transition so we wait for the next onLoadStop.
    if (_finishLoadTimer?.isActive ?? false) {
      logInfo('Page reloaded during grace period, cancelling transition');
      _cancelAllTimers();
      return;
    }

    logInfo(
      'WebView started loading: $url '
      '(stage: ${state.currentStage?.name ?? state.runtimeType})',
    );
    _cancelAllTimers();

    if (state.currentStage != GamePlayerLoadingStage.loadingAssets) {
      state = GamePlayerState.loading(
        stage: GamePlayerLoadingStage.loadingAssets,
        gameUrl: state.gameUrl,
        retryCount: state.retryCount,
      );
    }

    _startTimeoutTimer();
    _startFallbackLoadTimer(url);
  }

  void _onLoadStop([Uri? url]) {
    if (_isDisposed || state.isExiting) return;

    // Already stably playing — no state change needed.
    if (state.isPlaying && state.showWebView) {
      logInfo('Already playing, ignoring onLoadStop');
      return;
    }

    // Duplicate onLoadStop — let the existing finishLoadTimer complete.
    if (_finishLoadTimer?.isActive ?? false) {
      logInfo('Finish timer active, ignoring duplicate onLoadStop');
      return;
    }

    logInfo(
      'WebView finished loading: $url '
      '(stage: ${state.currentStage?.name ?? state.runtimeType})',
    );
    _cancelAllTimers();

    logInfo('Starting finishLoadTimer (${finishLoadDelay.inMilliseconds}ms)');
    _finishLoadTimer = Timer(finishLoadDelay, () {
      if (_isDisposed) return;

      final gameUrl = state.gameUrl;
      if (gameUrl != null) {
        state = GamePlayerState.playing(
          gameUrl: gameUrl,
          showWebView: true,
          isNewTabOpened: state.maybeMap(
            playing: (s) => s.isNewTabOpened,
            orElse: () => false,
          ),
        );
      } else {
        logError('onLoadStop called but gameUrl is null');
        _handleError(failureType: GamePlayerErrorType.missingGameUrl);
      }
    });
  }

  void onNewTabOpened() {
    logInfo('Game opened in new tab');
    _finishLoadTimer?.cancel();
    if (_isDisposed) return;

    final gameUrl = state.gameUrl;

    if (gameUrl != null) {
      state = GamePlayerState.playing(
        gameUrl: gameUrl,
        showWebView: true,
        isNewTabOpened: true,
      );
    }
    _onLoadStop();
  }

  void _handleError({
    String? message,
    bool isRetryable = true,
    GamePlayerErrorType failureType = GamePlayerErrorType.unknown,
  }) {
    if (_isDisposed) return;

    logError('WebView Error: ${message ?? failureType.name}');
    _cancelAllTimers();

    state = GamePlayerState.failure(
      failureType: failureType,
      failureMessage: message,
      isRetryable: isRetryable,
      retryCount: state.retryCount,
      gameUrl: state.gameUrl,
    );
  }
}
