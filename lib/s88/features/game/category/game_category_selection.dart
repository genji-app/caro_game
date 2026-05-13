import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// Selection state for game categories.
/// Simplified to use only the [CaxiloCategory] model for single-level selection.
class GameCategorySelection {
  /// The selected category (null means "All")
  final CaxiloCategory? category;

  const GameCategorySelection({this.category});

  /// Create selection from a category.
  factory GameCategorySelection.fromCategory(CaxiloCategory category) {
    return GameCategorySelection(category: category);
  }

  GameCategorySelection copyWith({
    CaxiloCategory? category,
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
  String get label => category?.displayName ?? I18n.txtGameCategoryAll;

  /// Check if a game block matches the current selection.
  ///
  /// ⚠️ Does NOT work correctly for collection-based categories
  /// (e.g., `newgames`, `featured`) because [collections] is not available here.
  /// Prefer [GameCategorySelectionX.toFilter] + [CaxiloRepository.getGames]
  /// for the correct filtering path.
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
