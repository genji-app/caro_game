import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/game/game_providers.dart';

/// Status of the game lobby
enum GameLobbyStatus { initial, loading, success, failure }

/// State for the game lobby
@immutable
class GameLobbyState {
  const GameLobbyState({
    this.status = GameLobbyStatus.initial,
    this.lobbyBlocks = const [],
    this.error,
  });

  final GameLobbyStatus status;
  final List<CaxiloLobbyBlock> lobbyBlocks;
  final String? error;

  GameLobbyState copyWith({
    GameLobbyStatus? status,
    List<CaxiloLobbyBlock>? lobbyBlocks,
    String? error,
  }) {
    return GameLobbyState(
      status: status ?? this.status,
      lobbyBlocks: lobbyBlocks ?? this.lobbyBlocks,
      error: error,
    );
  }

  bool get isLoading => status == GameLobbyStatus.loading;
  bool get isFailure => status == GameLobbyStatus.failure;
  bool get isSuccess => status == GameLobbyStatus.success;
}

/// Provider that manages the game lobby data (grouped view/home view)
class GameLobbyNotifier extends StateNotifier<GameLobbyState> {
  GameLobbyNotifier({required CaxiloRepository repository})
    : _repository = repository,
      super(const GameLobbyState(status: GameLobbyStatus.initial)) {
    _init();
  }

  final CaxiloRepository _repository;

  /// Refreshes the lobby by fetching fresh data from the repository.
  Future<void> refresh() async {
    state = state.copyWith(status: GameLobbyStatus.loading);
    try {
      await _repository.warmup();
      await _init();
    } catch (_) {
      // _init already handles error state
    }
  }

  Future<void> _init() async {
    state = state.copyWith(status: GameLobbyStatus.loading);
    try {
      // The repository is now the single source of truth for the lobby layout.
      // It handles fetching all sections in parallel and injecting banners
      // according to the remote configuration (SDUI).
      final items = await _repository.getGameLobby();

      state = state.copyWith(
        lobbyBlocks: items,
        status: GameLobbyStatus.success,
        error: null,
      );
    } on CaxiloFailure catch (e) {
      state = state.copyWith(
        status: GameLobbyStatus.failure,
        error: e.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        status: GameLobbyStatus.failure,
        error: e.toString(),
      );
    }
  }
}

/// Provider for the game lobby
final gameLobbyProvider =
    StateNotifierProvider.autoDispose<GameLobbyNotifier, GameLobbyState>(
      (ref) =>
          GameLobbyNotifier(repository: ref.read(caxiloRepositoryProvider)),
    );
