import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_images.dart';
import 'package:sun_sports/features/game/game.dart';

/// {@template game_category_asset_x}
/// UI extensions for [CaxiloCategory] to simplify asset path building.
/// {@endtemplate}
extension GameCategoryAssetX on CaxiloCategory {
  /// Returns the full asset path for the category icon.
  ///
  /// If [active] is true, returns the active version of the icon.
  ///
  /// Icons are retrieved from [AppIcons.REMOTE_PATH].
  String? getIconPath({bool active = false}) {
    final iconName = getIcon(active: active);

    if (iconName == null || iconName.isEmpty) return null;

    return '${AppIcons.REMOTE_PATH}/$iconName';
  }

  /// Whether this category has an icon defined.
  bool get hasIcon =>
      getIconPath() != null || getIconPath(active: true) != null;

  /// Returns the localized display name for this category.
  String get displayName =>
      I18n.translationMap[translationKey] ?? translationKey;
}

/// UI extensions for [GameBlock] record to simplify asset path building.
extension GameBlockX on GameBlock {
  /// Returns the full asset path for the game image.
  /// Centralizes the path logic so it can be changed to network/cloud storage later.
  String get imagePath {
    // Note: We only store the filename in the repository logic.
    // The actual storage location is controlled here (CDN game thumbs).
    // return 'assets/images/game_assets/$image';
    return '${AppImages.IMAGES_GAME_REMOTE_PATH}/$image';
  }

  /// Generates a unique, deterministic [ValueKey] for this game.
  ///
  /// The [prefix] helps avoid collisions when the same game appears
  /// in multiple places (e.g., 'GameGridView', 'GameLobbyView').
  ValueKey<String> buildWidgetKey(String prefix) {
    return ValueKey('$prefix-$providerId-$gameCode');
  }

  /// Determines the appropriate game orientation based on the device's screen size.
  List<GameOrientation> getOrientation(BuildContext context) {
    // Determine if we should use mobile layout or not, 600 here is
    // a common breakpoint for a typical phablet / small tablet.
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final bool isMobile = shortestSide < 600;

    return isMobile ? mobileOrientation : tabletOrientation;
  }

  /// Determines if the landscape viewport should be forced for this game.
  ///
  /// Logic:
  ///  - Check if [forceLandscapeViewportOnIpad] is configured.
  ///  - Only apply to tablets (shortest side >= 600).
  ///  - Only apply when ALL configured tablet orientations are landscape.
  bool shouldForceLandscapeViewport(BuildContext context) {
    if (!forceLandscapeViewportOnIpad) return false;

    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = shortestSide >= 600;
    if (!isTablet) return false;

    // Only inject when ALL configured tablet orientations are landscape.
    // If the list includes any portrait, we leave the game as-is.
    return tabletOrientation.every((o) => o.isLandscape);
  }
}

/// UI extensions for GameType
///
/// These extensions provide UI-specific functionality for GameType enum.
/// Separated from the model to maintain clean separation of concerns.
extension GameTypeUI on GameType {
  /// Display name for UI
  ///
  /// Returns a human-readable name for each game type.
  String get displayName {
    switch (this) {
      case GameType.slot:
        return I18n.txtGameSlots;
      case GameType.sport:
        return I18n.txtGameSports;
      case GameType.jackpot:
        return I18n.txtGameJackpot;
      case GameType.card:
        return I18n.txtGameCard;
      case GameType.dice:
        return I18n.txtGameDice;
      case GameType.live:
        return I18n.txtGameLive;
      case GameType.lottery:
        return I18n.txtGameLottery;
      case GameType.miniGame:
        return I18n.txtGameMiniGame;
      case GameType.fishing:
        return I18n.txtGameFishing;
      case GameType.others:
        return I18n.txtGameOthers;
      case GameType.unknown:
        return I18n.txtGameUnknown;
    }
  }
}
// ============================================================================
// GameCategorySelection extension
// ============================================================================

extension GameCategorySelectionX on GameCategorySelection {
  /// Converts this selection into a [CaxiloFilter].
  /// Returns `null` when the selection is empty (no filter applied).
  CaxiloFilter? toFilter() {
    if (isEmpty) return null;

    return category!.filter;
  }
}
