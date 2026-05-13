import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/game/game_providers.dart';

/// Provider that provides the complete game category data.
///
/// Watches [caxiloEventsProvider] so it rebuilds whenever the repository
/// emits a [CaxiloDataChanged] event (e.g., after remote settings reload).
final gameCategoriesProvider = Provider<CaxiloCategories>((ref) {
  ref.watch(caxiloEventsProvider);
  final repository = ref.watch(caxiloRepositoryProvider);
  return repository.getCaxiloCategories();
});

/// Provider that provides categorized data for the sidebar.
///
/// Watches [caxiloEventsProvider] so it rebuilds whenever the repository
/// emits a [CaxiloDataChanged] event (e.g., after remote settings reload).
final casinoSidebarCategoriesProvider = Provider<CaxiloSidebarData>((ref) {
  ref.watch(caxiloEventsProvider);
  final repository = ref.watch(caxiloRepositoryProvider);
  return repository.getSidebarData();
});
