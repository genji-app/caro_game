import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';

/// Adapter to convert sport_socket LeagueData to Freezed LeagueData.
///
/// This adapter bridges the mutable sport_socket models with the
/// immutable Freezed models used throughout the app.
class LeagueAdapter {
  const LeagueAdapter._();

  /// Convert sport_socket LeagueData to Freezed LeagueData
  static LeagueData toFreezed(socket.LeagueData source) {
    return LeagueData(
      leagueId: source.leagueId,
      leagueName: source.name,
      leagueLogo: source.logoUrl ?? '',
      priorityOrder: source.priorityOrder,
      events: [], // Events are populated separately
    );
  }

  /// Convert multiple leagues
  static List<LeagueData> toFreezedList(Iterable<socket.LeagueData> sources) {
    return sources.map(toFreezed).toList();
  }

  /// Convert sport_socket LeagueData with events
  static LeagueData toFreezedWithEvents(
    socket.LeagueData league,
    List<socket.EventData> events,
    Map<int, List<socket.MarketData>> marketsPerEvent,
    Map<String, List<socket.OddsData>> oddsPerMarket,
  ) {
    return LeagueData(
      leagueId: league.leagueId,
      leagueName: league.name,
      leagueLogo: league.logoUrl ?? '',
      priorityOrder: league.priorityOrder,
      events: events.map((e) {
        final eventMarkets = marketsPerEvent[e.eventId] ?? [];
        return EventAdapter.toFreezedWithMarkets(
          e,
          eventMarkets,
          oddsPerMarket,
        );
      }).toList(),
    );
  }

  /// Update existing Freezed LeagueData with new values from socket
  static LeagueData updateFreezed(
    LeagueData existing,
    socket.LeagueData source,
  ) {
    return existing.copyWith(
      leagueName: source.name,
      leagueLogo: source.logoUrl ?? existing.leagueLogo,
      priorityOrder: source.priorityOrder ?? existing.priorityOrder,
    );
  }
}

/// Adapter to convert sport_socket EventData to Freezed LeagueEventData.
class EventAdapter {
  const EventAdapter._();

  /// Convert sport_socket EventData to Freezed LeagueEventData
  static LeagueEventData toFreezed(socket.EventData source) {
    return LeagueEventData(
      eventId: source.eventId,
      homeId: source.homeId,
      homeName: source.homeName,
      awayId: source.awayId,
      awayName: source.awayName,
      homeLogoFirst: source.homeLogo,
      awayLogoFirst: source.awayLogo,
      startTime: source.startDate?.millisecondsSinceEpoch ?? 0,
      homeScore: source.homeScore ?? 0,
      awayScore: source.awayScore ?? 0,
      isLive: source.isLive,
      isGoingLive: source.isGoingLive,
      isLivestream: source.isLiveStream,
      isSuspended: source.status != 'ACTIVE',
      eventStatus: source.status,
      gameTime: source.gameTime ?? 0,
      gamePart: source.gamePart ?? 0,
      stoppageTime: source.stoppageTime ?? 0,
      cornersHome: source.cornersHome ?? 0,
      cornersAway: source.cornersAway ?? 0,
      redCardsHome: source.redCardsHome ?? 0,
      redCardsAway: source.redCardsAway ?? 0,
      yellowCardsHome: source.yellowCardsHome ?? 0,
      yellowCardsAway: source.yellowCardsAway ?? 0,
      markets: [], // Markets are populated separately
    );
  }

  /// Convert with markets
  static LeagueEventData toFreezedWithMarkets(
    socket.EventData source,
    List<socket.MarketData> markets,
    Map<String, List<socket.OddsData>> oddsPerMarket,
  ) {
    return LeagueEventData(
      eventId: source.eventId,
      homeId: source.homeId,
      homeName: source.homeName,
      awayId: source.awayId,
      awayName: source.awayName,
      homeLogoFirst: source.homeLogo,
      awayLogoFirst: source.awayLogo,
      startTime: source.startDate?.millisecondsSinceEpoch ?? 0,
      homeScore: source.homeScore ?? 0,
      awayScore: source.awayScore ?? 0,
      isLive: source.isLive,
      isGoingLive: source.isGoingLive,
      isLivestream: source.isLiveStream,
      isSuspended: source.status != 'ACTIVE',
      eventStatus: source.status,
      gameTime: source.gameTime ?? 0,
      gamePart: source.gamePart ?? 0,
      stoppageTime: source.stoppageTime ?? 0,
      cornersHome: source.cornersHome ?? 0,
      cornersAway: source.cornersAway ?? 0,
      redCardsHome: source.redCardsHome ?? 0,
      redCardsAway: source.redCardsAway ?? 0,
      yellowCardsHome: source.yellowCardsHome ?? 0,
      yellowCardsAway: source.yellowCardsAway ?? 0,
      totalMarketsCount: markets.length,
      markets: markets.map((m) {
        final marketKey = '${source.eventId}_${m.marketId}';
        final odds = oddsPerMarket[marketKey] ?? [];
        return MarketAdapter.toFreezed(m, odds);
      }).toList(),
    );
  }

  /// Convert multiple events
  static List<LeagueEventData> toFreezedList(
    Iterable<socket.EventData> sources,
  ) {
    return sources.map(toFreezed).toList();
  }

  /// Update existing Freezed LeagueEventData with live data from socket
  static LeagueEventData updateFreezed(
    LeagueEventData existing,
    socket.EventData source,
  ) {
    return existing.copyWith(
      homeScore: source.homeScore ?? existing.homeScore,
      awayScore: source.awayScore ?? existing.awayScore,
      isLive: source.isLive,
      isSuspended: source.status != 'ACTIVE',
      eventStatus: source.status ?? existing.eventStatus,
      gameTime: source.gameTime ?? existing.gameTime,
      gamePart: source.gamePart ?? existing.gamePart,
      stoppageTime: source.stoppageTime ?? existing.stoppageTime,
      cornersHome: source.cornersHome ?? existing.cornersHome,
      cornersAway: source.cornersAway ?? existing.cornersAway,
      redCardsHome: source.redCardsHome ?? existing.redCardsHome,
      redCardsAway: source.redCardsAway ?? existing.redCardsAway,
      yellowCardsHome: source.yellowCardsHome ?? existing.yellowCardsHome,
      yellowCardsAway: source.yellowCardsAway ?? existing.yellowCardsAway,
    );
  }
}

/// Adapter to convert sport_socket MarketData to Freezed LeagueMarketData.
class MarketAdapter {
  const MarketAdapter._();

  /// Convert sport_socket MarketData to Freezed LeagueMarketData
  static LeagueMarketData toFreezed(
    socket.MarketData source,
    List<socket.OddsData> odds,
  ) {
    return LeagueMarketData(
      marketId: source.marketId,
      marketName: MarketHelper.getMarketName(source.marketId),
      isParlay: false, // TODO: Get from source if available
      odds: odds.map(OddsAdapter.toFreezed).toList(),
    );
  }

  /// Convert multiple markets
  static List<LeagueMarketData> toFreezedList(
    Iterable<socket.MarketData> sources,
    Map<String, List<socket.OddsData>> oddsPerMarket,
  ) {
    return sources.map((m) {
      final marketKey = '${m.eventId}_${m.marketId}';
      final odds = oddsPerMarket[marketKey] ?? [];
      return toFreezed(m, odds);
    }).toList();
  }
}

/// Adapter to convert sport_socket OddsData to Freezed LeagueOddsData.
class OddsAdapter {
  const OddsAdapter._();

  /// Convert sport_socket OddsData to Freezed LeagueOddsData
  static LeagueOddsData toFreezed(socket.OddsData source) {
    return LeagueOddsData(
      points: source.points ?? '',
      isMainLine: source.isMainLine,
      offerId: source.offerId,
      selectionHomeId: source.selectionIdHome,
      selectionAwayId: source.selectionIdAway,
      selectionDrawId: source.selectionIdDraw,
      oddsHome: OddsValue(
        malay: _parseDouble(source.malayHome),
        indo: _parseDouble(source.indoHome),
        decimal: source.oddsHome ?? -100,
        hongKong: _parseDouble(source.hkHome),
      ),
      oddsAway: OddsValue(
        malay: _parseDouble(source.malayAway),
        indo: _parseDouble(source.indoAway),
        decimal: source.oddsAway ?? -100,
        hongKong: _parseDouble(source.hkAway),
      ),
      oddsDraw: source.oddsDraw != null
          ? OddsValue(
              malay: -100,
              indo: -100,
              decimal: source.oddsDraw!,
              hongKong: -100,
            )
          : const OddsValue(),
    );
  }

  /// Convert multiple odds
  static List<LeagueOddsData> toFreezedList(Iterable<socket.OddsData> sources) {
    return sources.map(toFreezed).toList();
  }

  // ===== OddsDirection Mapping =====

  /// Get odds direction for home from library OddsData
  static OddsChangeDirection getHomeDirection(socket.OddsData source) {
    return _mapDirection(source.homeDirection);
  }

  /// Get odds direction for away from library OddsData
  static OddsChangeDirection getAwayDirection(socket.OddsData source) {
    return _mapDirection(source.awayDirection);
  }

  /// Get odds direction for draw from library OddsData
  static OddsChangeDirection getDrawDirection(socket.OddsData source) {
    return _mapDirection(source.drawDirection);
  }

  /// Map library OddsDirection to app's OddsChangeDirection
  static OddsChangeDirection _mapDirection(socket.OddsDirection direction) {
    switch (direction) {
      case socket.OddsDirection.up:
        return OddsChangeDirection.up;
      case socket.OddsDirection.down:
        return OddsChangeDirection.down;
      case socket.OddsDirection.none:
        return OddsChangeDirection.none;
    }
  }

  static double _parseDouble(String? value) {
    if (value == null || value.isEmpty) return -100;
    return double.tryParse(value) ?? -100;
  }
}
