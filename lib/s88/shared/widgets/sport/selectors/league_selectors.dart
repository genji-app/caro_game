import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';

/// Pre-defined selectors for LeagueState
///
/// Use these selectors with ref.watch() to minimize rebuilds.
///
/// Example:
/// ```dart
/// final score = ref.watch(
///   leagueProvider.select((s) => s.selectScores(eventId)),
/// );
/// ```
extension LeagueStateSelectors on LeagueState {
  // ═══════════════════════════════════════════════════════════
  // EVENT SELECTORS
  // ═══════════════════════════════════════════════════════════

  /// Select single event by ID
  LeagueEventData? selectEvent(int eventId) => allEvents[eventId];

  /// Select event scores only
  ({int home, int away})? selectScores(int eventId) {
    final event = allEvents[eventId];
    if (event == null) return null;
    return (home: event.homeScore, away: event.awayScore);
  }

  /// Select event live status
  ({bool isLive, int gameTime, int gamePart})? selectLiveStatus(int eventId) {
    final event = allEvents[eventId];
    if (event == null) return null;
    return (
      isLive: event.isLive,
      gameTime: event.gameTime,
      gamePart: event.gamePart,
    );
  }

  /// Select event cards (red/yellow)
  ({int redHome, int redAway, int yellowHome, int yellowAway})? selectCards(
    int eventId,
  ) {
    final event = allEvents[eventId];
    if (event == null) return null;
    return (
      redHome: event.redCardsHome,
      redAway: event.redCardsAway,
      yellowHome: event.yellowCardsHome,
      yellowAway: event.yellowCardsAway,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ODDS SELECTORS
  // ═══════════════════════════════════════════════════════════

  /// Select odds for specific event and market
  LeagueOddsData? selectOdds(int eventId, int marketId) {
    final event = allEvents[eventId];
    if (event == null) return null;

    final market = event.markets
        .where((m) => m.marketId == marketId)
        .firstOrNull;
    if (market == null) return null;

    return market.odds.where((o) => o.isMainLine).firstOrNull;
  }

  /// Select main line odds values only (decimal format)
  ({double home, double away, double draw, String points})? selectOddsValues(
    int eventId,
    int marketId,
  ) {
    final odds = selectOdds(eventId, marketId);
    if (odds == null) return null;
    return (
      home: odds.oddsHome.decimal,
      away: odds.oddsAway.decimal,
      draw: odds.oddsDraw.decimal,
      points: odds.points,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MARKET SELECTORS
  // ═══════════════════════════════════════════════════════════

  /// Select market data
  LeagueMarketData? selectMarket(int eventId, int marketId) {
    final event = allEvents[eventId];
    if (event == null) return null;
    return event.markets.where((m) => m.marketId == marketId).firstOrNull;
  }

  /// Check if market is suspended
  bool selectIsMarketSuspended(int eventId, int marketId) {
    final event = allEvents[eventId];
    if (event == null) return true;
    if (event.isSuspended) return true;

    // TODO: Add market-level suspension check when available
    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // LEAGUE SELECTORS
  // ═══════════════════════════════════════════════════════════

  /// Select league by ID
  LeagueData? selectLeague(int leagueId) => leagueCache[leagueId];

  /// Select league event count
  int selectLeagueEventCount(int leagueId) {
    final league = leagueCache[leagueId];
    return league?.events.length ?? 0;
  }

  // ═══════════════════════════════════════════════════════════
  // LIST SELECTORS
  // ═══════════════════════════════════════════════════════════

  /// Select leagues count
  int get leaguesCount => leagues.length;

  /// Select total events count
  int get totalEventsCount => allEvents.length;

  /// Select live events count
  int get liveEventsCount => allEvents.values.where((e) => e.isLive).length;
}
