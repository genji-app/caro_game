import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/game_launch_strategy.dart';
import '../common/game_orientation.dart';
import '../common/game_type.dart';

part 'in_house_game.freezed.dart';
part 'in_house_game.g.dart';

/// Technical configuration data for a single casino game.
///
/// This model acts as the "Catalog" entry, defining how the game
/// should be launched and its basic identity.
@freezed
abstract class InHouseGame with _$InHouseGame {
  /// Defines the JSON structure for a game's technical catalog.
  const factory InHouseGame({
    /// Unique product identifier (e.g., 'sunwin_AVENGER').
    @JsonKey(name: 'product_id') required String productId,

    /// Unique short code for the game (e.g., 'AVENGER').
    @JsonKey(name: 'game_code') required String gameCode,

    /// Human-readable name of the game.
    @JsonKey(name: 'game_name') required String gameName,

    /// Unique id of the provider.
    @JsonKey(name: 'provider_id') required String providerId,

    /// Human-readable name of the provider.
    @JsonKey(name: 'provider_name') required String providerName,

    /// File path or name for the game thumbnail.
    @JsonKey(name: 'image') required String image,

    /// Language code to be used in the launch URL.
    @JsonKey(name: 'lang') required String lang,

    /// Categorization of the game.
    @JsonKey(name: 'game_type') required GameType gameType,

    /// Execution strategy for launching the game.
    @JsonKey(name: 'launch_strategy') required GameLaunchStrategy launchStrategy,

    /// Key used to resolve the base URL from environments.
    @JsonKey(name: 'base_url_key') String? baseUrlKey,

    /// Screen orientations supported on mobile devices.
    @JsonKey(name: 'mobile_orientation')
    @GameOrientationListConverter()
    @Default(GameOrientation.landscape)
    List<GameOrientation> mobileOrientation,

    /// Screen orientations supported on tablets.
    @JsonKey(name: 'tablet_orientation')
    @GameOrientationListConverter()
    @Default(GameOrientation.landscape)
    List<GameOrientation> tabletOrientation,

    /// Screen orientations supported on desktop.
    @JsonKey(name: 'desktop_orientation')
    @GameOrientationListConverter()
    @Default(GameOrientation.landscape)
    List<GameOrientation> desktopOrientation,

    /// Whether to enable bidirectional messaging between JS and Flutter.
    @JsonKey(name: 'enable_host_message') @Default(true) bool enableHostMessage,

    /// Optional specific game identifier for internal provider systems.
    @JsonKey(name: 'game_id') int? gameId,
  }) = _InHouseGame;

  /// Creates a [InHouseGame] from a JSON map.
  factory InHouseGame.fromJson(Map<String, dynamic> json) => _$InHouseGameFromJson(json);
}
