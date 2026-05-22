// WebSocket Isolate Types
//
// Serializable types for communication between main thread and isolate.
// All types must be primitive or easily serializable for isolate transfer.

/// Input for isolate processing
///
/// Contains raw JSON strings and context needed for processing.
/// Designed for minimal serialization overhead.
class WsIsolateInput {
  /// Raw JSON message strings (not parsed yet)
  final List<String> rawMessages;

  /// Current sport ID for filtering
  final int currentSportId;

  const WsIsolateInput({
    required this.rawMessages,
    required this.currentSportId,
  });

  /// Convert to Map for isolate transfer
  Map<String, dynamic> toMap() => {
    'rawMessages': rawMessages,
    'currentSportId': currentSportId,
  };

  /// Create from Map (in isolate)
  factory WsIsolateInput.fromMap(Map<String, dynamic> map) {
    return WsIsolateInput(
      rawMessages: List<String>.from(map['rawMessages'] as List),
      currentSportId: map['currentSportId'] as int,
    );
  }
}

/// Output from isolate processing
///
/// Contains parsed and processed data ready for state update.
/// Main thread only needs to apply this data, no heavy computation.
class WsIsolateOutput {
  /// Parsed odds updates (for popup/bet detail - direct emit)
  final List<IsolateOddsUpdate> oddsUpdates;

  /// Odds full list data (for FULL LIST behavior)
  final List<IsolateOddsFullList> oddsFullListUpdates;

  /// Event inserts
  final List<IsolateEventInsert> eventInserts;

  /// Event removes
  final List<IsolateEventRemove> eventRemoves;

  /// League inserts
  final List<IsolateLeagueInsert> leagueInserts;

  /// Market status updates
  final List<IsolateMarketStatus> marketStatusUpdates;

  /// Balance updates (pass through)
  final List<IsolateBalanceUpdate> balanceUpdates;

  /// Score updates (pass through)
  final List<IsolateScoreUpdate> scoreUpdates;

  /// Raw typed messages for backward compatibility
  final List<IsolateTypedMessage> typedMessages;

  const WsIsolateOutput({
    this.oddsUpdates = const [],
    this.oddsFullListUpdates = const [],
    this.eventInserts = const [],
    this.eventRemoves = const [],
    this.leagueInserts = const [],
    this.marketStatusUpdates = const [],
    this.balanceUpdates = const [],
    this.scoreUpdates = const [],
    this.typedMessages = const [],
  });

  /// Check if empty
  bool get isEmpty =>
      oddsUpdates.isEmpty &&
      oddsFullListUpdates.isEmpty &&
      eventInserts.isEmpty &&
      eventRemoves.isEmpty &&
      leagueInserts.isEmpty &&
      marketStatusUpdates.isEmpty &&
      balanceUpdates.isEmpty &&
      scoreUpdates.isEmpty &&
      typedMessages.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Convert to Map for isolate transfer
  Map<String, dynamic> toMap() => {
    'oddsUpdates': oddsUpdates.map((e) => e.toMap()).toList(),
    'oddsFullListUpdates': oddsFullListUpdates.map((e) => e.toMap()).toList(),
    'eventInserts': eventInserts.map((e) => e.toMap()).toList(),
    'eventRemoves': eventRemoves.map((e) => e.toMap()).toList(),
    'leagueInserts': leagueInserts.map((e) => e.toMap()).toList(),
    'marketStatusUpdates': marketStatusUpdates.map((e) => e.toMap()).toList(),
    'balanceUpdates': balanceUpdates.map((e) => e.toMap()).toList(),
    'scoreUpdates': scoreUpdates.map((e) => e.toMap()).toList(),
    'typedMessages': typedMessages.map((e) => e.toMap()).toList(),
  };

  /// Create from Map (on main thread)
  factory WsIsolateOutput.fromMap(Map<String, dynamic> map) {
    return WsIsolateOutput(
      oddsUpdates: (map['oddsUpdates'] as List? ?? [])
          .map((e) => IsolateOddsUpdate.fromMap(e as Map<String, dynamic>))
          .toList(),
      oddsFullListUpdates: (map['oddsFullListUpdates'] as List? ?? [])
          .map((e) => IsolateOddsFullList.fromMap(e as Map<String, dynamic>))
          .toList(),
      eventInserts: (map['eventInserts'] as List? ?? [])
          .map((e) => IsolateEventInsert.fromMap(e as Map<String, dynamic>))
          .toList(),
      eventRemoves: (map['eventRemoves'] as List? ?? [])
          .map((e) => IsolateEventRemove.fromMap(e as Map<String, dynamic>))
          .toList(),
      leagueInserts: (map['leagueInserts'] as List? ?? [])
          .map((e) => IsolateLeagueInsert.fromMap(e as Map<String, dynamic>))
          .toList(),
      marketStatusUpdates: (map['marketStatusUpdates'] as List? ?? [])
          .map((e) => IsolateMarketStatus.fromMap(e as Map<String, dynamic>))
          .toList(),
      balanceUpdates: (map['balanceUpdates'] as List? ?? [])
          .map((e) => IsolateBalanceUpdate.fromMap(e as Map<String, dynamic>))
          .toList(),
      scoreUpdates: (map['scoreUpdates'] as List? ?? [])
          .map((e) => IsolateScoreUpdate.fromMap(e as Map<String, dynamic>))
          .toList(),
      typedMessages: (map['typedMessages'] as List? ?? [])
          .map((e) => IsolateTypedMessage.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ===== INDIVIDUAL DATA TYPES =====

/// Odds update data (for popup/bet detail)
class IsolateOddsUpdate {
  final int eventId;
  final String marketId;
  final String selectionId;
  final String odds;
  final double? trueOdds;
  final Map<String, dynamic>? oddsValues;

  const IsolateOddsUpdate({
    required this.eventId,
    required this.marketId,
    required this.selectionId,
    required this.odds,
    this.trueOdds,
    this.oddsValues,
  });

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'marketId': marketId,
    'selectionId': selectionId,
    'odds': odds,
    'trueOdds': trueOdds,
    'oddsValues': oddsValues,
  };

  factory IsolateOddsUpdate.fromMap(Map<String, dynamic> map) {
    return IsolateOddsUpdate(
      eventId: map['eventId'] as int,
      marketId: map['marketId'] as String,
      selectionId: map['selectionId'] as String,
      odds: map['odds'] as String,
      trueOdds: map['trueOdds'] as double?,
      oddsValues: map['oddsValues'] as Map<String, dynamic>?,
    );
  }
}

/// Odds full list data (for FULL LIST behavior)
class IsolateOddsFullList {
  final int eventId;
  final int marketId;
  final List<String> validPoints;

  const IsolateOddsFullList({
    required this.eventId,
    required this.marketId,
    required this.validPoints,
  });

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'marketId': marketId,
    'validPoints': validPoints,
  };

  factory IsolateOddsFullList.fromMap(Map<String, dynamic> map) {
    return IsolateOddsFullList(
      eventId: map['eventId'] as int,
      marketId: map['marketId'] as int,
      validPoints: List<String>.from(map['validPoints'] as List),
    );
  }
}

/// Event insert data
class IsolateEventInsert {
  final int eventId;
  final int leagueId;
  final int sportId;
  final String homeName;
  final String awayName;
  final int homeScore;
  final int awayScore;
  final bool isLive;
  final String? startTime;
  final int? eventStatus;
  final String? gameTime;
  final String? gamePart;
  final String? homeLogo;
  final String? awayLogo;

  const IsolateEventInsert({
    required this.eventId,
    required this.leagueId,
    required this.sportId,
    required this.homeName,
    required this.awayName,
    this.homeScore = 0,
    this.awayScore = 0,
    this.isLive = false,
    this.startTime,
    this.eventStatus,
    this.gameTime,
    this.gamePart,
    this.homeLogo,
    this.awayLogo,
  });

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'leagueId': leagueId,
    'sportId': sportId,
    'homeName': homeName,
    'awayName': awayName,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'isLive': isLive,
    'startTime': startTime,
    'eventStatus': eventStatus,
    'gameTime': gameTime,
    'gamePart': gamePart,
    'homeLogo': homeLogo,
    'awayLogo': awayLogo,
  };

  factory IsolateEventInsert.fromMap(Map<String, dynamic> map) {
    return IsolateEventInsert(
      eventId: map['eventId'] as int,
      leagueId: map['leagueId'] as int,
      sportId: map['sportId'] as int,
      homeName: map['homeName'] as String,
      awayName: map['awayName'] as String,
      homeScore: map['homeScore'] as int? ?? 0,
      awayScore: map['awayScore'] as int? ?? 0,
      isLive: map['isLive'] as bool? ?? false,
      startTime: map['startTime'] as String?,
      eventStatus: map['eventStatus'] as int?,
      gameTime: map['gameTime'] as String?,
      gamePart: map['gamePart'] as String?,
      homeLogo: map['homeLogo'] as String?,
      awayLogo: map['awayLogo'] as String?,
    );
  }
}

/// Event remove data
class IsolateEventRemove {
  final int eventId;

  const IsolateEventRemove({required this.eventId});

  Map<String, dynamic> toMap() => {'eventId': eventId};

  factory IsolateEventRemove.fromMap(Map<String, dynamic> map) {
    return IsolateEventRemove(eventId: map['eventId'] as int);
  }
}

/// League insert data
class IsolateLeagueInsert {
  final int leagueId;
  final int sportId;
  final String leagueName;
  final String? logoUrl;

  const IsolateLeagueInsert({
    required this.leagueId,
    required this.sportId,
    required this.leagueName,
    this.logoUrl,
  });

  Map<String, dynamic> toMap() => {
    'leagueId': leagueId,
    'sportId': sportId,
    'leagueName': leagueName,
    'logoUrl': logoUrl,
  };

  factory IsolateLeagueInsert.fromMap(Map<String, dynamic> map) {
    return IsolateLeagueInsert(
      leagueId: map['leagueId'] as int,
      sportId: map['sportId'] as int,
      leagueName: map['leagueName'] as String,
      logoUrl: map['logoUrl'] as String?,
    );
  }
}

/// Market status data
class IsolateMarketStatus {
  final int eventId;
  final int marketId;
  final bool isSuspended;

  const IsolateMarketStatus({
    required this.eventId,
    required this.marketId,
    required this.isSuspended,
  });

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'marketId': marketId,
    'isSuspended': isSuspended,
  };

  factory IsolateMarketStatus.fromMap(Map<String, dynamic> map) {
    return IsolateMarketStatus(
      eventId: map['eventId'] as int,
      marketId: map['marketId'] as int,
      isSuspended: map['isSuspended'] as bool,
    );
  }
}

/// Balance update data
class IsolateBalanceUpdate {
  final double balance;
  final String? currency;

  const IsolateBalanceUpdate({required this.balance, this.currency});

  Map<String, dynamic> toMap() => {'balance': balance, 'currency': currency};

  factory IsolateBalanceUpdate.fromMap(Map<String, dynamic> map) {
    return IsolateBalanceUpdate(
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String?,
    );
  }
}

/// Score update data
class IsolateScoreUpdate {
  final int eventId;
  final int homeScore;
  final int awayScore;
  final String? gameTime;
  final String? gamePart;

  const IsolateScoreUpdate({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
    this.gameTime,
    this.gamePart,
  });

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'gameTime': gameTime,
    'gamePart': gamePart,
  };

  factory IsolateScoreUpdate.fromMap(Map<String, dynamic> map) {
    return IsolateScoreUpdate(
      eventId: map['eventId'] as int,
      homeScore: map['homeScore'] as int,
      awayScore: map['awayScore'] as int,
      gameTime: map['gameTime'] as String?,
      gamePart: map['gamePart'] as String?,
    );
  }
}

/// Typed message for backward compatibility
class IsolateTypedMessage {
  final String type;
  final Map<String, dynamic> data;

  const IsolateTypedMessage({required this.type, required this.data});

  Map<String, dynamic> toMap() => {'type': type, 'data': data};

  factory IsolateTypedMessage.fromMap(Map<String, dynamic> map) {
    return IsolateTypedMessage(
      type: map['type'] as String,
      data: Map<String, dynamic>.from(map['data'] as Map),
    );
  }
}
