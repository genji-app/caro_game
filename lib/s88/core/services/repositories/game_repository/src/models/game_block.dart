import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_api_client/game_api_client.dart';

part 'game_block.freezed.dart';

/// Defines the allowed orientation for a game
enum GameOrientation {
  /// If the device shows its boot logo in portrait, then the boot logo is shown
  /// in [portraitUp]. Otherwise, the device shows its boot logo in landscape
  /// and this orientation is obtained by rotating the device 90 degrees
  /// clockwise from its boot orientation.
  portraitUp,

  /// The orientation that is 90 degrees counterclockwise from [portraitUp].
  ///
  /// If the device shows its boot logo in landscape, then the boot logo is
  /// shown in [landscapeLeft].
  landscapeLeft,

  /// The orientation that is 180 degrees from [portraitUp].
  portraitDown,

  /// The orientation that is 90 degrees clockwise from [portraitUp].
  landscapeRight;

  /// Whether this orientation is a portrait variant.
  bool get isPortrait => this == portraitUp || this == portraitDown;

  /// Whether this orientation is a landscape variant.
  bool get isLandscape => this == landscapeLeft || this == landscapeRight;

  /// Helper for both portrait orientations.
  static const portrait = [portraitUp, portraitDown];

  /// Helper for both landscape orientations.
  static const landscape = [landscapeLeft, landscapeRight];

  /// Helper for all orientations.
  static const all = [portraitUp, landscapeLeft, portraitDown, landscapeRight];
}

/// {@template game_block}
/// A flattened representation of a game with its provider context.
///
/// This model combines [Game] data with its parent provider information,
/// facilitating linear list display and filtering without nested properties.
/// {@endtemplate}
@freezed
sealed class GameBlock with _$GameBlock {
  const factory GameBlock({
    // --- provider data & resolved image ---
    required String providerId,
    required String providerName,
    required String image,

    // --- core game data ---
    required String productId,
    required String gameCode,
    required String gameName,
    required String lang,
    required String lobbyUrl,
    required String cashierUrl,
    required GameType gameType,
    @Default(false) bool mobileLogin,

    @Default(GameOrientation.portrait) List<GameOrientation> mobileOrientation,
    @Default(GameOrientation.landscape) List<GameOrientation> tabletOrientation,
    @Default(GameOrientation.all) List<GameOrientation> desktopOrientation,

    @Default(false) bool forceLandscapeViewportOnIpad,

    /// Determines whether this game should be opened in a new tab to avoid crashes.
    ///
    /// Context: Some providers (e.g., Sexy/amb-vn) utilize resource-intensive
    /// WebGL and live video. When loaded inside an iframe on iPhone Safari, they
    /// share a ~1GB-limited WebContent process with Flutter's CanvasKit,
    /// ultimately causing Safari to force-kill the webpage. Opening in a new tab
    /// gives the game an isolated process with independent GPU and memory pool.
    ///
    /// **Design Note:** This flag should be set to `true` for heavy games.
    /// The UI presentation layer (GamePlayerScreen) combines this flag with
    /// `isIOSSafariWeb`. Thus, even if `true`, lighter environments (PC, Android)
    /// will still seamlessly open the game in an iframe, and only Safari iPhone
    /// will trigger the new-tab fallback.
    @Default(false) bool openInNewTabOnIOSSafariWeb,

    /// Whether this game requires a session cooldown guard before launching.
    ///
    /// Some providers (e.g. SEXY/amb-vn) maintain a single active session
    /// per player server-side. Opening a new game before the previous session
    /// is released causes error 1028 ("Unable to proceed").
    /// When `true`, [GamePlayerScreen.push] enforces a cooldown between launches.
    @Default(false) bool requiresSessionGuard,

    /// Whether this game enables host message channel.
    @Default(false) bool enableHostMessage,

    /// Whether this game belongs to an in-house provider (e.g., Sunwin, X88).
    ///
    /// In-house games are typically internal developments that require
    /// specialized runners (like IHRunner) and specific event handling
    /// compared to third-party integrated games.
    @Default(false) bool isInHouseGame,

    /// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
    Duration? loadStopDebounce,
  }) = _GameBlock;

  /// Helper factory to map from a [Game] DTO and context strings.
  factory GameBlock.fromGame({
    /// The source game DTO.
    required Game game,

    /// The provider ID to associate with the game.
    required String providerId,

    /// The provider name to associate with the game.
    required String providerName,

    /// The image URL for the game.
    required String image,

    /// Whether to enable the host message channel.
    bool enableHostMessage = false,

    /// Optional override for mobile orientation.
    List<GameOrientation>? mobileOrientation,

    /// Optional override for tablet orientation.
    List<GameOrientation>? tabletOrientation,

    /// Optional override for desktop orientation.
    List<GameOrientation>? desktopOrientation,
    bool? forceLandscapeViewportOnIpad,
    bool? openInNewTabOnIOSSafariWeb,

    /// Whether this game belongs to an in-house provider (Sunwin, X88).
    bool isInHouseGame = false,
  }) {
    final override = _resolveOverride(providerId);
    return GameBlock(
      productId: game.productId,
      gameCode: game.gameCode,
      gameName: game.gameName,
      lang: game.lang,
      lobbyUrl: game.lobbyUrl,
      cashierUrl: game.cashierUrl,
      mobileLogin: game.mobileLogin,
      providerId: providerId,
      providerName: providerName,
      image: image,
      gameType: override?.gameType ?? game.gameType,
      isInHouseGame: isInHouseGame,
      mobileOrientation:
          mobileOrientation ??
          override?.mobileOrientation ??
          GameOrientation.all,
      tabletOrientation:
          tabletOrientation ??
          override?.tabletOrientation ??
          GameOrientation.all,
      desktopOrientation:
          desktopOrientation ??
          override?.desktopOrientation ??
          GameOrientation.all,
      forceLandscapeViewportOnIpad:
          forceLandscapeViewportOnIpad ??
          override?.forceLandscapeViewportOnIpad ??
          false,
      openInNewTabOnIOSSafariWeb:
          openInNewTabOnIOSSafariWeb ??
          override?.openInNewTabOnIOSSafariWeb ??
          false,
      requiresSessionGuard: override?.requiresSessionGuard ?? false,
      enableHostMessage: enableHostMessage,
      loadStopDebounce: override?.loadStopDebounce,
    );
  }

  /// Centralized provider overrides.
  ///
  /// Each entry maps a **lowercase provider ID** to its configuration.
  /// To add or modify a provider, update this single map.
  static const _providerOverrides = <String, _ProviderOverride>{
    'vivo': _ProviderOverride(
      gameType: GameType.live,
      mobileOrientation: GameOrientation.portrait,
      // tabletOrientation: GameOrientation.portrait, // backup
      tabletOrientation: GameOrientation.landscape,
      // tabletOrientation: GameOrientation.all, // can support
      desktopOrientation: GameOrientation.all,
      openInNewTabOnIOSSafariWeb: true,
    ),
    'amb-vn': _ProviderOverride(
      gameType: GameType.live,
      mobileOrientation: GameOrientation.portrait,
      // tabletOrientation: GameOrientation.portrait, // backup
      tabletOrientation: GameOrientation.landscape,
      // tabletOrientation: GameOrientation.all, // can support
      desktopOrientation: GameOrientation.all,
      // Open in new browser tab on web to avoid iOS Safari crash.
      // Sexy provider uses heavy WebGL + live FLV video that exceeds
      // memory limits when sharing a process with Flutter CanvasKit.
      openInNewTabOnIOSSafariWeb: true,
      // Requires session guard: provider enforces 1 active session per player.
      // Rapid game opens cause error 1028 ("Unable to proceed").
      requiresSessionGuard: true,
      // Wait for 777ms after load stop for initial WebGL/Video stability.
      loadStopDebounce: Duration(milliseconds: 777),
    ),
    'lcevo': _ProviderOverride(
      gameType: GameType.live,
      mobileOrientation: GameOrientation.portrait,
      // tabletOrientation: GameOrientation.landscape, // backup
      tabletOrientation: GameOrientation.all, // can support
      desktopOrientation: GameOrientation.all,
      // Open in new browser tab on web to avoid iOS Safari crash.
      // Evolution provider uses heavy WebGL + live FLV video that exceeds
      // memory limits when sharing a process with Flutter CanvasKit.
      openInNewTabOnIOSSafariWeb: true,
    ),
    'via-casino-vn': _ProviderOverride(
      gameType: GameType.live,
      mobileOrientation: GameOrientation.portrait,
      tabletOrientation: [GameOrientation.landscapeRight],
      desktopOrientation: GameOrientation.all,
      forceLandscapeViewportOnIpad: true,
      openInNewTabOnIOSSafariWeb: true,
    ),
  };

  /// Looks up override config for the given [providerId].
  /// Returns `null` if no override is defined.
  static _ProviderOverride? _resolveOverride(String providerId) =>
      _providerOverrides[providerId.toLowerCase().trim()];
}

/// Holds override values for a specific game provider.
///
/// All fields are optional — `null` means "use the default value".
class _ProviderOverride {
  const _ProviderOverride({
    this.gameType,
    this.mobileOrientation,
    this.tabletOrientation,
    this.desktopOrientation,
    this.forceLandscapeViewportOnIpad,
    this.openInNewTabOnIOSSafariWeb,
    this.requiresSessionGuard,
    this.loadStopDebounce,
  });

  final GameType? gameType;
  final List<GameOrientation>? mobileOrientation;
  final List<GameOrientation>? tabletOrientation;
  final List<GameOrientation>? desktopOrientation;
  final bool? forceLandscapeViewportOnIpad;
  final bool? openInNewTabOnIOSSafariWeb;
  final bool? requiresSessionGuard;
  final Duration? loadStopDebounce;
}
