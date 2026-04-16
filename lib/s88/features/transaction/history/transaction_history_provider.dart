import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/misc/misc.dart';
import 'package:co_caro_flame/s88/core/pagination/paginated_notifier_mixin.dart';
import 'package:co_caro_flame/s88/core/services/providers/providers.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

final transactionHistoryProvider = StateNotifierProvider.autoDispose((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return TransactionHistoryNotifier(repository: transactionRepository)
    ..loadInitial();
}, name: 'TransactionHistoryNotifier');

class TransactionHistoryNotifier
    extends StateNotifier<PaginatedState<List<Transaction>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<PaginatedTransactions, List<Transaction>> {
  TransactionHistoryNotifier({required TransactionRepository repository})
    : _repository = repository,
      super(const PaginatedState.initial());

  final TransactionRepository _repository;

  bool _hasMore = true;
  Object? _error;

  bool get hasMore => _hasMore;
  Object? get error => _error;

  @override
  Future<PaginatedTransactions> request([int? cursor]) =>
      _repository.getTransactions(cursor: cursor);

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError('Request failed', error, stackTrace);
    _error = error;
  }

  @override
  Future<void> onInitialResponse(PaginatedTransactions response) async {
    final transactions = response.items.toList();
    logInfo('Loaded ${transactions.length} transactions (initial)');

    if (transactions.isEmpty) {
      _hasMore = false;
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: transactions,
        cursor: response.nextCursor,
      );
    }
  }

  @override
  Future<void> onMoreResponse(
    PaginatedTransactions response,
    List<Transaction> data,
  ) async {
    final transactions = response.items.toList();
    logInfo('Loaded ${transactions.length} more transactions');

    state = PaginatedState.withData(
      data: [...data, ...transactions],
      cursor: response.nextCursor,
    );
  }

  @override
  Future<void> onRefreshResponse(PaginatedTransactions response) async {
    final transactions = response.items.toList();
    logInfo('Refreshed ${transactions.length} transactions');

    if (transactions.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(
        data: transactions,
        cursor: response.nextCursor,
      );
    }
  }
}
