import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2_extensions.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/market_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_style_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart'
    show MarketHelper;
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Betting Popup Data Model for V2 API
///
/// Contains all data needed to display betting popup using V2 models.
class BettingPopupDataV2 {
  /// Sport ID for this bet (used for multi-sport subscriptions)
  final int sportId;

  /// Odds data - the specific odds clicked (V2 model)
  final OddsModelV2 oddsData;

  /// Market data - the market containing this odds (V2 model)
  final MarketModelV2 marketData;

  /// Event data - the event/match containing this market (V2 model)
  final EventModelV2 eventData;

  /// Odds type - which odds was clicked (home/away/draw/over/under)
  final OddsType oddsType;

  /// League data - league information (V2 model)
  final LeagueModelV2? leagueData;

  /// User's current odds format preference
  final OddsFormatV2 oddsFormat;

  /// Min stake from API calculateBets response
  final int minStake;

  /// Max stake from API calculateBets response
  final int maxStake;

  /// Max payout from API calculateBets response
  final int maxPayout;

  BettingPopupDataV2({
    this.sportId = 1,
    required this.oddsData,
    required this.marketData,
    required this.eventData,
    required this.oddsType,
    this.leagueData,
    this.oddsFormat = OddsFormatV2.decimal,
    this.minStake = 0,
    this.maxStake = 0,
    this.maxPayout = 0,
  });

  /// Get the selected odds value based on oddsType and oddsFormat
  double getSelectedOddsValue() {
    switch (oddsType) {
      case OddsType.home:
        return oddsData.getHomeOdds(oddsFormat);
      case OddsType.away:
        return oddsData.getAwayOdds(oddsFormat);
      case OddsType.draw:
        return oddsData.getDrawOdds(oddsFormat) ?? 0.0;
      default:
        return 0.0;
    }
  }

  /// Get display odds string based on oddsFormat
  String getDisplayOdds() {
    final oddsValue = getSelectedOddsValue();
    if (oddsValue <= 0) return '-';
    return oddsValue.toStringAsFixed(2);
  }

  /// Get selection ID based on oddsType
  String? getSelectionId() {
    switch (oddsType) {
      case OddsType.home:
        return oddsData.selectionHomeId;
      case OddsType.away:
        return oddsData.selectionAwayId;
      case OddsType.draw:
        return oddsData.selectionDrawId;
      default:
        return null;
    }
  }

  /// Get offer ID
  String? getOfferId() => oddsData.strOfferId;

  /// Get team name based on oddsType (for display purposes)
  String getTeamName() {
    switch (oddsType) {
      case OddsType.home:
        return eventData.homeName;
      case OddsType.away:
        return eventData.awayName;
      case OddsType.draw:
        return 'Draw';
      default:
        return '';
    }
  }

  /// Get selection name for API request (based on market type)
  String getSelectionName() {
    final marketId = marketData.marketId;

    // Special outright bets: marketId = 0 and awayName is empty
    if (marketId == 0 &&
        eventData.awayName.isEmpty &&
        eventData.homeName.isNotEmpty) {
      return eventData.homeName;
    }

    // 1. Handicap markets - Return team name
    if (MarketHelper.isHandicap(marketId)) {
      switch (oddsType) {
        case OddsType.home:
          return eventData.homeName;
        case OddsType.away:
          return eventData.awayName;
        case OddsType.draw:
          return 'Draw';
        default:
          return eventData.homeName;
      }
    }

    // 2. Over/Under markets - Return "Over" or "Under"
    if (MarketHelper.isOverUnder(marketId)) {
      return oddsType == OddsType.home ? 'Over' : 'Under';
    }

    // 3. Double Chance markets (7, 8)
    if (_isDoubleChanceMarket(marketId)) {
      switch (oddsType) {
        case OddsType.home:
          return '1X';
        case OddsType.away:
          return 'X2';
        case OddsType.draw:
          return '12';
        default:
          return '1X';
      }
    }

    // 4. Odd/Even markets
    if (MarketHelper.isOddEven(marketId)) {
      return oddsType == OddsType.home ? 'Odd' : 'Even';
    }

    // 5. Correct Score markets
    if (MarketHelper.isCorrectScore(marketId)) {
      final points = oddsData.points;
      final scores = points.split(RegExp(r'[:\-]'));
      if (scores.length >= 2) {
        final score1 = int.tryParse(scores[0]) ?? 0;
        final score2 = int.tryParse(scores[1]) ?? 0;
        if (score1 > score2) return 'Home';
        if (score1 < score2) return 'Away';
        return 'Draw';
      }
      return points;
    }

    // 6. 1X2 and other markets - Return "Home", "Away", "Draw"
    switch (oddsType) {
      case OddsType.home:
        return 'Home';
      case OddsType.away:
        return 'Away';
      case OddsType.draw:
        return 'Draw';
      default:
        return 'Home';
    }
  }

  bool _isDoubleChanceMarket(int marketId) => [7, 8].contains(marketId);

  /// Get point display string (e.g., "0.5 [1-0]@")
  String getPointDisplay() {
    final points = oddsData.points;
    final score = '[${eventData.homeScoreInt}-${eventData.awayScoreInt}]';

    // For corner markets, don't show score
    if (_isCornerMarket()) {
      return '$points@';
    }

    // For normal markets
    return '$points$score@';
  }

  /// Get market name
  String getMarketName() => marketData.marketType.displayName;

  /// Get market name in Vietnamese with period prefix
  String getMarketNameViDisplay() =>
      MarketHelper.getMarketNameViDisplay(marketData.marketId);

  /// Get league name
  String getLeagueName() => leagueData?.displayName ?? '';

  /// Get home team name
  String getHomeName() => eventData.homeName;

  /// Get away team name
  String getAwayName() => eventData.awayName;

  /// Get score string
  String getScore() => '[${eventData.homeScoreInt}-${eventData.awayScoreInt}]';

  /// Check if event is live
  bool get isLive => eventData.isLive;

  /// Get game time in minutes
  int get gameTime => eventData.gameTime ~/ 60000;

  /// Get game part (period)
  int get gamePart => eventData.gamePart;

  /// Get home corners
  int get cornersHome => eventData.cornersHome;

  /// Get away corners
  int get cornersAway => eventData.cornersAway;

  /// Get home yellow cards
  int get yellowCardsHome => eventData.yellowCardsHome;

  /// Get away yellow cards
  int get yellowCardsAway => eventData.yellowCardsAway;

  /// Get home red cards
  int get redCardsHome => eventData.redCardsHome;

  /// Get away red cards
  int get redCardsAway => eventData.redCardsAway;

  /// Get home logo
  String? get homeLogo =>
      eventData.homeLogo.isNotEmpty ? eventData.homeLogo : null;

  /// Get away logo
  String? get awayLogo =>
      eventData.awayLogo.isNotEmpty ? eventData.awayLogo : null;

  /// Check if parlay is enabled
  bool get isParlay => marketData.isParlay;

  /// Get match time as ISO string for API
  String getMatchTimeISO() {
    if (eventData.startTime == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(eventData.startTime);
    return dateTime.toIso8601String();
  }

  /// Get league ID as string for API
  String getLeagueIdString() {
    return leagueData?.leagueId.toString() ?? eventData.eventId.toString();
  }

  bool _isCornerMarket() {
    return MarketHelper.isCornerMarket(marketData.marketId);
  }
}
