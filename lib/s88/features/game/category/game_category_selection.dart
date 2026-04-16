import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';

import '../models/models.dart';

/// Selection state for game categories.
/// Simplified to use only the [GameCategory] model for single-level selection.
class GameCategorySelection {
  /// The selected category (null means "All")
  final GameCategory? category;

  const GameCategorySelection({this.category});

  /// Create selection from a category.
  factory GameCategorySelection.fromCategory(GameCategory category) {
    return GameCategorySelection(category: category);
  }

  GameCategorySelection copyWith({
    GameCategory? category,
    bool clearCategory = false,
  }) {
    return GameCategorySelection(
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  /// Check if this is an "All" selection (nothing specific selected)
  bool get isEmpty => category == null;

  /// Check if a specific category is selected
  bool get isNotEmpty => !isEmpty;

  /// Get a user-friendly label for this selection
  String get label => category?.label ?? 'Tất cả';

  /// Check if a game block matches the current selection
  bool matches(GameBlock gameBlock) {
    if (isEmpty) return true;
    return category!.matches(gameBlock);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCategorySelection &&
          runtimeType == other.runtimeType &&
          category == other.category;

  @override
  int get hashCode => category.hashCode;
}
