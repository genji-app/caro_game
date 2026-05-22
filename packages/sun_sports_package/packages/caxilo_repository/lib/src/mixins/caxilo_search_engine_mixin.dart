import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;

import '../caxilo_utils.dart';
import '../models/caxilo_filter.dart';
import '../models/caxilo_game_block.dart';

/// Mixin responsible for searching and filtering games in memory.
mixin CaxiloSearchEngineMixin {
  /// Utility for string normalization.
  CaxiloUtils get utils;

  /// Settings client for accessing featured game configuration.
  caxiloconfig.CaxiloConfigClient get configClient;

  /// The single source of truth for the default provider ID (e.g., 'sunwin').
  String get defaultProviderId;

  /// Returns games matching the given [query] and/or [filter].
  ///
  /// When [filter] is a [CollectionFilter], results are sorted by the order
  /// defined in the collection array — allowing the server to control per-section
  /// ordering independently of the global [CasinoDisplay.order].
  List<CaxiloGameBlock> applySearchAndFilter(
    List<CaxiloGameBlock> games, {
    String? query,
    CaxiloFilter? filter,
  }) {
    final rawQuery = query?.toLowerCase().trim() ?? '';
    final normalizedQuery = rawQuery.isNotEmpty ? utils.removeDiacritics(rawQuery) : '';

    final collections = configClient.config?.display.collections;

    final result = games.where((block) {
      if (filter != null && !filter.matches(block, collections: collections)) {
        return false;
      }
      return rawQuery.isEmpty || _matchesQuery(block, rawQuery, normalizedQuery);
    }).toList();

    // For collection filters: sort by the server-defined order in the collection
    // array, so each section can have its own independent ordering.
    if (filter case CollectionFilter(:final collectionId)) {
      final ordered = collections?[collectionId] ?? [];
      if (ordered.isNotEmpty) {
        result.sort((a, b) {
          final indexA = ordered.indexOf(a.gameCode);
          final indexB = ordered.indexOf(b.gameCode);
          // Games not found in the list go to the end (safety fallback).
          final weightA = indexA == -1 ? ordered.length : indexA;
          final weightB = indexB == -1 ? ordered.length : indexB;
          return weightA.compareTo(weightB);
        });
      }
    }

    return result;
  }

  /// Returns games in the 'popular' collection as defined by remote settings.
  ///
  /// Returns an empty list if the 'popular' collection is not configured.
  List<CaxiloGameBlock> getPopularGamesFromList(List<CaxiloGameBlock> allGames) {
    final collections = configClient.config?.display.collections;
    return allGames
        .where((g) => CaxiloFilter.popular.matches(g, collections: collections))
        .toList();
  }

  /// Returns `true` if [block] matches the search term [q].
  bool _matchesQuery(CaxiloGameBlock block, String q, String normalizedQuery) {
    if (q.isEmpty) return true;

    final query = q.toLowerCase();

    // 1. Check direct matches (ID, Code, Name)
    final matchesRaw =
        block.gameName.toLowerCase().contains(query) ||
        block.gameCode.toLowerCase().contains(query) ||
        block.productId.toLowerCase().contains(query) ||
        block.providerName.toLowerCase().contains(query) ||
        block.providerId.toLowerCase().contains(query);

    if (matchesRaw) return true;

    // 2. Advanced: Normalized matching (e.g. "tai xiu" matches "Tài Xỉu")
    if (normalizedQuery.isEmpty) return false;

    return utils.removeDiacritics(block.gameName).toLowerCase().contains(normalizedQuery) ||
        utils.removeDiacritics(block.providerName).toLowerCase().contains(normalizedQuery);
  }
}
