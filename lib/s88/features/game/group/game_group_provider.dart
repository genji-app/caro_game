import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GAME GROUP PROVIDER (GENERIC)
// ═══════════════════════════════════════════════════════════════════════════

/// Generic family provider that returns games for a specific [GameFilter]
/// as a List of [GameBlock].
///
/// **Usage:**
/// ```dart
/// // Fetch games for the "Live Casino" category
/// final liveCasinoGames = ref.watch(gameGroupProvider(
///   const GameCategory.gameType(
///     type: GameType.live,
///     displayLabel: 'Live Casino',
///   ).toFilter()
/// ));
/// ```
///
/// Uses [GameRepository.getGames] with the filter automatically extracted
/// from the provided [GameCategory].
/// Returns `null` if no games are available.
final gameGroupProvider = FutureProvider.family
    .autoDispose<List<GameBlock>, GameFilter>((ref, filter) async {
      // 1. NGĂN CHẶN RELOAD KHI SCROLL (KeepAlive Timer)
      // Khi widget chứa provider này bị unmount (kéo ra khỏi màn hình),
      // nó sẽ không bị huỷ ngay lập tức mà giữ lại cache trong 5 phút.
      final link = ref.keepAlive();
      final timer = Timer(const Duration(minutes: 5), link.close);
      ref.onDispose(timer.cancel);

      // Watch repository events so this provider re-runs when
      // the cache is refreshed (e.g., remote data arrives after warmup).
      ref.watch(gameEventsProvider);

      final repository = ref.watch(gameRepositoryProvider);

      return repository.getGames(filter: filter);
    });
