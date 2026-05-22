import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:flutter/foundation.dart';

import '../caxilo_failure.dart';
import '../models/models.dart';

/// Mixin responsible for building the game home lobby based on remote configuration.
mixin CaxiloLobbyMixin {
  /// Settings client for accessing lobby layout configuration.
  caxiloconfig.CaxiloConfigClient get configClient;

  /// Fetches games matching the given [filter].
  Future<List<CaxiloGameBlock>> getCaxiloGames({String? query, CaxiloFilter? filter});

  /// Builds the complete game lobby using Server-Driven UI (SDUI).
  Future<List<CaxiloLobbyBlock>> getCaxiloLobby() async {
    final sections = configClient.config?.lobby?.sections ?? [];

    if (sections.isEmpty) {
      debugPrint('⚠️ CaxiloLobbyMixin: No lobbySections found in configuration');
      return [];
    }

    try {
      final fetchEntries = <({caxiloconfig.LobbySectionConfig section, CaxiloFilter filter})>[];

      for (final section in sections) {
        final filter = _mapSectionToFilter(section);
        if (filter != null) {
          fetchEntries.add((section: section, filter: filter));
        }
      }

      final results = await Future.wait(fetchEntries.map((e) => getCaxiloGames(filter: e.filter)));

      final gamesBySection = <caxiloconfig.LobbySectionConfig, List<CaxiloGameBlock>>{};
      for (var i = 0; i < fetchEntries.length; i++) {
        final entry = fetchEntries[i];
        gamesBySection[entry.section] = _applyLimit(results[i], entry.section.displayLimit);
      }

      final List<CaxiloLobbyBlock> lobbyBlocks = [];

      for (final section in sections) {
        final block = section.isBanner
            ? CaxiloBannerBlock(bannerId: section.bannerId!)
            : section.isGames
            ? () {
                final games = gamesBySection[section] ?? [];
                return games.isNotEmpty
                    ? CaxiloGroupBlock(label: section.title ?? '', games: games)
                    : null;
              }()
            : null;

        if (block != null) {
          lobbyBlocks.add(block);
        }
      }

      return lobbyBlocks;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToCaxiloFailure(error), stackTrace);
    }
  }

  /// Maps a [caxiloconfig.LobbySectionConfig] configuration into a [CaxiloFilter].
  CaxiloFilter? _mapSectionToFilter(caxiloconfig.LobbySectionConfig section) {
    if (section.filter != null) {
      return CaxiloFilter.fromFilterConfig(section.filter!);
    }
    return null;
  }

  /// Takes only [limit] items from the [games] list.
  List<CaxiloGameBlock> _applyLimit(List<CaxiloGameBlock> games, int limit) {
    if (limit < 0 || games.length <= limit) return games;
    return games.take(limit).toList();
  }
}
