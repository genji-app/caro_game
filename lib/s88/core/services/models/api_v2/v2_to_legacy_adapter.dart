import '../league_model.dart';
import 'event_detail_response_v2.dart';
import 'event_model_v2.dart';
import 'league_model_v2.dart';
import 'market_model_v2.dart';
import 'odds_model_v2.dart';
import 'odds_style_model_v2.dart';
import 'score_model_v2.dart';

/// V2 to Legacy Model Adapters
///
/// Extension methods to convert V2 models to legacy models.
/// This allows existing widgets to continue working while we
/// gradually migrate to V2 models.

// ============================================================================
// LEAGUE ADAPTER
// ============================================================================

extension LeagueModelV2Adapter on LeagueModelV2 {
  /// Convert LeagueModelV2 to LeagueData (legacy)
  LeagueData toLegacy() {
    return LeagueData(
      leagueId: leagueId,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      priorityOrder: priorityOrder,
      events: events.map((e) => e.toLegacy()).toList(),
    );
  }
}

extension LeagueModelV2ListAdapter on List<LeagueModelV2> {
  /// Convert list of LeagueModelV2 to list of LeagueData
  List<LeagueData> toLegacy() {
    return map((league) => league.toLegacy()).toList();
  }
}

// ============================================================================
// EVENT ADAPTER
// ============================================================================

extension EventModelV2Adapter on EventModelV2 {
  /// Convert EventModelV2 to LeagueEventData (legacy)
  LeagueEventData toLegacy() {
    // Extract scores from ScoreModelV2
    int homeScoreInt = 0;
    int awayScoreInt = 0;
    int cornersHome = 0;
    int cornersAway = 0;
    int redCardsHome = 0;
    int redCardsAway = 0;
    int yellowCardsHome = 0;
    int yellowCardsAway = 0;

    if (score != null) {
      // Parse score strings to int
      homeScoreInt = int.tryParse(score!.homeScore) ?? 0;
      awayScoreInt = int.tryParse(score!.awayScore) ?? 0;

      // Extract soccer-specific stats if available
      if (score is SoccerScoreModelV2) {
        final soccerScore = score! as SoccerScoreModelV2;
        cornersHome = soccerScore.homeCorner;
        cornersAway = soccerScore.awayCorner;
        redCardsHome = soccerScore.redCardsHome;
        redCardsAway = soccerScore.redCardsAway;
        yellowCardsHome = soccerScore.yellowCardsHome;
        yellowCardsAway = soccerScore.yellowCardsAway;
      }
    }

    return LeagueEventData(
      eventId: eventId,
      homeId: homeId,
      awayId: awayId,
      homeName: homeName,
      awayName: awayName,
      homeLogoFirst: homeLogo,
      awayLogoFirst: awayLogo,
      startTime: startTime,
      isLive: isLive,
      isGoingLive: isGoingLive,
      isLivestream: isLiveStream,
      isSuspended: isSuspended,
      eventStatsId: eventStatsId,
      gamePart: gamePart,
      gameTime: gameTime,
      homeScore: homeScoreInt,
      awayScore: awayScoreInt,
      cornersHome: cornersHome,
      cornersAway: cornersAway,
      redCardsHome: redCardsHome,
      redCardsAway: redCardsAway,
      yellowCardsHome: yellowCardsHome,
      yellowCardsAway: yellowCardsAway,
      totalMarketsCount: marketCount,
      markets: markets.map((m) => m.toLegacy()).toList(),
    );
  }
}

extension EventModelV2ListAdapter on List<EventModelV2> {
  /// Convert list of EventModelV2 to list of LeagueEventData
  List<LeagueEventData> toLegacy() {
    return map((event) => event.toLegacy()).toList();
  }
}

// ============================================================================
// MARKET ADAPTER
// ============================================================================

extension MarketModelV2Adapter on MarketModelV2 {
  /// Convert MarketModelV2 to LeagueMarketData (legacy)
  LeagueMarketData toLegacy() {
    return LeagueMarketData(
      marketId: marketId,
      marketName: marketType.displayName,
      isParlay: isParlay,
      odds: oddsList.map((o) => o.toLegacy()).toList(),
    );
  }
}

extension MarketModelV2ListAdapter on List<MarketModelV2> {
  /// Convert list of MarketModelV2 to list of LeagueMarketData
  List<LeagueMarketData> toLegacy() {
    return map((market) => market.toLegacy()).toList();
  }
}

// ============================================================================
// ODDS ADAPTER
// ============================================================================

extension OddsModelV2Adapter on OddsModelV2 {
  /// Convert OddsModelV2 to LeagueOddsData (legacy)
  LeagueOddsData toLegacy() {
    return LeagueOddsData(
      points: points,
      isMainLine: isMainLine,
      selectionHomeId: selectionHomeId,
      selectionAwayId: selectionAwayId,
      selectionDrawId: selectionDrawId,
      offerId: strOfferId,
      oddsHome: homeOdds?.toLegacyOddsValue() ?? const OddsValue(),
      oddsAway: awayOdds?.toLegacyOddsValue() ?? const OddsValue(),
      oddsDraw: drawOdds?.toLegacyOddsValue() ?? const OddsValue(),
    );
  }
}

extension OddsModelV2ListAdapter on List<OddsModelV2> {
  /// Convert list of OddsModelV2 to list of LeagueOddsData
  List<LeagueOddsData> toLegacy() {
    return map((odds) => odds.toLegacy()).toList();
  }
}

// ============================================================================
// ODDS STYLE ADAPTER
// ============================================================================

extension OddsStyleModelV2Adapter on OddsStyleModelV2 {
  /// Convert OddsStyleModelV2 to OddsValue (legacy)
  OddsValue toLegacyOddsValue() {
    return OddsValue(
      malay: malayValue,
      indo: indoValue,
      decimal: decimalValue,
      hongKong: hkValue,
    );
  }
}

// ============================================================================
// EVENT DETAIL RESPONSE ADAPTER
// ============================================================================

extension EventDetailResponseV2Adapter on EventDetailResponseV2 {
  /// Convert EventDetailResponseV2 to LeagueEventData (legacy)
  /// Includes markets from both main event and child events (Corner, Extra, Penalty)
  LeagueEventData toLeagueEventData() {
    // Main event markets
    final mainMarkets = markets.map((m) => m.toLegacy()).toList();

    // Child events markets (Corner, Extra Time, Penalty)
    final childMarkets = <LeagueMarketData>[];
    for (final child in children) {
      childMarkets.addAll(child.markets.map((m) => m.toLegacy()));
    }

    return LeagueEventData(
      eventId: eventId,
      homeId: homeId,
      awayId: awayId,
      homeName: homeName,
      awayName: awayName,
      homeLogoFirst: homeLogo,
      awayLogoFirst: awayLogo,
      startTime: startTime,
      isLive: isLive,
      isGoingLive: isGoingLive,
      isLivestream: isLiveStream,
      isSuspended: isSuspended,
      eventStatsId: eventStatsId,
      gamePart: gamePart,
      gameTime: gameTime,
      stoppageTime: stoppageTime,
      totalMarketsCount: marketCount,
      markets: [...mainMarkets, ...childMarkets],
    );
  }
}
