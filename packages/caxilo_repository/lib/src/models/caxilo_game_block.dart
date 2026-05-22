import 'package:caxilo_config/caxilo_config.dart'
    show GameOrientation, GameOrientationListConverter, GameType;
import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'caxilo_game_block.freezed.dart';
part 'caxilo_game_block.g.dart';

/// {@template caxilo_game_block}
/// A flattened representation of a game with its provider context.
///
/// This model combines [Game] data with its parent provider information,
/// facilitating linear list display and filtering without nested properties.
/// {@endtemplate}
@freezed
sealed class CaxiloGameBlock with _$CaxiloGameBlock {
  const factory CaxiloGameBlock.liveStream({
    // --- provider data & resolved image ---
    /// The unique id of the provider (e.g. `amb-vn`, `vivo`, `sunwin`)
    required String providerId,

    /// The human-readable name of the provider.
    required String providerName,

    /// The resolved image path or name for the game thumbnail.
    required String image,

    // --- core game data ---

    /// The specific product API identifier (e.g., 'SEXY', 'EVO').
    required String productId,

    /// The specific unique code for this game within the provider.
    required String gameCode,

    /// The human-readable name of the game.
    required String gameName,

    /// The required language code for the game url.
    required String lang,

    /// The generic category of this game (e.g. slot, live, sport).
    @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)
    required caxiloconfig.GameType gameType,

    // --- live stream specific ---

    /// The lobby URL for this live stream game (used to return to the provider's lobby).
    required String lobbyUrl,

    /// The cashier URL for this live stream game (used if player needs to deposit).
    required String cashierUrl,

    /// Whether this game requires setting a mobile specific flag in its URL.
    @Default(false) bool mobileLogin,

    /// Allowed orientations on mobile phones.
    @GameOrientationListConverter()
    @Default(caxiloconfig.GameOrientation.portrait)
    List<caxiloconfig.GameOrientation> mobileOrientation,

    /// Allowed orientations on tablets.
    @GameOrientationListConverter()
    @Default(caxiloconfig.GameOrientation.landscape)
    List<caxiloconfig.GameOrientation> tabletOrientation,

    /// Allowed orientations on desktops.
    @GameOrientationListConverter()
    @Default(caxiloconfig.GameOrientation.all)
    List<caxiloconfig.GameOrientation> desktopOrientation,

    /// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
    Duration? loadStopDebounce,

    /// Determines the order in which this game is displayed relative to others.
    @Default(999) int sortOrder,

    /// Whether this game should forcefully render in an immersive landscape virtual viewport on iPad.
    @Default(false) bool forceLandscapeViewportOnIpad,

    /// Determines whether this game should be opened in a new tab to avoid crashes.
    @Default(false) bool openInNewTabOnIOSSafariWeb,

    /// Whether this game requires a session cooldown guard before launching.
    @Default(false) bool requiresSessionGuard,
  }) = CaxiloGameBlockLiveStream;

  const factory CaxiloGameBlock.inHouse({
    // --- provider data & resolved image ---
    /// The unique id of the provider (e.g. `amb-vn`, `vivo`, `sunwin`)
    required String providerId,

    /// The human-readable name of the provider.
    required String providerName,

    /// The resolved image path or name for the game thumbnail.
    required String image,

    // --- core game data ---

    /// The specific product API identifier (e.g., 'SEXY', 'EVO').
    required String productId,

    /// The specific unique code for this game within the provider.
    required String gameCode,

    /// The human-readable name of the game.
    required String gameName,

    /// The required language code for the game url.
    required String lang,

    /// The generic category of this game (e.g. slot, live, sport).
    @JsonKey(fromJson: GameType.fromJson, toJson: GameType.staticToJson)
    required caxiloconfig.GameType gameType,

    /// Allowed orientations on mobile phones.
    @GameOrientationListConverter()
    @Default(caxiloconfig.GameOrientation.portrait)
    List<caxiloconfig.GameOrientation> mobileOrientation,

    /// Allowed orientations on tablets.
    @GameOrientationListConverter()
    @Default(caxiloconfig.GameOrientation.all)
    List<caxiloconfig.GameOrientation> tabletOrientation,

    /// Allowed orientations on desktops.
    @GameOrientationListConverter()
    @Default(caxiloconfig.GameOrientation.all)
    List<caxiloconfig.GameOrientation> desktopOrientation,

    /// Specialized debounce for [onLoadStop] event to wait for final JS/DOM states.
    Duration? loadStopDebounce,

    /// Determines the order in which this game is displayed relative to others.
    @Default(999) int sortOrder,

    // --- in-house specific ---

    /// Whether this game enables host message channel.
    @Default(false) bool enableHostMessage,
  }) = CaxiloGameBlockInHouse;

  factory CaxiloGameBlock.fromJson(Map<String, dynamic> json) => _$CaxiloGameBlockFromJson(json);
}

/// Extension to provide handy getters and state checks for [CaxiloGameBlock].
extension CaxiloGameBlockX on CaxiloGameBlock {
  /// Whether this game was developed in-house (e.g. Sunwin).
  bool get isInHouseGame => this is CaxiloGameBlockInHouse;

  /// Whether this is a remote live stream game.
  bool get isLiveStreamGame => this is CaxiloGameBlockLiveStream;

  /// Flag to force landscape rendering on iPads.
  bool get forceLandscapeViewportOnIpad =>
      this is CaxiloGameBlockLiveStream &&
      (this as CaxiloGameBlockLiveStream).forceLandscapeViewportOnIpad;

  /// Flag to open the game in a new browser tab on iOS Safari.
  bool get openInNewTabOnIOSSafariWeb =>
      this is CaxiloGameBlockLiveStream &&
      (this as CaxiloGameBlockLiveStream).openInNewTabOnIOSSafariWeb;

  /// Flag to enforce a session guard before launching the game.
  bool get requiresSessionGuard =>
      this is CaxiloGameBlockLiveStream && (this as CaxiloGameBlockLiveStream).requiresSessionGuard;

  /// Flag to enable host message communication (mostly for in-house).
  bool get enableHostMessage =>
      this is CaxiloGameBlockInHouse && (this as CaxiloGameBlockInHouse).enableHostMessage;
}
