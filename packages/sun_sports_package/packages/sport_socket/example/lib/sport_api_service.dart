import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sport_socket/sport_socket.dart';

/// Example implementation of ISportApiService for testing.
///
/// This service fetches sport data from REST API and converts
/// JSON response to library models using ModelConverter.
///
/// Usage:
/// ```dart
/// final apiService = ExampleApiService(
///   baseUrl: 'https://your-api-domain.com',
///   agentId: 'your-agent-id',
/// );
///
/// await client.initialize(
///   apiService: apiService,
///   sportId: 1,
/// );
/// ```
class ExampleApiService implements ISportApiService {
  final String baseUrl;
  final String agentId;
  final String? token;
  final http.Client _httpClient;
  final Dio _dio;

  /// Tag for debug logging
  static const _tag = '[ExampleApiService]';

  ExampleApiService({
    required this.baseUrl,
    this.agentId = 'sun',
    this.token,
    http.Client? httpClient,
    Dio? dio,
  })  : _httpClient = httpClient ?? http.Client(),
        _dio = dio ?? Dio();

  // ===== ISportApiService Implementation =====

  @override
  Future<List<LeagueData>> fetchEarlyLeagues({
    required int sportId,
    int? days,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
        '$_tag 📡 FETCH EARLY/TODAY - sportId: $sportId, days: ${days ?? 0}');

    try {
      final data = await _fetchLeaguesJson(
        sportId: sportId,
        days: days ?? 0,
        isLive: false,
      );

      stopwatch.stop();
      debugPrint(
          '$_tag ✅ EARLY/TODAY SUCCESS - sportId: $sportId, leagues: ${data.length} (${stopwatch.elapsedMilliseconds}ms)');

      return _convertJsonToLeagues(data, sportId);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '$_tag ❌ EARLY/TODAY FAILED - sportId: $sportId, error: $e (${stopwatch.elapsedMilliseconds}ms)');
      rethrow; // Let caller handle the error - don't return empty list!
    }
  }

  @override
  Future<List<LeagueData>> fetchLiveLeagues({
    required int sportId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH LIVE - sportId: $sportId');

    try {
      final data = await _fetchLeaguesJson(
        sportId: sportId,
        isLive: true,
      );

      stopwatch.stop();
      debugPrint(
          '$_tag ✅ LIVE SUCCESS - sportId: $sportId, leagues: ${data.length} (${stopwatch.elapsedMilliseconds}ms)');

      return _convertJsonToLeagues(data, sportId);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '$_tag ❌ LIVE FAILED - sportId: $sportId, error: $e (${stopwatch.elapsedMilliseconds}ms)');
      rethrow; // Let caller handle the error - don't return empty list!
    }
  }

  @override
  Future<List<LeagueData>> fetchHotLeagues({
    required int sportId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH HOT - sportId: $sportId');

    try {
      final data = await _fetchHotLeaguesJson(sportId: sportId);

      stopwatch.stop();
      debugPrint(
          '$_tag ✅ HOT SUCCESS - sportId: $sportId, leagues: ${data.length} (${stopwatch.elapsedMilliseconds}ms)');

      return _convertJsonToLeagues(data, sportId);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '$_tag ❌ HOT FAILED - sportId: $sportId, error: $e (${stopwatch.elapsedMilliseconds}ms)');
      rethrow; // Let caller handle the error - don't return empty list!
    }
  }

  @override
  Future<LeagueData?> fetchLeagueDetail({
    required int sportId,
    required int leagueId,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
        '$_tag 📡 FETCH LEAGUE DETAIL - sportId: $sportId, leagueId: $leagueId');

    try {
      final data = await _fetchLeaguesJson(
        sportId: sportId,
        leagueId: leagueId,
      );

      stopwatch.stop();

      if (data.isEmpty) {
        debugPrint(
            '$_tag ⚠️ LEAGUE DETAIL NOT FOUND - leagueId: $leagueId (${stopwatch.elapsedMilliseconds}ms)');
        return null;
      }

      final leagues = _convertJsonToLeagues(data, sportId);
      debugPrint(
          '$_tag ✅ LEAGUE DETAIL SUCCESS - leagueId: $leagueId (${stopwatch.elapsedMilliseconds}ms)');

      return leagues.firstWhere(
        (l) => l.leagueId == leagueId,
        orElse: () => leagues.first,
      );
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '$_tag ❌ LEAGUE DETAIL FAILED - leagueId: $leagueId, error: $e (${stopwatch.elapsedMilliseconds}ms)');
      return null;
    }
  }

  // ===== Extended Methods for Full Data Population =====

  /// Fetch and populate data store directly.
  ///
  /// This method fetches Early + Live data in parallel and populates
  /// the data store using ModelConverter.populateDataStore().
  ///
  /// Use this when you need full hierarchy (leagues + events + markets + odds)
  /// instead of flat LeagueData models.
  ///
  /// [cancelToken] - Optional Dio CancelToken to cancel in-flight requests
  Future<void> fetchAndPopulateStore({
    required int sportId,
    required SportDataStore store,
    bool fetchHot = false,
    CancelToken? cancelToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint(
        '$_tag 📡 FETCH & POPULATE - sportId: $sportId, fetchHot: $fetchHot');

    try {
      // Parallel fetch using Dio with CancelToken
      final futures = <Future<List<Map<String, dynamic>>>>[
        _fetchLeaguesJsonWithDio(
            sportId: sportId, days: 0, isLive: false, cancelToken: cancelToken),
        _fetchLeaguesJsonWithDio(
            sportId: sportId, isLive: true, cancelToken: cancelToken),
      ];

      if (fetchHot) {
        futures.add(_fetchHotLeaguesJsonWithDio(
            sportId: sportId, cancelToken: cancelToken));
      }

      final results = await Future.wait(futures);

      // Check if cancelled after await
      if (cancelToken?.isCancelled == true) {
        debugPrint('$_tag ⚠️ Request cancelled, skipping populate');
        return;
      }

      final earlyJson = results[0];
      final liveJson = results[1];
      final hotJson = fetchHot ? results[2] : <Map<String, dynamic>>[];

      // Populate store using ModelConverter
      ModelConverter.populateDataStore(
        earlyJson,
        store,
        sportId: sportId,
        timeRange: TimeRange.early,
      );

      ModelConverter.populateDataStore(
        liveJson,
        store,
        sportId: sportId,
        timeRange: TimeRange.live,
      );

      if (hotJson.isNotEmpty) {
        ModelConverter.populateDataStore(
          hotJson,
          store,
          sportId: sportId,
          timeRange: TimeRange.early,
        );
      }

      stopwatch.stop();
      debugPrint(
          '$_tag ✅ POPULATE COMPLETE - sportId: $sportId (${stopwatch.elapsedMilliseconds}ms)');
    } on DioException catch (e) {
      stopwatch.stop();
      if (e.type == DioExceptionType.cancel) {
        debugPrint(
            '$_tag ⚠️ Request cancelled after ${stopwatch.elapsedMilliseconds}ms');
        rethrow; // Let caller handle cancel
      }
      debugPrint(
          '$_tag ❌ DIO ERROR after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
          '$_tag ❌ POPULATE FAILED after ${stopwatch.elapsedMilliseconds}ms: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Fetch leagues JSON using Dio (supports CancelToken)
  Future<List<Map<String, dynamic>>> _fetchLeaguesJsonWithDio({
    required int sportId,
    int? days,
    bool? isLive,
    int? leagueId,
    CancelToken? cancelToken,
  }) async {
    final queryParams = <String, dynamic>{
      'agentId': agentId,
      'sportId': sportId,
    };
    if (token != null) queryParams['token'] = token;
    if (days != null) queryParams['days'] = days;
    if (isLive != null) queryParams['isLive'] = isLive;
    if (leagueId != null) queryParams['leagueId'] = leagueId;

    final url = '$baseUrl/event/get-event-market';
    debugPrint(
        '$_tag DIO GET: $url?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');

    final response = await _dio.get(
      url,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    return _parseDioResponse(response.data);
  }

  /// Fetch hot leagues JSON using Dio (supports CancelToken)
  Future<List<Map<String, dynamic>>> _fetchHotLeaguesJsonWithDio({
    required int sportId,
    CancelToken? cancelToken,
  }) async {
    final url = '$baseUrl/event/hot';
    final queryParams = <String, dynamic>{
      'agentId': agentId,
      'sportId': sportId,
    };
    if (token != null) queryParams['token'] = token;

    debugPrint(
        '$_tag DIO GET: $url?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');

    final response = await _dio.get(
      url,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    return _parseDioResponse(response.data);
  }

  /// Parse Dio response data
  List<Map<String, dynamic>> _parseDioResponse(dynamic data) {
    if (data == null) return [];

    // Direct array response
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }

    // Wrapped in object: { data: [...] } or { leagues: [...] }
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['leagues'];
      if (list is List) {
        return list.cast<Map<String, dynamic>>();
      }
    }

    return [];
  }

  /// Fetch LIVE leagues và populate store trực tiếp.
  ///
  /// Dùng cho AutoRefresh - API là source of truth.
  /// Method này giữ nguyên raw JSON để process full hierarchy.
  ///
  /// [sportId] - Sport ID cần fetch
  /// [store] - SportDataStore để populate
  ///
  /// Throws: Không throw exception - giữ data cũ khi API fail
  @override
  Future<void> fetchLiveAndPopulate({
    required int sportId,
    required SportDataStore store,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH LIVE & POPULATE - sportId: $sportId');

    try {
      // 1. Fetch raw JSON (giữ nguyên nested events/markets/odds)
      final liveJson = await _fetchLeaguesJson(
        sportId: sportId,
        isLive: true,
      );

      stopwatch.stop();

      // 2. Safety check - skip nếu API trả empty
      if (liveJson.isEmpty) {
        debugPrint(
          '$_tag ⚠️ LIVE EMPTY - keeping existing data (${stopwatch.elapsedMilliseconds}ms)',
        );
        return;
      }

      // 3. UPSERT full hierarchy vào store
      ModelConverter.upsertPopulateDataStore(
        liveJson,
        store,
        sportId: sportId,
        timeRange: TimeRange.live,
      );

      // 4. Emit changes để UI nhận được notification
      store.emitBatchChanges();

      // Stats logging disabled for LIVE to reduce noise
      // final leagues = store.getLeaguesBySport(sportId);
      // debugPrint('$_tag ✅ LIVE POPULATE DONE');
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
        '$_tag ❌ LIVE POPULATE FAILED (${stopwatch.elapsedMilliseconds}ms): $e',
      );
      debugPrint('Stack: $stack');
      // KHÔNG rethrow - giữ data cũ khi API fail
    }
  }

  /// Fetch TODAY leagues và populate store trực tiếp.
  ///
  /// Dùng cho AutoRefresh khi user ở tab TODAY.
  /// API params: days=1, isLive=false
  @override
  Future<void> fetchTodayAndPopulate({
    required int sportId,
    required SportDataStore store,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH TODAY & POPULATE - sportId: $sportId');

    try {
      // 1. Fetch raw JSON với days=1, isLive=false
      final todayJson = await _fetchLeaguesJson(
        sportId: sportId,
        days: 1, // TODAY = 1 day ahead
        isLive: false,
      );

      stopwatch.stop();

      // 2. Safety check - skip nếu API trả empty
      if (todayJson.isEmpty) {
        debugPrint(
          '$_tag ⚠️ TODAY EMPTY - keeping existing data (${stopwatch.elapsedMilliseconds}ms)',
        );
        return;
      }

      // 3. UPSERT full hierarchy vào store
      ModelConverter.upsertPopulateDataStore(
        todayJson,
        store,
        sportId: sportId,
        timeRange: TimeRange.today,
      );

      // 4. Emit changes để UI nhận được notification
      store.emitBatchChanges();

      // 5. Log stats
      final leagues = store.getLeaguesBySport(sportId);
      int totalEvents = 0;
      for (final league in leagues) {
        totalEvents += store.getEventsByLeague(league.leagueId).length;
      }

      debugPrint(
        '$_tag ✅ TODAY POPULATE DONE\n'
        '   └─ API: ${todayJson.length} leagues\n'
        '   └─ Store: ${leagues.length} leagues, $totalEvents events\n'
        '   └─ Duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
        '$_tag ❌ TODAY POPULATE FAILED (${stopwatch.elapsedMilliseconds}ms): $e',
      );
      debugPrint('Stack: $stack');
      // KHÔNG rethrow - giữ data cũ khi API fail
    }
  }

  /// Fetch EARLY leagues và populate store trực tiếp.
  ///
  /// Dùng cho AutoRefresh khi user ở tab EARLY (Đấu sớm).
  /// API params: days=2, isLive=false
  @override
  Future<void> fetchEarlyAndPopulate({
    required int sportId,
    required SportDataStore store,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('$_tag 📡 FETCH EARLY & POPULATE - sportId: $sportId');

    try {
      // 1. Fetch raw JSON với days=2, isLive=false
      final earlyJson = await _fetchLeaguesJson(
        sportId: sportId,
        days: 2, // EARLY = 2+ days ahead
        isLive: false,
      );

      stopwatch.stop();

      // 2. Safety check - skip nếu API trả empty
      if (earlyJson.isEmpty) {
        debugPrint(
          '$_tag ⚠️ EARLY EMPTY - keeping existing data (${stopwatch.elapsedMilliseconds}ms)',
        );
        return;
      }

      // 3. UPSERT full hierarchy vào store
      ModelConverter.upsertPopulateDataStore(
        earlyJson,
        store,
        sportId: sportId,
        timeRange: TimeRange.early,
      );

      // 4. Emit changes để UI nhận được notification
      store.emitBatchChanges();

      // 5. Log stats
      final leagues = store.getLeaguesBySport(sportId);
      int totalEvents = 0;
      for (final league in leagues) {
        totalEvents += store.getEventsByLeague(league.leagueId).length;
      }

      debugPrint(
        '$_tag ✅ EARLY POPULATE DONE\n'
        '   └─ API: ${earlyJson.length} leagues\n'
        '   └─ Store: ${leagues.length} leagues, $totalEvents events\n'
        '   └─ Duration: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint(
        '$_tag ❌ EARLY POPULATE FAILED (${stopwatch.elapsedMilliseconds}ms): $e',
      );
      debugPrint('Stack: $stack');
      // KHÔNG rethrow - giữ data cũ khi API fail
    }
  }

  // ===== HTTP Methods =====

  /// Fetch leagues JSON from API.
  ///
  /// API endpoint: GET /event/get-event-market
  /// Query params: agentId, token, sportId, days, isLive, leagueId
  Future<List<Map<String, dynamic>>> _fetchLeaguesJson({
    required int sportId,
    int? days,
    bool? isLive,
    int? leagueId,
  }) async {
    final queryParams = StringBuffer();
    queryParams.write('agentId=$agentId');
    if (token != null) queryParams.write('&token=$token');
    queryParams.write('&sportId=$sportId');
    if (days != null) queryParams.write('&days=$days');
    if (isLive != null) queryParams.write('&isLive=$isLive');
    if (leagueId != null) queryParams.write('&leagueId=$leagueId');

    final url = '$baseUrl/event/get-event-market?$queryParams';
    debugPrint('$_tag HTTP GET: $url');

    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    return _parseJsonResponse(response.body);
  }

  /// Fetch hot leagues JSON from API.
  ///
  /// API endpoint: GET /event/hot
  Future<List<Map<String, dynamic>>> _fetchHotLeaguesJson({
    required int sportId,
  }) async {
    final tokenParam = token != null ? '&token=$token' : '';
    final url =
        '$baseUrl/event/hot?agentId=$agentId$tokenParam&sportId=$sportId';
    debugPrint('$_tag HTTP GET: $url');

    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    return _parseJsonResponse(response.body);
  }

  /// Parse JSON response.
  ///
  /// API returns: [{ li, ln, e, ... }, ...] or { data: [...] }
  List<Map<String, dynamic>> _parseJsonResponse(String body) {
    if (body.isEmpty) return [];

    final dynamic decoded = jsonDecode(body);

    // Direct array response
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }

    // Wrapped in object: { data: [...] } or { leagues: [...] }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['leagues'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    }

    return [];
  }

  /// Convert JSON to flat LeagueData models.
  ///
  /// Note: This only returns league-level data. For full hierarchy,
  /// use fetchAndPopulateStore() instead.
  List<LeagueData> _convertJsonToLeagues(
    List<Map<String, dynamic>> jsonList,
    int sportId,
  ) {
    return jsonList
        .map((json) => ModelConverter.fromFreezedLeague(json, sportId: sportId))
        .toList();
  }

  /// Dispose HTTP client and Dio.
  void dispose() {
    _httpClient.close();
    _dio.close();
  }
}
