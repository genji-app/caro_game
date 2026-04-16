import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// UI configuration for game category display
class GameCategoryConfig {
  final String displayName;
  final String icon;
  final String iconActive;

  const GameCategoryConfig({
    required this.displayName,
    required this.icon,
    required this.iconActive,
  });
}

/// Shared configuration for the "All" category
const allCategoryConfig = GameCategoryConfig(
  displayName: I18n.txtGameCategoryAll,
  icon: 'ic_home.svg',
  iconActive: 'ic_home_yellow.svg',
);

const _defaultCategoryConfig = GameCategoryConfig(
  displayName: I18n.txtGameOthers,
  icon: 'casino_all.svg',
  iconActive: 'casiono_all_selected.svg',
);

/// Map of game type display configurations
const _gameTypeDisplayConfig = {
  GameType.slot: GameCategoryConfig(
    displayName: I18n.txtGameSlots,
    icon: 'ic_slots.svg',
    iconActive: 'ic_slots_yellow.svg',
  ),
  GameType.sport: GameCategoryConfig(
    displayName: I18n.txtGameSports,
    icon: 'ic_football.svg',
    iconActive: 'ic_football_yellow.svg',
  ),
  GameType.jackpot: GameCategoryConfig(
    displayName: I18n.txtGameJackpot,
    icon: 'ic_jackpot.svg',
    iconActive: 'ic_jackpot_yellow.svg',
  ),
  GameType.card: GameCategoryConfig(
    displayName: I18n.txtGameCategoryCards,
    icon: 'ic_card.svg',
    iconActive: 'ic_card_yellow.svg',
  ),
  GameType.live: GameCategoryConfig(
    displayName: I18n.txtGameCategoryLiveDealer,
    icon: 'ic_live.svg',
    iconActive: 'ic_live_yellow.svg',
  ),
  GameType.dice: GameCategoryConfig(
    displayName: I18n.txtGameCategoryCasino,
    icon: 'ic_dice.svg',
    iconActive: 'ic_dice_yellow.svg',
  ),
  GameType.miniGame: GameCategoryConfig(
    displayName: I18n.txtGameCategoryArcade,
    icon: 'ic_arcade.svg',
    iconActive: 'ic_arcade_yellow.svg',
  ),
  GameType.lottery: GameCategoryConfig(
    displayName: I18n.txtGameCategoryLotto,
    icon: 'ic_roulette.svg',
    iconActive: 'ic_roulette_yellow.svg',
  ),
  GameType.fishing: GameCategoryConfig(
    displayName: I18n.txtGameCategoryFish,
    icon: 'ic_fish.svg',
    iconActive: 'ic_fish_yellow.svg',
  ),
  GameType.others: GameCategoryConfig(
    displayName: I18n.txtGameOthers,
    icon: 'ic_arcade.svg',
    iconActive: 'ic_arcade_yellow.svg',
  ),
};

/// Helper to get display configuration for a game type
GameCategoryConfig getGameTypeConfig(GameType type) =>
    _gameTypeDisplayConfig[type] ?? _defaultCategoryConfig;

/// Provider for standard game type categories.
final standardCategoriesProvider = Provider<List<GameCategory>>((ref) {
  return _gameTypeDisplayConfig.entries.map((entry) {
    return GameCategory.gameType(
      type: entry.key,
      displayLabel: entry.value.displayName,
      icon: entry.value.icon,
      iconActive: entry.value.iconActive,
      // gameCount: 0, // Will be updated when real data is available
      // providerIds: [],
    );
  }).toList();
});

/// Provider that provides the complete game category data.
///
/// Combines priority categories and standard game type categories.
final gameCategoriesProvider = Provider<GameCategories>((ref) {
  final standard = ref.watch(standardCategoriesProvider);

  final sunwinProviderId = GameRepository.sunwinProviderId;
  final sunwinCategory = GameCategory.provider(
    providerId: sunwinProviderId,
    displayLabel: I18n.txtGameCategorySunwin,
    icon: 'ic_sunwin_bw.png',
    iconActive: 'ic_sunwin.png',
  );

  // 2. New Games Custom Category
  final newGamesFilter = const GameFilter.byReleaseDate(daysAgo: 30);
  final newGamesCategory = GameCategory.custom(
    categoryId: 'newgames',
    displayLabel: I18n.txtGameCategoryNewGames,
    icon: 'ic_bling.svg',
    iconActive: 'ic_bling_yellow.svg',
    filter: newGamesFilter,
  );

  return GameCategories(
    categories: [sunwinCategory, ...standard, newGamesCategory],
  );
});
