import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/repositories/history_repository.dart';
import 'package:co_caro_flame/s88/core/services/models/ticket_model.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/history_enums.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/history_enums.dart';

/// History State
class HistoryState {
  final List<TicketModel> tickets;
  final HistoryFilter filter;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;
  final int totalStake;
  final int totalWinnings;

  const HistoryState({
    this.tickets = const [],
    this.filter = HistoryFilter.all,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
    this.totalStake = 0,
    this.totalWinnings = 0,
  });

  HistoryState copyWith({
    List<TicketModel>? tickets,
    HistoryFilter? filter,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastUpdated,
    int? totalStake,
    int? totalWinnings,
  }) => HistoryState(
    tickets: tickets ?? this.tickets,
    filter: filter ?? this.filter,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    error: error,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    totalStake: totalStake ?? this.totalStake,
    totalWinnings: totalWinnings ?? this.totalWinnings,
  );

  List<TicketModel> get filteredTickets {
    if (filter == HistoryFilter.all) return tickets;
    return tickets.where((t) => t.status == filter.apiValue).toList();
  }

  int get pendingCount =>
      tickets.where((t) => t.status == BetStatuses.pending).length;
  int get wonCount => tickets.where((t) => t.status == BetStatuses.won).length;
  int get lostCount =>
      tickets.where((t) => t.status == BetStatuses.lost).length;
}

/// History Notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super(const HistoryState());

  /// Fetch bet history
  Future<void> fetchHistory({HistoryFilter? filter}) async {
    final effectiveFilter = filter ?? state.filter;
    state = state.copyWith(
      isLoading: true,
      error: null,
      filter: effectiveFilter,
    );

    try {
      final response = await _repository.getBetHistory(
        status: effectiveFilter.apiValue,
      );

      state = state.copyWith(
        tickets: response.bets,
        isLoading: false,
        lastUpdated: DateTime.now(),
        totalStake: response.totalStake,
        totalWinnings: response.totalWinnings,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Fetch pending bets
  Future<void> fetchPendingBets() async =>
      fetchHistory(filter: HistoryFilter.pending);

  /// Refresh history
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true);

    try {
      await fetchHistory();
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Set filter
  void setFilter(HistoryFilter filter) {
    if (filter != state.filter) {
      fetchHistory(filter: filter);
    }
  }

  /// Get ticket by ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    final local = state.tickets
        .where((t) => t.ticketId == ticketId)
        .firstOrNull;
    if (local != null) return local;
    return _repository.getTicketById(ticketId);
  }

  /// Get cash out options for a ticket
  Future<CashOutOptionsResponse?> getCashOutOptions(String ticketId) =>
      _repository.getCashOutOptions(ticketId);

  /// Perform cash out
  Future<CashOutResponse?> cashOut(String ticketId) async {
    final result = await _repository.cashOut(ticketId);
    if (result != null && result.isSuccess) {
      await fetchHistory();
    }
    return result;
  }

  /// Clear history
  void clear() {
    state = const HistoryState();
  }
}

/// History Repository Provider
final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(),
);

/// History Provider
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository);
});

/// Derived providers
final historyFilterProvider = Provider<HistoryFilter>(
  (ref) => ref.watch(historyProvider).filter,
);

final filteredTicketsProvider = Provider<List<TicketModel>>(
  (ref) => ref.watch(historyProvider).filteredTickets,
);

final pendingTicketsCountProvider = Provider<int>(
  (ref) => ref.watch(historyProvider).pendingCount,
);

final historyLoadingProvider = Provider<bool>(
  (ref) => ref.watch(historyProvider).isLoading,
);

/// Ticket by ID provider
final ticketByIdProvider = FutureProvider.family<TicketModel?, String>((
  ref,
  ticketId,
) async {
  final notifier = ref.read(historyProvider.notifier);
  return notifier.getTicketById(ticketId);
});

/// Cash out options provider
final cashOutOptionsProvider =
    FutureProvider.family<CashOutOptionsResponse?, String>((
      ref,
      ticketId,
    ) async {
      final notifier = ref.read(historyProvider.notifier);
      return notifier.getCashOutOptions(ticketId);
    });
