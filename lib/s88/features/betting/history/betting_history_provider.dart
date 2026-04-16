// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/misc/misc.dart';
import 'package:co_caro_flame/s88/core/pagination/pagination.dart';
import 'package:co_caro_flame/s88/core/services/providers/providers.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/log_helper.dart';

final bettingHistoryProvider =
    StateNotifierProvider.autoDispose<
      BettingHistoryNotifier,
      PaginatedState<List<BetSlip>>
    >((ref) {
      return BettingHistoryNotifier(
        repository: ref.watch(myBetRepositoryProvider),
      );
    });

class BettingHistoryNotifier
    extends StateNotifier<PaginatedState<List<BetSlip>>>
    with
        RequestLock,
        LoggerMixin,
        PaginatedNotifierMixin<List<BetSlip>, List<BetSlip>> {
  BettingHistoryNotifier({required MyBetRepository repository})
    : _repository = repository,
      _filter = MyBetFilter.active, // Default to Active (tab 0)
      super(const PaginatedState.initial());

  final MyBetRepository _repository;

  StreamSubscription<CashoutResponse>? _cashoutSubscription;

  /// Get current filter
  /// Set filter and reload data
  MyBetFilter _filter = MyBetFilter.active;
  MyBetFilter get filter => _filter;
  void setFilter(MyBetFilter filter) {
    if (_filter == filter) return;
    logInfo('Filter changed: $_filter → $filter');
    _filter = filter;
  }

  /// Subscribe to cashout success events to update local state
  void _subscribeToCashoutEvents() {
    _cashoutSubscription = _repository.onTicketCashoutSuccess.listen(
      (response) => _handleCashoutSuccess(response),
    );
  }

  void _handleCashoutSuccess(CashoutResponse response) {
    if (_filter == MyBetFilter.active) {
      // Remove from list if we are in active tab
      final currentData = state.data ?? [];
      final newData = currentData
          .where((b) => b.ticketId != response.ticketId)
          .toList();

      // Check if list is empty after removal
      if (newData.isEmpty) {
        state = PaginatedState.empty();
      } else {
        state = state.copyWith(data: newData);
      }

      logInfo(
        'Cashout success - removed ticket ${response.ticketId} from active list',
      );
    } else {
      // Update status and winnings if we are in settled tab
      final currentData = state.data;
      if (currentData == null) return;

      final newData = currentData.map((bet) {
        if (bet.ticketId == response.ticketId) {
          return bet.applyCashout(response);
        }
        return bet;
      }).toList();

      state = state.copyWith(data: newData);
      logInfo(
        'Cashout success - updated ticket ${response.ticketId} in settled list',
      );
    }
  }

  /// Update a ticket in the local list with a new version
  void updateTicketLocally(BetSlip updatedBet) {
    final currentData = state.data;
    if (currentData == null) return;

    final newData = currentData.map((bet) {
      if (bet.ticketId == updatedBet.ticketId) {
        return updatedBet;
      }
      return bet;
    }).toList();

    state = state.copyWith(data: newData);
  }

  /// Initialize the notifier by setting up event subscriptions and loading initial data
  ///
  /// This should be called once when the view mounts to:
  /// - Subscribe to cashout success events
  /// - Load the initial list of betting history
  ///
  /// Returns a Future that completes when initial data is loaded
  Future<void> initialize() {
    logInfo('✅ BettingHistoryNotifier initialize');
    _subscribeToCashoutEvents();
    return loadInitial();
  }

  @override
  void dispose() {
    logInfo('🔴 BettingHistoryNotifier disposed');
    _cashoutSubscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> loadInitial() {
    // Reset data to null before loading (freezed requires null, not empty list)
    state = const PaginatedState.initial();
    return super.loadInitial();
  }

  @override
  Future<void> onRequestError(Object error, StackTrace stackTrace) async {
    logError('Request failed', error, stackTrace);
  }

  @override
  Future<void> onInitialResponse(List<BetSlip> response) async {
    logInfo('Loaded ${response.length} bets (initial) | filter: $_filter');

    if (response.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(data: response);
    }
  }

  @override
  Future<void> onMoreResponse(
    List<BetSlip> response,
    List<BetSlip> data,
  ) async {
    // Should not be called if cursor is always null, but implementing for completeness
    state = PaginatedState.withData(data: [...data, ...response]);
  }

  @override
  Future<void> onRefreshResponse(List<BetSlip> response) async {
    logInfo('Refreshed ${response.length} bets | filter: $_filter');

    if (response.isEmpty) {
      state = PaginatedState.empty();
    } else {
      state = PaginatedState.withData(data: response);
    }
  }

  @override
  Future<List<BetSlip>> request([int? cursor]) {
    logDebug('Requesting bets... | filter: $_filter');
    return _repository.getTickets(filter: _filter);
  }
}
