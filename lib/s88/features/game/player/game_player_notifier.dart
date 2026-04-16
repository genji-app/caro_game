import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

part 'game_player_notifier.freezed.dart';

/// Represents the high-level lifecycle of the Game Player.
enum GamePlayerStatus {
  /// Initial state, before any action is taken.
  initial,

  /// Currently fetching the game URL or the WebView is loading.
  loading,

  /// The game URL is resolved and the WebView has finished loading.
  loaded,

  /// An error occurred during fetching or loading.
  failure,

  /// The game is confirmed to be under maintenance.
  maintenance;

  /// Helper to check if the status is loading.
  bool get isLoading => this == GamePlayerStatus.loading;

  /// Helper to check if the status is failure.
  bool get isFailure => this == GamePlayerStatus.failure;

  /// Helper to check if the status is maintenance.
  bool get isMaintenance => this == GamePlayerStatus.maintenance;

  /// Helper to check if the status is loaded.
  bool get isLoaded => this == GamePlayerStatus.loaded;
}

/// Immutable state for the Game Player screen.
///
/// Each field maps to a specific section of the UI:
/// - [gameUrl]       → WebView layer
/// - [showWebView]   → WebView fade-in animation
/// - [isLoading]     → loading overlay + back-button lock
/// - [errorMessage]  → error overlay
@freezed
sealed class GamePlayerState with _$GamePlayerState {
  const GamePlayerState._(); // Required for custom getters/methods

  const factory GamePlayerState({
    /// Current lifecycle status of the player.
    @Default(GamePlayerStatus.initial) GamePlayerStatus status,

    /// Error message to display — `null` means no error.
    String? errorMessage,

    /// Whether the orientation is locked and ready for rendering/fetching.
    @Default(false) bool isOrientationReady,

    /// Whether the WebView should be visible (controls fade-in animation).
    @Default(false) bool showWebView,

    /// The resolved game URL to load in the WebView.
    String? gameUrl,

    /// Whether the game has been opened in a new tab (for iOS Safari fallback).
    @Default(false) bool isNewTabOpened,

    /// Number of times the game URL fetch has been retried.
    @Default(0) int retryCount,
  }) = _GamePlayerState;

  /// Whether the user can pop (back) from this screen.
  ///
  /// Prevents accidental exits while the game is still loading.
  bool get canPop => status != GamePlayerStatus.loading;

  /// Whether there's an active error or the game is in maintenance.
  bool get hasError =>
      status == GamePlayerStatus.failure ||
      status == GamePlayerStatus.maintenance ||
      errorMessage != null;

  /// Whether the game is currently loading.
  bool get isLoading => status == GamePlayerStatus.loading;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages all business logic for the Game Player screen.
///
/// Responsibilities:
/// - Fetch game URL from API
/// - Track WebView lifecycle (load start/stop/error)
/// - Manage loading timeout
/// - Manage loading timeout
///
/// The UI layer ([GamePlayerScreen]) should only read state via `ref.watch`
/// and delegate all mutations to this notifier.
class GamePlayerNotifier extends StateNotifier<GamePlayerState>
    with LoggerMixin {
  GamePlayerNotifier({
    required GameBlock game,
    required GameRepository repository,
    required GameSessionGuard sessionGuard,
    this.finishLoadDelay = const Duration(milliseconds: 777),
  }) : _game = game,
       _repository = repository,
       _sessionGuard = sessionGuard,
       super(const GamePlayerState(status: GamePlayerStatus.loading)) {
    logInfo('GamePlayerNotifier created for ${game.gameName}');
  }

  final GameBlock _game;
  final GameRepository _repository;
  final GameSessionGuard _sessionGuard;

  /// Additional delay after WebView finishes loading before hiding the overlay.
  /// This ensures that the game engine has enough time to render its initial frame.
  final Duration finishLoadDelay;

  /// Timeout duration before considering the WebView load as failed.
  static const _loadTimeout = Duration(seconds: 30);

  /// Maximum number of retries for getting the game URL.
  static const _maxRetryCount = 3;

  Timer? _timeoutTimer;
  Timer? _finishLoadTimer;

  @override
  String get logTag => 'GamePlayer';

  // ---- Public API (called by UI) ----

  bool _isInitCalled = false;

  /// Call this from the UI once to trigger required startup behaviors like cooldowns.
  Future<void> initializePlayer({bool? isMobileLogin}) async {
    if (_isInitCalled) return;
    _isInitCalled = true;

    try {
      if (_game.requiresSessionGuard) {
        final remaining = _sessionGuard.remainingCooldown(_game.providerId);
        if (remaining > Duration.zero) {
          logInfo(
            'Cooldown active. Waiting ${remaining.inSeconds}s before starting session.',
          );
          await Future<void>.delayed(remaining);
        }
        _sessionGuard.onSessionStarted(_game.providerId);
      }
    } catch (e, st) {
      logError('Failed to setup orientation/UI mode: $e', st);
    } finally {
      // Proceed to load the game URL after orientation is locked (or failed)
      state = state.copyWith(isOrientationReady: true);
      await loadGameUrl(isMobileLogin: isMobileLogin);
    }
  }

  /// Fetches the game URL from the server and triggers the loading flow.
  ///
  /// [isMobileLogin] is determined by the UI based on screen size.
  Future<void> loadGameUrl({bool? isMobileLogin}) async {
    logInfo(
      'Fetching game URL: '
      'provider=${_game.providerId}, '
      'product=${_game.productId}, '
      'game=${_game.gameCode}',
    );

    // Clear any previous error and enter loading state
    state = state.copyWith(
      status: GamePlayerStatus.loading,
      errorMessage: null,
    );

    try {
      final url = await _repository.getGameUrl(
        providerId: _game.providerId,
        productId: _game.productId,
        gameCode: _game.gameCode,
        lang: _game.lang,
        isMobileLogin: isMobileLogin,
      );

      if (!mounted) return;

      logInfo('Game URL fetched successfully');
      state = state.copyWith(
        gameUrl: url,
        retryCount: 0, // Reset retry count on success
      );
    } catch (e, stackTrace) {
      _handleLoadGameUrlError(e, stackTrace);
    }
  }

  /// Categorizes and handles errors occurring during the game URL fetch process.
  void _handleLoadGameUrlError(Object e, StackTrace stackTrace) {
    if (!mounted) return;

    if (e is GameMaintenanceFailure) {
      logError('Game is under maintenance', e, stackTrace);
      state = state.copyWith(
        status: GamePlayerStatus.maintenance,
        errorMessage: e.errorMessage,
      );
    } else if (e is GetGameUrlFailure) {
      logError('Failed to get game URL', e, stackTrace);
      state = state.copyWith(
        status: GamePlayerStatus.failure,
        errorMessage: e.errorMessage,
      );
    } else {
      logError('Unexpected error while getting game URL', e, stackTrace);
      state = state.copyWith(
        status: GamePlayerStatus.failure,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Called by the WebView when it starts loading a page.
  void onLoadStart() {
    logInfo('WebView started loading');
    _timeoutTimer?.cancel();

    if (!mounted) return;

    state = state.copyWith(
      status: GamePlayerStatus.loading,
      errorMessage: null,
    );

    _timeoutTimer = Timer(_loadTimeout, () {
      if (mounted && state.isLoading) {
        logError('WebView load timeout after ${_loadTimeout.inSeconds}s');
        handleError('Tải game quá lâu hoặc gặp lỗi hiển thị nội dung.');
      }
    });
  }

  /// Called by the WebView when a page finishes loading.
  void onLoadStop() {
    logInfo('WebView finished loading');
    _timeoutTimer?.cancel();
    _finishLoadTimer?.cancel();

    if (!mounted) return;

    // Show WebView immediately (it's hidden behind the loading overlay anyway)
    // so it can start rendering its first frames while we still show the spinner.
    state = state.copyWith(showWebView: true);

    _finishLoadTimer = Timer(finishLoadDelay, () {
      if (!mounted) return;
      // state = state.copyWith(
      //   status: GamePlayerStatus.loaded,
      //   showWebView: true,
      // );

      state = state.copyWith(status: GamePlayerStatus.loaded);
    });
  }

  /// Called when the game is successfully opened in a new browser tab.
  /// (Fallback strategy for iOS Safari).
  void onNewTabOpened() {
    logInfo('Game opened in new tab');
    _finishLoadTimer?.cancel();
    if (!mounted) return;

    state = state.copyWith(isNewTabOpened: true);
    onLoadStop();
  }

  /// Called by the WebView (or timeout) when an error occurs.
  void handleError(String error) {
    logError('WebView Error: $error');
    _timeoutTimer?.cancel();

    if (!mounted) return;

    state = state.copyWith(
      status: GamePlayerStatus.failure,
      errorMessage: error,
      showWebView: false,
    );
  }

  /// Retries the last game URL request.
  void retry() {
    final nextRetryCount = state.retryCount + 1;
    logInfo('Retrying game URL request (attempt $nextRetryCount)');

    if (nextRetryCount >= _maxRetryCount) {
      logError('Max retry count reached. Switching to maintenance state.');
      state = state.copyWith(
        status: GamePlayerStatus.maintenance,
        errorMessage: 'Quá số lần thử lại. Game đang bảo trì.',
        retryCount: 0, // Reset for potential manual retry later if needed
      );
      return;
    }

    state = state.copyWith(
      status: GamePlayerStatus.loading,
      errorMessage: null,
      retryCount: nextRetryCount,
    );
    loadGameUrl();
  }

  @override
  void dispose() {
    logInfo('Disposing GamePlayerNotifier for ${_game.gameName}');
    _timeoutTimer?.cancel();
    _finishLoadTimer?.cancel();
    super.dispose();
  }
}
