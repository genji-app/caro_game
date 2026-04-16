import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:co_caro_flame/s88/core/services/websocket/base_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/core/services/websocket/message_queue/message_queue.dart';
import 'package:co_caro_flame/s88/core/services/websocket/isolate/ws_isolate.dart';
import 'package:co_caro_flame/s88/core/utils/app_logger.dart';

/// Sportbook WebSocket
///
/// Handles real-time updates from the sportbook server:
/// - Odds updates
/// - Balance updates
/// - Event status changes
/// - Score updates
/// - Market status changes
class SbWebSocket extends BaseWebSocket {
  final AppLogger _logger = AppLogger();

  /// Message processor for queue-based rate limiting
  late final WsMessageProcessor _messageProcessor;

  /// Whether message processor is initialized
  bool _processorInitialized = false;

  // ===== ISOLATE PROCESSING =====

  /// Isolate processor for background JSON parsing
  final WsIsolateProcessor _isolateProcessor = WsIsolateProcessor();

  /// Buffer for raw messages (not parsed yet)
  final List<String> _rawMessageBuffer = [];

  /// Timer for isolate batch processing
  Timer? _isolateTimer;

  /// Whether isolate processing is enabled
  bool _useIsolate = true;

  /// Whether isolate is initialized
  bool _isolateInitialized = false;

  // DISABLED: Isolate stats for logging - now using SportSocketAdapter from sport_socket library
  // int _isolateMessagesReceived = 0;
  // int _isolateMessagesProcessed = 0;
  // int _isolateBatchCount = 0;
  // DateTime _isolateStatsStartTime = DateTime.now();
  // Timer? _isolateStatsTimer;

  /// Customer login ID for balance subscription
  String? _custLogin;

  /// Subscribed sports
  final Set<int> _subscribedSports = {};

  /// Subscribed events
  final Set<int> _subscribedEvents = {};

  /// Stream controller for typed messages
  final StreamController<WsMessage> _typedMessageController =
      StreamController<WsMessage>.broadcast();

  /// Stream controller for odds updates (odds_up, odds_ins)
  final StreamController<OddsUpdateData> _oddsController =
      StreamController<OddsUpdateData>.broadcast();

  /// Stream controller for odds remove (odds_rmv)
  final StreamController<OddsRemoveData> _oddsRemoveController =
      StreamController<OddsRemoveData>.broadcast();

  /// Stream controller for balance updates
  final StreamController<BalanceUpdateData> _balanceController =
      StreamController<BalanceUpdateData>.broadcast();

  /// Stream controller for score updates
  final StreamController<ScoreUpdateData> _scoreController =
      StreamController<ScoreUpdateData>.broadcast();

  /// Stream controller for odds full list updates (FULL LIST behavior)
  final StreamController<OddsFullListData> _oddsFullListController =
      StreamController<OddsFullListData>.broadcast();

  /// Stream controller for event insert (event_ins)
  final StreamController<EventInsertData> _eventInsertController =
      StreamController<EventInsertData>.broadcast();

  /// Stream controller for event remove (event_rm)
  final StreamController<EventRemoveData> _eventRemoveController =
      StreamController<EventRemoveData>.broadcast();

  /// Stream controller for league insert (league_ins)
  final StreamController<LeagueInsertData> _leagueInsertController =
      StreamController<LeagueInsertData>.broadcast();

  /// Stream controller for market status (market_up)
  final StreamController<MarketStatusData> _marketStatusController =
      StreamController<MarketStatusData>.broadcast();

  /// Stream controller for batch updates (all changes from a single tick)
  /// Use this instead of individual streams for optimized state updates
  final StreamController<WsBatchUpdate> _batchUpdateController =
      StreamController<WsBatchUpdate>.broadcast();

  @override
  String get name => 'SbWebSocket';

  // ===== STREAMS =====

  /// Typed message stream
  Stream<WsMessage> get typedMessageStream => _typedMessageController.stream;

  /// Odds update stream (odds_up, odds_ins)
  Stream<OddsUpdateData> get oddsStream => _oddsController.stream;

  /// Odds remove stream (odds_rmv)
  Stream<OddsRemoveData> get oddsRemoveStream => _oddsRemoveController.stream;

  /// Balance update stream
  Stream<BalanceUpdateData> get balanceStream => _balanceController.stream;

  /// Score update stream
  Stream<ScoreUpdateData> get scoreStream => _scoreController.stream;

  /// Odds full list stream (FULL LIST behavior - all valid selections for an event)
  Stream<OddsFullListData> get oddsFullListStream =>
      _oddsFullListController.stream;

  /// Event insert stream (event_ins) - new events added
  Stream<EventInsertData> get eventInsertStream =>
      _eventInsertController.stream;

  /// Event remove stream (event_rm) - events removed/finished
  Stream<EventRemoveData> get eventRemoveStream =>
      _eventRemoveController.stream;

  /// League insert stream (league_ins) - new leagues added
  Stream<LeagueInsertData> get leagueInsertStream =>
      _leagueInsertController.stream;

  /// Market status stream (market_up) - market suspended/active changes
  Stream<MarketStatusData> get marketStatusStream =>
      _marketStatusController.stream;

  /// Batch update stream - all changes from a single tick combined
  /// Use this for optimized state updates (1 rebuild per tick instead of N)
  Stream<WsBatchUpdate> get batchUpdateStream => _batchUpdateController.stream;

  // ===== MESSAGE PROCESSOR API =====

  /// Stream for popup priority messages (bypasses queue)
  Stream<WsQueuedMessage> get popupMessageStream =>
      _messageProcessor.popupMessageStream;

  /// Whether message processor is initialized
  bool get isProcessorInitialized => _processorInitialized;

  /// Get/set current sport ID for filtering
  int? get currentSportId =>
      _processorInitialized ? _messageProcessor.currentSportId : null;
  set currentSportId(int? sportId) {
    if (_processorInitialized) {
      _messageProcessor.currentSportId = sportId;
    }
  }

  /// Get/set bypass queue mode (for rollback)
  bool get bypassQueue =>
      _processorInitialized ? _messageProcessor.bypassQueue : true;
  set bypassQueue(bool value) {
    if (_processorInitialized) {
      _messageProcessor.bypassQueue = value;
    }
  }

  /// Get/set debug mode for logging
  bool get debugMode =>
      _processorInitialized ? _messageProcessor.debugMode : false;
  set debugMode(bool value) {
    if (_processorInitialized) {
      _messageProcessor.debugMode = value;
    }
  }

  /// Get/set sequence tracking mode
  /// When enabled, logs message flow patterns after event_ins/league_ins
  /// Format: event_ins:123(1) -> market_up:123(5) -> odds_up:123(10) -> ...
  bool get enableSequenceTracking =>
      _processorInitialized ? _messageProcessor.enableSequenceTracking : true;
  set enableSequenceTracking(bool value) {
    if (_processorInitialized) {
      _messageProcessor.enableSequenceTracking = value;
    }
  }

  /// Force flush current sequence log
  void flushSequenceLog() {
    if (_processorInitialized) {
      _messageProcessor.flushSequenceLog();
    }
  }

  /// Get processor statistics
  WsProcessorStats? get processorStats =>
      _processorInitialized ? _messageProcessor.stats : null;

  // ===== ISOLATE API =====

  /// Get/set isolate processing mode
  /// When enabled, JSON parsing is done in background isolate/worker
  bool get useIsolate => _useIsolate;
  set useIsolate(bool value) {
    _useIsolate = value;
    if (!value) {
      // Clear buffer when disabling isolate
      _rawMessageBuffer.clear();
    }
  }

  /// Whether isolate processor is initialized
  bool get isIsolateInitialized => _isolateInitialized;

  /// Register popup for priority message forwarding
  void registerPopup(int eventId) {
    if (_processorInitialized) {
      _messageProcessor.registerPopup(eventId);
    }
  }

  /// Unregister popup
  void unregisterPopup() {
    if (_processorInitialized) {
      _messageProcessor.unregisterPopup();
    }
  }

  /// Initialize the message processor
  ///
  /// Must be called with a TickerProvider to enable frame-based rate limiting.
  /// Call this from a StatefulWidget with TickerProviderStateMixin.
  void initializeProcessor(TickerProvider tickerProvider) {
    if (_processorInitialized) return;

    _messageProcessor = WsMessageProcessor(
      onBatchProcess: _handleBatchedMessages,
    );
    _messageProcessor.initialize(tickerProvider);
    _processorInitialized = true;

    _logger.i('$name: Message processor initialized');
    // Note: Isolate initialization moved to onConnected()
    // because we only need isolate when websocket is connected and receiving messages
  }

  /// Initialize the isolate processor for background JSON parsing
  Future<void> _initializeIsolate() async {
    if (_isolateInitialized) return;

    _logger.i('$name: [ISOLATE] Starting isolate initialization...');

    try {
      await _isolateProcessor.initialize();
      _isolateInitialized = true;

      // Pause WsMessageProcessor since isolate is now handling messages
      // This saves resources - no duplicate timers running
      if (_processorInitialized) {
        _messageProcessor.pause();
        _logger.i(
          '$name: [ISOLATE] WsMessageProcessor paused (isolate active)',
        );
      }

      // Start timer for batch processing from isolate
      // Process every 16ms (~60fps) to match frame rate
      _isolateTimer = Timer.periodic(
        const Duration(milliseconds: 16),
        (_) => _processIsolateBuffer(),
      );

      _logger.i(
        '$name: [ISOLATE] ✅ Isolate processor initialized successfully',
      );
      _logger.i(
        '$name: [ISOLATE] Messages will now be processed in background isolate/worker',
      );

      // DISABLED: Stats logging - now using SportSocketAdapter from sport_socket library
      // Start stats logging timer (every 30 seconds)
      // _isolateStatsStartTime = DateTime.now();
      // _isolateStatsTimer = Timer.periodic(
      //   const Duration(seconds: 30),
      //   (_) => _logIsolateStats(),
      // );
    } catch (e) {
      _logger.w(
        '$name: [ISOLATE] ❌ Initialization failed, falling back to main thread: $e',
      );
      _useIsolate = false;
      // Resume WsMessageProcessor as fallback
      if (_processorInitialized) {
        _messageProcessor.resume();
      }
    }
  }

  // Track message types for debugging
  final Map<String, int> _messageTypeCounts = {};

  // DISABLED: Stats logging - now using SportSocketAdapter from sport_socket library
  // /// Log isolate processing stats
  // void _logIsolateStats() {
  //   final elapsed = DateTime.now().difference(_isolateStatsStartTime).inSeconds;
  //   final rate = elapsed > 0 ? (_isolateMessagesReceived / elapsed).toStringAsFixed(1) : '0';
  //
  //   _logger.i('''
  // $name: [ISOLATE Stats - 30s interval]
  //     Received: $_isolateMessagesReceived ($rate/s) | Processed: $_isolateMessagesProcessed
  //     Batches: $_isolateBatchCount | Buffer: ${_rawMessageBuffer.length}
  //     Types: $_messageTypeCounts''');
  //
  //   // Reset counters
  //   _isolateMessagesReceived = 0;
  //   _isolateMessagesProcessed = 0;
  //   _isolateBatchCount = 0;
  //   _messageTypeCounts.clear();
  //   _isolateStatsStartTime = DateTime.now();
  // }

  /// Flag to prevent concurrent processing
  bool _isProcessingIsolateBuffer = false;

  /// Process buffered raw messages in isolate
  ///
  /// Called every 16ms by timer. Takes all buffered messages,
  /// sends to isolate for JSON parsing, then dispatches results.
  Future<void> _processIsolateBuffer() async {
    if (_rawMessageBuffer.isEmpty) return;

    // Prevent concurrent processing (async can overlap)
    if (_isProcessingIsolateBuffer) return;
    _isProcessingIsolateBuffer = true;

    // Take all messages from buffer
    final messages = List<String>.from(_rawMessageBuffer);
    _rawMessageBuffer.clear();

    // Get current sport ID for filtering in isolate
    final sportId = currentSportId ?? 0;

    try {
      // Process in isolate (JSON parsing + categorization)
      final input = WsIsolateInput(
        rawMessages: messages,
        currentSportId: sportId,
      );

      // Add timeout to prevent hanging
      final output = await _isolateProcessor
          .process(input)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              _logger.w(
                '$name: [ISOLATE] Process timeout after 5s for ${messages.length} messages',
              );
              throw TimeoutException('Isolate process timeout');
            },
          );

      // DISABLED: Track stats - now using SportSocketAdapter
      // _isolateMessagesProcessed += messages.length;
      // _isolateBatchCount++;

      // Dispatch results to streams and batch update
      _handleIsolateOutput(output);
    } catch (e) {
      _logger.e('$name: [ISOLATE] Processing error: $e');
      // Fallback: process on main thread
      for (final message in messages) {
        final wsMessage = WsMessage.parse(message);
        if (_processorInitialized) {
          _messageProcessor.enqueue(wsMessage);
        } else {
          _typedMessageController.add(wsMessage);
          _dispatchMessage(wsMessage);
        }
      }
    } finally {
      _isProcessingIsolateBuffer = false;
    }
  }

  /// Handle output from isolate processor
  ///
  /// Converts isolate output types to app types and dispatches to streams.
  void _handleIsolateOutput(WsIsolateOutput output) {
    // Debug: Log counts and message types
    if (output.scoreUpdates.isNotEmpty || output.eventInserts.isNotEmpty) {
      // _logger.i('$name: [ISOLATE OUTPUT] scores=${output.scoreUpdates.length}, eventInserts=${output.eventInserts.length}, markets=${output.marketStatusUpdates.length}');
    }

    // Track message types for stats
    for (final msg in output.typedMessages) {
      _messageTypeCounts[msg.type] = (_messageTypeCounts[msg.type] ?? 0) + 1;
    }

    final batchBuilder = WsBatchUpdateBuilder();

    // Process odds updates (for popup/bet detail)
    for (final odds in output.oddsUpdates) {
      final oddsValuesMap = odds.oddsValues;
      _oddsController.add(
        OddsUpdateData(
          eventId: odds.eventId,
          marketId: odds.marketId,
          selectionId: odds.selectionId,
          odds: odds.odds,
          trueOdds: odds.trueOdds,
          oddsValues: oddsValuesMap != null
              ? OddsStyleValues.fromJson(oddsValuesMap)
              : const OddsStyleValues(),
        ),
      );
    }

    // Process odds full list (for FULL LIST behavior)
    for (final fullList in output.oddsFullListUpdates) {
      final data = OddsFullListData(
        eventId: fullList.eventId,
        marketId: fullList.marketId,
        validPoints: fullList.validPoints.toSet(),
      );
      batchBuilder.addOddsFullList(data);
      _oddsFullListController.add(data);
    }

    // Process event inserts
    for (final event in output.eventInserts) {
      final data = EventInsertData(
        sportId: event.sportId,
        leagueId: event.leagueId,
        eventId: event.eventId,
        homeName: event.homeName,
        awayName: event.awayName,
        homeScore: event.homeScore,
        awayScore: event.awayScore,
        isLive: event.isLive,
        startTime: int.tryParse(event.startTime ?? '') ?? 0,
        eventStatus: event.eventStatus?.toString(),
        gameTime: int.tryParse(event.gameTime ?? '') ?? 0,
        gamePart: int.tryParse(event.gamePart ?? '') ?? 0,
        homeLogo: event.homeLogo,
        awayLogo: event.awayLogo,
      );
      batchBuilder.addEventInsert(data);
      _eventInsertController.add(data);
    }

    // Process event removes
    for (final event in output.eventRemoves) {
      // EventRemoveData requires leagueId but isolate only has eventId
      // Use 0 as default leagueId since it's not critical for removal
      final data = EventRemoveData(eventId: event.eventId, leagueId: 0);
      batchBuilder.addEventRemove(data);
      _eventRemoveController.add(data);
    }

    // Process league inserts
    for (final league in output.leagueInserts) {
      final data = LeagueInsertData(
        sportId: league.sportId,
        leagueId: league.leagueId,
        leagueName: league.leagueName,
        logoUrl: league.logoUrl,
      );
      batchBuilder.addLeagueInsert(data);
      _leagueInsertController.add(data);
    }

    // Process market status updates
    for (final market in output.marketStatusUpdates) {
      // Convert boolean isSuspended to MarketStatus enum
      // Note: isolate only has isSuspended flag, not full status code
      // Assume: suspended = MarketStatus.suspended, not suspended = MarketStatus.active
      final status = market.isSuspended
          ? MarketStatus.suspended
          : MarketStatus.active;

      final data = MarketStatusData(
        eventId: market.eventId,
        leagueId: 0, // Not available from isolate
        marketId: market.marketId,
        status: status,
      );
      batchBuilder.addMarketStatus(data);
      _marketStatusController.add(data);
    }

    // Process balance updates (not batched)
    for (final balance in output.balanceUpdates) {
      _balanceController.add(
        BalanceUpdateData(
          balance: balance.balance,
          raw: balance.balance.toString(),
        ),
      );
    }

    // Process score updates (not batched)
    // Includes gameTime, gamePart from event_up messages
    for (final score in output.scoreUpdates) {
      // _logger.d('$name: [ISOLATE] 📤 Emitting score update: eventId=${score.eventId}, home=${score.homeScore}, away=${score.awayScore}, gameTime=${score.gameTime}, gamePart=${score.gamePart}');
      _scoreController.add(
        ScoreUpdateData(
          eventId: score.eventId,
          home: score.homeScore,
          away: score.awayScore,
          gameTime: int.tryParse(score.gameTime ?? ''),
          gamePart: int.tryParse(score.gamePart ?? ''),
        ),
      );
    }

    // Process typed messages for backward compatibility
    for (final typed in output.typedMessages) {
      _typedMessageController.add(
        WsMessage(
          type: WsMessageType.values.firstWhere(
            (t) => t.name == typed.type,
            orElse: () => WsMessageType.unknown,
          ),
          data: typed.data,
        ),
      );
    }

    // Emit batch update if there are any state changes
    if (batchBuilder.isNotEmpty) {
      _batchUpdateController.add(batchBuilder.build());
    }
  }

  // ===== PUBLIC METHODS =====

  /// Connect with customer login
  Future<bool> connectWithAuth(String url, String custLogin) async {
    _custLogin = custLogin;
    return connect(url);
  }

  /// Subscribe to a sport (e.g., football = 1)
  void subscribeSport(int sportId) {
    if (_subscribedSports.contains(sportId)) return;

    _subscribedSports.add(sportId);
    if (isConnected) {
      _sendSportSubscription(sportId);
    }
  }

  /// Unsubscribe from a sport
  void unsubscribeSport(int sportId) {
    _subscribedSports.remove(sportId);
    if (isConnected) {
      send('UNSUB:s:$sportId');
    }
  }

  /// Subscribe to an event
  void subscribeEvent(int eventId) {
    if (_subscribedEvents.contains(eventId)) return;

    _subscribedEvents.add(eventId);
    if (isConnected) {
      _sendEventSubscription(eventId);
    }
  }

  /// Unsubscribe from an event
  void unsubscribeEvent(int eventId) {
    _subscribedEvents.remove(eventId);
    if (isConnected) {
      send('UNSUB:e:$eventId');
    }
  }

  /// Subscribe to balance updates
  void subscribeBalance() {
    if (_custLogin != null && isConnected) {
      send('userbal:$_custLogin');
    }
  }

  /// Clear all subscriptions
  void clearSubscriptions() {
    _subscribedSports.clear();
    _subscribedEvents.clear();
  }

  @override
  void dispose() {
    // Dispose message processor
    if (_processorInitialized) {
      _messageProcessor.dispose();
    }

    // Dispose isolate processor
    _isolateTimer?.cancel();
    _isolateTimer = null;
    // _isolateStatsTimer?.cancel(); // DISABLED: Stats logging
    // _isolateStatsTimer = null;
    _isolateProcessor.dispose();
    _rawMessageBuffer.clear();

    // Close stream controllers
    _typedMessageController.close();
    _oddsController.close();
    _oddsRemoveController.close();
    _oddsFullListController.close();
    _balanceController.close();
    _scoreController.close();
    _eventInsertController.close();
    _eventRemoveController.close();
    _leagueInsertController.close();
    _marketStatusController.close();
    _batchUpdateController.close();
    super.dispose();
  }

  // ===== PROTECTED OVERRIDES =====

  @override
  void onConnected() {
    _logger.i('$name: Connected, restoring subscriptions...');

    // Initialize isolate processor when connected (messages will start arriving)
    if (_useIsolate && !_isolateInitialized) {
      _initializeIsolate();
    }

    // Restore sport subscriptions
    for (final sportId in _subscribedSports) {
      _sendSportSubscription(sportId);
    }

    // Restore event subscriptions
    for (final eventId in _subscribedEvents) {
      _sendEventSubscription(eventId);
    }

    // Subscribe to balance
    subscribeBalance();
  }

  @override
  void onMessage(String message) {
    // When isolate is enabled and initialized, buffer raw messages
    // for background processing (JSON parsing offloaded to isolate)
    if (_useIsolate && _isolateInitialized) {
      _rawMessageBuffer.add(message);
      // _isolateMessagesReceived++; // DISABLED: Stats logging
      return;
    }

    // Parse message on main thread
    final wsMessage = WsMessage.parse(message);

    // Use message processor if initialized
    if (_processorInitialized) {
      _messageProcessor.enqueue(wsMessage);
      return;
    }

    // Fallback: direct processing (old behavior) when processor not initialized
    _typedMessageController.add(wsMessage);
    _dispatchMessage(wsMessage);
  }

  /// Handle odds remove message (odds_rmv)
  void _handleOddsRemove(WsMessage wsMessage) {
    final data = wsMessage.data;
    final d = data['d'] as Map<String, dynamic>?;

    if (d != null) {
      final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
      if (kafkaOddsList != null) {
        for (final item in kafkaOddsList) {
          if (item is Map<String, dynamic>) {
            final removeData = OddsRemoveData.fromKafkaItem(item);
            _logger.d('$name: Odds removed - $removeData');
            _oddsRemoveController.add(removeData);
          }
        }
      }
    }
  }

  /// Handle odds update message with kafkaOddsList format
  void _handleOddsUpdate(WsMessage wsMessage) {
    final data = wsMessage.data;

    // New format: {"t":"odds_up","d":{"kafkaOddsList":[...]}}
    final d = data['d'] as Map<String, dynamic>?;
    if (d != null) {
      final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
      if (kafkaOddsList != null) {
        // FULL LIST behavior: Collect valid points per (eventId, marketId)
        // Key: "eventId_marketId", Value: Set of valid points
        final validPointsPerMarket = <String, Set<String>>{};
        // Store eventId and marketId for each key
        final marketInfo = <String, (int, int)>{};

        for (final item in kafkaOddsList) {
          if (item is Map<String, dynamic>) {
            _emitOddsFromKafkaItem(item, validPointsPerMarket, marketInfo);
          }
        }

        // Emit full list data for FULL LIST behavior - per market!
        for (final entry in validPointsPerMarket.entries) {
          final info = marketInfo[entry.key];
          if (info != null) {
            _oddsFullListController.add(
              OddsFullListData(
                eventId: info.$1,
                marketId: info.$2,
                validPoints: entry.value,
              ),
            );
          }
        }
        return;
      }
    }

    // Legacy format fallback
    final oddsData = OddsUpdateData.fromMessage(wsMessage);
    if (oddsData.selectionId.isNotEmpty) {
      _logger.d(
        '$name: Odds update - selectionId: ${oddsData.selectionId}, odds: ${oddsData.odds}',
      );
      _oddsController.add(oddsData);
    }
  }

  /// Extract and emit odds from kafka item
  ///
  /// Processes ALL market IDs (not just main 6) to support bet detail screen
  /// Also collects valid points into [validPointsPerMarket] for FULL LIST behavior
  /// Key is "eventId_marketId" to track per-market validity
  void _emitOddsFromKafkaItem(
    Map<String, dynamic> item,
    Map<String, Set<String>> validPointsPerMarket,
    Map<String, (int, int)> marketInfo,
  ) {
    final eventId = item['eventId'] as int? ?? 0;
    final marketIdInt =
        item['domainMarketId'] as int? ?? item['marketId'] as int? ?? 0;
    final marketId = marketIdInt.toString();
    final odds = item['odds'] as Map<String, dynamic>?;

    if (odds == null) return;

    final points = odds['points'] as String? ?? '';
    final selectionHomeId = odds['selectionHomeId'] as String? ?? '';
    final selectionAwayId = odds['selectionAwayId'] as String? ?? '';
    final selectionDrawId = odds['selectionDrawId'] as String?;

    final oddsHome = odds['oddsHome'] as Map<String, dynamic>?;
    final oddsAway = odds['oddsAway'] as Map<String, dynamic>?;
    final oddsDraw = odds['oddsDraw'] as Map<String, dynamic>?;

    // Create market key for FULL LIST tracking
    final marketKey = '${eventId}_$marketIdInt';
    validPointsPerMarket[marketKey] ??= <String>{};
    marketInfo[marketKey] = (eventId, marketIdInt);

    // Add points to valid set for this market
    if (points.isNotEmpty) {
      validPointsPerMarket[marketKey]!.add(points);
    }

    // Emit home odds with all styles
    if (selectionHomeId.isNotEmpty && oddsHome != null) {
      final oddsValues = OddsStyleValues.fromJson(oddsHome);
      final decimalOdds = oddsHome['decimal']?.toString() ?? '0';
      final trueOdds = double.tryParse(oddsHome['trueOdds']?.toString() ?? '');

      // Debug: Log raw odds data (uncomment to debug)
      // _logger.d('$name: oddsHome raw: $oddsHome');
      // _logger.d('$name: oddsValues parsed: $oddsValues');

      _oddsController.add(
        OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionHomeId,
          odds: decimalOdds,
          trueOdds: trueOdds,
          oddsValues: oddsValues,
        ),
      );
    }

    // Emit away odds with all styles
    if (selectionAwayId.isNotEmpty && oddsAway != null) {
      final oddsValues = OddsStyleValues.fromJson(oddsAway);
      final decimalOdds = oddsAway['decimal']?.toString() ?? '0';
      final trueOdds = double.tryParse(oddsAway['trueOdds']?.toString() ?? '');
      _oddsController.add(
        OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionAwayId,
          odds: decimalOdds,
          trueOdds: trueOdds,
          oddsValues: oddsValues,
        ),
      );
    }

    // Emit draw odds with all styles (for 1X2 markets)
    if (selectionDrawId != null &&
        selectionDrawId.isNotEmpty &&
        oddsDraw != null) {
      final oddsValues = OddsStyleValues.fromJson(oddsDraw);
      final decimalOdds = oddsDraw['decimal']?.toString() ?? '0';
      final trueOdds = double.tryParse(oddsDraw['trueOdds']?.toString() ?? '');
      _oddsController.add(
        OddsUpdateData(
          eventId: eventId,
          marketId: marketId,
          selectionId: selectionDrawId,
          odds: decimalOdds,
          trueOdds: trueOdds,
          oddsValues: oddsValues,
        ),
      );
    }
  }

  @override
  void onDisconnected() {
    _logger.w('$name: Disconnected');
  }

  @override
  void onError(dynamic error) {
    _logger.e('$name: Error: $error');
  }

  // ===== PRIVATE METHODS =====

  /// Handle batched messages from the processor
  ///
  /// Called by WsMessageProcessor after rate limiting and filtering.
  /// Collects all state-affecting updates into a single WsBatchUpdate
  /// to enable 1 state update per tick instead of N.
  void _handleBatchedMessages(List<WsQueuedMessage> messages) {
    final batchBuilder = WsBatchUpdateBuilder();

    for (final queuedMessage in messages) {
      final wsMessage = queuedMessage.message;

      // Emit typed message for backward compatibility
      _typedMessageController.add(wsMessage);

      // Collect state-affecting updates into batch
      // Non-state-affecting updates are dispatched directly
      _collectOrDispatchMessage(wsMessage, batchBuilder);
    }

    // Emit batch update if there are any state changes
    if (batchBuilder.isNotEmpty) {
      _batchUpdateController.add(batchBuilder.build());
    }
  }

  /// Collect state-affecting messages into batch, dispatch others directly
  ///
  /// State-affecting messages (collected for batching):
  /// - odds_up/odds_ins → oddsFullListUpdates
  /// - event_ins → eventInserts
  /// - event_rm → eventRemoves
  /// - league_ins → leagueInserts
  /// - market_up → marketStatusUpdates
  ///
  /// Non-state-affecting (dispatched directly):
  /// - balance_up, score_up, etc.
  void _collectOrDispatchMessage(
    WsMessage wsMessage,
    WsBatchUpdateBuilder builder,
  ) {
    switch (wsMessage.type) {
      // Odds messages - collect for batching
      case WsMessageType.oddsUpdate:
      case WsMessageType.oddsInsert:
        _collectOddsUpdate(wsMessage, builder);
        break;
      case WsMessageType.oddsRemove:
        _handleOddsRemove(wsMessage);
        break;

      // Balance messages - dispatch directly (different provider)
      case WsMessageType.balanceUpdate:
        _balanceController.add(BalanceUpdateData.fromMessage(wsMessage));
        break;

      // Score messages - dispatch directly
      case WsMessageType.scoreUpdate:
        final batchScoreData = ScoreUpdateData.fromMessage(wsMessage);
        // _logger.d('$name: [BATCH] 📤 Emitting score update: eventId=${batchScoreData.eventId}, home=${batchScoreData.home}, away=${batchScoreData.away}');
        _scoreController.add(batchScoreData);
        break;

      // Event status updates (event_up) - already via typed stream
      case WsMessageType.eventStatus:
        break;

      // Event insert - collect for batching
      case WsMessageType.eventInsert:
        _collectEventInsert(wsMessage, builder);
        break;

      // Event remove - collect for batching
      case WsMessageType.eventRemove:
        _collectEventRemove(wsMessage, builder);
        break;

      // Market status - collect for batching
      case WsMessageType.marketStatus:
        _collectMarketStatus(wsMessage, builder);
        break;

      // League insert - collect for batching
      case WsMessageType.leagueInsert:
        _collectLeagueInsert(wsMessage, builder);
        break;

      default:
        break;
    }
  }

  // ===== BATCH COLLECTION METHODS =====

  /// Collect odds update into batch (for batched state updates)
  /// Also emits to _oddsController for popup/bet detail (not state-affecting)
  void _collectOddsUpdate(WsMessage wsMessage, WsBatchUpdateBuilder builder) {
    final data = wsMessage.data;

    final d = data['d'] as Map<String, dynamic>?;
    if (d != null) {
      final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
      if (kafkaOddsList != null) {
        // Track valid points per market for FULL LIST behavior
        final validPointsPerMarket = <String, Set<String>>{};
        final marketInfo = <String, (int, int)>{};

        for (final item in kafkaOddsList) {
          if (item is Map<String, dynamic>) {
            // Emit to _oddsController for popup/bet detail (not batched)
            _emitOddsFromKafkaItem(item, validPointsPerMarket, marketInfo);
          }
        }

        // Collect full list data into batch
        for (final entry in validPointsPerMarket.entries) {
          final info = marketInfo[entry.key];
          if (info != null) {
            builder.addOddsFullList(
              OddsFullListData(
                eventId: info.$1,
                marketId: info.$2,
                validPoints: entry.value,
              ),
            );
          }
        }
        return;
      }
    }

    // Legacy format - emit directly to odds controller
    final oddsData = OddsUpdateData.fromMessage(wsMessage);
    if (oddsData.selectionId.isNotEmpty) {
      _oddsController.add(oddsData);
    }
  }

  /// Collect event insert into batch
  void _collectEventInsert(WsMessage wsMessage, WsBatchUpdateBuilder builder) {
    final data = EventInsertData.fromMessage(wsMessage);
    if (data.eventId == 0) return;
    builder.addEventInsert(data);
  }

  /// Collect event remove into batch
  void _collectEventRemove(WsMessage wsMessage, WsBatchUpdateBuilder builder) {
    final data = EventRemoveData.fromMessage(wsMessage);
    if (data.eventId == 0) return;
    builder.addEventRemove(data);
  }

  /// Collect league insert into batch
  void _collectLeagueInsert(WsMessage wsMessage, WsBatchUpdateBuilder builder) {
    final data = LeagueInsertData.fromMessage(wsMessage);
    if (data.leagueId == 0) return;
    builder.addLeagueInsert(data);
  }

  /// Collect market status into batch
  void _collectMarketStatus(WsMessage wsMessage, WsBatchUpdateBuilder builder) {
    final data = MarketStatusData.fromMessage(wsMessage);
    if (data.eventId == 0 || data.marketId == 0) return;
    builder.addMarketStatus(data);
  }

  /// Dispatch message to specific streams based on type
  void _dispatchMessage(WsMessage wsMessage) {
    switch (wsMessage.type) {
      // Odds messages
      case WsMessageType.oddsUpdate:
      case WsMessageType.oddsInsert:
        _handleOddsUpdate(wsMessage);
        break;
      case WsMessageType.oddsRemove:
        _handleOddsRemove(wsMessage);
        break;

      // Balance messages
      case WsMessageType.balanceUpdate:
        _balanceController.add(BalanceUpdateData.fromMessage(wsMessage));
        break;

      // Score messages
      case WsMessageType.scoreUpdate:
        final scoreData = ScoreUpdateData.fromMessage(wsMessage);
        // _logger.d('$name: [MAIN] 📤 Emitting score update: eventId=${scoreData.eventId}, home=${scoreData.home}, away=${scoreData.away}');
        _scoreController.add(scoreData);
        break;

      // Event status updates (event_up)
      case WsMessageType.eventStatus:
        // Already emitted via _typedMessageController
        break;

      // Event insert (event_ins) - new event added
      case WsMessageType.eventInsert:
        _handleEventInsert(wsMessage);
        break;

      // Event remove (event_rm) - event finished/removed
      case WsMessageType.eventRemove:
        _handleEventRemove(wsMessage);
        break;

      // Market status (market_up) - market suspended/active
      case WsMessageType.marketStatus:
        _handleMarketStatus(wsMessage);
        break;

      // League insert (league_ins) - new league added
      case WsMessageType.leagueInsert:
        _handleLeagueInsert(wsMessage);
        break;

      default:
        break;
    }
  }

  void _sendSportSubscription(int sportId) {
    send('SUB:s:$sportId');
    _logger.d('$name: Subscribed to sport $sportId');
  }

  void _sendEventSubscription(int eventId) {
    send('SUB:e:$eventId');
    _logger.d('$name: Subscribed to event $eventId');
  }

  /// Handle event insert message (event_ins)
  void _handleEventInsert(WsMessage wsMessage) {
    final data = EventInsertData.fromMessage(wsMessage);
    if (data.eventId == 0) return;

    _logger.d('$name: Event inserted - $data');
    _eventInsertController.add(data);
  }

  /// Handle event remove message (event_rm)
  void _handleEventRemove(WsMessage wsMessage) {
    final data = EventRemoveData.fromMessage(wsMessage);
    if (data.eventId == 0) return;

    _logger.d('$name: Event removed - $data');
    _eventRemoveController.add(data);
  }

  /// Handle league insert message (league_ins)
  void _handleLeagueInsert(WsMessage wsMessage) {
    final data = LeagueInsertData.fromMessage(wsMessage);
    if (data.leagueId == 0) return;

    _logger.d('$name: League inserted - $data');
    _leagueInsertController.add(data);
  }

  /// Handle market status message (market_up)
  void _handleMarketStatus(WsMessage wsMessage) {
    final data = MarketStatusData.fromMessage(wsMessage);
    if (data.eventId == 0 || data.marketId == 0) return;

    _logger.d('$name: Market status - $data');
    _marketStatusController.add(data);
  }
}
