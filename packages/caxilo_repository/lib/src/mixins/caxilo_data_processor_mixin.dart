import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:flutter/foundation.dart';
import 'package:game_api_client/game_api_client.dart' as gac;

import '../caxilo_mapper.dart';
import '../caxilo_utils.dart';
import '../models/models.dart';

/// Mixin responsible for processing raw game data from APIs and merging with in-house games.
mixin CaxiloDataProcessorMixin {
  /// Settings client for accessing in-house game list and display order.
  caxiloconfig.CaxiloConfigClient get configClient;

  /// Utility for generating image names.
  CaxiloUtils get utils;

  /// Retrieves in-house games and converts them to [CaxiloGameBlock] models.
  Future<List<CaxiloGameBlock>> getInHouseGameBlocks() async {
    final localConfigs = await configClient.getAllInHouseGames();
    return localConfigs.map((c) => CaxiloGameBlockMapper.fromInHouseConfig(c)).toList();
  }

  /// Maps raw [ProviderGames] into a flat, filtered list.
  ///
  /// Uses the hybrid whitelist from [caxiloconfig.CaxiloConfigClient] (Remote > Local Fallback).
  List<CaxiloGameBlock> processRawGames(List<gac.ProviderGames> allGames) {
    final result = <CaxiloGameBlock>[];
    var total = 0;

    final externalSettings = configClient.config?.external;

    for (final provider in allGames) {
      total += provider.gameList.length;
      for (final game in provider.gameList) {
        // Use the hybrid isSupported logic now encapsulated in the package.
        final isSupported =
            externalSettings?.isSupported(provider.providerId, game.gameCode) ?? false;

        if (isSupported) {
          result.add(
            CaxiloGameBlockMapper.fromGame(
              game: game,
              providerId: provider.providerId,
              providerName: provider.providerName,
              externalSettings: externalSettings,
              image:
                  externalSettings?.getGameImage(provider.providerId, game.gameCode) ??
                  utils.generateImageName(
                    providerId: provider.providerId,
                    gameCode: game.gameCode,
                    gameName: game.gameName,
                  ),
            ),
          );
        }
      }
    }

    debugPrint('📊 Games: $total total → ${result.length} after hybrid whitelist');
    return result;
  }

  /// Merges remote and local games, then sorts them based on remote settings.
  List<CaxiloGameBlock> mergeAndSortGames({
    required List<CaxiloGameBlock> processedRemoteGames,
    required List<CaxiloGameBlock> localGames,
  }) {
    final filtered = List<CaxiloGameBlock>.from(processedRemoteGames);
    filtered.addAll(localGames);
    debugPrint('📊 Added ${localGames.length} local games');

    // Sort entire list based on priority groups and remote settings display order
    final displayOrder = configClient.config?.display.order ?? [];

    filtered.sort((a, b) {
      final indexA = displayOrder.indexOf(a.gameCode);
      final indexB = displayOrder.indexOf(b.gameCode);
      final aInOrder = indexA != -1;
      final bInOrder = indexB != -1;

      // Both in displayOrder: fully mixed — follow exact server-defined order.
      if (aInOrder && bInOrder) return indexA.compareTo(indexB);

      // Only one in displayOrder: the ordered game comes first.
      if (aInOrder) return -1;
      if (bInOrder) return 1;

      // Neither in displayOrder: in-house before remote, then provider, then name.
      if (a.isInHouseGame != b.isInHouseGame) {
        return a.isInHouseGame ? -1 : 1;
      }
      if (!a.isInHouseGame) {
        final providerComp = a.providerName.compareTo(b.providerName);
        if (providerComp != 0) return providerComp;
      }
      return a.gameName.compareTo(b.gameName);
    });

    debugPrint('⚖️ CaxiloRepository: Sorted games (In-house > Remote, sub-sorted by provider)');

    return filtered;
  }
}
