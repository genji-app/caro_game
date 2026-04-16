import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Betting Popup Data Model
///
/// Contains all data needed to display betting popup.
/// Based on FLUTTER_BETTING_POPUP_COMPLETE_GUIDE.md
class BettingPopupData {
  /// Sport ID for this bet (used for multi-sport subscriptions)
  final int sportId;

  /// Odds data - the specific odds clicked
  final LeagueOddsData oddsData;

  /// Market data - the market containing this odds
  final LeagueMarketData marketData;

  /// Event data - the event/match containing this market
  final LeagueEventData eventData;

  /// Odds type - which odds was clicked (home/away/draw/over/under)
  final OddsType oddsType;

  /// League data - league information
  final LeagueData? leagueData;

  /// User's current odds style preference
  final OddsStyle oddsStyle;

  BettingPopupData({
    this.sportId =
        1, // Default to sport 1 for backward compatibility (layout files not yet updated)
    required this.oddsData,
    required this.marketData,
    required this.eventData,
    required this.oddsType,
    this.leagueData,
    this.oddsStyle = OddsStyle.decimal,
    this.minStake = 0,
    this.maxStake = 0,
    this.maxPayout = 0,
  });

  /// Get the selected odds value based on oddsType and oddsStyle
  double getSelectedOddsValue() {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(oddsStyle);
  }

  /// Get display odds string based on oddsStyle
  String getDisplayOdds() {
    final oddsValue = getSelectedOddsValue();
    if (oddsValue <= 0 || oddsValue == -100) return '-';
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
  String? getOfferId() => oddsData.offerId ?? oddsData.offerIdLegacy;

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
  /// - Special Outright: team/selection name (homeName for outright bets)
  /// - Handicap: team name (homeName/awayName)
  /// - Over/Under: "Over" or "Under"
  /// - 1X2: "Home", "Away", "Draw"
  /// - Double Chance: "1X", "X2", "12"
  /// - Odd/Even: "Odd", "Even"
  /// - Correct Score: "Home", "Away", "Draw" based on score
  String getSelectionName() {
    final marketId = marketData.marketId;

    // Special outright bets: marketId = 0 and awayName is empty
    // Return homeName (which contains selection name like "Aston Villa")
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

  /// Check if market is Double Chance (7, 8)
  bool _isDoubleChanceMarket(int marketId) => [7, 8].contains(marketId);

  /// Get point display string (e.g., "0.5 [1-0]@")
  String getPointDisplay() {
    final points = oddsData.points;
    final score = '[${eventData.homeScore}-${eventData.awayScore}]';

    // For corner markets, don't show score
    if (_isCornerMarket()) {
      return '$points@';
    }

    // For normal markets
    return '$points$score@';
  }

  /// Get market name
  String getMarketName() {
    return marketData.marketName.isNotEmpty
        ? marketData.marketName
        : MarketHelper.getMarketName(marketData.marketId);
  }

  /// Get market name in Vietnamese with period prefix
  /// Format: "Period - Market Type" (e.g., "Toàn trận - Kèo chấp")
  String getMarketNameViDisplay() =>
      MarketHelper.getMarketNameViDisplay(marketData.marketId);

  /// Get league name
  String getLeagueName() {
    return leagueData?.leagueName ?? '';
  }

  /// Get home team name
  String getHomeName() => eventData.homeName;

  /// Get away team name
  String getAwayName() => eventData.awayName;

  /// Get score string
  String getScore() => '[${eventData.homeScore}-${eventData.awayScore}]';

  /// Check if event is live
  bool get isLive => eventData.isLive;

  /// Get game time in minutes
  int get gameTime => eventData.gameTime ~/ 60000; // Convert from milliseconds

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
  String? get homeLogo => eventData.homeLogoFirst ?? eventData.homeLogoLast;

  /// Get away logo
  String? get awayLogo => eventData.awayLogoFirst ?? eventData.awayLogoLast;

  /// Check if parlay is enabled
  bool get isParlay => eventData.isParlay && marketData.isParlay;

  /// Min stake from API calculateBets response
  final int minStake;

  /// Max stake from API calculateBets response
  final int maxStake;

  /// Max payout from API calculateBets response
  final int maxPayout;

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

  // Private helpers

  OddsValue _getOddsValueByType() {
    switch (oddsType) {
      case OddsType.home:
        return oddsData.oddsHome;
      case OddsType.away:
        return oddsData.oddsAway;
      case OddsType.draw:
        return oddsData.oddsDraw;
      default:
        return const OddsValue();
    }
  }

  bool _isCornerMarket() {
    return MarketHelper.isCornerMarket(marketData.marketId);
  }
}
