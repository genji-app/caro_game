import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/features/game/game.dart';

/// Status of the game feed
enum GameFeedStatus { initial, loading, success, failure }

/// State for the game feed
@immutable
class GameFeedState {
  const GameFeedState({
    this.status = GameFeedStatus.initial,
    this.feedItems = const [],
    this.error,
  });

  final GameFeedStatus status;
  final List<GameFeedBlock> feedItems;
  final String? error;

  GameFeedState copyWith({
    GameFeedStatus? status,
    List<GameFeedBlock>? feedItems,
    String? error,
  }) {
    return GameFeedState(
      status: status ?? this.status,
      feedItems: feedItems ?? this.feedItems,
      error: error,
    );
  }

  bool get isLoading => status == GameFeedStatus.loading;
  bool get isFailure => status == GameFeedStatus.failure;
  bool get isSuccess => status == GameFeedStatus.success;
}

/// Provider that manages the game feed data (grouped view/home view)
class GameFeedNotifier extends StateNotifier<GameFeedState> {
  GameFeedNotifier({required GameRepository repository})
    : _repository = repository,
      super(const GameFeedState(status: GameFeedStatus.initial)) {
    _init();
  }

  final GameRepository _repository;

  /// Refreshes the feed by fetching fresh data from the repository.
  Future<void> refresh() async {
    state = state.copyWith(status: GameFeedStatus.loading);
    try {
      await _repository.warmup();
      await _init();
    } catch (_) {
      // _init already handles error state
    }
  }

  Future<void> _init() async {
    state = state.copyWith(status: GameFeedStatus.loading);
    try {
      // Fetch specific categories in parallel for the feed sections
      final results = await Future.wait([
        _repository.getGames(
          filter: const GameFilter.byPopularity(minPlayCount: 100),
        ),
        _repository.getGames(
          filter: const GameFilter.byReleaseDate(daysAgo: 30),
        ),
        _repository.getGames(
          filter: const GameFilter.byProviders(
            providerIds: [GameRepository.sunwinProviderId],
          ),
        ),

        _repository.getGames(
          filter: const GameFilter.byGameTypes(gameTypes: [GameType.live]),
        ),
        _repository.getGames(
          filter: const GameFilter.byGameTypes(gameTypes: [GameType.slot]),
        ),
        _repository.getGames(
          filter: const GameFilter.byGameTypes(gameTypes: [GameType.card]),
        ),
        _repository.getGames(
          filter: const GameFilter.byGameTypes(gameTypes: [GameType.jackpot]),
        ),
      ]);

      final items = _processGamesToFeedItems(
        outstandingGames: results[0],
        newGames: results[1],
        sunwinGames: results[2],
        liveGames: results[3],
        slotGames: results[4],
        cardGames: results[5],
        jackpotGames: results[6],
      );

      state = state.copyWith(
        feedItems: items,
        status: GameFeedStatus.success,
        error: null,
      );
    } on GameFailure catch (e) {
      state = state.copyWith(
        status: GameFeedStatus.failure,
        error: e.errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: GameFeedStatus.failure,
        error: e.toString(),
      );
    }
  }

  /// Process filtered games into grouped items with injected banners.
  List<GameFeedBlock> _processGamesToFeedItems({
    required List<GameBlock> outstandingGames,
    required List<GameBlock> newGames,
    required List<GameBlock> sunwinGames,
    required List<GameBlock> liveGames,
    required List<GameBlock> slotGames,
    required List<GameBlock> cardGames,
    required List<GameBlock> jackpotGames,
  }) {
    final List<GameFeedBlock> items = [];

    // --- 1. Top Priority Items (Before Banner) ---

    // A. Casino Nổi Bật (Live)
    if (outstandingGames.isNotEmpty) {
      items.add(
        GameGroupBlock(label: 'Casino nổi bật', games: outstandingGames),
      );
    }

    // B. Mới ra mắt (New Games)
    if (newGames.isNotEmpty) {
      items.add(GameGroupBlock(label: 'Mới ra mắt', games: newGames));
    }

    // C. Game Sunwin (Sunwin Provider)
    if (sunwinGames.isNotEmpty) {
      items.add(GameGroupBlock(label: 'Game Sunwin', games: sunwinGames));
    }

    // --- 2. Inject Banner ---
    if (items.isNotEmpty) {
      final bannerIndex = items.length >= 3 ? 3 : items.length;
      items.insert(bannerIndex, GameBannerBlock.providersBanner);
    }

    // --- 3. Post-Banner Priority Items (Requested order: Live, Slot, Game bài, Jackpots) ---

    // D. Live (Standard category)
    if (liveGames.isNotEmpty) {
      items.add(GameGroupBlock(label: 'Live', games: liveGames));
    }

    // E. Slot
    if (slotGames.isNotEmpty) {
      items.add(GameGroupBlock(label: 'Slots', games: slotGames));
    }

    // F. Game bài
    if (cardGames.isNotEmpty) {
      items.add(GameGroupBlock(label: 'Game bài', games: cardGames));
    }

    // G. Jackpots
    if (jackpotGames.isNotEmpty) {
      items.add(GameGroupBlock(label: 'Jackpots', games: jackpotGames));
    }

    return items;
  }
}

/// Provider for the game feed
final gameFeedProvider =
    StateNotifierProvider.autoDispose<GameFeedNotifier, GameFeedState>(
      (ref) => GameFeedNotifier(repository: ref.read(gameRepositoryProvider)),
    );
