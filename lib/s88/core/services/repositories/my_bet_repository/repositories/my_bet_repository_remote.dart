import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';

/// {@macro my_bet_repository}
class MyBetRepositoryRemote implements MyBetRepository {
  /// {@macro my_bet_repository}
  MyBetRepositoryRemote({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  final SbHttpManager _http;

  // Reactive State Management
  // Using broadcast stream to allow multiple listeners
  final _activeCountController = StreamController<int>.broadcast();
  final _cashoutSuccessController =
      StreamController<CashoutResponse>.broadcast();
  int _currentActiveCount = 0;

  String get token => _http.userTokenSb;

  @override
  Stream<int> get activeBetCountStream => _activeCountController.stream;

  @override
  Stream<CashoutResponse> get onTicketCashoutSuccess =>
      _cashoutSuccessController.stream;

  @override
  int get currentActiveCount => _currentActiveCount;

  @override
  void dispose() {
    _activeCountController.close();
    _cashoutSuccessController.close();
  }

  @override
  Future<GetCashoutResponse?> getCashout({
    required num amount,
    required String displayOdds,
    required num stake,
    required String ticketId,
  }) async {
    try {
      // Prepare request payload
      final requestBody = {
        'amount': amount.toInt(),
        'displayOdds': displayOdds,
        'stake': stake.toInt(),
        'ticketId': ticketId,
        'token': token,
        'userId': '', // Empty string as per API spec
      };

      debugPrint('MyBetRepositoryRemote: getCashout request: $requestBody');

      // Call API via SbHttpManager
      final response = await _http.getCashOut(requestBody);

      // Parse response to GetCashoutResponse model
      if (response.isEmpty) {
        // debugPrint('BetTicketRepositoryRemote: Empty cash out response');
        return null;
      }

      // debugPrint('BetTicketRepositoryRemote: getCashout response: $response');
      return GetCashoutResponse.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('MyBetRepositoryRemote: Failed to get cash out: $e');
      Error.throwWithStackTrace(GetCashoutFailure(e), stackTrace);
    }
  }

  @override
  Future<CashoutResponse> performCashout({
    required String ticketId,
    required num amount,
    required String displayOdds,
    required num stake,
  }) async {
    try {
      // Prepare request payload
      final requestBody = {
        'amount': amount,
        'displayOdds': displayOdds,
        'stake': stake,
        'ticketId': ticketId,
        // 'token': token,
        'userId': '', // Empty string as per API spec
      };

      // Call API via SbHttpManager
      final response = await _http.cashOut(requestBody);

      // Parse response to CashoutResponse model
      if (response.isEmpty) {
        // debugPrint('BetTicketRepositoryRemote: Empty cash out response');
        throw Exception('Empty cash out response from server');
      }

      final cashoutResponse = CashoutResponse.fromJson(response);

      // Check if the API actually performed the cashout successfully
      if (!cashoutResponse.isSuccess) {
        debugPrint(
          'MyBetRepositoryRemote: Cash out API returned success:false - '
          'ticketId: ${cashoutResponse.ticketId}, '
          'status: ${cashoutResponse.settlementStatus}',
        );
        throw Exception('Cash out failed: ${cashoutResponse.settlementStatus}');
      }

      // Log success
      debugPrint(
        'MyBetRepositoryRemote: Cash out successful - '
        'ticketId: ${cashoutResponse.ticketId}, '
        'amount: ${cashoutResponse.cashoutAmount}, '
        'status: ${cashoutResponse.settlementStatus}',
      );

      // Notify listeners about the success
      _cashoutSuccessController.add(cashoutResponse);

      return cashoutResponse;
    } catch (e, stackTrace) {
      debugPrint('MyBetRepositoryRemote: Failed to perform cash out: $e');
      Error.throwWithStackTrace(PerformCashoutFailure(e), stackTrace);
    }
  }

  @override
  Future<PlayHistoryResponse> getPlayHistory({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      debugPrint(
        'MyBetRepositoryRemote: getPlayHistory request: skip=$skip, limit=$limit',
      );
      // if (kDebugMode) {
      //   return Future.delayed(
      //     const Duration(seconds: 2),
      //     () => kPlayingHistoryResponse.dataOrThrow,
      //   );
      // }
      return await _http.fetchPlayHistory(
        skip: skip,
        limit: limit,
        assetName: 'gold',
      );
    } catch (e, stackTrace) {
      debugPrint('MyBetRepositoryRemote: Failed to get play history: $e');
      Error.throwWithStackTrace(GetPlayHistoryFailure(e), stackTrace);
    }
  }

  @override
  Future<void> refreshActiveCount() async {
    try {
      // Query with limit 1 just to get the totalCount metadata
      // This minimizes (in theory) the processing needed if API supported paging
      await getTickets(filter: MyBetFilter.active);
    } catch (e) {
      debugPrint('MyBetRepositoryRemote: Warm-up active count failed: $e');
    }
  }

  /// Internal method to update the active count and notify listeners
  void _updateActiveCount(int count) {
    if (_currentActiveCount != count && !_activeCountController.isClosed) {
      _currentActiveCount = count;
      _activeCountController.add(count);
      debugPrint('MyBetRepositoryRemote: Active count updated to $count');
    }
  }

  @override
  Future<List<BetSlip>> getTickets({
    MyBetFilter filter = MyBetFilter.active,
  }) async {
    // Delegate to specific methods based on filter
    switch (filter) {
      case MyBetFilter.active:
        return getActiveTickets();
      case MyBetFilter.settled:
        return getSettledTickets();
    }
  }

  /// Get active tickets (Running, Pending)
  ///
  /// Uses getBetSlipByStatus API which returns standard BetSlip JSON format including cashout info.
  Future<List<BetSlip>> getActiveTickets() async {
    try {
      // Fetch both Active and Pending statuses in parallel using standard API
      final results = await Future.wait([
        _http.getBetSlipByStatus(
          BettingHistoryConstants.apiStatusActive,
          sportId: _http.sportTypeId,
          token: token,
        ),
        _http.getBetSlipByStatus(
          BettingHistoryConstants.apiStatusPending,
          sportId: _http.sportTypeId,
          token: token,
        ),
      ]);

      // Parse standard JSON format (includes cashOutAbleAmount)
      final activeBets = _parseBetSlipsStandard(results[0] as List<dynamic>);
      final pendingBets = _parseBetSlipsStandard(results[1] as List<dynamic>);

      // Merge both lists
      final allActiveBets = [...activeBets, ...pendingBets];
      // final allActiveBets = [...activeBets, ...pendingBets, kSpecialTicket];

      // Sort by newest first
      _sortBets(allActiveBets);

      // Update active count (reactive state)
      _updateActiveCount(allActiveBets.length);

      return allActiveBets;
    } catch (e, stackTrace) {
      debugPrint('MyBetRepositoryRemote: Failed to get active tickets: $e');
      Error.throwWithStackTrace(GetActiveTicketsFailure(e), stackTrace);
    }
  }

  /// Get settled tickets (Won, Lost, Void, Refunded, Declined, etc.)
  ///
  /// Uses betsReporting API which returns numeric key JSON format.
  Future<List<BetSlip>> getSettledTickets() async {
    try {
      // Fetch both Settled and Declined statuses in parallel
      final results = await Future.wait([
        _http.betsReporting(
          BettingHistoryConstants.apiStatusSettled,
          sportId: _http.sportTypeId,
          token: token,
        ),
        _http.betsReporting(
          BettingHistoryConstants.apiStatusDeclined,
          sportId: _http.sportTypeId,
          token: token,
        ),
      ]);

      // Parse numeric key format
      final settledBets = _parseBetSlipsNumeric(results[0] as List<dynamic>);
      final declinedBets = _parseBetSlipsNumeric(results[1] as List<dynamic>);

      // Merge both lists
      final allSettledBets = [...settledBets, ...declinedBets];

      // Sort by newest first
      _sortBets(allSettledBets);

      return allSettledBets;
    } catch (e, stackTrace) {
      debugPrint('MyBetRepositoryRemote: Failed to get settled tickets: $e');
      Error.throwWithStackTrace(GetSettledTicketsFailure(e), stackTrace);
    }
  }

  // ===== PARSING METHODS =====

  /// Parse bets from standard JSON format (matching BetSlip model)
  List<BetSlip> _parseBetSlipsStandard(List<dynamic> data) {
    return data
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return BetSlip.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Error parsing standard BetSlip: $e');
            return null;
          }
        })
        .whereType<BetSlip>()
        .toList();
  }

  /// Parse bets from numeric key JSON format (betsReporting API)
  List<BetSlip> _parseBetSlipsNumeric(List<dynamic> data) {
    return data
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return BetSlipParser.parse(item);
            }
            return null;
          } catch (e) {
            debugPrint('Error parsing numeric BetSlip: $e');
            return null;
          }
        })
        .whereType<BetSlip>()
        .toList();
  }

  // ===== HELPER METHODS =====

  /// Sort bets by time (newest first)
  void _sortBets(List<BetSlip> bets) {
    bets.sort((a, b) => b.betTime.compareTo(a.betTime));
  }

  // NOTE: _formatScore and _parseActiveBetFromNumericKeys have been moved to
  // ActiveBetParser class for better separation of concerns
  @override
  Future<BetSlip?> getTicketDetail(String ticketId) async {
    try {
      // Call API to get ticket status
      final response = await _http.getStatusByTicketId(ticketId);

      if (response['ticket'] == null) return null;

      final ticketData = response['ticket'] as Map<String, dynamic>;
      return BetSlipParser.parse(ticketData);
    } catch (e, stackTrace) {
      debugPrint('MyBetRepositoryRemote: Failed to get ticket detail: $e');
      Error.throwWithStackTrace(GetTicketDetailFailure(e), stackTrace);
    }
  }
}
