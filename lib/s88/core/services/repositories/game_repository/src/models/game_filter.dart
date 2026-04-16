import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_api_client/game_api_client.dart';

import 'game_block.dart';

part 'game_filter.freezed.dart';

/// {@template game_filter}
/// Defines the criteria for filtering games.
/// Allows flexible filtering based on various game attributes.
///
/// ## Available Filter Types
///
/// 1. **By Release Date** - Filter by how recently games were released
/// 2. **By Popularity** - Filter by minimum play count
/// 3. **By Providers** - Filter by provider IDs
/// 4. **By Game Types** - Filter by game types
/// 5. **All (AND)** - Combine multiple filters (must match ALL)
/// 6. **Any (OR)** - Combine multiple filters (must match ANY)
///
/// ## Examples
///
/// ### Simple Filter
/// ```dart
/// // Games released in last 30 days
/// GameFilter.byReleaseDate(daysAgo: 30)
///
/// // Games with at least 1000 plays
/// GameFilter.byPopularity(minPlayCount: 1000)
///
/// // Games from specific providers
/// GameFilter.byProviders(providerIds: ['sunwin', 'vivo'])
///
/// // Slot or Live games
/// GameFilter.byGameTypes(gameTypes: [GameType.slot, GameType.live])
/// ```
///
/// ### Combined Filter (AND)
/// ```dart
/// // Games released recently AND from specific providers
/// GameFilter.all(
///   filters: [
///     GameFilter.byReleaseDate(daysAgo: 30),
///     GameFilter.byProviders(providerIds: ['sunwin']),
///   ],
/// )
/// ```
///
/// ### Combined Filter (OR)
/// ```dart
/// // Games that are EITHER new OR popular
/// GameFilter.any(
///   filters: [
///     GameFilter.byReleaseDate(daysAgo: 7),
///     GameFilter.byPopularity(minPlayCount: 5000),
///   ],
/// )
/// ```
///
/// **Note**: Some fields like `releaseDate` and `playCount` are currently not available in the [Game] model.
/// Filters using these fields will temporarily return `true` to avoid filtering out all games.
/// {@endtemplate}
@freezed
sealed class GameFilter with _$GameFilter {
  /// Filter games by release date
  const factory GameFilter.byReleaseDate({required int daysAgo}) =
      ReleaseDateFilter;

  /// Filter games by popularity/play count
  const factory GameFilter.byPopularity({required int minPlayCount}) =
      PopularityFilter;

  /// Filter games by multiple providers
  const factory GameFilter.byProviders({required List<String> providerIds}) =
      ProvidersFilter;

  /// Filter games by game types
  const factory GameFilter.byGameTypes({required List<GameType> gameTypes}) =
      GameTypesFilter;

  /// Combine multiple filters with AND logic
  const factory GameFilter.all({required List<GameFilter> filters}) = AllFilter;

  /// Combine multiple filters with OR logic
  const factory GameFilter.any({required List<GameFilter> filters}) = AnyFilter;
}

/// Extension methods for filtering games based on criteria
extension GameFilterX on GameFilter {
  /// Check if a game block matches this filter
  ///
  /// [gameBlock] The game block to check
  /// [now] Optional current time for relative date calculations
  bool matches(GameBlock gameBlock, {DateTime? now}) {
    return when(
      byReleaseDate: (daysAgo) {
        // Release date filtering is currently a placeholder as Game model doesn't have it yet
        return true;
      },
      byPopularity: (minPlayCount) {
        // Popularity filtering is currently a placeholder as Game model doesn't have it yet
        return true;
      },
      byProviders: (providerIds) {
        return providerIds.contains(gameBlock.providerId);
      },
      byGameTypes: (gameTypes) {
        return gameTypes.contains(gameBlock.gameType);
      },
      all: (filters) {
        return filters.every((c) => c.matches(gameBlock, now: now));
      },
      any: (filters) {
        return filters.any((c) => c.matches(gameBlock, now: now));
      },
    );
  }
}
