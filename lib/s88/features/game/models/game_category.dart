import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';

part 'game_category.freezed.dart';

/// {@template game_category}
/// Represents a flexible category that can be based on:
/// - Game type (Casino, Slots, Sports, etc.)
/// - Provider (show all games from a specific provider)
/// - Custom criteria (New releases, Hot games, etc.)
///
/// This allows the UI to display various category tabs beyond just game types.
///
/// ## Examples
///
/// ### Traditional game type category:
/// ```dart
/// const GameCategory.gameType(
///   type: GameType.slot,
///   displayLabel: 'Slots',
///   gameCount: 200,
/// )
/// ```
///
/// ### Provider-specific category:
/// ```dart
/// const GameCategory.provider(
///   providerId: 'sunwin',
///   displayLabel: 'Game Sunwin',
///   gameCount: 45,
/// )
/// ```
///
/// ### Custom "New Releases" category:
/// ```dart
/// const GameCategory.custom(
///   categoryId: 'new_releases',
///   displayLabel: 'Mới ra mắt',
///   filter: GameFilter.byReleaseDate(daysAgo: 30),
///   gameCount: 20,
/// )
/// ```
///
/// ### Custom "Hot Games" category (AND logic):
/// ```dart
/// const GameCategory.custom(
///   categoryId: 'hot_games',
///   displayLabel: 'Hot Games',
///   filter: GameFilter.all(
///     filters: [
///       GameFilter.byReleaseDate(daysAgo: 7),
///       GameFilter.byPopularity(minPlayCount: 1000),
///     ],
///   ),
///   gameCount: 35,
/// )
/// ```
/// {@endtemplate}
@freezed
sealed class GameCategory with _$GameCategory {
  const GameCategory._();

  /// Category by game type (traditional category)
  ///
  /// Example:
  /// ```dart
  /// const GameCategory.gameType(
  ///   type: GameType.slot,
  ///   displayLabel: 'Slots',
  ///   gameCount: 200,
  ///   providerIds: ['pg_soft', 'pragmatic'],
  /// )
  /// ```
  const factory GameCategory.gameType({
    required GameType type,
    required String displayLabel,
    String? icon,
    String? iconActive,
    @Default(0) int gameCount,
    @Default([]) List<String> providerIds,
  }) = GameTypeCategory;

  /// Category by provider (show all games from a specific provider)
  ///
  /// Example:
  /// ```dart
  /// const GameCategory.provider(
  ///   providerId: 'sunwin',
  ///   displayLabel: 'Game Sunwin',
  ///   icon: 'assets/providers/sunwin_logo.png',
  ///   gameCount: 45,
  ///   gameTypes: [GameType.slot, GameType.card],
  /// )
  /// ```
  const factory GameCategory.provider({
    required String providerId,
    required String displayLabel,
    String? icon,
    String? iconActive,
    @Default(0) int gameCount,
    @Default([]) List<GameType> gameTypes,
  }) = ProviderCategory;

  /// Category by custom criteria
  ///
  /// Examples:
  /// ```dart
  /// // New releases (last 30 days)
  /// const GameCategory.custom(
  ///   categoryId: 'new_releases',
  ///   displayLabel: 'Mới ra mắt',
  ///   filter: GameFilter.byReleaseDate(daysAgo: 30),
  ///   gameCount: 20,
  /// )
  ///
  /// // Hot games (recently released AND popular)
  /// const GameCategory.custom(
  ///   categoryId: 'hot_games',
  ///   displayLabel: 'Hot Games',
  ///   filter: GameFilter.all(
  ///     filters: [
  ///       GameFilter.byReleaseDate(daysAgo: 7),
  ///       GameFilter.byPopularity(minPlayCount: 1000),
  ///     ],
  ///   ),
  ///   gameCount: 35,
  /// )
  ///
  /// // Recommended (popular OR recently released)
  /// const GameCategory.custom(
  ///   categoryId: 'recommended',
  ///   displayLabel: 'Đề xuất',
  ///   filter: GameFilter.any(
  ///     filters: [
  ///       GameFilter.byReleaseDate(daysAgo: 14),
  ///       GameFilter.byPopularity(minPlayCount: 5000),
  ///     ],
  ///   ),
  ///   gameCount: 50,
  /// )
  /// ```
  const factory GameCategory.custom({
    required String categoryId,
    required String displayLabel,
    required GameFilter filter,
    String? icon,
    String? iconActive,
    @Default(0) int gameCount,
  }) = CustomCategory;

  /// Get a unique identifier for this category
  String get id => when(
    gameType: (type, _, __, ___, ____, _____) => 'type_${type.value}',
    provider: (providerId, _, __, ___, ____, _____) => 'provider_$providerId',
    custom: (categoryId, _, __, ___, ____, _____) => 'custom_$categoryId',
  );

  /// Get the display label for this category
  String get label => when(
    gameType: (_, label, __, ___, ____, _____) => label,
    provider: (_, label, __, ___, ____, _____) => label,
    custom: (_, label, __, ___, ____, _____) => label,
  );

  /// Get the game count for this category
  int get count => when(
    gameType: (_, __, ___, ____, count, _____) => count,
    provider: (_, __, ___, ____, count, _____) => count,
    custom: (_, __, ___, ____, _____, count) => count,
  );

  /// Get the icon name (filename) for this category
  /// If [active] is true, returns the active icon name
  String? getIcon({bool active = false}) => when(
    gameType: (_, __, icon, activeIcon, ___, ____) =>
        active ? activeIcon : icon,
    provider: (_, __, icon, activeIcon, ___, ____) =>
        active ? activeIcon : icon,
    custom: (_, __, ___, icon, activeIcon, ____) => active ? activeIcon : icon,
  );

  /// Check if a game matches this category
  bool matches(GameBlock game) {
    return when(
      gameType: (type, _, __, ___, ____, _____) => game.gameType == type,
      provider: (id, _, __, ___, ____, _____) => game.providerId == id,
      custom: (_, __, filter, ___, ____, _____) => filter.matches(game),
    );
  }
}
