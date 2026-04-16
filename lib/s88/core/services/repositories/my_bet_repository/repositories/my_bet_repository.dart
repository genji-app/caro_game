import 'dart:async';

import 'package:co_caro_flame/s88/core/services/models/play_history_model.dart';

import '../models/models.dart';
import 'my_bet_failure.dart';

/// Enum to filter bet history requests
enum MyBetFilter {
  /// Active bets (Running, Pending)
  active,

  /// Settled bets (Won, Lost, Refunded)
  settled,
}

/// {@template my_bet_repository}
/// A repository that manages bet history and cashout operations.
/// {@endtemplate}
abstract class MyBetRepository {
  /// Get ticket list (all items, no pagination).
  ///
  /// Returns tickets based on the specified [filter] (default is active).
  ///
  /// Throws [GetActiveTicketsFailure] or [GetSettledTicketsFailure]
  /// if the underlying API call fails.
  Future<List<BetSlip>> getTickets({MyBetFilter filter = MyBetFilter.active});

  /// Get ticket details by ID.
  ///
  /// Throws [GetTicketDetailFailure] if the underlying API call fails.
  Future<BetSlip?> getTicketDetail(String ticketId);

  /// Get cash out information for a specific bet ticket.
  ///
  /// Returns a [GetCashoutResponse] containing the current cashout quote,
  /// or `null` if the response is empty.
  ///
  /// Throws [GetCashoutFailure] if the underlying API call fails.
  Future<GetCashoutResponse?> getCashout({
    required String ticketId,
    required num amount,
    required String displayOdds,
    required num stake,
  });

  /// Perform a cash out operation for a bet ticket.
  ///
  /// Throws [PerformCashoutFailure] if the underlying API call fails
  /// or if the cash out was rejected by the server.
  Future<CashoutResponse> performCashout({
    required String ticketId,
    required num amount,
    required String displayOdds,
    required num stake,
  });

  /// Get play history.
  ///
  /// Returns a [PlayHistoryResponse].
  ///
  /// Throws [GetPlayHistoryFailure] if the underlying API call fails.
  Future<PlayHistoryResponse> getPlayHistory({int skip = 0, int limit = 20});

  // ---------------------------------------------------------------------------
  // Reactive State Management
  // ---------------------------------------------------------------------------

  /// Stream to listen for changes in active bet count.
  ///
  /// Useful for updating UI badges in real-time.
  Stream<int> get activeBetCountStream;

  /// Stream to listen for successful ticket cashouts.
  Stream<CashoutResponse> get onTicketCashoutSuccess;

  /// Get the current cached active bet count.
  int get currentActiveCount;

  /// Force a refresh of the active bet count from the server.
  Future<void> refreshActiveCount();

  /// Dispose resources.
  void dispose();
}
