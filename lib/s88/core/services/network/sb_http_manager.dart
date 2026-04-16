import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/network/api_endpoints.dart';
import 'package:co_caro_flame/s88/core/network/sb_api_client.dart';
import 'package:co_caro_flame/s88/core/network/sb_betting_service.dart';
import 'package:co_caro_flame/s88/core/network/sb_config_loader.dart';
import 'package:co_caro_flame/s88/core/network/sb_sport_service.dart';
import 'package:co_caro_flame/s88/core/network/sb_user_service.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_detail_response_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/events_request_model.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_pin_item.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/livestream_response.dart';
import 'package:co_caro_flame/s88/core/services/models/favorite_data.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/models/play_history_model.dart';
import 'package:co_caro_flame/s88/core/services/models/sun_api_response.dart';
import 'package:co_caro_flame/s88/core/services/models/transaction.dart';

import 'sun_extension.dart';

/// Sportbook HTTP Manager
///
/// Facade that delegates HTTP operations to SbApiClient.
/// Keeps settings, domains, user data and API methods.
class SbHttpManager {
  // ===== SINGLETON PATTERN =====
  static final SbHttpManager _instance = SbHttpManager._internal();
  factory SbHttpManager() => _instance;
  SbHttpManager._internal() {
    _initServices();
  }

  static SbHttpManager get instance => _instance;

  /// Initialize dependent services with getters
  void _initServices() {
    // Setup SbSportService
    SbSportService.instance.getUrlHomeExposeService = () =>
        urlHomeExposeService;
    SbSportService.instance.getUserTokenSb = () => _userTokenSb;
    SbSportService.instance.getSportTypeId = () => sportTypeId;

    // Setup SbBettingService
    SbBettingService.instance.getUrlHomeBettingService = () =>
        urlHomeBettingService;
    SbBettingService.instance.getUrlHomeExposeService = () =>
        urlHomeExposeService;
    SbBettingService.instance.getUserTokenSb = () => _userTokenSb;
    SbBettingService.instance.getSportTypeId = () => sportTypeId;
    SbBettingService.instance.getCustId = () => custId;
    SbBettingService.instance.getCustLogin = () => custLogin;
  }

  // ===== TOKENS - delegate to SbApiClient =====
  String get _userToken => SbApiClient.instance.userToken;
  set _userToken(String value) => SbApiClient.instance.userToken = value;

  String get _userTokenSb => SbApiClient.instance.userTokenSb;
  set _userTokenSb(String value) => SbApiClient.instance.userTokenSb = value;

  String get _chatToken => SbApiClient.instance.chatToken;
  set _chatToken(String value) => SbApiClient.instance.chatToken = value;

  // ===== DOMAINS (loaded from getSetting) =====
  final Map<String, String> _domains = {
    'urlHomeExposeService': '', // GET events, markets, user info
    'urlHomeBettingService': '', // POST betting operations
    'urlHomeOAuthService': '', // Auth
    'urlHomeWebsocket': '', // WebSocket URL
    'urlVideoJS': '',
    'urlVirtualVideoJS': '',
    'urlStatistics': '',
  };

  // ===== USER DATA =====
  final Map<String, dynamic> _user = {
    'uid': '',
    'displayName': '',
    'cust_login': '',
    'cust_id': '',
    'balance': 0.0,
    'currency': '',
    'status': 'Active',
  };

  // ===== SETTINGS =====
  /// Auto-refresh balance with API
  bool _refreshWithAPI = false;

  /// Balance refresh interval (seconds)
  int _timeRefreshBalance = 5;

  /// Current sport type ID (1 = Football, 2 = Basketball, etc.)
  int sportTypeId = 1;

  // ===== GETTERS =====
  String get userToken => _userToken;
  String get userTokenSb => _userTokenSb;
  String get chatToken => _chatToken;
  String get custLogin => _user['cust_login'] as String;
  String get custId => _user['cust_id'] as String;
  String get uid => _user['uid'] as String;
  String get displayName => _user['displayName'] as String;
  double get userBalance => (_user['balance'] as num).toDouble();
  String get currency => _user['currency'] as String;
  String get status => _user['status'] as String;
  Map<String, dynamic> get user => Map.from(_user);

  /// User balance in 1K units (for display)
  double get userBalanceX1k => userBalance;

  // Domain getters
  String get urlHomeExposeService => _domains['urlHomeExposeService'] ?? '';
  String get urlHomeBettingService => _domains['urlHomeBettingService'] ?? '';
  String get urlHomeOAuthService => _domains['urlHomeOAuthService'] ?? '';
  String get urlHomeWebsocket => _domains['urlHomeWebsocket'] ?? '';
  String get urlVideoJS => _domains['urlVideoJS'] ?? '';
  String get urlVirtualVideoJS => _domains['urlVirtualVideoJS'] ?? '';
  String get urlStatistics => _domains['urlStatistics'] ?? '';

  String get hostDomain => SbConfig.instance.hostDomain ?? '';

  String get apiDomain =>
      SbConfig.instance.mainConfig['api_domain'] as String? ?? '';

  bool get refreshWithAPI => _refreshWithAPI;
  int get timeRefreshBalance => _timeRefreshBalance;

  // ===== SETTERS =====
  set userToken(String value) => _userToken = value;
  set userTokenSb(String value) => _userTokenSb = value;
  set chatToken(String value) => _chatToken = value;

  /// Update user data (for WebSocket updates)
  void updateUserData(String key, dynamic value) {
    if (_user.containsKey(key)) {
      _user[key] = value;
    }
  }

  // ===== CORE SEND METHOD - delegate to SbApiClient =====
  Future<dynamic> send(
    String url, {
    bool post = false,
    bool delete = false,
    String? body,
    bool contentJson = false,
    bool headerToken = false,
    bool base64 = false,
    bool json = false,
    bool authorization = false,
    String? token,
    String? lng,
    CancelToken? cancelToken,
  }) async {
    return SbApiClient.instance.send(
      url,
      post: post,
      delete: delete,
      body: body,
      contentJson: contentJson,
      headerToken: headerToken,
      base64: base64,
      json: json,
      authorization: authorization,
      token: token,
      lng: lng,
      cancelToken: cancelToken,
    );
  }

  // ===== STATIC CONFIG LOADER =====
  /// Load remote config with cache busting
  /// Response is base64-encoded JSON
  static Future<Map<String, dynamic>> getConfig(String url) =>
      SbConfigLoader.getConfig(url);

  // ===== AUTHENTICATION METHODS =====

  /// Get Sportbook Token
  ///
  /// Request: GET {sport_domain}?command=get-token
  /// Header: Authorization: {user_token}
  /// Response: { data: { token: "eyJhbGc..." } }
  Future<String> getSbToken() async {
    final config = SbConfig.instance;
    final tokenUrl = config.sportTokenUrl;

    if (tokenUrl.isEmpty) {
      throw Exception('Sport token URL not configured. Load mainConfig first.');
    }

    if (_userToken.isEmpty) {
      throw Exception('User token not set. Call refreshToken first.');
    }

    final res =
        await send(tokenUrl, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    if (res['data'] == null || res['data']['token'] == null) {
      throw Exception('Invalid token response');
    }

    _userTokenSb = res['data']['token'] as String;
    return _userTokenSb;
  }

  /// Load Server Settings & Domains
  ///
  /// Request: GET {sbConfigUrl}{agentId}
  /// Response (numeric keys format):
  /// {
  ///   "0": {"0": exposeDomain, "1": bettingDomain, ...},
  ///   "1": {"0": refreshTime, "1": isRefreshAPI},
  ///   "2": {"0": memSize}
  /// }
  Future<void> getSetting(String urlSetting, int agentId) async {
    final setting =
        await send(urlSetting + agentId.toString(), json: true)
            as Map<String, dynamic>;

    // // Load domains using SbConfigLoader
    // final domainSettings = SbConfigLoader.parseDomains(setting);
    // _domains['urlHomeExposeService'] = domainSettings.exposeDomain;
    // _domains['urlHomeBettingService'] = domainSettings.bettingDomain;
    // _domains['urlHomeOAuthService'] = domainSettings.authDomain;
    // _domains['urlHomeWebsocket'] = domainSettings.websocketDomain;
    // _domains['urlVideoJS'] = domainSettings.videoDomain;
    // _domains['urlVirtualVideoJS'] = domainSettings.virtualVideoDomain;
    // _domains['urlStatistics'] = domainSettings.statisticsDomain;

    // Load domains
    if (setting['domains'] != null) {
      final domains = setting['domains'] as Map<String, dynamic>;
      _domains['urlHomeExposeService'] =
          domains['urlHomeExposeService'] as String? ?? '';
      _domains['urlHomeBettingService'] =
          domains['urlHomeBettingService'] as String? ?? '';
      _domains['urlHomeOAuthService'] =
          domains['urlHomeOAuthService'] as String? ?? '';
      _domains['urlHomeWebsocket'] =
          domains['urlHomeWebsocket'] as String? ?? '';
      _domains['urlVideoJS'] = domains['urlVideoJS'] as String? ?? '';
      _domains['urlVirtualVideoJS'] =
          domains['urlVirtualVideoJS'] as String? ?? '';
      _domains['urlStatistics'] = domains['urlStatistics'] as String? ?? '';
    }

    // Load balance refresh settings
    if (setting['updateBalance'] != null) {
      final updateBalance = setting['updateBalance'] as Map<String, dynamic>;
      _timeRefreshBalance = updateBalance['timeRefeshBalance'] as int? ?? 5;
      _refreshWithAPI = updateBalance['refeshWithAPI'] as bool? ?? false;
    }

    // // Load balance refresh settings using SbConfigLoader
    // final balanceSettings = SbConfigLoader.parseBalanceSettings(setting);
    // _timeRefreshBalance = balanceSettings.refreshTime;
    // _refreshWithAPI = balanceSettings.isRefreshAPI;
  }

  /// Wait for config to be ready (similar to AuthConfigService.initializeConfig pattern)
  /// Returns true if config is ready, false if timeout
  /// This should be called before making API calls that require urlHomeExposeService
  Future<bool> waitForConfigReady({
    Duration maxWaitTime = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) {
    return SbConfigLoader.waitForReady(
      isReady: () => urlHomeExposeService.isNotEmpty,
      maxWaitTime: maxWaitTime,
      checkInterval: checkInterval,
    );
  }

  /// Validate Token & Get User Info
  ///
  /// Request: GET {urlHomeExposeService}/api/v1/users/info
  /// Header: token
  /// Response: {"0":"username","1":"VND","2":"500.000","3":"Active"}
  Future<bool> getUserByToken() async {
    return await getUserInfo();
  }

  /// Get User Info
  ///
  /// Request: GET {urlHomeExposeService}/api/v1/users/info
  /// Header: token
  /// Response: {"0":"username","1":"VND","2":"500.000","3":"Active"}
  Future<bool> getUserInfo() async {
    if (urlHomeExposeService.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    if (_userTokenSb.isEmpty) {
      throw Exception('Sportbook token not set. Call getSbToken() first.');
    }

    final url = SbUserService.buildUserInfoUrl(urlHomeExposeService);
    final info =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;

    // Parse and update user data using SbUserService
    final parsed = SbUserService.parseUserInfo(info);
    _user.addAll(parsed);

    return true;
  }

  /// GET {urlHomeExposeService}/api/v1/notification
  ///
  /// Response: {"0":[{ "0": id, "1": message, "2": isoDate }]}
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (urlHomeExposeService.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }
    if (_userTokenSb.isEmpty) {
      throw Exception('Sportbook token not set. Call getSbToken() first.');
    }
    final url = SbUserService.buildNotificationUrl(urlHomeExposeService);
    final data =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;
    final raw = data['0'];
    if (raw is! List) return [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
        .toList();
  }

  /// Get User Balance
  ///
  /// Request: GET {urlHomeExposeService}/api/v1/users/balance
  /// Header: token
  /// Response: {"0":"username","1":"VND","2":"500.000","3":"Active"}
  Future<bool> getUserBalance() async {
    if (urlHomeExposeService.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    if (_userTokenSb.isEmpty) {
      throw Exception('Sportbook token not set. Call getSbToken() first.');
    }

    final url = SbUserService.buildUserBalanceUrl(urlHomeExposeService);
    final info =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;

    // Parse and update user data using SbUserService
    final parsed = SbUserService.parseUserInfo(info);
    _user.addAll(parsed);

    return true;
  }

  /// Get User Info (Balance, Profile) - Legacy method
  @Deprecated('Use getUserInfo() or getUserBalance() instead')
  Future<bool> getInfo({String cmd = 'getBalanceUser'}) async {
    if (cmd == 'getUserByToken') {
      return getUserInfo();
    }
    return getUserBalance();
  }

  // ===== EVENT & MARKET METHODS - delegate to SbSportService =====

  Future<Map<String, dynamic>> getEventMarket(String info, int agentId) =>
      SbSportService.instance.getEventMarket(info, agentId);

  Future<Map<String, dynamic>> getEventHotMatch(int agentId) =>
      SbSportService.instance.getEventHotMatch(agentId);

  Future<Map<String, dynamic>> getEventOutright(String info, int agentId) =>
      SbSportService.instance.getEventOutright(info, agentId);

  // ===== LEAGUE API METHODS - delegate to SbSportService =====

  Future<List<LeagueData>> getLeagues({
    int? days,
    bool? isLive,
    int? leagueId,
    int? sportId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getLeagues(
    days: days,
    isLive: isLive,
    leagueId: leagueId,
    sportId: sportId,
    cancelToken: cancelToken,
  );

  Future<List<LeagueData>> getOutrightLeagues() =>
      SbSportService.instance.getOutrightLeagues();

  Future<List<LeagueModelV2>> getHotLeagues() =>
      SbSportService.instance.getHotLeagues();

  Future<List<LeagueModelV2>> getPopularLeagues() =>
      SbSportService.instance.getPopularLeagues();

  // ===== EVENTS V2 API - delegate to SbSportService =====

  Future<List<LeagueModelV2>> getEventsV2(
    EventsRequestModel request, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEventsV2(request, cancelToken: cancelToken);

  Future<List<LeaguePinItem>> getLeaguesPin(
    int sportId, {
    CancelToken? cancelToken,
  }) =>
      SbSportService.instance.getLeaguesPin(sportId, cancelToken: cancelToken);

  Future<Map<String, dynamic>> getSearch(
    String txtSearch, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getSearch(txtSearch, cancelToken: cancelToken);

  Future<List<LeagueModelV2>> getLiveEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getLiveEventsV2(
    sportId,
    sportTypeId: sportTypeId,
    cancelToken: cancelToken,
  );

  Future<List<LeagueModelV2>> getTodayEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getTodayEventsV2(
    sportId,
    sportTypeId: sportTypeId,
    cancelToken: cancelToken,
  );

  Future<List<LeagueModelV2>> getEarlyEventsV2(
    int sportId, {
    int? sportTypeId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEarlyEventsV2(
    sportId,
    sportTypeId: sportTypeId,
    cancelToken: cancelToken,
  );

  Future<EventDetailResponseV2> getEventDetailV2(
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
    CancelToken? cancelToken,
  }) => SbSportService.instance.getEventDetailV2(
    eventId,
    isMobile: isMobile,
    onlyParlay: onlyParlay,
    cancelToken: cancelToken,
  );

  // ===== FAVORITES - delegate to SbSportService =====

  Future<FavoriteData> getFavorites(int sportId, {CancelToken? cancelToken}) =>
      SbSportService.instance.getFavorites(sportId, cancelToken: cancelToken);

  Future<List<LeagueModelV2>> getFavoriteEvents(
    int sportId, {
    CancelToken? cancelToken,
  }) => SbSportService.instance.getFavoriteEvents(
    sportId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> addFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.addFavoriteLeague(
    sportId: sportId,
    leagueId: leagueId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> removeFavoriteLeague({
    required int sportId,
    required int leagueId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.removeFavoriteLeague(
    sportId: sportId,
    leagueId: leagueId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> addFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.addFavoriteEvent(
    sportId: sportId,
    eventId: eventId,
    cancelToken: cancelToken,
  );

  Future<Map<String, dynamic>> removeFavoriteEvent({
    required int sportId,
    required int eventId,
    CancelToken? cancelToken,
  }) => SbSportService.instance.removeFavoriteEvent(
    sportId: sportId,
    eventId: eventId,
    cancelToken: cancelToken,
  );

  // ===== BETTING METHODS - delegate to SbBettingService =====

  Future<Map<String, dynamic>> calculateBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
  }) => SbBettingService.instance.calculateBets(body, isV2: isV2);

  Future<Map<String, dynamic>> calculateBetsParlay(Map<String, dynamic> body) =>
      SbBettingService.instance.calculateBetsParlay(body);

  Future<Map<String, dynamic>> placeBets(
    Map<String, dynamic> body, {
    bool isV2 = false,
  }) => SbBettingService.instance.placeBets(body, isV2: isV2);

  Future<Map<String, dynamic>> placeBetsParlay(Map<String, dynamic> body) =>
      SbBettingService.instance.placeBetsParlay(body);

  // ===== BET HISTORY METHODS - delegate to SbBettingService =====

  Future<dynamic> betsReporting(
    String status, {
    int sportId = 1,
    String? token,
  }) => SbBettingService.instance.betsReporting(
    status,
    sportId: sportId,
    token: token,
  );

  Future<dynamic> getBetSlipByStatus(
    String status, {
    int sportId = 1,
    String? token,
  }) => SbBettingService.instance.getBetSlipByStatus(
    status,
    sportId: sportId,
    token: token,
  );

  /// Request OTP for phone number verification
  ///
  /// Request: GET {paygateUrl}?command=getOTPCode&type=1&phone={phoneNumber}
  /// Response: { status: 0, data: { message: "..." } }
  Future<SunApiResponse<dynamic>> getOTPCode(String phoneNumber) async {
    final paygateUrl = SbConfig.instance.paygateDomainUrl;
    final queryParameters = {
      'command': 'getOTPCode',
      'type': '1',
      'phone': phoneNumber,
    };
    final url = Uri.parse(
      paygateUrl,
    ).replace(queryParameters: queryParameters).toString();
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    return SunApiResponse.fromJson(response, (json) => json);
  }

  /// Activate phone number
  ///
  /// Request: GET {paygateUrl}?command=activePhone&otp={otp}
  /// Response: { status: 0, data: { message: "..." } }
  /// Throws [SunApiException] if response is a failure.
  Future<dynamic> activePhone(String otp) async {
    final paygateUrl = SbConfig.instance.paygateDomainUrl;
    final queryParameters = {'command': 'activePhone', 'otp': otp};
    final url = Uri.parse(
      paygateUrl,
    ).replace(queryParameters: queryParameters).toString();
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<dynamic>.fromJson(
      response,
      (json) => json,
    );

    return parsedResponse.dataOrThrow;
  }

  /// Throws [SunApiException] if response is a failure.
  Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = SbConfig.instance.changePasswordUrl;
    final response =
        await send(
              url,
              json: true,
              post: true,
              authorization: true,
              token: _userToken,
              body: jsonEncode({
                'oldPassword': oldPassword,
                'newPassword': newPassword,
              }),
            )
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<dynamic>.fromJson(
      response,
      (json) => json,
    );

    return parsedResponse.dataOrThrow;
  }

  /// Throws [SunApiException] if response is a failure.
  Future<TransactionResponseData> getTransactionSlipHistory({
    int slipType = 0,
    int skip = 0,
    int limit = 10,
  }) async {
    final url = SbUserService.buildTransactionHistoryUrl(
      apiDomain,
      slipType: slipType,
      skip: skip,
      limit: limit,
    );
    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    final parsedResponse = SunApiResponse<TransactionResponseData>.fromJsonMap(
      response,
      TransactionResponseData.fromJson,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<dynamic> fetchBankAccounts() async {
    final url = SbUserService.buildBankAccountsUrl(apiDomain);
    return await send(url, json: true, authorization: true, token: _userToken);
  }

  /// Throws [SunApiException] if response is a failure.
  Future<PlayHistoryResponse> fetchPlayHistory({
    int skip = 0,
    int limit = 5,
    String? assetName = 'gold',
  }) async {
    final url = SbUserService.buildPlayHistoryUrl(
      apiDomain,
      skip: skip,
      limit: limit,
      assetName: assetName,
    );

    final response =
        await send(url, json: true, authorization: true, token: _userToken)
            as Map<String, dynamic>;

    // debugPrint('fetchPlayHistory token: $_userToken');
    // debugPrint('fetchPlayHistory response: $response');

    final parsedResponse = SunApiResponse<PlayHistoryResponse>.fromJsonMap(
      response,
      PlayHistoryResponse.fromJson,
    );

    return parsedResponse.dataOrThrow;
  }

  Future<Map<String, dynamic>> getStatusByTicketId(String ticketId) =>
      SbBettingService.instance.getStatusByTicketId(ticketId);

  // ===== CASH OUT METHODS - delegate to SbBettingService =====

  Future<Map<String, dynamic>> getCashOut(Map<String, dynamic> body) =>
      SbBettingService.instance.getCashOut(body);

  Future<Map<String, dynamic>> cashOut(Map<String, dynamic> body) =>
      SbBettingService.instance.cashOut(body);

  // ===== VIDEO & STATS METHODS =====

  /// Get Live Stream Link
  Future<LivestreamResponse> getLiveLink(String eventId, String brand) async {
    final url = SbApiEndpoints.buildLiveStreamUrl(
      urlHomeExposeService,
      eventId,
      brand,
    );
    final response =
        await send(url, json: true, headerToken: true) as Map<String, dynamic>;
    return LivestreamResponse.fromJson(response);
  }

  /// Get Highlight Videos
  Future<Map<String, dynamic>> getHighlight() async {
    final url = SbApiEndpoints.buildHighlightsUrl(
      urlHomeExposeService,
      sportTypeId,
      _userTokenSb,
    );
    return await send(url, json: true) as Map<String, dynamic>;
  }

  /// Get Statistics Link
  Future<Map<String, dynamic>> getStatsLink(String eventId) async {
    final url = SbApiEndpoints.buildStatsUrl(
      urlStatistics,
      eventId,
      _userTokenSb,
    );
    return await send(url, json: true) as Map<String, dynamic>;
  }

  /// Get Tracker Link
  Future<Map<String, dynamic>> getTrackerLink(String eventId) async {
    final url = SbApiEndpoints.buildTrackerUrl(
      urlStatistics,
      eventId,
      _userTokenSb,
    );
    return await send(url, json: true) as Map<String, dynamic>;
  }

  // ===== RESET =====
  /// Reset manager state (useful for reconnect)
  void reset() {
    _userTokenSb = '';
    _chatToken = '';
    _domains.clear();
    _user.clear();
  }

  /// Reset tokens and user data only for logout (keeps domains/settings)
  ///
  /// This only clears:
  /// - Tokens (userToken, userTokenSb, chatToken)
  /// - User data (uid, displayName, balance, etc.)
  ///
  /// Keeps:
  /// - Domains (urlHomeExposeService, urlHomeBettingService, etc.)
  /// - Settings (refreshWithAPI, timeRefreshBalance, sportTypeId)
  void resetForLogout() {
    _userToken = '';
    _userTokenSb = '';
    _chatToken = '';
    SbUserService.resetUserData(_user);
  }

  @override
  String toString() =>
      'SbHttpManager(userToken: ${_userToken.isNotEmpty}, userTokenSb: ${_userTokenSb.isNotEmpty}, custLogin: $custLogin, balance: $userBalance)';
}
