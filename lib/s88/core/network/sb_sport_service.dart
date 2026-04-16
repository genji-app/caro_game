import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:co_caro_flame/s88/core/network/api_endpoints.dart';
import 'package:co_caro_flame/s88/core/network/sb_api_client.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/events_request_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_detail_response_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_pin_item.dart';
import 'package:co_caro_flame/s88/core/services/models/favorite_data.dart';

/// Sport service for Sportbook.
///
/// Handles events, leagues, and favorites API operations.
/// Uses SbApiClient for HTTP and gets config from SbHttpManager.
class SbSportService {
  SbSportService._internal();
  static final SbSportService _instance = SbSportService._internal();
  static SbSportService get instance => _instance;

  // Dependencies - set by SbHttpManager
  String Function() getUrlHomeExposeService = () => '';
  String Function() getUserTokenSb = () => '';
  int Function() getSportTypeId = () => 1;

  String get _baseUrl => getUrlHomeExposeService();
  String get _token => getUserTokenSb();
  int get _sportTypeId => getSportTypeId();

  // ===== EVENT & MARKET METHODS =====

  /// Get Events & Markets
  Future<Map<String, dynamic>> getEventMarket(String info, int agentId) async {
    final url = SbApiEndpoints.buildEventMarketUrl(
      _baseUrl,
      agentId,
      _token,
      _sportTypeId,
      info,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  /// Get Hot Matches
  Future<Map<String, dynamic>> getEventHotMatch(int agentId) async {
    final url = SbApiEndpoints.buildEventHotUrl(
      _baseUrl,
      agentId,
      _sportTypeId,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  /// Get Outright Bets
  Future<Map<String, dynamic>> getEventOutright(
    String info,
    int agentId,
  ) async {
    final url = SbApiEndpoints.buildEventOutrightUrl(
      _baseUrl,
      agentId,
      _token,
      _sportTypeId,
      info,
    );
    return await SbApiClient.instance.send(url, json: true)
        as Map<String, dynamic>;
  }

  // ===== LEAGUE API METHODS =====

  /// Get Leagues with Events & Markets
  Future<List<LeagueData>> getLeagues({
    int? days,
    bool? isLive,
    int? leagueId,
    int? sportId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final queryParams = StringBuffer();
    if (days != null) queryParams.write('&days=$days');
    if (isLive != null) queryParams.write('&isLive=$isLive');
    if (leagueId != null) queryParams.write('&leagueId=$leagueId');

    final effectiveSportId = sportId ?? _sportTypeId;
    final url = SbApiEndpoints.buildEventMarketUrl(
      _baseUrl,
      SbConfig.agentId,
      _token,
      effectiveSportId,
      queryParams.toString(),
    );

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseLeagueResponse(response);
  }

  /// Get Outright Leagues
  Future<List<LeagueData>> getOutrightLeagues() async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventOutrightUrl(
      _baseUrl,
      SbConfig.agentId,
      _token,
      _sportTypeId,
    );
    final response = await SbApiClient.instance.send(url, json: true);

    return _parseLeagueResponse(response);
  }

  /// Get Hot/Featured Leagues (returns V2 model for hot match flow).
  /// Hot API trả về array với numeric keys ("0"=event, "1"=leagueId, "2"=leagueName, "4"=priority, "5"=logo),
  /// không phải format legacy (li, ln, e). Parse trực tiếp bằng LeagueModelV2.fromJson.
  Future<List<LeagueModelV2>> getHotLeagues() async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventHotUrl(
      _baseUrl,
      SbConfig.agentId,
      _sportTypeId,
    );
    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
    );
    return _parseHotLeagueV2Response(response);
  }

  /// Get Popular/Trending Leagues (returns V2 model).
  /// Response format is standard LeagueModelV2 with numeric keys.
  Future<List<LeagueModelV2>> getPopularLeagues() async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventsPopularUrl(
      _baseUrl,
      SbConfig.agentId,
    );
    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
    );
    return _parseLeagueV2Response(response);
  }

  /// Parse hot API response (numeric keys) → List<LeagueModelV2>.
  List<LeagueModelV2> _parseHotLeagueV2Response(dynamic response) {
    if (response is List) {
      return response
          .map(
            (item) =>
                LeagueModelV2.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['leagues'] ?? response['0'];
      if (data is List) {
        return data
            .map(
              (item) => LeagueModelV2.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    }
    return [];
  }

  /// Parse league response from API
  List<LeagueData> _parseLeagueResponse(dynamic response) {
    if (response is List) {
      return response
          .map((json) => LeagueData.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['leagues'] ?? <dynamic>[];
      if (data is List) {
        return data
            .map((json) => LeagueData.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  // ===== EVENTS V2 API =====

  /// Get Events V2 - New API endpoint
  Future<List<LeagueModelV2>> getEventsV2(
    EventsRequestModel request, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final queryParams = request.toQueryParameters();

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final url = SbApiEndpoints.buildEventsV2Url(_baseUrl, queryString);

    if (kDebugMode) {
      debugPrint('[SbSport] getEventsV2 URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    return _parseLeagueV2Response(response);
  }

  /// Get Live Events V2
  Future<List<LeagueModelV2>> getLiveEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => getEventsV2(
    EventsRequestModel.live(sportId, sportTypeId: sportTypeId),
    cancelToken: cancelToken,
  );

  /// Get Today Events V2
  Future<List<LeagueModelV2>> getTodayEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => getEventsV2(
    EventsRequestModel.today(sportId, sportTypeId: sportTypeId),
    cancelToken: cancelToken,
  );

  /// Get Early Events V2
  Future<List<LeagueModelV2>> getEarlyEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => getEventsV2(
    EventsRequestModel.early(sportId, sportTypeId: sportTypeId),
    cancelToken: cancelToken,
  );

  /// Get Event Detail V2
  Future<EventDetailResponseV2> getEventDetailV2(
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildEventDetailV2Url(
      _baseUrl,
      eventId,
      isMobile: isMobile,
      onlyParlay: onlyParlay,
    );

    if (kDebugMode) {
      debugPrint('[SbSport] getEventDetailV2 URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    if (response is Map<String, dynamic>) {
      return EventDetailResponseV2.fromJson(response);
    } else if (response is Map) {
      return EventDetailResponseV2.fromJson(
        Map<String, dynamic>.from(response),
      );
    }

    throw const FormatException('Invalid event detail response format');
  }

  /// Get pinned leagues for a sport (id, name, logo, order).
  /// Response: list of maps "0","1","2","3","4" = leagueId, name, logoUrl, sortOrder.
  Future<List<LeaguePinItem>> getLeaguesPin(
    int sportId, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildLeaguesPinUrl(_baseUrl, sportId);

    if (kDebugMode) {
      debugPrint('[SbSport] getLeaguesPin URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    return _parseLeaguesPinResponse(response);
  }

  /// Search: GET /api/app/search?txtSearch=...
  /// Returns raw response map (keys "0", "1") for caller to parse.
  Future<Map<String, dynamic>> getSearch(
    String txtSearch, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }
    final url = SbApiEndpoints.buildSearchUrl(_baseUrl, txtSearch);
    if (kDebugMode) {
      debugPrint('[SbSport] getSearch URL: $url');
    }
    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );
    if (response is Map<String, dynamic>) return response;
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return <String, dynamic>{};
  }

  /// Parse leagues/pin response: "1"=leagueId, "2"=name, "3"=logo, "4"=sortOrder.
  /// Handles both raw List and wrapped Map (data / leagues / 0).
  List<LeaguePinItem> _parseLeaguesPinResponse(dynamic response) {
    dynamic list = response;
    if (response is Map<String, dynamic>) {
      list = response['data'] ?? response['leagues'] ?? response['0'];
    } else if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      list = map['data'] ?? map['leagues'] ?? map['0'];
    }
    if (list is! List) return [];
    final result = <LeaguePinItem>[];
    for (final item in list) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final id = map['1'];
        final leagueId = id is int ? id : (id is num ? id.toInt() : 0);
        if (leagueId == 0) continue;
        final name = map['2']?.toString().trim() ?? '';
        final logoUrl = map['3']?.toString() ?? '';
        final order = map['4'];
        final sortOrder = order is int
            ? order
            : (order is num ? order.toInt() : 0);
        result.add(
          LeaguePinItem(
            leagueId: leagueId,
            name: name,
            logoUrl: logoUrl,
            sortOrder: sortOrder,
          ),
        );
      }
    }
    return result;
  }

  /// Parse LeagueModelV2 response from API
  List<LeagueModelV2> _parseLeagueV2Response(dynamic response) {
    if (response is List) {
      return response.map((json) {
        if (json is Map<String, dynamic>) {
          return LeagueModelV2.fromJson(json);
        } else if (json is Map) {
          return LeagueModelV2.fromJson(Map<String, dynamic>.from(json));
        }
        throw const FormatException('Invalid league data format');
      }).toList();
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['leagues'] ?? <dynamic>[];
      if (data is List) {
        return data.map((json) {
          if (json is Map<String, dynamic>) {
            return LeagueModelV2.fromJson(json);
          } else if (json is Map) {
            return LeagueModelV2.fromJson(Map<String, dynamic>.from(json));
          }
          throw const FormatException('Invalid league data format');
        }).toList();
      }
    }

    return [];
  }

  // ===== FAVORITES =====

  /// Get favorite leagues and events for a sport
  Future<FavoriteData> getFavorites(
    int sportId, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoritesUrl(_baseUrl, sportId);

    if (kDebugMode) {
      debugPrint('[SbSport] getFavorites URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
    );

    if (response is Map<String, dynamic>) {
      return FavoriteData.fromJson(response, sportId);
    }

    return FavoriteData(sportId: sportId, leagueIds: [], eventIds: []);
  }

  /// Get all favorite events for a sport
  Future<List<LeagueModelV2>> getFavoriteEvents(
    int sportId, {
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteEventsUrl(_baseUrl, sportId);

    if (kDebugMode) {
      debugPrint('[SbSport] getFavoriteEvents URL: $url');
    }

    final response = await SbApiClient.instance.send(
      url,
      json: true,
      headerToken: true,
      cancelToken: cancelToken,
    );

    final leagues = _parseFavoriteEventsResponse(response);

    return leagues
        .map(
          (l) => l.copyWith(
            events: l.events.map((e) => e.copyWith(isFavorited: true)).toList(),
          ),
        )
        .toList();
  }

  /// Parse favorite events response
  List<LeagueModelV2> _parseFavoriteEventsResponse(dynamic response) {
    if (response is List) {
      return _parseLeagueV2Response(response);
    }

    if (response is Map<String, dynamic>) {
      final data = response['1'] ?? response['data'] ?? response['leagues'];
      if (data is! List) return [];

      final flattened = <dynamic>[];
      for (final item in data) {
        if (item is List) {
          flattened.addAll(item);
        } else if (item is Map) {
          flattened.add(item);
        }
      }
      return _parseLeagueV2Response(flattened);
    }

    return [];
  }

  /// Add favorite league
  Future<Map<String, dynamic>> addFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteLeagueUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'leagueId': leagueId});

    if (kDebugMode) debugPrint('[SbSport] addFavoriteLeague: $url');

    final response = await SbApiClient.instance.send(
      url,
      post: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  /// Remove favorite league
  Future<Map<String, dynamic>> removeFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteLeagueUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'leagueId': leagueId});

    if (kDebugMode) debugPrint('[SbSport] removeFavoriteLeague: $url');

    final response = await SbApiClient.instance.send(
      url,
      delete: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  /// Add favorite event
  Future<Map<String, dynamic>> addFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteEventUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'eventId': eventId});

    if (kDebugMode) debugPrint('[SbSport] addFavoriteEvent: $url');

    final response = await SbApiClient.instance.send(
      url,
      post: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  /// Remove favorite event
  Future<Map<String, dynamic>> removeFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) async {
    if (_baseUrl.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final url = SbApiEndpoints.buildFavoriteEventUrl(_baseUrl);
    final body = jsonEncode({'sportId': sportId, 'eventId': eventId});

    if (kDebugMode) debugPrint('[SbSport] removeFavoriteEvent: $url');

    final response = await SbApiClient.instance.send(
      url,
      delete: true,
      body: body,
      contentJson: true,
      headerToken: true,
      json: true,
      cancelToken: cancelToken,
    );

    return _parseMapResponse(response);
  }

  /// Parse Map response
  Map<String, dynamic> _parseMapResponse(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
  }
}
