import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'caxilo_game_block.dart';

part 'caxilo_filter.freezed.dart';

/// {@template caxilo_filter}
/// Defines the criteria for filtering games.
/// Allows flexible filtering based on various game attributes.
///
/// ## Available Filter Types
///
/// 1. **By Collection** - Filter by game codes in a named collection (from remote settings)
/// 2. **By Game Codes** - Filter by an explicit list of game codes
/// 3. **By Providers** - Filter by provider IDs
/// 4. **By Game Types** - Filter by game types
/// 5. **By In-House** - Filter for in-house developed games
/// 6. **All (AND)** - Combine multiple filters (must match ALL)
/// 7. **Any (OR)** - Combine multiple filters (must match ANY)
/// 8. **From Strategy** - Create filter from a remote configuration strategy
///
/// ## Examples
///
/// ### Simple Filter
/// ```dart
/// // Games in the 'popular' collection
/// CaxiloFilter.byCollection(collectionId: 'popular')
///
/// // Explicit list of games
/// CaxiloFilter.byGameCodes(gameCodes: ['AVENGER', 'SC'])
///
/// // Games from specific providers
/// CaxiloFilter.byProviders(providerIds: ['sunwin', 'vivo'])
///
/// // Slot or Live games
/// CaxiloFilter.byGameTypes(gameTypes: [caxiloconfig.GameType.slot, caxiloconfig.GameType.live])
///
/// // In-house developed games
/// CaxiloFilter.isInHouse()
///
/// // Create from remote config strategy
/// CaxiloFilter.fromStrategy('collection', {'id': 'popular'})
/// ```
///
/// ### Combined Filter (AND)
/// ```dart
/// // Games in 'new' collection AND from specific providers
/// CaxiloFilter.all(
///   filters: [
///     CaxiloFilter.byCollection(collectionId: 'new'),
///     CaxiloFilter.byProviders(providerIds: ['sunwin']),
///   ],
/// )
/// ```
///
/// ### Combined Filter (OR)
/// ```dart
/// // Games that are EITHER in collection OR explicitly listed
/// CaxiloFilter.any(
///   filters: [
///     CaxiloFilter.byCollection(collectionId: 'hot'),
///     CaxiloFilter.byGameCodes(gameCodes: ['AVENGER']),
///   ],
/// )
/// ```
/// {@endtemplate}
@freezed
sealed class CaxiloFilter with _$CaxiloFilter {
  /// Filter games by a named collection defined in remote settings.
  const factory CaxiloFilter.byCollection({required String collectionId}) = CollectionFilter;

  /// Filter games by an explicit list of game codes.
  const factory CaxiloFilter.byGameCodes({required List<String> gameCodes}) = GameCodesFilter;

  /// Filter games by multiple providers
  const factory CaxiloFilter.byProviders({required List<String> providerIds}) = ProvidersFilter;

  /// Filter games by game types
  const factory CaxiloFilter.byGameTypes({required List<caxiloconfig.GameType> gameTypes}) =
      CaxiloTypesFilter;

  /// Filter only in-house developed games
  const factory CaxiloFilter.isInHouse() = InHouseFilter;

  /// Combine multiple filters with AND logic
  const factory CaxiloFilter.all({required List<CaxiloFilter> filters}) = AllFilter;

  /// Combine multiple filters with OR logic
  const factory CaxiloFilter.any({required List<CaxiloFilter> filters}) = AnyFilter;

  /// Builds a [CaxiloFilter] from a [caxiloconfig.CaxiloFilter].
  factory CaxiloFilter.fromFilterConfig(caxiloconfig.CaxiloFilter config) {
    return CaxiloFilter.fromStrategy(config.strategy, config.params);
  }

  /// Builds a [CaxiloFilter] from a strategy and its parameters.
  factory CaxiloFilter.fromStrategy(
    caxiloconfig.CaxiloFilterStrategy strategy,
    Map<String, dynamic>? params,
  ) {
    switch (strategy) {
      case caxiloconfig.CaxiloFilterStrategy.collection:
        final id = params?['id'] as String? ?? '';
        return CaxiloFilter.byCollection(collectionId: id);

      case caxiloconfig.CaxiloFilterStrategy.byGameCodes:
        final rawCodes = params?['game_codes'] as List<dynamic>? ?? [];
        final codes = rawCodes.map((e) => e.toString()).toList();
        return CaxiloFilter.byGameCodes(gameCodes: codes);

      case caxiloconfig.CaxiloFilterStrategy.byGameType:
        final rawType = params?['game_type'] as String?;
        final type = caxiloconfig.GameType.fromJson(rawType);
        return CaxiloFilter.byGameTypes(gameTypes: [type]);

      case caxiloconfig.CaxiloFilterStrategy.byProvider:
        final providerId = params?['provider_id'] as String? ?? '';
        return CaxiloFilter.byProviders(providerIds: [providerId]);

      case caxiloconfig.CaxiloFilterStrategy.inHouse:
        return const CaxiloFilter.isInHouse();

      case caxiloconfig.CaxiloFilterStrategy.unknown:
        debugPrint('[CaxiloFilter] Unknown filter strategy encountered');
        // Return an empty filter as a safe fallback (matches nothing)
        return const CaxiloFilter.none();
    }
  }

  /// A filter that matches no games.
  const factory CaxiloFilter.none() = NoneFilter;

  // ---------------------------------------------------------------------------
  // Preset filters — convenience shorthands for commonly used filter configs.
  // These mirror the collection IDs and strategies defined in display_presets.
  // ---------------------------------------------------------------------------

  /// Games in the 'featured' collection.
  static const CaxiloFilter featured = CaxiloFilter.byCollection(collectionId: 'featured');

  /// Games in the 'popular' collection.
  static const CaxiloFilter popular = CaxiloFilter.byCollection(collectionId: 'popular');

  /// Games in the 'new' collection.
  static const CaxiloFilter newGames = CaxiloFilter.byCollection(collectionId: 'new');

  /// In-house (Sunwin) games only.
  static const CaxiloFilter inHouse = CaxiloFilter.isInHouse();

  /// Live casino games.
  static const CaxiloFilter live = CaxiloFilter.byGameTypes(
    gameTypes: [caxiloconfig.GameType.live],
  );

  /// Slot games.
  static const CaxiloFilter slots = CaxiloFilter.byGameTypes(
    gameTypes: [caxiloconfig.GameType.slot],
  );

  /// Card games.
  static const CaxiloFilter cardGames = CaxiloFilter.byGameTypes(
    gameTypes: [caxiloconfig.GameType.card],
  );

  /// Jackpot games.
  static const CaxiloFilter jackpots = CaxiloFilter.byGameTypes(
    gameTypes: [caxiloconfig.GameType.jackpot],
  );
}

/// Extension methods for filtering games based on criteria
extension CaxiloFilterX on CaxiloFilter {
  /// Check if a game block matches this filter
  ///
  /// [gameBlock] The game block to check
  /// [now] Optional current time for relative date calculations
  /// [collections] Optional collections map from remote settings for [CollectionFilter] lookup
  bool matches(CaxiloGameBlock gameBlock, {DateTime? now, Map<String, List<String>>? collections}) {
    return when(
      byCollection: (collectionId) {
        final list = collections?[collectionId] ?? [];
        return list.contains(gameBlock.gameCode);
      },
      byGameCodes: (gameCodes) {
        return gameCodes.contains(gameBlock.gameCode);
      },
      byProviders: (providerIds) {
        return providerIds.contains(gameBlock.providerId);
      },
      byGameTypes: (gameTypes) {
        return gameTypes.contains(gameBlock.gameType);
      },
      isInHouse: () {
        return gameBlock.isInHouseGame;
      },
      all: (filters) {
        return filters.every((c) => c.matches(gameBlock, now: now, collections: collections));
      },
      any: (filters) {
        return filters.any((c) => c.matches(gameBlock, now: now, collections: collections));
      },
      none: () => false,
    );
  }
}
