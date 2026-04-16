import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/misc/misc.dart';
import 'package:co_caro_flame/s88/core/pagination/pagination.dart';
import 'package:co_caro_flame/s88/core/services/providers/providers.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

class PlayHistoryNotifier
    extends StateNotifier<PaginatedState<List<PlayHistoryItem>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<PlayHistoryResponse, List<PlayHistoryItem>> {
  PlayHistoryNotifier({required MyBetRepository repository})
    : _repository = repository,
      super(const PaginatedState.initial());

  final MyBetRepository _repository;

  static const int _limit = 20;

  Future<void> initialize() {
    logInfo('✅ PlayHistoryNotifier initialize');
    return loadInitial();
  }

  @override
  void dispose() {
    logInfo('🔴 PlayHistoryNotifier disposed');
    super.dispose();
  }

  @override
  Future<void> loadInitial() {
    state = const PaginatedState.initial();
    return super.loadInitial();
  }

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError('Request failed', error, stackTrace);
  }

  @override
  Future<void> onInitialResponse(PlayHistoryResponse response) async {
    logInfo('Loaded ${response.items.length} items (initial)');

    if (response.items.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: response.items,
        cursor: response.items.length == _limit ? response.items.length : null,
      );
    }
  }

  @override
  Future<void> onMoreResponse(
    PlayHistoryResponse response,
    List<PlayHistoryItem> data,
  ) async {
    logInfo('Loaded ${response.items.length} items (more)');
    final newData = [...data, ...response.items];
    state = PaginatedState.withData(
      data: newData,
      cursor: response.items.length == _limit ? newData.length : null,
    );
  }

  @override
  Future<void> onRefreshResponse(PlayHistoryResponse response) async {
    logInfo('Refreshed ${response.items.length} items');

    if (response.items.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: response.items,
        cursor: response.items.length == _limit ? response.items.length : null,
      );
    }
  }

  @override
  Future<PlayHistoryResponse> request([int? cursor]) {
    final skip = cursor ?? 0;
    logDebug('Requesting play history... | skip: $skip');
    return _repository.getPlayHistory(skip: skip, limit: _limit);
  }
}

final playHistoryProvider =
    StateNotifierProvider.autoDispose<
      PlayHistoryNotifier,
      PaginatedState<List<PlayHistoryItem>>
    >((ref) {
      return PlayHistoryNotifier(repository: ref.read(myBetRepositoryProvider));
    });
