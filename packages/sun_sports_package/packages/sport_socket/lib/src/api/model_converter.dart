import '../data/models/league_data.dart';
import '../data/models/event_data.dart';
import '../data/models/market_data.dart';
import '../data/models/odds_data.dart';
import '../data/sport_data_store.dart';

/// Converts between Freezed models (app layer) and Library mutable models.
///
/// This converter enables the library to work with the app's Freezed models
/// without directly depending on them. The app layer passes data as Maps
/// (from Freezed.toJson()) and receives data as Maps (for Freezed.fromJson()).
///
/// Usage:
/// ```dart
/// // Import in SportSocketClient
/// final leagues = await apiService.fetchLiveLeagues(sportId: 1);
/// ModelConverter.populateDataStore(leagues, store, sportId: 1, timeRange: TimeRange.live);
/// ```
class ModelConverter {
  ModelConverter._();

  // ===== Freezed → Library (for API data import) =====

  /// Convert Freezed LeagueData JSON to Library LeagueData.
  ///
  /// Freezed fields: li, ln, lg, lpo
  /// Library fields: leagueId, sportId, name, priorityOrder, logoUrl
  static LeagueData fromFreezedLeague(
    Map<String, dynamic> freezed, {
    required int sportId,
  }) {
    return LeagueData(
      leagueId: _parseInt(freezed['li'] ?? freezed['leagueId']) ?? 0,
      sportId: sportId,
      name:
          freezed['ln']?.toString() ?? freezed['leagueName']?.toString() ?? '',
      priorityOrder: _parseInt(freezed['lpo'] ?? freezed['priorityOrder']) ?? 0,
      logoUrl: freezed['lg']?.toString() ?? freezed['leagueLogo']?.toString(),
      cashout: true,
    );
  }

  /// Convert Freezed LeagueEventData JSON to Library EventData.
  ///
  /// Freezed fields: ei, hn, an, hi, ai, hf, hl, af, al, st, hs, as, l, gl, ls, s, es, esi, gt, gp, stm, hc, ac, rch, rca, ych, yca, mc, ip
  static EventData fromFreezedEvent(
    Map<String, dynamic> freezed, {
    required int leagueId,
    required int sportId,
  }) {
    return EventData(
      eventId: _parseInt(freezed['ei'] ?? freezed['eventId']) ?? 0,
      leagueId: leagueId,
      sportId: sportId,
      // Team info
      homeName:
          freezed['hn']?.toString() ?? freezed['homeName']?.toString() ?? '',
      awayName:
          freezed['an']?.toString() ?? freezed['awayName']?.toString() ?? '',
      homeId: _parseInt(freezed['hi'] ?? freezed['homeId']) ?? 0,
      awayId: _parseInt(freezed['ai'] ?? freezed['awayId']) ?? 0,
      homeLogo: freezed['hf']?.toString() ??
          freezed['hl']?.toString() ??
          freezed['homeLogoFirst']?.toString() ??
          freezed['homeLogoLast']?.toString(),
      awayLogo: freezed['af']?.toString() ??
          freezed['al']?.toString() ??
          freezed['awayLogoFirst']?.toString() ??
          freezed['awayLogoLast']?.toString(),
      // Status
      status: freezed['es']?.toString() ??
          freezed['eventStatus']?.toString() ??
          'ACTIVE',
      isLive: _parseBool(freezed['l'] ?? freezed['isLive']),
      isGoingLive: _parseBool(freezed['gl'] ?? freezed['isGoingLive']),
      isLiveStream: _parseBool(freezed['ls'] ?? freezed['isLivestream']),
      isSuspended: _parseBool(freezed['s'] ?? freezed['isSuspended']),
      startDate: _parseDateTime(
          freezed['st'] ?? freezed['et'] ?? freezed['startTime']),
      eventStatsId: _parseInt(freezed['esi'] ?? freezed['eventStatsId']),
      // Live data
      homeScore: _parseInt(freezed['hs'] ?? freezed['homeScore']),
      awayScore: _parseInt(freezed['as'] ?? freezed['awayScore']),
      gameTime: _parseInt(freezed['gt'] ?? freezed['gameTime']),
      gamePart: _parseInt(freezed['gp'] ?? freezed['gamePart']),
      stoppageTime: _parseInt(freezed['stm'] ?? freezed['stoppageTime']),
      redCardsHome: _parseInt(freezed['rch'] ?? freezed['redCardsHome']),
      redCardsAway: _parseInt(freezed['rca'] ?? freezed['redCardsAway']),
      yellowCardsHome: _parseInt(freezed['ych'] ?? freezed['yellowCardsHome']),
      yellowCardsAway: _parseInt(freezed['yca'] ?? freezed['yellowCardsAway']),
      cornersHome: _parseInt(freezed['hc'] ?? freezed['cornersHome']),
      cornersAway: _parseInt(freezed['ac'] ?? freezed['cornersAway']),
      // Additional
      totalMarketsCount:
          _parseInt(freezed['mc'] ?? freezed['totalMarketsCount']) ?? 0,
      isParlay: _parseBool(freezed['ip'] ?? freezed['isParlay']),
    );
  }

  /// Convert Freezed LeagueMarketData JSON to Library MarketData.
  ///
  /// Freezed fields: mi, mn, mt, ip
  static MarketData fromFreezedMarket(
    Map<String, dynamic> freezed, {
    required int eventId,
  }) {
    return MarketData(
      marketId: _parseInt(freezed['mi'] ?? freezed['marketId']) ?? 0,
      eventId: eventId,
      name: freezed['mn']?.toString() ?? freezed['marketName']?.toString(),
      marketType:
          freezed['mt']?.toString() ?? freezed['marketType']?.toString(),
      status: MarketStatus.active,
    );
  }

  /// Convert Freezed LeagueOddsData JSON to Library OddsData.
  ///
  /// Freezed fields: p, ml, shi, sai, sdi, soi, oh, oa, od
  /// OddsValue structure: {ma, in, de, hk}
  static OddsData fromFreezedOdds(
    Map<String, dynamic> freezed, {
    required int eventId,
    required int marketId,
    required String timeRange,
  }) {
    final points =
        freezed['p']?.toString() ?? freezed['points']?.toString() ?? '';
    final offerId = freezed['soi']?.toString() ??
        freezed['offerId']?.toString() ??
        '${eventId}_${marketId}_$points';

    // Parse OddsValue objects
    final oddsHome = _parseOddsValue(freezed['oh'] ?? freezed['oddsHome']);
    final oddsAway = _parseOddsValue(freezed['oa'] ?? freezed['oddsAway']);
    final oddsDraw = _parseOddsValue(freezed['od'] ?? freezed['oddsDraw']);

    return OddsData(
      offerId: offerId,
      eventId: eventId,
      marketId: marketId,
      timeRange: timeRange,
      points: points,
      isMainLine: _parseBool(freezed['ml'] ?? freezed['isMainLine']),
      isSuspended: false,
      promotionType: 0,
      // Decimal odds (primary)
      oddsHome: oddsHome?['decimal'],
      oddsAway: oddsAway?['decimal'],
      oddsDraw: oddsDraw?['decimal'],
      // Malay format
      malayHome: oddsHome?['malay']?.toString(),
      malayAway: oddsAway?['malay']?.toString(),
      // Hong Kong format
      hkHome: oddsHome?['hongKong']?.toString(),
      hkAway: oddsAway?['hongKong']?.toString(),
      // Indo format
      indoHome: oddsHome?['indo']?.toString(),
      indoAway: oddsAway?['indo']?.toString(),
      // Selection IDs
      selectionIdHome:
          freezed['shi']?.toString() ?? freezed['selectionHomeId']?.toString(),
      selectionIdAway:
          freezed['sai']?.toString() ?? freezed['selectionAwayId']?.toString(),
      selectionIdDraw:
          freezed['sdi']?.toString() ?? freezed['selectionDrawId']?.toString(),
    );
  }

  /// Batch populate store from Freezed leagues.
  ///
  /// Converts Freezed LeagueData list to Library models and inserts into store.
  /// This is an atomic operation that processes the full hierarchy:
  /// League → Events → Markets → Odds
  ///
  /// [freezedLeagues] - List of Freezed LeagueData as JSON maps
  /// [store] - SportDataStore to populate
  /// [sportId] - Sport ID for all data
  /// [timeRange] - TimeRange.live or TimeRange.early
  static void populateDataStore(
    List<Map<String, dynamic>> freezedLeagues,
    SportDataStore store, {
    required int sportId,
    required String timeRange,
  }) {
    for (final leagueJson in freezedLeagues) {
      // 1. Insert league
      final league = fromFreezedLeague(leagueJson, sportId: sportId);
      store.insertLeague(league);

      // 2. Insert events
      final events = leagueJson['e'] as List<dynamic>? ??
          leagueJson['events'] as List<dynamic>? ??
          [];
      for (final eventJson in events) {
        if (eventJson is! Map<String, dynamic>) continue;

        final event = fromFreezedEvent(
          eventJson,
          leagueId: league.leagueId,
          sportId: sportId,
        );
        store.insertEvent(event);

        // 3. Insert markets
        final markets = eventJson['m'] as List<dynamic>? ??
            eventJson['markets'] as List<dynamic>? ??
            [];
        for (final marketJson in markets) {
          if (marketJson is! Map<String, dynamic>) continue;

          final marketId =
              _parseInt(marketJson['mi'] ?? marketJson['marketId']) ?? 0;

          // Convert to library format for upsert
          store.upsertMarketFromJson(event.eventId, {
            'marketId': marketId,
            'marketName': marketJson['mn'] ?? marketJson['marketName'],
            'marketType': marketJson['mt'] ?? marketJson['marketType'],
          });

          // 4. Insert odds
          final odds = marketJson['o'] as List<dynamic>? ??
              marketJson['odds'] as List<dynamic>? ??
              [];
          for (final oddsJson in odds) {
            if (oddsJson is! Map<String, dynamic>) continue;

            // Convert Freezed odds format to library format
            final oddsHomeValue =
                _parseOddsValue(oddsJson['oh'] ?? oddsJson['oddsHome']);
            final oddsAwayValue =
                _parseOddsValue(oddsJson['oa'] ?? oddsJson['oddsAway']);
            final oddsDrawValue =
                _parseOddsValue(oddsJson['od'] ?? oddsJson['oddsDraw']);

            store.upsertOddsFromJson(
              event.eventId,
              marketId,
              {
                'strOfferId': oddsJson['soi'] ?? oddsJson['offerId'],
                'points': oddsJson['p'] ?? oddsJson['points'],
                'isMainLine': oddsJson['ml'] ?? oddsJson['isMainLine'],
                'selectionIdHome':
                    oddsJson['shi'] ?? oddsJson['selectionHomeId'],
                'selectionIdAway':
                    oddsJson['sai'] ?? oddsJson['selectionAwayId'],
                'selectionIdDraw':
                    oddsJson['sdi'] ?? oddsJson['selectionDrawId'],
                'oddsHome': oddsHomeValue?['decimal'],
                'oddsAway': oddsAwayValue?['decimal'],
                'oddsDraw': oddsDrawValue?['decimal'],
                'malayHome': oddsHomeValue?['malay']?.toString(),
                'malayAway': oddsAwayValue?['malay']?.toString(),
                'hkHome': oddsHomeValue?['hongKong']?.toString(),
                'hkAway': oddsAwayValue?['hongKong']?.toString(),
                'indoHome': oddsHomeValue?['indo']?.toString(),
                'indoAway': oddsAwayValue?['indo']?.toString(),
              },
              timeRange: timeRange,
            );
          }
        }
      }
    }
  }

  /// Batch UPSERT store from raw JSON leagues.
  ///
  /// Khác với populateDataStore() dùng insert, method này dùng upsert
  /// để update nếu entity đã tồn tại. Phù hợp cho AutoRefresh.
  ///
  /// [jsonLeagues] - Raw JSON từ API (giữ nguyên nested e, m, o)
  /// [store] - SportDataStore để populate
  /// [sportId] - Sport ID
  /// [timeRange] - TimeRange.live hoặc TimeRange.early
  static void upsertPopulateDataStore(
    List<Map<String, dynamic>> jsonLeagues,
    SportDataStore store, {
    required int sportId,
    required String timeRange,
  }) {
    for (final leagueJson in jsonLeagues) {
      final leagueId =
          _parseInt(leagueJson['li'] ?? leagueJson['leagueId']) ?? 0;
      if (leagueId == 0) continue;

      // 1. UPSERT League
      store.upsertLeagueFromJson({
        'leagueId': leagueId,
        'sportId': sportId,
        'leagueName': leagueJson['ln'] ?? leagueJson['leagueName'],
        'priorityOrder': leagueJson['lpo'] ?? leagueJson['priorityOrder'],
        'logoUrl': leagueJson['lg'] ?? leagueJson['leagueLogo'],
      });

      // 2. UPSERT Events (nested "e" array)
      final events = leagueJson['e'] as List<dynamic>? ??
          leagueJson['events'] as List<dynamic>? ??
          [];

      for (final eventJson in events) {
        if (eventJson is! Map<String, dynamic>) continue;

        final eventId = _parseInt(eventJson['ei'] ?? eventJson['eventId']) ?? 0;
        if (eventId == 0) continue;

        store.upsertEventFromJson({
          'eventId': eventId,
          'leagueId': leagueId,
          'sportId': sportId,
          'homeName': eventJson['hn'] ?? eventJson['homeName'] ?? '',
          'awayName': eventJson['an'] ?? eventJson['awayName'] ?? '',
          'homeId': eventJson['hi'] ?? eventJson['homeId'] ?? 0,
          'awayId': eventJson['ai'] ?? eventJson['awayId'] ?? 0,
          'homeLogo':
              eventJson['hf'] ?? eventJson['hl'] ?? eventJson['homeLogoFirst'],
          'awayLogo':
              eventJson['af'] ?? eventJson['al'] ?? eventJson['awayLogoFirst'],
          'status': eventJson['es'] ?? eventJson['eventStatus'] ?? 'ACTIVE',
          'isLive': eventJson['l'] ?? eventJson['isLive'] ?? false,
          'isGoingLive': eventJson['gl'] ?? eventJson['isGoingLive'] ?? false,
          'isLiveStream': eventJson['ls'] ?? eventJson['isLivestream'] ?? false,
          'isSuspended': eventJson['s'] ?? eventJson['isSuspended'] ?? false,
          'startDate':
              eventJson['st'] ?? eventJson['et'] ?? eventJson['startTime'],
          'homeScore': eventJson['hs'] ?? eventJson['homeScore'],
          'awayScore': eventJson['as'] ?? eventJson['awayScore'],
          'gameTime': eventJson['gt'] ?? eventJson['gameTime'],
          'gamePart': eventJson['gp'] ?? eventJson['gamePart'],
          'stoppageTime': eventJson['stm'] ?? eventJson['stoppageTime'],
          'redCardsHome': eventJson['rch'] ?? eventJson['redCardsHome'],
          'redCardsAway': eventJson['rca'] ?? eventJson['redCardsAway'],
          'yellowCardsHome': eventJson['ych'] ?? eventJson['yellowCardsHome'],
          'yellowCardsAway': eventJson['yca'] ?? eventJson['yellowCardsAway'],
          'cornersHome': eventJson['hc'] ?? eventJson['cornersHome'],
          'cornersAway': eventJson['ac'] ?? eventJson['cornersAway'],
          'totalMarketsCount':
              eventJson['mc'] ?? eventJson['totalMarketsCount'] ?? 0,
          'isParlay': eventJson['ip'] ?? eventJson['isParlay'] ?? false,
          'eventStatsId': eventJson['esi'] ?? eventJson['eventStatsId'],
        });

        // 3. UPSERT Markets (nested "m" array)
        final markets = eventJson['m'] as List<dynamic>? ??
            eventJson['markets'] as List<dynamic>? ??
            [];

        for (final marketJson in markets) {
          if (marketJson is! Map<String, dynamic>) continue;

          final marketId =
              _parseInt(marketJson['mi'] ?? marketJson['marketId']) ?? 0;
          if (marketId == 0) continue;

          store.upsertMarketFromJson(eventId, {
            'marketId': marketId,
            'marketName': marketJson['mn'] ?? marketJson['marketName'],
            'marketType': marketJson['mt'] ?? marketJson['marketType'],
          });

          // 4. UPSERT Odds (nested "o" array)
          final odds = marketJson['o'] as List<dynamic>? ??
              marketJson['odds'] as List<dynamic>? ??
              [];

          for (final oddsJson in odds) {
            if (oddsJson is! Map<String, dynamic>) continue;

            final oddsHomeValue =
                _parseOddsValue(oddsJson['oh'] ?? oddsJson['oddsHome']);
            final oddsAwayValue =
                _parseOddsValue(oddsJson['oa'] ?? oddsJson['oddsAway']);
            final oddsDrawValue =
                _parseOddsValue(oddsJson['od'] ?? oddsJson['oddsDraw']);

            store.upsertOddsFromJson(
              eventId,
              marketId,
              {
                'strOfferId': oddsJson['soi'] ?? oddsJson['offerId'],
                'points': oddsJson['p'] ?? oddsJson['points'],
                'isMainLine': oddsJson['ml'] ?? oddsJson['isMainLine'],
                'selectionIdHome':
                    oddsJson['shi'] ?? oddsJson['selectionHomeId'],
                'selectionIdAway':
                    oddsJson['sai'] ?? oddsJson['selectionAwayId'],
                'selectionIdDraw':
                    oddsJson['sdi'] ?? oddsJson['selectionDrawId'],
                'oddsHome': oddsHomeValue?['decimal'],
                'oddsAway': oddsAwayValue?['decimal'],
                'oddsDraw': oddsDrawValue?['decimal'],
                'malayHome': oddsHomeValue?['malay']?.toString(),
                'malayAway': oddsAwayValue?['malay']?.toString(),
                'hkHome': oddsHomeValue?['hongKong']?.toString(),
                'hkAway': oddsAwayValue?['hongKong']?.toString(),
                'indoHome': oddsHomeValue?['indo']?.toString(),
                'indoAway': oddsAwayValue?['indo']?.toString(),
              },
              timeRange: timeRange,
            );
          }
        }
      }
    }
  }

  // ===== Library → Freezed (for UI consumption) =====

  /// Convert Library LeagueData to Freezed JSON format.
  static Map<String, dynamic> toFreezedLeague(
    LeagueData library,
    SportDataStore store,
  ) {
    final events = store.getEventsByLeague(library.leagueId);

    return {
      'li': library.leagueId,
      'ln': library.name,
      'lg': library.logoUrl ?? '',
      'lpo': library.priorityOrder,
      'e': events.map((e) => toFreezedEvent(e, store)).toList(),
    };
  }

  /// Convert Library EventData to Freezed JSON format.
  static Map<String, dynamic> toFreezedEvent(
    EventData library,
    SportDataStore store,
  ) {
    final markets = store.getMarketsByEvent(library.eventId);

    return {
      'ei': library.eventId,
      'hn': library.homeName,
      'an': library.awayName,
      'hi': library.homeId,
      'ai': library.awayId,
      'hf': library.homeLogo,
      'af': library.awayLogo,
      'st': library.startDate?.millisecondsSinceEpoch ?? 0,
      'hs': library.homeScore ?? 0,
      'as': library.awayScore ?? 0,
      'l': library.isLive,
      'gl': library.isGoingLive,
      'ls': library.isLiveStream,
      's': library.isSuspended,
      'es': library.status,
      'esi': library.eventStatsId ?? 0,
      'gt': library.gameTime ?? 0,
      'gp': library.gamePart ?? 0,
      'stm': library.stoppageTime ?? 0,
      'hc': library.cornersHome ?? 0,
      'ac': library.cornersAway ?? 0,
      'rch': library.redCardsHome ?? 0,
      'rca': library.redCardsAway ?? 0,
      'ych': library.yellowCardsHome ?? 0,
      'yca': library.yellowCardsAway ?? 0,
      'mc': library.totalMarketsCount,
      'ip': library.isParlay,
      'm': markets
          .map((m) => toFreezedMarket(m, library.eventId, store))
          .toList(),
    };
  }

  /// Convert Library MarketData to Freezed JSON format.
  static Map<String, dynamic> toFreezedMarket(
    MarketData library,
    int eventId,
    SportDataStore store,
  ) {
    final odds = store.getOddsByMarket(eventId, library.marketId);

    return {
      'mi': library.marketId,
      'mn': library.name ?? '',
      'mt': library.marketType,
      'ip': false,
      'o': odds.map((o) => toFreezedOdds(o)).toList(),
    };
  }

  /// Convert Library OddsData to Freezed JSON format.
  static Map<String, dynamic> toFreezedOdds(OddsData library) {
    return {
      'p': library.points ?? '',
      'ml': library.isMainLine,
      'shi': library.selectionIdHome,
      'sai': library.selectionIdAway,
      'sdi': library.selectionIdDraw,
      'soi': library.offerId,
      'oh': _buildOddsValueJson(
        decimal: library.oddsHome,
        malay: library.malayHome,
        indo: library.indoHome,
        hongKong: library.hkHome,
      ),
      'oa': _buildOddsValueJson(
        decimal: library.oddsAway,
        malay: library.malayAway,
        indo: library.indoAway,
        hongKong: library.hkAway,
      ),
      'od': library.oddsDraw != null
          ? _buildOddsValueJson(decimal: library.oddsDraw)
          : null,
    };
  }

  // ===== Helper methods =====

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final asInt = int.tryParse(value);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Parse OddsValue object from Freezed format.
  /// OddsValue: {ma, in, de, hk} or {malay, indo, decimal, hongKong}
  static Map<String, double?>? _parseOddsValue(dynamic value) {
    if (value == null) return null;
    if (value is! Map) return null;

    final map = value as Map<String, dynamic>;
    return {
      'decimal': _parseDouble(map['de'] ?? map['decimal']),
      'malay': _parseDouble(map['ma'] ?? map['malay']),
      'indo': _parseDouble(map['in'] ?? map['indo']),
      'hongKong': _parseDouble(map['hk'] ?? map['hongKong']),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _buildOddsValueJson({
    double? decimal,
    String? malay,
    String? indo,
    String? hongKong,
  }) {
    return {
      'de': decimal ?? -100,
      'ma': double.tryParse(malay ?? '') ?? -100,
      'in': double.tryParse(indo ?? '') ?? -100,
      'hk': double.tryParse(hongKong ?? '') ?? -100,
    };
  }
}
