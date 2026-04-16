import 'dart:convert';
import 'package:co_caro_flame/s88/core/network/api_endpoints.dart';
import 'package:co_caro_flame/s88/core/network/sb_api_client.dart';

/// Betting service for Sportbook.
///
/// Handles betting, bet history, and cash out operations.
/// Uses SbApiClient for HTTP and gets config from SbHttpManager.
class SbBettingService {
  SbBettingService._internal();
  static final SbBettingService _instance = SbBettingService._internal();
  static SbBettingService get instance => _instance;

  // Dependencies - set by SbHttpManager
  String Function() getUrlHomeBettingService = () => '';
  String Function() getUrlHomeExposeService = () => '';
  String Function() getUserTokenSb = () => '';
  int Function() getSportTypeId = () => 1;
  String Function() getCustId = () => '';
  String Function() getCustLogin = () => '';

  String get _bettingUrl => getUrlHomeBettingService();
  String get _exposeUrl => getUrlHomeExposeService();
  String get _token => getUserTokenSb();
  int get _sportTypeId => getSportTypeId();
  String get _custId => getCustId();
  String get _custLogin => getCustLogin();

  // ===== BETTING METHODS =====

  /// Calculate Bet Min/Max Stakes
  Future<Map<String, dynamic>> calculateBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
  }) async {
    final url = SbApiEndpoints.buildCalculateBetsUrl(_bettingUrl, _sportTypeId);
    final requestBody = {...body, 'token': _token, 'userId': _custId};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          authorization: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  /// Calculate Parlay Bet Min/Max Stakes
  Future<Map<String, dynamic>> calculateBetsParlay(
    Map<String, dynamic> body,
  ) async {
    final url = SbApiEndpoints.buildCalculateBetsV2Url(
      _bettingUrl,
      _sportTypeId,
    );
    final requestBody = {...body, 'token': _token, 'userId': _custId};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          authorization: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  /// Place Bet
  Future<Map<String, dynamic>> placeBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
  }) async {
    final url = SbApiEndpoints.buildPlaceBetsUrl(_bettingUrl, _sportTypeId);
    final requestBody = {
      ...body,
      'token': _token,
      'userName': _custLogin,
      'userId': '', // Match web behavior - send empty string
    };

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
          lng: 'vi',
        )
        as Map<String, dynamic>;
  }

  /// Place Parlay Bet (v2 endpoint)
  Future<Map<String, dynamic>> placeBetsParlay(
    Map<String, dynamic> body,
  ) async {
    final url = SbApiEndpoints.buildPlaceBetsV2Url(_bettingUrl, _sportTypeId);
    final requestBody = {
      ...body,
      'token': _token,
      'userName': _custLogin,
      'userId': '', // Match web behavior - send empty string
    };

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
          lng: 'vi',
        )
        as Map<String, dynamic>;
  }

  // ===== BET HISTORY METHODS =====

  /// Get Bet History/Reporting
  Future<dynamic> betsReporting(
    String status, {
    int sportId = 1,
    String? token,
  }) async {
    final url = SbApiEndpoints.buildBetsReportingUrl(
      _exposeUrl,
      _sportTypeId,
      status,
      _custId,
      token ?? _token,
    );
    final response = await SbApiClient.instance.send(
      url,
      headerToken: true,
      json: true,
    );

    if (response is List) {
      return response;
    } else if (response is Map<String, dynamic>) {
      if (response.containsKey('bets')) {
        return response['bets'];
      }
      return response;
    }
    return [];
  }

  /// Get Bet Slips by Status
  Future<dynamic> getBetSlipByStatus(
    String status, {
    int sportId = 1,
    String? token,
  }) async {
    final url = SbApiEndpoints.buildBetSlipByStatusUrl(
      _exposeUrl,
      _sportTypeId,
      status,
      _custId,
      token ?? _token,
    );
    return await SbApiClient.instance.send(url, headerToken: true, json: true);
  }

  /// Check Bet Ticket Status
  Future<Map<String, dynamic>> getStatusByTicketId(String ticketId) async {
    final url = SbApiEndpoints.buildTicketStatusUrl(
      _exposeUrl,
      ticketId,
      _token,
      _sportTypeId,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  // ===== CASH OUT METHODS =====

  /// Get Cash Out Options
  Future<Map<String, dynamic>> getCashOut(Map<String, dynamic> body) async {
    final url = SbApiEndpoints.buildGetCashOutUrl(_bettingUrl, _sportTypeId);
    final requestBody = {'userId': _custId, ...body, 'token': _token};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
        )
        as Map<String, dynamic>;
  }

  /// Perform Cash Out
  Future<Map<String, dynamic>> cashOut(Map<String, dynamic> body) async {
    final url = SbApiEndpoints.buildCashOutUrl(_bettingUrl, _sportTypeId);
    final requestBody = {'userId': _custId, ...body, 'token': _token};

    return await SbApiClient.instance.send(
          url,
          post: true,
          body: jsonEncode(requestBody),
          contentJson: true,
          headerToken: true,
          json: true,
        )
        as Map<String, dynamic>;
  }
}
