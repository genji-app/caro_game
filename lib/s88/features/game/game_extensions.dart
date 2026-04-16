import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// UI extensions for [GameCategory] to simplify asset path building.
extension GameCategoryAssetX on GameCategory {
  /// Returns the full asset path for the category icon.
  /// If [active] is true, returns the active version of the icon.
  String getIconPath({bool active = false}) {
    final iconName = getIcon(active: active);

    // Fallback to default "All" icon if specific icon is not found
    final effectiveIconName =
        iconName ??
        (active ? allCategoryConfig.iconActive : allCategoryConfig.icon);

    return '${AppIcons.REMOTE_PATH}/$effectiveIconName';
  }

  /// Converts this category into a [GameFilter].
  GameFilter toFilter() {
    return when(
      gameType: (type, label, icon, iconActive, count, providerIds) {
        if (providerIds.isEmpty) {
          return GameFilter.byGameTypes(gameTypes: [type]);
        }
        return GameFilter.all(
          filters: [
            GameFilter.byGameTypes(gameTypes: [type]),
            GameFilter.byProviders(providerIds: providerIds),
          ],
        );
      },
      provider: (providerId, label, icon, iconActive, count, gameTypes) {
        if (gameTypes.isEmpty) {
          return GameFilter.byProviders(providerIds: [providerId]);
        }
        return GameFilter.all(
          filters: [
            GameFilter.byProviders(providerIds: [providerId]),
            GameFilter.byGameTypes(gameTypes: gameTypes),
          ],
        );
      },
      custom: (categoryId, label, filter, icon, iconActive, count) => filter,
    );
  }
}

/// UI extensions for [GameCategoryConfig] to simplify asset path building.
extension GameCategoryConfigAssetX on GameCategoryConfig {
  /// Returns the full asset path for the category config icon.
  String getIconPath({bool active = false}) {
    return '${AppIcons.REMOTE_PATH}/${active ? iconActive : icon}';
  }
}

/// UI extensions for [GameBlock] record to simplify asset path building.
extension GameBlockX on GameBlock {
  /// Returns the full asset path for the game image.
  /// Centralizes the path logic so it can be changed to network/cloud storage later.
  String get imagePath {
    // Note: We only store the filename in the repository logic.
    // The actual storage location is controlled here (CDN game thumbs).
    return '${AppImages.IMAGES_GAME_REMOTE_PATH}/$image';
  }

  /// Generates a unique, deterministic [ValueKey] for this game.
  ///
  /// The [prefix] helps avoid collisions when the same game appears
  /// in multiple places (e.g., 'GameGridView', 'GameFeedView').
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
  /// Converts this selection into a [GameFilter].
  /// Returns `null` when the selection is empty (no filter applied).
  GameFilter? toFilter() {
    if (isEmpty) return null;

    return category!.toFilter();
  }
}
