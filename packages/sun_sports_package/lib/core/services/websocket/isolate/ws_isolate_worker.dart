import 'dart:convert';

import 'package:isolate_manager/isolate_manager.dart';

import 'ws_isolate_types.dart';

/// WebSocket Isolate Worker Entry Point
///
/// This file contains the worker function that runs in isolate/web worker.
/// Must be compiled separately for web: dart compile js -o web/ws_worker.js
///
/// Usage:
/// - Native: Function runs in Dart Isolate automatically
/// - Web: Compile this file to JS, then isolate_manager uses it as Web Worker

/// Worker entry point - processes WebSocket messages
///
/// This is the main function that runs in the background thread.
/// It receives raw JSON strings and returns processed data.
@pragma('vm:entry-point')
@isolateManagerWorker
Map<String, dynamic> wsIsolateWorker(Map<String, dynamic> inputMap) {
  final rawMessages = List<String>.from(inputMap['rawMessages'] as List);
  final currentSportId = inputMap['currentSportId'] as int;

  final output = _processMessagesSync(rawMessages, currentSportId);
  return output.toMap();
}

/// Synchronous message processing (runs in isolate/worker)
///
/// This is where all the heavy lifting happens:
/// - JSON parsing
/// - Message type detection
/// - Data extraction and transformation
/// - Grouping by type
WsIsolateOutput _processMessagesSync(
  List<String> rawMessages,
  int currentSportId,
) {
  final oddsUpdates = <IsolateOddsUpdate>[];
  final oddsFullListUpdates = <IsolateOddsFullList>[];
  final eventInserts = <IsolateEventInsert>[];
  final eventRemoves = <IsolateEventRemove>[];
  final leagueInserts = <IsolateLeagueInsert>[];
  final marketStatusUpdates = <IsolateMarketStatus>[];
  final balanceUpdates = <IsolateBalanceUpdate>[];
  final scoreUpdates = <IsolateScoreUpdate>[];
  final typedMessages = <IsolateTypedMessage>[];

  // Track valid points per market for FULL LIST behavior
  final validPointsPerMarket = <String, Set<String>>{};
  final marketInfo = <String, (int, int)>{}; // key -> (eventId, marketId)

  for (final rawJson in rawMessages) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final type = data['t'] as String? ?? '';

      // Add to typed messages for backward compatibility
      typedMessages.add(IsolateTypedMessage(type: type, data: data));

      // Process based on type
      switch (type) {
        case 'odds_up':
        case 'odds_ins':
          _processOddsUpdate(
            data,
            oddsUpdates,
            validPointsPerMarket,
            marketInfo,
          );
          break;

        case 'event_ins':
          final eventData = _parseEventInsert(data);
          if (eventData != null) {
            eventInserts.add(eventData);
          }
          break;

        case 'event_rm':
          final eventId = _extractEventId(data);
          if (eventId != null && eventId > 0) {
            eventRemoves.add(IsolateEventRemove(eventId: eventId));
          }
          break;

        case 'league_ins':
          final leagueData = _parseLeagueInsert(data);
          if (leagueData != null) {
            leagueInserts.add(leagueData);
          }
          break;

        case 'market_up':
          final marketData = _parseMarketStatus(data);
          if (marketData != null) {
            marketStatusUpdates.add(marketData);
          }
          break;

        case 'balance_up':
          final balanceData = _parseBalanceUpdate(data);
          if (balanceData != null) {
            balanceUpdates.add(balanceData);
          }
          break;

        case 'score_up':
          final scoreData = _parseScoreUpdate(data);
          if (scoreData != null) {
            scoreUpdates.add(scoreData);
          }
          break;

        case 'event_up':
          // event_up can also contain score updates
          final eventScoreData = _parseEventUpdate(data);
          if (eventScoreData != null) {
            scoreUpdates.add(eventScoreData);
          }
          break;
      }
    } catch (e) {
      // Skip malformed messages
      continue;
    }
  }

  // Convert valid points map to list
  for (final entry in validPointsPerMarket.entries) {
    final info = marketInfo[entry.key];
    if (info != null) {
      oddsFullListUpdates.add(
        IsolateOddsFullList(
          eventId: info.$1,
          marketId: info.$2,
          validPoints: entry.value.toList(),
        ),
      );
    }
  }

  return WsIsolateOutput(
    oddsUpdates: oddsUpdates,
    oddsFullListUpdates: oddsFullListUpdates,
    eventInserts: eventInserts,
    eventRemoves: eventRemoves,
    leagueInserts: leagueInserts,
    marketStatusUpdates: marketStatusUpdates,
    balanceUpdates: balanceUpdates,
    scoreUpdates: scoreUpdates,
    typedMessages: typedMessages,
  );
}

// ===== PARSING HELPERS =====

/// Process odds update message
void _processOddsUpdate(
  Map<String, dynamic> data,
  List<IsolateOddsUpdate> oddsUpdates,
  Map<String, Set<String>> validPointsPerMarket,
  Map<String, (int, int)> marketInfo,
) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return;

  final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
  if (kafkaOddsList == null) return;

  for (final item in kafkaOddsList) {
    if (item is! Map<String, dynamic>) continue;

    final eventId = item['eventId'] as int? ?? 0;
    final marketIdInt =
        item['domainMarketId'] as int? ?? item['marketId'] as int? ?? 0;
    final marketId = marketIdInt.toString();
    final odds = item['odds'] as Map<String, dynamic>?;

    if (odds == null || eventId == 0) continue;

    final points = odds['points'] as String? ?? '';
    final selectionHomeId = odds['selectionHomeId'] as String? ?? '';
    final selectionAwayId = odds['selectionAwayId'] as String? ?? '';
    final selectionDrawId = odds['selectionDrawId'] as String?;

    final oddsHome = odds['oddsHome'] as Map<String, dynamic>?;
    final oddsAway = odds['oddsAway'] as Map<String, dynamic>?;
    final oddsDraw = odds['oddsDraw'] as Map<String, dynamic>?;

    // Track valid points for FULL LIST behavior
    final marketKey = '${eventId}_$marketIdInt';
    validPointsPerMarket[marketKey] ??= <String>{};
    marketInfo[marketKey] = (eventId, marketIdInt);

    if (points.isNotEmpty) {
      validPointsPerMarket[marketKey]!.add(points);
    }

    // Extract odds updates
    if (selectionHomeId.isNotEmpty && oddsHome != null) {
      oddsUpdates.add(
        IsolateOddsUpdate(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionHomeId,
          odds: oddsHome['decimal']?.toString() ?? '0',
          trueOdds: double.tryParse(oddsHome['trueOdds']?.toString() ?? ''),
          oddsValues: oddsHome,
        ),
      );
    }

    if (selectionAwayId.isNotEmpty && oddsAway != null) {
      oddsUpdates.add(
        IsolateOddsUpdate(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionAwayId,
          odds: oddsAway['decimal']?.toString() ?? '0',
          trueOdds: double.tryParse(oddsAway['trueOdds']?.toString() ?? ''),
          oddsValues: oddsAway,
        ),
      );
    }

    if (selectionDrawId != null &&
        selectionDrawId.isNotEmpty &&
        oddsDraw != null) {
      oddsUpdates.add(
        IsolateOddsUpdate(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionDrawId,
          odds: oddsDraw['decimal']?.toString() ?? '0',
          trueOdds: double.tryParse(oddsDraw['trueOdds']?.toString() ?? ''),
          oddsValues: oddsDraw,
        ),
      );
    }
  }
}

/// Parse event insert message
/// Format: {"s":1,"t":"event_ins","d":{...}}
/// Note: sportId is at root level 's', not inside 'd'
IsolateEventInsert? _parseEventInsert(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final eventId = d['eventId'] as int? ?? 0;
  if (eventId == 0) return null;

  // sportId is at root level 's', fallback to d['sportId']
  final sportId = data['s'] as int? ?? d['sportId'] as int? ?? 0;

  return IsolateEventInsert(
    eventId: eventId,
    leagueId: d['leagueId'] as int? ?? 0,
    sportId: sportId,
    homeName: d['homeName'] as String? ?? '',
    awayName: d['awayName'] as String? ?? '',
    homeScore: d['homeScore'] as int? ?? 0,
    awayScore: d['awayScore'] as int? ?? 0,
    isLive: d['isLive'] as bool? ?? false,
    startTime: d['startTime'] as String?,
    eventStatus: d['eventStatus'] as int?,
    gameTime: d['gameTime'] as String?,
    gamePart: d['gamePart'] as String?,
    homeLogo: d['homeLogo'] as String?,
    awayLogo: d['awayLogo'] as String?,
  );
}

/// Parse league insert message
/// Format: {"s":1,"t":"league_ins","d":{...}}
/// Note: sportId is at root level 's', not inside 'd'
IsolateLeagueInsert? _parseLeagueInsert(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final leagueId = d['leagueId'] as int? ?? 0;
  if (leagueId == 0) return null;

  // sportId is at root level 's', fallback to d['sportId']
  final sportId = data['s'] as int? ?? d['sportId'] as int? ?? 0;

  return IsolateLeagueInsert(
    leagueId: leagueId,
    sportId: sportId,
    leagueName: d['leagueName'] as String? ?? '',
    logoUrl: d['logoUrl'] as String?,
  );
}

/// Parse market status message
IsolateMarketStatus? _parseMarketStatus(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final eventId = d['eventId'] as int? ?? 0;
  final marketId = d['marketId'] as int? ?? 0;
  if (eventId == 0 || marketId == 0) return null;

  return IsolateMarketStatus(
    eventId: eventId,
    marketId: marketId,
    isSuspended: d['isSuspended'] as bool? ?? false,
  );
}

/// Parse balance update message
IsolateBalanceUpdate? _parseBalanceUpdate(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  final balance = d['balance'];
  if (balance == null) return null;

  return IsolateBalanceUpdate(
    balance: (balance as num).toDouble(),
    currency: d['currency'] as String?,
  );
}

/// Parse score update message
IsolateScoreUpdate? _parseScoreUpdate(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  // eventId can be int or String
  final eventId = _parseIntField(d['eventId']);
  if (eventId == 0) return null;

  return IsolateScoreUpdate(
    eventId: eventId,
    homeScore: _parseIntField(d['homeScore']),
    awayScore: _parseIntField(d['awayScore']),
    gameTime: _parseStringField(d['gameTime']),
    gamePart: _parseStringField(d['gamePart']),
  );
}

/// Extract event ID from message
int? _extractEventId(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  return d?['eventId'] as int?;
}

/// Parse event update message (event_up)
/// This can contain score updates, game time, and game part
IsolateScoreUpdate? _parseEventUpdate(Map<String, dynamic> data) {
  final d = data['d'] as Map<String, dynamic>?;
  if (d == null) return null;

  // eventId can be int or String
  final eventId = _parseIntField(d['eventId']);
  if (eventId == 0) return null;

  // event_up may contain score, gameTime, gamePart
  // All fields can be int or String from server
  return IsolateScoreUpdate(
    eventId: eventId,
    homeScore: _parseIntField(d['homeScore']),
    awayScore: _parseIntField(d['awayScore']),
    gameTime: _parseStringField(d['gameTime']),
    gamePart: _parseStringField(d['gamePart']),
  );
}

/// Parse field that can be int or String to int
int _parseIntField(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

/// Parse field that can be int or String to String
String? _parseStringField(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
