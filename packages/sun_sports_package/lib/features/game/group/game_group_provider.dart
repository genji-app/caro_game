import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/game/game.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GAME GROUP PROVIDER (GENERIC)
// ═══════════════════════════════════════════════════════════════════════════

/// Generic family provider that returns games for a specific [CaxiloFilter]
/// as a List of [GameBlock].
///
/// **Usage:**
/// ```dart
/// // Fetch games for the "Live Casino" category
/// final liveCasinoGames = ref.watch(gameGroupProvider(
///   const CaxiloCategory.gameType(
///     type: GameType.live,
///     translationKey: 'txt_game_category_live_dealer',
///   ).toFilter()
/// ));
/// ```
///
/// Uses [CaxiloRepository.getGames] with the filter automatically extracted
/// from the provided [CaxiloCategory].
/// Returns `null` if no games are available.
final gameGroupProvider = FutureProvider.family
    .autoDispose<List<GameBlock>, CaxiloFilter>((ref, filter) async {
      // 1. NGĂN CHẶN RELOAD KHI SCROLL (KeepAlive Timer)
      // Khi widget chứa provider này bị unmount (kéo ra khỏi màn hình),
      // nó sẽ không bị huỷ ngay lập tức mà giữ lại cache trong 5 phút.
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 5), link.close);
      ref.onDispose(timer.cancel);

      // Watch repository events so this provider re-runs when
      // the cache is refreshed (e.g., remote data arrives after warmup).
      ref.watch(caxiloEventsProvider);

      final repository = ref.watch(caxiloRepositoryProvider);

      return repository.getGames(filter: filter);
    });
