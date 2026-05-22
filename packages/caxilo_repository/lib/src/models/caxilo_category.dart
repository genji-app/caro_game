import 'package:freezed_annotation/freezed_annotation.dart';

import 'caxilo_filter.dart';
import 'caxilo_game_block.dart';

part 'caxilo_category.freezed.dart';

/// {@template caxilo_category}
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
/// const CaxiloCategory.gameType(
///   type: GameType.slot,
///   translationKey: 'txt_game_slots',
/// )
/// ```
///
/// ### Provider-specific category:
/// ```dart
/// const CaxiloCategory.provider(
///   providerId: 'sunwin',
///   translationKey: 'txt_game_category_sunwin',
/// )
/// ```
///
/// ### Custom "New Releases" category:
/// ```dart
/// const CaxiloCategory.custom(
///   categoryId: 'new_releases',
///   translationKey: 'txt_game_category_new_games',
///   filter: CaxiloFilter.byCollection(collectionId: 'new'),
/// )
/// ```
///
/// ### Custom "Hot Games" category (AND logic):
/// ```dart
/// const CaxiloCategory.custom(
///   categoryId: 'hot_games',
///   translationKey: 'txt_game_category_hot_games',
///   filter: CaxiloFilter.all(
///     filters: [
///       CaxiloFilter.byCollection(collectionId: 'new'),
///       CaxiloFilter.byCollection(collectionId: 'popular'),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
@freezed
sealed class CaxiloCategory with _$CaxiloCategory {
  /// {@macro caxilo_category}
  const factory CaxiloCategory({
    required String categoryId,
    required String translationKey,
    required CaxiloFilter filter,
    String? icon,
    String? iconActive,
  }) = _CaxiloCategory;
}

/// Extension for [CaxiloCategory] to provide utility methods and getters.
extension CaxiloCategoryX on CaxiloCategory {
  /// Get a unique identifier for this category
  String get id => categoryId;

  /// Get the icon name (filename) for this category
  /// If [active] is true, returns the active icon name
  String? getIcon({bool active = false}) => active ? iconActive : icon;

  /// Check if a game matches this category
  bool matches(CaxiloGameBlock game, {Map<String, List<String>>? collections}) {
    return filter.matches(game, collections: collections);
  }
}
