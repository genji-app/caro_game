import 'package:caxilo_config/caxilo_config.dart' as caxiloconfig;
import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Mixin responsible for building dynamic game categories from remote settings.
mixin CaxiloCategoryMixin {
  /// Settings client for accessing category configuration.
  caxiloconfig.CaxiloConfigClient get configClient;

  /// Returns the default "Lobby" (All Games) category.
  ///
  /// Used as a fallback when [caxiloconfig.CaxiloConfig.lobbyCategory] is not configured.
  CaxiloCategory getLobbyCategory() {
    return const CaxiloCategory(
      categoryId: 'all',
      translationKey: 'txt_game_category_all',
      icon: 'ic_home.svg',
      iconActive: 'ic_home_yellow.svg',
      filter: CaxiloFilter.all(filters: []),
    );
  }

  /// Returns the complete list of game categories.
  ///
  /// - [CaxiloCategories.all] is built from [caxiloconfig.CaxiloConfig.lobby] tab fields
  ///   when available; falls back to [getLobbyCategory] hardcode otherwise.
  /// - [CaxiloCategories.categories] is built from [caxiloconfig.CaxiloConfig.categories].
  CaxiloCategories getCaxiloCategories() {
    final config = configClient.config;
    final remoteLobby = config?.lobby;

    if (config == null || config.categories.isEmpty) {
      debugPrint('⚠️ CaxiloRepository: No categories found in configuration');
      return CaxiloCategories(all: getLobbyCategory(), categories: []);
    }

    final allCategory =
        remoteLobby?.translationKey != null &&
            remoteLobby?.icon != null &&
            remoteLobby?.iconActive != null
        ? CaxiloCategory(
            categoryId: 'all',
            translationKey: remoteLobby!.translationKey!,
            icon: remoteLobby.icon!,
            iconActive: remoteLobby.iconActive!,
            filter: const CaxiloFilter.all(filters: []),
          )
        : getLobbyCategory();

    final domainCategories = config.categories
        .map(
          (remote) => CaxiloCategory(
            categoryId: remote.id,
            translationKey: remote.translationKey,
            icon: remote.icon,
            iconActive: remote.iconActive,
            filter: CaxiloFilter.fromFilterConfig(remote.filter),
          ),
        )
        .toList();

    return CaxiloCategories(all: allCategory, categories: domainCategories);
  }

  /// Returns the categorized data specifically for the sidebar.
  ///
  /// Uses [CasinoCategory.groupKey] when present to assign categories to
  /// `priority` or `standard` groups. Falls back to type-based classification
  /// for categories without a [groupKey] (backward compatible).
  CaxiloSidebarData getCaxiloSidebarData() {
    final categoryData = getCaxiloCategories();
    final remoteGroupKeys = {
      for (final c in configClient.config?.categories ?? <caxiloconfig.CategoryConfig>[])
        c.id: c.groupKey,
    };

    const priorityTypes = {caxiloconfig.GameType.jackpot};
    const excludedTypes = {caxiloconfig.GameType.sport};

    final priorityList = <CaxiloCategory>[categoryData.all];
    final standardList = <CaxiloCategory>[];

    for (final category in categoryData.categories) {
      final groupKey = remoteGroupKeys[category.categoryId];

      if (groupKey == 'priority') {
        priorityList.add(category);
      } else if (groupKey == 'standard') {
        standardList.add(category);
      } else {
        _classifyByType(category, priorityList, standardList, priorityTypes, excludedTypes);
      }
    }

    return CaxiloSidebarData(
      groups: [
        CaxiloSidebarGroup(id: 'priority', categories: priorityList),
        CaxiloSidebarGroup(id: 'standard', categories: standardList),
      ],
    );
  }

  /// Fallback type-based classification for categories without a [groupKey].
  void _classifyByType(
    CaxiloCategory category,
    List<CaxiloCategory> priority,
    List<CaxiloCategory> standard,
    Set<caxiloconfig.GameType> priorityTypes,
    Set<caxiloconfig.GameType> excludedTypes,
  ) {
    final filter = category.filter;

    if (filter is InHouseFilter || filter is ProvidersFilter) {
      priority.add(category);
    } else if (filter is CaxiloTypesFilter) {
      final type = filter.gameTypes.isEmpty ? null : filter.gameTypes.first;
      if (type != null) {
        if (priorityTypes.contains(type)) {
          priority.add(category);
        } else if (!excludedTypes.contains(type)) {
          standard.add(category);
        }
      }
    }
  }
}
