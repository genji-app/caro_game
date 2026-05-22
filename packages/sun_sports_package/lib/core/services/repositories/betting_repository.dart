import 'package:flutter/foundation.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/models/bet_model.dart';
import 'package:sun_sports/features/parlay/domain/models/single_bet_data.dart';

/// Betting Repository Interface
abstract class BettingRepository {
  Future<CalculateBetResponse> calculateBet(CalculateBetRequest request, {int? sportId});
  Future<PlaceBetResponse> placeBet(PlaceBetRequest request, {int? sportId});

  /// Calculate parlay bet - returns min/max stakes and matches limits
  Future<CalculateBetResponse> calculateParlayBet(
    List<SingleBetData> comboBets,
    String oddsStyle,
  );

  /// Place parlay bet
  Future<PlaceBetResponse> placeParlayBet(
    List<SingleBetData> comboBets,
    int stake,
    String oddsStyle,
  );
}

/// Betting Repository Implementation
class BettingRepositoryImpl implements BettingRepository {
  final SbHttpManager _http;

  BettingRepositoryImpl({SbHttpManager? http})
    : _http = http ?? SbHttpManager.instance;

  @override
  Future<CalculateBetResponse> calculateBet(CalculateBetRequest request, {int? sportId}) async {
    final body = {
      'leagueId': request.leagueId,
      'matchTime': request.matchTime,
      'isLive': request.isLive,
      'offerId': request.offerId,
      'selectionId': request.selectionId,
      'displayOdds': request.displayOdds,
      'oddsStyle': request.oddsStyle,
    };

    final response = await _http.calculateBets(body, sportId: sportId);
    return CalculateBetResponse.fromJson(response);
  }

  @override
  Future<PlaceBetResponse> placeBet(PlaceBetRequest request, {int? sportId}) async {
    final selectionsJson = request.selections.map((s) {
      return s.toRequestJson(s.stake ?? 0);
    }).toList();

    // Extract sportId from selections if not provided (all selections in a single bet share the same sport)
    final effectiveSportId = sportId ??
        (request.selections.isNotEmpty ? request.selections.first.sportId : 1);

    final body = {
      'acceptBetterOdds': request.acceptBetterOdds,
      'acceptMaxStake': request.acceptMaxStake,
      'matchId': request.matchId,
      'selections': selectionsJson,
      'singleBet': request.singleBet,
    };

    // Debug log request body
    debugPrint('[BettingRepository] placeBet body: $body');

    final response = await _http.placeBets(body, sportId: effectiveSportId);
    debugPrint('[BettingRepository] placeBet response: $response');
    return PlaceBetResponse.fromJson(response);
  }

  @override
  Future<CalculateBetResponse> calculateParlayBet(
    List<SingleBetData> comboBets,
    String oddsStyle,
  ) async {
    // Build calculateBetRequests array for parlay
    final calculateBetRequests = comboBets.map((bet) {
      return {
        'displayOdds': bet.displayOdds, // number, not string
        'isLive': bet.isLive,
        'leagueId': int.tryParse(bet.leagueIdString) ?? 0,
        'matchTime': bet.matchTimeISO,
        'offerId': bet.offerId ?? '',
        'selectionId': bet.selectionId ?? '',
      };
    }).toList();

    final body = {
      'calculateBetRequests': calculateBetRequests,
      'currency': 'VND',
      'oddsStyle': oddsStyle,
      'parlay': true,
    };

    // Extract sportId from combo bets
    final sportId = comboBets.isNotEmpty ? comboBets.first.sportId : 1;

    // Use calculateBetsParlay which adds token/userId to body
    final response = await _http.calculateBetsParlay(body, sportId: sportId);
    return CalculateBetResponse.fromJson(response);
  }

  @override
  Future<PlaceBetResponse> placeParlayBet(
    List<SingleBetData> comboBets,
    int stake,
    String oddsStyle,
  ) async {
    // Build selections array for parlay
    // Only first selection has stake, others have stake = 0
    final selections = comboBets.asMap().entries.map((entry) {
      final index = entry.key;
      final bet = entry.value;
      final selectionStake = index == 0 ? stake : 0;

      return {
        'homeScore': bet.eventData.homeScore,
        'awayScore': bet.eventData.awayScore,
        'cls': bet.cls,
        'displayOdds': bet.displayOdds, // number, not string
        'oddsStyle': oddsStyle,
        'selectionId': bet.selectionId ?? '',
        'selectionName': bet.selectionName,
        'offerId': bet.offerId ?? '',
        'stake': selectionStake,
        'trueOdds': 0,
        'winnings': 0,
      };
    }).toList();

    final body = {
      'acceptAllOdds': true,
      'acceptBetterOdds': true,
      'acceptMaxStake': true,
      'selections': selections,
      'singleBet': true,
      'parlay': true,
    };

    // debugPrint('[BettingRepository] placeParlayBet body: $body');

    // Extract sportId from combo bets (all bets in a parlay share the same sport)
    final sportId = comboBets.isNotEmpty ? comboBets.first.sportId : 1;

    // Use v2/placeBets endpoint for parlay
    final response = await _http.placeBetsParlay(body, sportId: sportId);
    // debugPrint('[BettingRepository] placeParlayBet raw response: $response');

    try {
      final parsedResponse = PlaceBetResponse.fromJson(response);
      // debugPrint('[BettingRepository] placeParlayBet parsed: ticketId=${parsedResponse.ticketId}, status=${parsedResponse.status}, errorCode=${parsedResponse.errorCode}, isSuccess=${parsedResponse.isSuccess}');
      return parsedResponse;
    } catch (e, stackTrace) {
      // debugPrint('[BettingRepository] placeParlayBet parse error: $e');
      // debugPrint('[BettingRepository] stackTrace: $stackTrace');

      // If parsing fails but we have ticketId and status=Active, consider it success
      final ticketId = response['ticketId']?.toString();
      final status = response['status']?.toString() ?? '';
      if (ticketId != null && ticketId.isNotEmpty && status == 'Active') {
        // debugPrint('[BettingRepository] Manual success detection: ticketId=$ticketId, status=$status');
        return PlaceBetResponse(
          ticketId: ticketId,
          status: status,
          errorCode: 0,
        );
      }
      rethrow;
    }
  }
}
