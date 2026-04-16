import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';
import 'package:co_caro_flame/s88/features/search/data/datasources/search_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/search/data/datasources/search_remote_datasource_impl.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_response_model.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';
import 'package:co_caro_flame/s88/features/search/data/repositories/search_repository_impl.dart';
import 'package:co_caro_flame/s88/features/search/data/storage/casino_recent_games_storage.dart';
import 'package:co_caro_flame/s88/features/search/data/storage/search_recent_storage.dart';
import 'package:co_caro_flame/s88/features/search/domain/repositories/search_repository.dart';
import 'package:co_caro_flame/s88/features/search/domain/usecases/search_usecase.dart';

// ============================================================================
// Data layer
// ============================================================================

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSourceImpl(SbHttpManager.instance);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dataSource = ref.read(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(dataSource);
});

// ============================================================================
// Domain layer (use cases)
// ============================================================================

final searchUseCaseProvider = Provider<SearchUseCase>((ref) {
  final repository = ref.read(searchRepositoryProvider);
  return SearchUseCase(repository);
});

// ============================================================================
// Search state (debounced query + result)
// ============================================================================

/// Debounced query: widget cập nhật sau delay khi user gõ.
final searchDebouncedQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Danh sách từ khóa tìm kiếm gần đây tab Thể thao. Invalidate sau khi thêm/xóa.
final searchRecentSportProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return SearchRecentStorage.getRecentSport();
});

/// Danh sách từ khóa tìm kiếm gần đây tab Casino. Invalidate sau khi thêm/xóa.
final searchRecentCasinoProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return SearchRecentStorage.getRecentCasino();
});

/// Phổ biến tab Thể thao: từ API getPopularLeagues lấy 5 trận có nhiều kèo (marketCount),
/// map sang [SearchResultItem] để hiển thị đúng UI Figma (league + giờ + 2 đội).
final searchPopularLeaguesProvider =
    FutureProvider.autoDispose<List<SearchResultItem>>((ref) async {
      final leagues = await SbHttpManager.instance.getPopularLeagues();
      final candidates = <({LeagueModelV2 league, EventModelV2 event})>[];
      for (final league in leagues) {
        for (final event in league.events) {
          candidates.add((league: league, event: event));
        }
      }
      candidates.sort(
        (a, b) => (b.event.marketCount).compareTo(a.event.marketCount),
      );
      final top5 = candidates.take(5).toList();
      return top5
          .map(
            (e) => SearchResultItem(
              sportId: e.event.sportId,
              eventId: e.event.eventId,
              leagueName: e.league.leagueName,
              leagueId: e.league.leagueId,
              eventName: '${e.event.homeName} vs ${e.event.awayName}',
              startTimeIso: e.event.startDate,
              startTimeMs: e.event.startTime,
              isLive: e.event.isLive,
              status: e.event.type,
              leagueIconUrl: e.league.leagueLogo,
              homeTeamLogoUrl: e.event.homeLogo,
              awayTeamLogoUrl: e.event.awayLogo,
            ),
          )
          .toList();
    });

/// Kết quả tìm kiếm theo query; dùng [SearchUseCase], hủy request cũ khi đổi query.
final searchResultProvider = FutureProvider.autoDispose
    .family<SearchResponseModel, String>((ref, query) async {
      if (query.isEmpty) return const SearchResponseModel();

      final token = CancelToken();
      ref.onDispose(token.cancel);

      final useCase = ref.read(searchUseCaseProvider);
      final result = await useCase.call(query, cancelToken: token);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (model) => model,
      );
    });

// ============================================================================
// Casino search (in-data: filter games from allGamesProvider by query)
// ============================================================================

/// Kết quả tìm kiếm game casino: filter trong data đã load (allGamesProvider),
/// không gọi API. Dùng khi tab Casino trong search dialog/screen.
final casinoSearchResultsProvider = Provider.autoDispose<List<GameBlock>>((
  ref,
) {
  final allGames = ref.watch(allGamesProvider).value ?? [];
  final query = ref.watch(searchDebouncedQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return allGames;

  return allGames.where((block) {
    final gameName = block.gameName.toLowerCase();
    final gameCode = block.gameCode.toLowerCase();
    final productId = block.productId.toLowerCase();
    final providerName = block.providerName.toLowerCase();
    final providerId = block.providerId.toLowerCase();
    return gameName.contains(query) ||
        gameCode.contains(query) ||
        productId.contains(query) ||
        providerName.contains(query) ||
        providerId.contains(query);
  }).toList();
});

// ============================================================================
// Casino: Chơi gần đây + Phổ biến (khi chưa search)
// ============================================================================

/// Danh sách key game đã chơi gần đây (tối đa 5). Invalidate sau khi thêm.
final casinoRecentKeysProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return CasinoRecentGamesStorage.getKeys();
});

/// Resolve key "providerId|productId|gameCode" thành [GameBlock] từ allGames.
/// Trả về tối đa 5 item, đúng thứ tự gần đây. Item không còn trong catalog thì bỏ qua.
final casinoRecentGameBlocksProvider = Provider.autoDispose<List<GameBlock>>((
  ref,
) {
  final allGames = ref.watch(allGamesProvider).value ?? [];
  final keysAsync = ref.watch(casinoRecentKeysProvider);

  return keysAsync.maybeWhen(
    data: (keys) {
      final list = <GameBlock>[];
      for (final key in keys.take(5)) {
        final parts = key.split('|');
        if (parts.length != 3) continue;
        final providerId = parts[0];
        final productId = parts[1];
        final gameCode = parts[2];
        GameBlock? block;
        for (final b in allGames) {
          if (b.providerId == providerId &&
              b.productId == productId &&
              b.gameCode == gameCode) {
            block = b;
            break;
          }
        }
        if (block != null) list.add(block);
      }
      return list;
    },
    orElse: () => [],
  );
});

/// 5 game Sunwin đầu tiên (Phổ biến) từ GameRepository.
final casinoPopularGamesProvider = FutureProvider.autoDispose<List<GameBlock>>((
  ref,
) {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.getPopularGames();
});
