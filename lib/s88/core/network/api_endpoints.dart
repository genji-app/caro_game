/// API endpoints configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this to your actual API base URL
  static const String baseUrl = 'https://api.example.com';

  // API version
  static const String apiVersion = '/api/v1';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String profile = '$apiVersion/auth/profile';

  // User endpoints
  static const String userInfoByToken = '/api/v1/users/info';
  static const String userBalanceByToken = '/api/v1/users/balance';
  static const String users = '$apiVersion/users';
  static String user(String id) => '$users/$id';

  // Game endpoints
  static const String games = '$apiVersion/games';
  static String game(String id) => '$games/$id';

  // Casino endpoints
  static const String casinos = '$apiVersion/casinos';
  static String casino(String id) => '$casinos/$id';

  // Sports endpoints
  static const String sports = '$apiVersion/sports';
  static String sport(String id) => '$sports/$id';
}

/// Sportbook API endpoints
///
/// Centralized endpoint definitions for all Sportbook services.
/// Base URLs are loaded from config at runtime.
class SbApiEndpoints {
  SbApiEndpoints._();

  // ===== EVENT ENDPOINTS (urlHomeExposeService) =====

  /// Get events & markets
  /// Full: {baseUrl}/event/get-event-market?agentId={}&token={}&sportId={}
  static const String eventMarket = '/event/get-event-market';

  /// Get hot/featured matches
  /// Full: {baseUrl}/event/hot?agentId={}&token={}&sportId={}
  static const String eventHot = '/api/v1/events/hot';

  /// Get outright bets
  /// Full: {baseUrl}/event/outright?agentId={}&token={}&sportId={}
  static const String eventOutright = '/event/outright';

  // ===== EVENTS V2 ENDPOINTS =====

  /// Get events (V2 API)
  /// Full: {baseUrl}/api/v1/events?sportId={}&timeRange={}
  /// Header: token
  static const String eventsV2 = '/api/v1/events';

  /// Get event detail (V2 API)
  /// Full: {baseUrl}/api/v1/events/{eventId}?isMobile={}&onlyParlay={}
  /// Header: token
  static String eventDetailV2(int eventId) => '$eventsV2/$eventId';

  /// Get pinned leagues for a sport
  /// Full: {baseUrl}/api/v1/leagues/pin?sportId={}
  /// Header: token
  static const String leaguesPin = '/api/v1/leagues/pin';

  /// Search (sport/casino)
  /// Full: {baseUrl}/api/v1/search?txtSearch={}
  static const String search = '/api/v1/search';

  // ===== FAVORITE ENDPOINTS =====

  /// Get favorites
  /// Full: {baseUrl}/api/app/favorite?sportId={}
  static const String favorites = '/api/v1/favorite';

  /// Get favorite events
  /// Full: {baseUrl}/api/app/favorite/events?sportId={}
  static const String favoriteEvents = '/api/v1/favorite/events';

  /// Add/Remove favorite league
  /// Full: {baseUrl}/api/app/favorite/league
  static const String favoriteLeague = '/api/v1/favorite/league';

  /// Add/Remove favorite event
  /// Full: {baseUrl}/api/app/favorite/event
  static const String favoriteEvent = '/api/v1/favorite/event';

  // ===== USER ENDPOINTS =====

  /// Get user info by token
  /// Full: {baseUrl}/api/v1/users/info
  /// Header: token
  static const String userInfo = '/api/v1/users/info';

  /// Get user balance by token
  /// Full: {baseUrl}/api/v1/users/balance
  /// Header: token
  static const String userBalance = '/api/v1/users/balance';

  static const String notification = '/api/v1/notification';

  // ===== BET HISTORY ENDPOINTS =====

  /// Get bet history/reporting
  /// Full: {baseUrl}/bet/betsReporting?sportId={}&status={}&userId={}&token={}
  static const String betsReporting = '/api/v1/bet/betslips/history';

  /// Get bet slips by status
  /// Full: {baseUrl}/bet/getBetSlipByStatus?sportId={}&status={}&userId={}&token={}
  static const String betSlipByStatus = '/api/v1/bet/betslips';

  /// Get bet ticket status
  /// Full: {baseUrl}/bet/getStatusByTicketId?ticketId={}&token={}&sportId={}
  static const String ticketStatus = '/bet/getStatusByTicketId';

  // ===== STREAMING ENDPOINTS =====

  /// Get live stream link
  /// Full: {baseUrl}/streaming/get-live-link/{eventId}/?brand={}&token={}
  static String liveStreamLink(String eventId) => '/api/v1/streaming/$eventId';

  /// Get highlight videos
  /// Full: {baseUrl}/streaming/game/highlight?sportId={}&token={}
  static const String highlights = '/streaming/game/highlight';

  // ===== BETTING SERVICE ENDPOINTS (urlHomeBettingService) =====

  /// Calculate bet stakes
  /// Full: {baseUrl}/calculateBets?sportId={}
  static const String calculateBets = '/api/v1/bet/single/calculate-bet';

  /// Calculate parlay bet stakes (V2)
  /// Full: {baseUrl}/v2/calculateBets?sportId={}
  static const String calculateBetsV2 = '/api/v1/bet/parlay/calculate-bet';

  /// Place bet
  /// Full: {baseUrl}/placeBets?sportId={}
  static const String placeBets = '/api/v1/bet/single/place-bet';

  /// Place parlay bet (V2)
  /// Full: {baseUrl}/v2/placeBets?sportId={}
  static const String placeBetsV2 = '/api/v1/bet/parlay/place-bet';

  /// Get cash out options
  /// Full: {baseUrl}/get-cash-out?sportId={}
  static const String getCashOut = '/api/v1/bet/cash-out/get';

  /// Perform cash out
  /// Full: {baseUrl}/cash-out?sportId={}
  static const String cashOut = '/api/v1/bet/cash-out';

  // ===== STATISTICS ENDPOINTS (urlStatistics) =====

  /// Get statistics link
  /// Full: {baseUrl}/stats/{eventId}?token={}
  static String stats(String eventId) => '/stats/$eventId';

  /// Get tracker link
  /// Full: {baseUrl}/tracker/{eventId}?token={}
  static String tracker(String eventId) => '/tracker/$eventId';

  // ===== POPULAR EVENTS ENDPOINT =====

  /// Get popular/trending events
  /// Full: {baseUrl}/api/v1/events/popular?agentId={}
  /// Header: token
  static const String eventsPopular = '/api/v1/events/popular';

  // ===== BET STATISTICS (urlHomeExposeService) - for hot match enrichment =====

  /// Bet statistics simple (per-event market percentages)
  /// Full: {baseUrl}/api/v2/bet/statistics/simple?agentId={}&eventId={}
  static const String betStatisticsSimple = '/api/v1/bet/statistics/simple';

  /// Bet statistics user-details (user bets, total count)
  /// Full: {baseUrl}/api/v2/bet/statistics/user-details?agentId={}&leagueId={}&eventId={}&marketId={}&filter={}
  static const String betStatisticsUserDetails = '/api/v1/bet/statistics/users';

  // ===== PAYGATE ENDPOINTS =====

  /// Paygate commands (append to paygateUrl)
  static const String paygateGetOTP = 'getOTPCode';
  static const String paygateActivePhone = 'activePhone';
  static const String paygateTransactionHistory = 'fetchTransactionSlipHistory';
  static const String paygateBankAccounts = 'fetchBankAccounts';
  static const String fetchUserTransaction2 = 'fetch-user-transaction2';

  // ===== URL BUILDERS =====

  /// Build event market URL
  static String buildEventMarketUrl(
    String baseUrl,
    int agentId,
    String token,
    int sportId, [
    String? extraParams,
  ]) {
    return '$baseUrl$eventMarket?agentId=$agentId&token=$token&sportId=$sportId${extraParams ?? ''}';
  }

  /// Build event hot URL
  static String buildEventHotUrl(String baseUrl, int agentId, int sportId) {
    return '$baseUrl$eventHot?agentId=$agentId&sportId=$sportId';
  }

  /// Build event outright URL
  static String buildEventOutrightUrl(
    String baseUrl,
    int agentId,
    String token,
    int sportId, [
    String? extraParams,
  ]) {
    return '$baseUrl$eventOutright?agentId=$agentId&token=$token&sportId=$sportId${extraParams ?? ''}';
  }

  /// Build events V2 URL
  static String buildEventsV2Url(String baseUrl, String queryString) {
    return '$baseUrl$eventsV2?$queryString';
  }

  /// Build event detail V2 URL
  static String buildEventDetailV2Url(
    String baseUrl,
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
  }) {
    return '$baseUrl${eventDetailV2(eventId)}?isMobile=$isMobile&onlyParlay=$onlyParlay';
  }

  /// Build leagues pin URL
  static String buildLeaguesPinUrl(String baseUrl, int sportId) {
    return '$baseUrl$leaguesPin?sportId=$sportId';
  }

  /// Build search URL
  static String buildSearchUrl(String baseUrl, String txtSearch) {
    return '$baseUrl$search?txtSearch=${Uri.encodeComponent(txtSearch)}';
  }

  /// Build favorites URL
  static String buildFavoritesUrl(String baseUrl, int sportId) {
    return '$baseUrl$favorites?sportId=$sportId';
  }

  /// Build favorite events URL
  static String buildFavoriteEventsUrl(String baseUrl, int sportId) {
    return '$baseUrl$favoriteEvents?sportId=$sportId';
  }

  /// Build favorite league URL
  static String buildFavoriteLeagueUrl(String baseUrl) {
    return '$baseUrl$favoriteLeague';
  }

  /// Build favorite event URL
  static String buildFavoriteEventUrl(String baseUrl) {
    return '$baseUrl$favoriteEvent';
  }

  /// Build user info URL
  static String buildUserInfoUrl(String baseUrl) {
    return '$baseUrl$userInfo';
  }

  /// Build user balance URL
  static String buildUserBalanceUrl(String baseUrl) {
    return '$baseUrl$userBalance';
  }

  static String buildNotificationUrl(String baseUrl) {
    return '$baseUrl$notification';
  }

  /// Build bets reporting URL
  static String buildBetsReportingUrl(
    String baseUrl,
    int sportId,
    String status,
    String userId,
    String token,
  ) {
    return '$baseUrl$betsReporting?sportId=$sportId&status=$status&userId=$userId&token=$token';
  }

  /// Build bet slip by status URL
  static String buildBetSlipByStatusUrl(
    String baseUrl,
    int sportId,
    String status,
    String userId,
    String token,
  ) {
    return '$baseUrl$betSlipByStatus?sportId=$sportId&status=$status&userId=$userId&token=$token';
  }

  /// Build ticket status URL
  static String buildTicketStatusUrl(
    String baseUrl,
    String ticketId,
    String token,
    int sportId,
  ) {
    return '$baseUrl$ticketStatus?ticketId=$ticketId&token=$token&sportId=$sportId';
  }

  /// Build live stream URL
  static String buildLiveStreamUrl(
    String baseUrl,
    String eventId,
    String brand,
  ) {
    return '$baseUrl${liveStreamLink(eventId)}?brand=$brand';
  }

  /// Build highlights URL
  static String buildHighlightsUrl(String baseUrl, int sportId, String token) {
    return '$baseUrl$highlights?sportId=$sportId&token=$token';
  }

  /// Build calculate bets URL
  static String buildCalculateBetsUrl(String baseUrl, int sportId) {
    return '$baseUrl$calculateBets?sportId=$sportId';
  }

  /// Build calculate bets V2 URL
  static String buildCalculateBetsV2Url(String baseUrl, int sportId) {
    return '$baseUrl$calculateBetsV2?sportId=$sportId';
  }

  /// Build place bets URL
  static String buildPlaceBetsUrl(String baseUrl, int sportId) {
    return '$baseUrl$placeBets?sportId=$sportId';
  }

  /// Build place bets V2 URL
  static String buildPlaceBetsV2Url(String baseUrl, int sportId) {
    return '$baseUrl$placeBetsV2?sportId=$sportId';
  }

  /// Build get cash out URL
  static String buildGetCashOutUrl(String baseUrl, int sportId) {
    return '$baseUrl$getCashOut';
  }

  /// Build cash out URL
  static String buildCashOutUrl(String baseUrl, int sportId) {
    return '$baseUrl$cashOut';
  }

  /// Build stats URL
  static String buildStatsUrl(String baseUrl, String eventId, String token) {
    return '$baseUrl${stats(eventId)}?token=$token';
  }

  /// Build tracker URL
  static String buildTrackerUrl(String baseUrl, String eventId, String token) {
    return '$baseUrl${tracker(eventId)}?token=$token';
  }

  /// Build popular events URL
  static String buildEventsPopularUrl(String baseUrl, int agentId) {
    return '$baseUrl$eventsPopular?agentId=$agentId';
  }

  /// Build bet statistics simple URL (for hot match enrichment).
  /// Query: ?agentId=32&eventId=4580034
  static String buildBetStatisticsSimpleUrl(
    String baseUrl,
    int agentId,
    int eventId,
  ) {
    return '$baseUrl$betStatisticsSimple?agentId=$agentId&eventId=$eventId';
  }

  /// Build bet statistics user-details URL (for hot match enrichment).
  /// Query: ?agentId=25&leagueId=5041&eventId=4509289&marketId=0&filter=latest
  static String buildBetStatisticsUserDetailsUrl(
    String baseUrl,
    int agentId,
    int leagueId,
    int eventId, {
    int marketId = 0,
    String filter = 'latest',
  }) {
    return '$baseUrl$betStatisticsUserDetails?agentId=$agentId&leagueId=$leagueId&eventId=$eventId&marketId=$marketId&filter=${Uri.encodeComponent(filter)}';
  }

  /// Build transaction history URL
  static String buildTransactionHistoryUrl(
    String apiDomain, {
    int slipType = 0,
    int skip = 0,
    int limit = 10,
  }) {
    return '$apiDomain/paygate?command=$paygateTransactionHistory&limit=$limit&skip=$skip&slipType=$slipType';
  }

  /// Build bank accounts URL
  static String buildBankAccountsUrl(String apiDomain) {
    return '$apiDomain/paygate?command=$paygateBankAccounts';
  }

  /// Build play history URL
  static String buildPlayHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 5,
    String? assetName,
  }) {
    if (assetName == null || assetName.isEmpty) {
      return '$apiDomain/sa?command=$fetchUserTransaction2&limit=$limit&skip=$skip';
    }
    return '$apiDomain/sa?command=$fetchUserTransaction2&limit=$limit&skip=$skip&assetName=$assetName';
  }
}
