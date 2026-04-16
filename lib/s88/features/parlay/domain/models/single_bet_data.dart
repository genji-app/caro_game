import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Single Bet Data Model
///
/// Contains all data needed to display and place a single bet.
/// Used by ParlayMatchCard in Single tab.
class SingleBetData {
  /// Sport ID for this bet (used for multi-sport subscriptions)
  final int sportId;

  /// Odds data - the specific odds clicked
  final LeagueOddsData oddsData;

  /// Market data - the market containing this odds
  final LeagueMarketData marketData;

  /// Event data - the event/match containing this market
  final LeagueEventData eventData;

  /// Odds type - which odds was clicked (home/away/draw)
  final OddsType oddsType;

  /// League data - league information
  final LeagueData? leagueData;

  /// User's current odds style preference
  final OddsStyle oddsStyle;

  /// Stake amount entered by user (in VND, e.g., 100000 = 100,000đ)
  final int stake;

  /// Min stake from API calculateBets response (raw value, multiply by 1000 for actual)
  final int minStake;

  /// Max stake from API calculateBets response (raw value, multiply by 1000 for actual)
  final int maxStake;

  /// Max payout from API calculateBets response (in display units - K VND)
  final int maxPayout;

  /// Is calculating min/max stake
  final bool isCalculating;

  /// Error message if any
  final String? errorMessage;

  /// Updated odds from server (if changed)
  final double? updatedOdds;

  /// Is bet disabled (e.g., error 607 - odds not found)
  /// Disabled bets cannot be placed and won't receive WebSocket updates
  final bool isDisabled;

  const SingleBetData({
    required this.sportId,
    required this.oddsData,
    required this.marketData,
    required this.eventData,
    required this.oddsType,
    this.leagueData,
    this.oddsStyle = OddsStyle.decimal,
    this.stake = 0,
    this.minStake = 50,
    this.maxStake = 10000,
    this.maxPayout = 0,
    this.isCalculating = false,
    this.errorMessage,
    this.updatedOdds,
    this.isDisabled = false,
  });

  /// Create from BettingPopupData
  factory SingleBetData.fromBettingPopupData(BettingPopupData popupData) {
    return SingleBetData(
      sportId: popupData.sportId,
      oddsData: popupData.oddsData,
      marketData: popupData.marketData,
      eventData: popupData.eventData,
      oddsType: popupData.oddsType,
      leagueData: popupData.leagueData,
      oddsStyle: popupData.oddsStyle,
      minStake: popupData.minStake > 0 ? popupData.minStake : 50,
      maxStake: popupData.maxStake > 0 ? popupData.maxStake : 10000,
      maxPayout: popupData.maxPayout,
    );
  }

  /// Convert to BettingPopupData
  BettingPopupData toBettingPopupData() {
    return BettingPopupData(
      sportId: sportId,
      oddsData: oddsData,
      marketData: marketData,
      eventData: eventData,
      oddsType: oddsType,
      leagueData: leagueData,
      oddsStyle: oddsStyle,
      minStake: minStake,
      maxStake: maxStake,
      maxPayout: maxPayout,
    );
  }

  SingleBetData copyWith({
    int? sportId,
    LeagueOddsData? oddsData,
    LeagueMarketData? marketData,
    LeagueEventData? eventData,
    OddsType? oddsType,
    LeagueData? leagueData,
    OddsStyle? oddsStyle,
    int? stake,
    int? minStake,
    int? maxStake,
    int? maxPayout,
    bool? isCalculating,
    String? errorMessage,
    double? updatedOdds,
    bool? isDisabled,
  }) {
    return SingleBetData(
      sportId: sportId ?? this.sportId,
      oddsData: oddsData ?? this.oddsData,
      marketData: marketData ?? this.marketData,
      eventData: eventData ?? this.eventData,
      oddsType: oddsType ?? this.oddsType,
      leagueData: leagueData ?? this.leagueData,
      oddsStyle: oddsStyle ?? this.oddsStyle,
      stake: stake ?? this.stake,
      minStake: minStake ?? this.minStake,
      maxStake: maxStake ?? this.maxStake,
      maxPayout: maxPayout ?? this.maxPayout,
      isCalculating: isCalculating ?? this.isCalculating,
      errorMessage: errorMessage,
      updatedOdds: updatedOdds ?? this.updatedOdds,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() => {
    'sportId': sportId,
    'oddsData': oddsData.toJson(),
    'marketData': marketData.toJson(),
    'eventData': eventData.toJson(),
    'oddsType': oddsType.value,
    'leagueData': leagueData?.toJson(),
    'oddsStyle': oddsStyle.value,
    'stake': stake,
    'minStake': minStake,
    'maxStake': maxStake,
    'maxPayout': maxPayout,
    'updatedOdds': updatedOdds,
    'isDisabled': isDisabled,
  };

  /// Create from JSON (for local storage restore)
  factory SingleBetData.fromJson(Map<String, dynamic> json) {
    return SingleBetData(
      sportId:
          json['sportId'] as int? ??
          1, // Default to sport 1 for backward compatibility
      oddsData: LeagueOddsData.fromJson(
        json['oddsData'] as Map<String, dynamic>,
      ),
      marketData: LeagueMarketData.fromJson(
        json['marketData'] as Map<String, dynamic>,
      ),
      eventData: LeagueEventData.fromJson(
        json['eventData'] as Map<String, dynamic>,
      ),
      oddsType: OddsType.values.firstWhere(
        (e) => e.value == (json['oddsType'] as int? ?? 0),
        orElse: () => OddsType.none,
      ),
      leagueData: json['leagueData'] != null
          ? LeagueData.fromJson(json['leagueData'] as Map<String, dynamic>)
          : null,
      oddsStyle: OddsStyle.fromInt(json['oddsStyle'] as int? ?? 2),
      stake: json['stake'] as int? ?? 0,
      minStake: json['minStake'] as int? ?? 50,
      maxStake: json['maxStake'] as int? ?? 10000,
      maxPayout: json['maxPayout'] as int? ?? 0,
      updatedOdds: (json['updatedOdds'] as num?)?.toDouble(),
      isDisabled: json['isDisabled'] as bool? ?? false,
    );
  }

  // ===== GETTERS =====

  /// Get the original odds value from oddsData (ignores updatedOdds)
  /// Used to compare if odds have actually changed
  double get originalOdds {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(oddsStyle);
  }

  /// Get the selected odds value based on oddsType and oddsStyle
  double get displayOdds {
    if (updatedOdds != null) return updatedOdds!;

    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(oddsStyle);
  }

  /// Get odds value by any OddsStyle (for dynamic style switching)
  double getOddsByStyle(OddsStyle style) {
    final oddsValue = _getOddsValueByType();
    return oddsValue.getByStyle(style);
  }

  /// Get display odds string
  String get displayOddsString {
    final odds = displayOdds;
    if (odds <= 0 || odds == -100) return '-';
    return odds.toStringAsFixed(2);
  }

  /// Get selection ID based on oddsType
  String? get selectionId {
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
  String? get offerId => oddsData.offerId ?? oddsData.offerIdLegacy;

  /// Get team name based on oddsType
  String get teamName {
    switch (oddsType) {
      case OddsType.home:
        return eventData.homeName;
      case OddsType.away:
        return eventData.awayName;
      case OddsType.draw:
        return 'Hòa';
      default:
        return '';
    }
  }

  /// Get selection name for API request (NO points included!)
  /// Based on market type:
  /// - Handicap: team name (homeName/awayName)
  /// - Over/Under: "Over" or "Under"
  /// - 1X2: "Home", "Away", "Draw"
  /// - Double Chance: "1X", "X2", "12"
  /// - Odd/Even: "Odd", "Even"
  /// - Correct Score: "Home", "Away", "Draw" based on score
  String get selectionName {
    final marketId = marketData.marketId;

    // 1. Handicap markets - Return team name (NO points!)
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

  /// Suffix hiển thị hệ số chấp/tài xỉu, ẩn nếu rỗng hoặc bằng "0"
  String get _pointsSuffix {
    final p = oddsData.points;
    if (p.isEmpty || p == '0') return '';
    return ' ($p)';
  }

  /// Get display name for UI (Vietnamese)
  /// Based on market type:
  /// - Handicap: team name + points (e.g., "Sunderland (0-0.5)")
  /// - Over/Under: "Tài" or "Xỉu" + points (e.g., "Tài (2.5)")
  /// - 1X2: team name or "Hòa" + points nếu có
  /// - Double Chance: "1X", "X2", "12" + points nếu có
  /// - Odd/Even: "Lẻ", "Chẵn" + points nếu có
  /// - Correct Score: score (e.g., "1:0") - không thêm suffix
  String get displayName {
    final marketId = marketData.marketId;

    // 1. Correct Score markets - Return score only (points IS the name)
    if (MarketHelper.isCorrectScore(marketId)) {
      return oddsData.points;
    }

    // 2. Handicap markets
    if (MarketHelper.isHandicap(marketId)) {
      return '$teamName$_pointsSuffix';
    }

    // 3. Over/Under markets
    if (MarketHelper.isOverUnder(marketId)) {
      final name = oddsType == OddsType.home ? 'Tài' : 'Xỉu';
      return '$name$_pointsSuffix';
    }

    // 4. Double Chance markets (7, 8)
    if (_isDoubleChanceMarket(marketId)) {
      final name = switch (oddsType) {
        OddsType.home => '1X',
        OddsType.away => 'X2',
        OddsType.draw => '12',
        _ => '1X',
      };
      return '$name$_pointsSuffix';
    }

    // 5. Odd/Even markets
    if (MarketHelper.isOddEven(marketId)) {
      final name = oddsType == OddsType.home ? 'Lẻ' : 'Chẵn';
      return '$name$_pointsSuffix';
    }

    // 6. 1X2 and other markets
    return '$teamName$_pointsSuffix';
  }

  /// Get point display string (e.g., "0.5 [1-0]@")
  String get pointDisplay {
    final points = oddsData.points;
    final score = '[${eventData.homeScore}-${eventData.awayScore}]';

    // For corner markets, don't show score
    if (MarketHelper.isCornerMarket(marketData.marketId)) {
      return '$points@';
    }

    // For normal markets
    return '$points$score@';
  }

  /// Get market name in Vietnamese
  String get marketName {
    // Always use Vietnamese name from marketId for consistency
    return MarketHelper.getMarketNameVi(marketData.marketId);
  }

  /// Get league name
  String get leagueName => leagueData?.leagueName ?? '';

  /// Get home team name
  String get homeName => eventData.homeName;

  /// Get away team name
  String get awayName => eventData.awayName;

  /// Get score string
  String get score => '[${eventData.homeScore}-${eventData.awayScore}]';

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
  String? get homeLogo => eventData.homeLogoFirst ?? eventData.homeLogoLast;

  /// Get away logo
  String? get awayLogo => eventData.awayLogoFirst ?? eventData.awayLogoLast;

  /// Check if parlay is enabled
  bool get isParlay => eventData.isParlay && marketData.isParlay;

  /// Get match time as ISO string for API
  String get matchTimeISO {
    if (eventData.startTime == 0) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(eventData.startTime);
    return dateTime.toIso8601String();
  }

  /// Get league ID as string for API
  String get leagueIdString {
    return leagueData?.leagueId.toString() ?? eventData.eventId.toString();
  }

  // ===== CALCULATIONS =====

  /// Calculate potential winnings based on current stake
  /// Uses decimal odds for calculation
  double get potentialWinnings {
    if (stake <= 0) return 0;
    final odds = displayOdds;
    if (odds <= 0 || odds == -100) return 0;

    // Calculate based on odds style
    switch (oddsStyle) {
      case OddsStyle.decimal:
        return stake * odds;
      case OddsStyle.malay:
        if (odds > 0 && odds <= 1) {
          return stake * odds + stake;
        } else if (odds < 0) {
          return stake + stake / odds.abs();
        }
        return stake.toDouble();
      case OddsStyle.indo:
        if (odds >= 1) {
          return stake * odds + stake;
        } else if (odds < -1) {
          return stake + stake / odds.abs();
        }
        return stake.toDouble();
      case OddsStyle.hongKong:
        return stake * odds + stake;
    }
  }

  /// Calculate total cost (actual stake required)
  /// For negative Malay/Indo odds, cost differs from stake
  double get totalCost {
    if (stake <= 0) return 0;
    final odds = displayOdds;

    // For Malay negative odds, cost = stake * |odds|
    if (oddsStyle == OddsStyle.malay && odds < 0) {
      return stake * odds.abs();
    }

    // For Indo negative odds, cost = stake * |odds|
    if (oddsStyle == OddsStyle.indo && odds < -1) {
      return stake * odds.abs();
    }

    return stake.toDouble();
  }

  /// Get actual min stake (minStake * 1000)
  int get minStakeActual => minStake * 1000;

  /// Get actual max stake (maxStake * 1000)
  int get maxStakeActual => maxStake * 1000;

  /// Check if stake is valid (comparing with actual values)
  bool get isStakeValid => stake >= minStakeActual && stake <= maxStakeActual;

  /// Check if can place bet
  bool get canPlaceBet =>
      stake > 0 && isStakeValid && !isCalculating && !isDisabled;

  /// Get CLS string for API (e.g., "2.25", "-2.25")
  /// No suffix - just number with possible negative sign for handicap away bets
  String get cls {
    final points = oddsData.points;
    final pointsNumber = double.tryParse(points) ?? 0;
    final pointsAbs = pointsNumber.abs();

    double clsValue = pointsAbs;

    // For Handicap markets, apply negative sign based on odds type
    if (MarketHelper.isHandicap(marketData.marketId)) {
      if (pointsNumber > 0) {
        // Positive points: Away gets negative
        if (oddsType == OddsType.away) {
          clsValue = -pointsAbs;
        }
      } else {
        // Zero or negative points: Home gets negative
        if (oddsType == OddsType.home) {
          clsValue = -pointsAbs;
        }
      }
    }

    // Ensure decimal format (add ".0" if whole number)
    String clsStr = clsValue.toString();
    if (clsValue == clsValue.floor()) {
      clsStr = '${clsValue.toInt()}.0';
    }

    return clsStr;
  }

  // ===== PRIVATE HELPERS =====

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
}
