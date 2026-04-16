import 'package:co_caro_flame/s88/features/game/game.dart';

/// {@template game_categories}
/// Represents the complete structure for game categories.
///
/// Supports flexible categories including:
/// - Traditional game type categories (Casino, Slots, Sports, etc.)
/// - Provider-specific categories ("Game Sunwin", "Vivo Gaming", etc.)
/// - Custom criteria categories ("Mới ra mắt", "Hot Games", etc.)
/// {@endtemplate}
class GameCategories {
  /// {@macro game_categories}
  const GameCategories({this.categories = const []});

  /// Flexible category categories (game types, providers, custom criteria)
  /// This is the new recommended way to define categories
  final List<GameCategory> categories;

  /// Create category data with specific categories
  static GameCategories withCategories(List<GameCategory> categories) =>
      GameCategories(categories: categories);
}
