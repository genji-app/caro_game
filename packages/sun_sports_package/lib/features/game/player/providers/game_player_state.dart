part of 'game_player_notifier.dart';

/// Categorizes the type of error for the Game Player UI to render
/// the appropriate error widget and action.
enum GamePlayerErrorType {
  /// Network connectivity issue or request timeout.
  network,

  /// Session expired or authentication required.
  sessionExpired,

  /// Game is not yet released.
  comingSoon,

  /// Game has been disabled or is unavailable.
  unavailable,

  /// Server-side error that may resolve on retry.
  serverError,

  /// The game is confirmed to be under maintenance.
  maintenance,

  /// The game load timed out.
  loadTimeout,

  /// Missing game URL.
  missingGameUrl,

  /// Failed to setup orientation during initialization.
  orientationSetupFailed,

  /// Unclassified error.
  unknown,
}

/// Represents the sub-stages of the Game Player loading process.
enum GamePlayerLoadingStage {
  /// Setting up orientation and environment.
  settingUp,

  /// Connecting to server to fetch game URL.
  connecting,

  /// WebView is loading game assets.
  loadingAssets,
}

/// Immutable state for the [GamePlayerNotifier].
@freezed
sealed class GamePlayerState with _$GamePlayerState {
  const GamePlayerState._();

  /// Initial state, before any action is taken.
  const factory GamePlayerState.initial() = GamePlayerInitialState;

  /// Setting up, connecting, or loading assets.
  const factory GamePlayerState.loading({
    @Default(GamePlayerLoadingStage.settingUp) GamePlayerLoadingStage stage,
    @Default(0) int retryCount,
    String? gameUrl,
  }) = GamePlayerLoadingState;

  /// Game is ready and being played.
  const factory GamePlayerState.playing({
    required String gameUrl,
    @Default(false) bool showWebView,
    @Default(false) bool isNewTabOpened,
  }) = GamePlayerPlayingState;

  /// A failure occurred during fetching or loading.
  const factory GamePlayerState.failure({
    required GamePlayerErrorType failureType,
    String? failureMessage,
    @Default(false) bool isRetryable,
    @Default(0) int retryCount,
    String? gameUrl,
  }) = GamePlayerFailureState;

  /// Smoothing exit transition.
  const factory GamePlayerState.exiting({@Default(false) bool showWebView}) =
      GamePlayerExitingState;

  /// Whether the user can pop (back) from this screen.
  bool get canPop =>
      maybeMap(initial: (_) => true, failure: (_) => true, orElse: () => false);

  /// Whether there is an active failure or the game is in maintenance.
  bool get hasFailure => maybeMap(failure: (_) => true, orElse: () => false);

  /// Whether the game is currently loading.
  bool get isLoading => maybeMap(loading: (_) => true, orElse: () => false);

  /// Whether the game is currently being played.
  bool get isPlaying => maybeMap(playing: (_) => true, orElse: () => false);

  /// Whether the orientation is locked and ready for rendering/fetching.
  bool get isOrientationReady => maybeMap(
    loading: (s) => s.stage != GamePlayerLoadingStage.settingUp,
    playing: (_) => true,
    exiting: (_) => true,
    orElse: () => false,
  );

  /// Whether the loading overlay should be visible.
  bool get showLoading => map(
    initial: (_) => false,
    loading: (_) => true,
    playing: (_) => false,
    failure: (_) => false,
    exiting: (_) => true,
  );

  /// The active failure type, if any.
  GamePlayerErrorType? get failureType =>
      maybeMap(failure: (s) => s.failureType, orElse: () => null);

  /// Whether the stage is exiting.
  bool get isExiting => maybeMap(exiting: (_) => true, orElse: () => false);

  /// The current game URL, if available.
  String? get gameUrl => mapOrNull(
    loading: (s) => s.gameUrl,
    playing: (s) => s.gameUrl,
    failure: (s) => s.gameUrl,
  );

  /// The current retry count.
  int get retryCount => map(
    initial: (_) => 0,
    loading: (s) => s.retryCount,
    playing: (_) => 0,
    failure: (s) => s.retryCount,
    exiting: (_) => 0,
  );

  /// The active loading stage, or null if not in a loading state.
  GamePlayerLoadingStage? get currentStage =>
      maybeMap(loading: (s) => s.stage, orElse: () => null);

  /// The active failure message, if any.
  String? get failureMessage =>
      maybeMap(failure: (s) => s.failureMessage, orElse: () => null);

  /// Whether the current failure can be retried.
  bool get isRetryable =>
      maybeMap(failure: (s) => s.isRetryable, orElse: () => false);

  /// Whether the WebView should be visible.
  bool get showWebView => maybeMap(
    playing: (s) => s.showWebView,
    exiting: (s) => s.showWebView,
    orElse: () => false,
  );
}
