import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/core/services/models/bet_model.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/repositories/betting_repository.dart';
import 'package:co_caro_flame/s88/core/services/websocket/message_queue/message_queue.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_manager.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';

/// Betting Popup State
///
/// Manages all state for the betting popup including:
/// - Bet amount and calculations
/// - Min/max stake from calculateBets API
/// - Loading states
/// - Error handling
/// - WebSocket real-time updates
class BettingPopupState {
  /// The betting data (odds, event, market info)
  final BettingPopupData? bettingData;

  /// User input amount (in 1K units, e.g., 100 = 100,000 VND)
  /// For Malay/Indo negative odds, this represents "amount to win"
  final String betAmount;

  /// Min stake allowed (from calculateBets API, in 1K units)
  final int minStake;

  /// Max stake allowed (from calculateBets API, in 1K units)
  final int maxStake;

  /// Max payout allowed (from calculateBets API, in 1K units)
  final int maxPayout;

  /// Is calculateBets API call in progress
  final bool isCalculating;

  /// Is placeBets API call in progress
  final bool isPlacingBet;

  /// Current error message
  final String? error;

  /// Error code from API
  final int? errorCode;

  /// Updated odds value from WebSocket (if changed)
  final double? updatedOdds;

  /// Is popup closed
  final bool isClosed;

  const BettingPopupState({
    this.bettingData,
    this.betAmount = '0',
    this.minStake = 0,
    this.maxStake = 0,
    this.maxPayout = 0,
    this.isCalculating = false,
    this.isPlacingBet = false,
    this.error,
    this.errorCode,
    this.updatedOdds,
    this.isClosed = false,
  });

  BettingPopupState copyWith({
    BettingPopupData? bettingData,
    String? betAmount,
    int? minStake,
    int? maxStake,
    int? maxPayout,
    bool? isCalculating,
    bool? isPlacingBet,
    String? error,
    int? errorCode,
    double? updatedOdds,
    bool? isClosed,
    bool clearError = false,
  }) {
    return BettingPopupState(
      bettingData: bettingData ?? this.bettingData,
      betAmount: betAmount ?? this.betAmount,
      minStake: minStake ?? this.minStake,
      maxStake: maxStake ?? this.maxStake,
      maxPayout: maxPayout ?? this.maxPayout,
      isCalculating: isCalculating ?? this.isCalculating,
      isPlacingBet: isPlacingBet ?? this.isPlacingBet,
      error: clearError ? null : (error ?? this.error),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      updatedOdds: updatedOdds ?? this.updatedOdds,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  /// Get current odds value (from WebSocket update or original)
  double getCurrentOdds() =>
      updatedOdds ?? bettingData?.getSelectedOddsValue() ?? 0.0;

  /// Get display odds string
  String getDisplayOdds() {
    final odds = getCurrentOdds();
    if (odds <= 0 || odds == -100) return '-';
    return odds.toStringAsFixed(2);
  }

  /// Calculate actual stake based on bet amount
  /// For Malay/Indo negative, betAmount = "amount to win", returns actual stake
  /// For others, betAmount = stake
  int getActualStake() {
    // betAmount may include thousands separators from UI, strip commas before parsing
    final amount = int.tryParse(betAmount.replaceAll(',', '')) ?? 0;
    if (amount == 0) return 0;

    final oddsStyle = bettingData?.oddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    // Malay negative: user enters "amount to win"
    if (oddsStyle == OddsStyle.malay && oddsValue < 0) {
      return (amount * oddsValue.abs()).floor();
    }

    // Indo negative: user enters "amount to win"
    if (oddsStyle == OddsStyle.indo && oddsValue < -1) {
      return (amount * oddsValue.abs()).floor();
    }

    // For other styles, betAmount = stake
    return amount;
  }

  /// Calculate total winnings
  int calculateWinnings() {
    // betAmount may include thousands separators from UI, strip commas before parsing
    final amount = int.tryParse(betAmount.replaceAll(',', '')) ?? 0;
    if (amount == 0) return 0;

    final oddsStyle = bettingData?.oddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    // Malay negative: user enters "amount to win"
    if (oddsStyle == OddsStyle.malay && oddsValue < 0) {
      final actualStake = (amount * oddsValue.abs()).floor();
      return amount + actualStake;
    }

    // Indo negative: user enters "amount to win"
    if (oddsStyle == OddsStyle.indo && oddsValue < -1) {
      final actualStake = (amount * oddsValue.abs()).floor();
      return amount + actualStake;
    }

    // For other styles
    return _calculateNormalWinnings(amount, oddsValue, oddsStyle);
  }

  int _calculateNormalWinnings(int stake, double odds, OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return (stake * odds).floor();
      case OddsStyle.malay:
        if (odds >= 0) {
          return (stake * (1 + odds)).floor();
        } else {
          // Should not reach here (handled above)
          return stake;
        }
      case OddsStyle.indo:
        if (odds >= 0) {
          return (stake * (1 + odds)).floor();
        } else {
          // Should not reach here (handled above)
          return stake;
        }
      case OddsStyle.hongKong:
        return (stake * (1 + odds)).floor();
    }
  }

  /// Get placeholder text for money input
  String getInputPlaceholder() {
    final oddsStyle = bettingData?.oddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    if ((oddsStyle == OddsStyle.malay && oddsValue < 0) ||
        (oddsStyle == OddsStyle.indo && oddsValue < -1)) {
      return 'Nhập mức thắng';
    }

    return 'Nhập tiền cược';
  }

  /// Get cost label text
  String getCostLabel() {
    final oddsStyle = bettingData?.oddsStyle ?? OddsStyle.decimal;
    final oddsValue = getCurrentOdds();

    if ((oddsStyle == OddsStyle.malay && oddsValue < 0) ||
        (oddsStyle == OddsStyle.indo && oddsValue < -1)) {
      return 'Số Tiền Cược';
    }

    return 'Tổng tiền cược';
  }
}

/// Betting Popup Notifier
///
/// Manages betting popup state and handles:
/// - calculateBets API call on initialization
/// - placeBets API call
/// - WebSocket subscriptions for real-time updates
/// - Odds changes, market removals, event removals
class BettingPopupNotifier extends StateNotifier<BettingPopupState> {
  final Ref _ref;
  final SbHttpManager _httpManager = SbHttpManager.instance;
  final WebSocketManager _wsManager = WebSocketManager.instance;
  final BettingRepository _repository = BettingRepositoryImpl();

  StreamSubscription<WsMessage>? _wsSubscription;
  StreamSubscription<WsQueuedMessage>? _popupPrioritySubscription;
  Timer? _debounceTimer;

  BettingPopupNotifier(this._ref) : super(const BettingPopupState());

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _popupPrioritySubscription?.cancel();
    _debounceTimer?.cancel();

    // Unregister popup from WebSocket processor
    _wsManager.sportbook.unregisterPopup();

    super.dispose();
  }

  /// Reset state for new popup - MUST be called synchronously before build
  /// This prevents the popup from closing immediately due to stale isClosed=true
  void resetForNewPopup(BettingPopupData data) {
    // Cancel any existing subscriptions from previous popup
    _wsSubscription?.cancel();
    _popupPrioritySubscription?.cancel();
    _debounceTimer?.cancel();

    // Unregister any previous popup
    _wsManager.sportbook.unregisterPopup();

    // Reset ALL state including isClosed to ensure popup stays open
    state = const BettingPopupState().copyWith(
      bettingData: data,
      betAmount: '0',
    );
  }

  /// Initialize async operations (WebSocket + API)
  /// Called after resetForNewPopup in a microtask
  Future<void> initializeAsync() async {
    // Subscribe to WebSocket updates
    _subscribeToWebSocket();

    // Call calculateBets API
    await calculateBets();
  }

  /// Initialize popup with betting data (legacy - combines reset + async)
  ///
  /// Called when popup opens, automatically calls calculateBets API
  Future<void> initialize(BettingPopupData data) async {
    resetForNewPopup(data);
    await initializeAsync();
  }

  /// Subscribe to WebSocket updates for this bet
  void _subscribeToWebSocket() {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    final sportbookWs = _wsManager.sportbook;
    final eventId = bettingData.eventData.eventId;

    // Subscribe to event updates
    sportbookWs.subscribeEvent(eventId);

    // Register popup for priority message forwarding (bypasses queue) when processor is ready
    if (sportbookWs.isProcessorInitialized) {
      sportbookWs.registerPopup(eventId);

      // Listen to priority popup messages (immediate, bypasses queue)
      _popupPrioritySubscription = sportbookWs.popupMessageStream.listen((
        queuedMessage,
      ) {
        _handleWebSocketMessage(queuedMessage.message);
      });
    }

    // Also listen to normal WebSocket messages as fallback
    // (in case processor is not initialized)
    _wsSubscription = sportbookWs.typedMessageStream.listen((message) {
      _handleWebSocketMessage(message);
    });
  }

  /// Handle WebSocket messages
  void _handleWebSocketMessage(WsMessage message) {
    final bettingData = state.bettingData;
    if (bettingData == null || state.isClosed) return;

    switch (message.type) {
      case WsMessageType.oddsUpdate:
        _handleOddsUpdate(message);
        break;
      case WsMessageType.marketStatus:
        _handleMarketUpdate(message);
        break;
      case WsMessageType.eventStatus:
        _handleEventUpdate(message);
        break;
      default:
        break;
    }
  }

  /// Handle odds update from WebSocket
  void _handleOddsUpdate(WsMessage message) {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    final data = message.data;
    final d = data['d'] as Map<String, dynamic>?;

    if (d != null) {
      final kafkaOddsList = d['kafkaOddsList'] as List<dynamic>?;
      if (kafkaOddsList == null) return;

      for (final item in kafkaOddsList) {
        if (item is! Map<String, dynamic>) continue;

        // Parse values that might come as String or int
        final eventId = _parseToInt(item['eventId']);
        final marketId = _parseToInt(item['marketId']);
        final oddsMap = item['odds'] as Map<String, dynamic>?;

        if (eventId != bettingData.eventData.eventId ||
            marketId != bettingData.marketData.marketId) {
          continue;
        }

        if (oddsMap == null) continue;

        final newPoints = oddsMap['points'] as String?;
        final currentPoints = bettingData.oddsData.points;

        // CHECK 1: Points changed -> close popup
        if (newPoints != null && newPoints != currentPoints) {
          _closePopupWithMessage('Kèo đã thay đổi!');
          return;
        }

        // Update odds value
        final newOddsValue = _getOddsValueFromUpdate(
          oddsMap,
          bettingData.oddsType,
        );
        if (newOddsValue != null) {
          state = state.copyWith(updatedOdds: newOddsValue);
        }
      }
    }
  }

  /// Get odds value from WebSocket update based on odds type
  double? _getOddsValueFromUpdate(
    Map<String, dynamic> oddsMap,
    OddsType oddsType,
  ) {
    switch (oddsType) {
      case OddsType.home:
        final oddsHome = oddsMap['oddsHome'];
        return oddsHome is num ? oddsHome.toDouble() : null;
      case OddsType.away:
        final oddsAway = oddsMap['oddsAway'];
        return oddsAway is num ? oddsAway.toDouble() : null;
      case OddsType.draw:
        final oddsDraw = oddsMap['oddsDraw'];
        return oddsDraw is num ? oddsDraw.toDouble() : null;
      default:
        return null;
    }
  }

  /// Handle market update from WebSocket
  void _handleMarketUpdate(WsMessage message) {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    final data = message.data;
    final d = data['d'] as Map<String, dynamic>?;

    if (d != null) {
      // Parse values that might come as String or int
      final eventId = _parseToInt(d['eventId']);
      final marketId = _parseToInt(d['domainMarketId']);
      final status = _parseToInt(d['status']);

      if (eventId == bettingData.eventData.eventId &&
          marketId == bettingData.marketData.marketId) {
        // CHECK 3: Market inactive -> close popup
        if (status != 1) {
          _closePopupWithMessage('Market không khả dụng!');
        }
      }
    }
  }

  /// Parse dynamic value to int (handles both String and int)
  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Handle event update from WebSocket
  void _handleEventUpdate(WsMessage message) {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    final data = message.data;
    final d = data['d'] as Map<String, dynamic>?;

    if (d != null) {
      // Parse eventId that might come as String or int
      final eventId = _parseToInt(d['eventId']);

      // CHECK 4: Event removed -> close popup
      if (eventId == bettingData.eventData.eventId) {
        final eventStatus = d['status'];
        if (eventStatus == 'removed' || eventStatus == 'finished') {
          _closePopupWithMessage('Trận đấu đã kết thúc!');
        }
      }
    }
  }

  /// Close popup with error message
  void _closePopupWithMessage(String message) {
    state = state.copyWith(error: message, isClosed: true);
  }

  /// Update bet amount
  void updateBetAmount(String amount) {
    state = state.copyWith(betAmount: amount, clearError: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Call calculateBets API
  Future<void> calculateBets() async {
    final bettingData = state.bettingData;
    if (bettingData == null) return;

    state = state.copyWith(isCalculating: true, clearError: true);

    try {
      final requestBody = _buildCalculateBetsRequest(bettingData);
      final response = await _httpManager.calculateBets(requestBody);

      // Check for errors
      final errorCode = response['errorCode'] as int?;
      if (errorCode != null && errorCode != 0) {
        state = state.copyWith(
          isCalculating: false,
          error: bettingApiErrorDisplayMessage(
            errorCode,
            serverMessage: response['message'] as String?,
            fallback: bettingApiCalculateBetFailureFallback,
          ),
          errorCode: errorCode,
        );
        return;
      }

      // Parse response - values may come as String or num
      final minStake = _parseToInt(response['minStake']) ?? 0;
      final maxStake = _parseToInt(response['maxStake']) ?? 0;
      final maxPayout = _parseToInt(response['maxPayout']) ?? 0;
      final displayOdds = response['displayOdds'] as String?;

      // Update odds if changed
      double? updatedOdds;
      if (displayOdds != null) {
        updatedOdds = double.tryParse(displayOdds);
      }

      state = state.copyWith(
        isCalculating: false,
        minStake: minStake,
        maxStake: maxStake,
        maxPayout: maxPayout,
        updatedOdds: updatedOdds,
      );
    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        error: 'Lỗi kết nối: ${e.toString()}',
      );
    }
  }

  /// Build calculateBets request body
  Map<String, dynamic> _buildCalculateBetsRequest(BettingPopupData data) {
    return {
      'leagueId': data.getLeagueIdString(),
      'matchTime': data.getMatchTimeISO(),
      'isLive': data.isLive,
      'offerId': data.getOfferId(),
      'selectionId': data.getSelectionId(),
      'displayOdds': data.getDisplayOdds(),
      'oddsStyle': _getOddsStyleCode(data.oddsStyle),
    };
  }

  /// Get odds style code for API
  String _getOddsStyleCode(OddsStyle style) {
    switch (style) {
      case OddsStyle.decimal:
        return 'de';
      case OddsStyle.malay:
        return 'ma';
      case OddsStyle.indo:
        return 'in';
      case OddsStyle.hongKong:
        return 'hk';
    }
  }

  /// Place bet using BettingRepository (same as parlay single bet)
  Future<bool> placeBet() async {
    final bettingData = state.bettingData;
    if (bettingData == null) return false;

    // Validate bet amount
    final actualStake = state.getActualStake();
    if (actualStake < state.minStake * 1000) {
      state = state.copyWith(
        error: 'Số tiền cược tối thiểu: ${state.minStake}',
      );
      return false;
    }

    if (actualStake > state.maxStake * 1000) {
      state = state.copyWith(error: 'Số tiền cược tối đa: ${state.maxStake}');
      return false;
    }

    state = state.copyWith(isPlacingBet: true, clearError: true);

    try {
      // Check if this is a special outright bet (no away team)
      final isSpecialOutright =
          bettingData.eventData.awayName.isEmpty &&
          bettingData.eventData.homeName.isNotEmpty &&
          bettingData.eventData.eventName != null &&
          bettingData.eventData.eventName!.isNotEmpty;

      // Build eventName - use eventName for special outright bets, otherwise use "Home vs Away" format
      final eventName = isSpecialOutright
          ? bettingData.eventData.eventName!
          : '${bettingData.getHomeName()} vs ${bettingData.getAwayName()}';

      // Build selection using BetSelectionModel (same as parlay single bet)
      // Note: actualStake is already in the correct unit (1K units), no need to multiply
      final selection = BetSelectionModel(
        eventId: bettingData.eventData.eventId,
        eventName: eventName,
        selectionId: bettingData.getSelectionId() ?? '',
        selectionName: bettingData.getSelectionName(),
        offerId: bettingData.getOfferId() ?? '',
        displayOdds: state.getCurrentOdds().toStringAsFixed(2),
        oddsStyle: _getOddsStyleCode(bettingData.oddsStyle),
        cls: _getCls(bettingData),
        leagueId: bettingData.getLeagueIdString(),
        matchTime: bettingData.getMatchTimeISO(),
        isLive: bettingData.isLive,
        sportId: 1,
        homeScore: bettingData.eventData.homeScore,
        awayScore: bettingData.eventData.awayScore,
        stake: actualStake.toDouble(),
        winnings: state.calculateWinnings().toDouble(),
      );

      final request = PlaceBetRequest(
        matchId: bettingData.eventData.eventId,
        selections: [selection],
        singleBet: true,
      );

      final response = await _repository.placeBet(request);

      if (response.isSuccess) {
        state = state.copyWith(isPlacingBet: false, isClosed: true);
        return true;
      } else {
        state = state.copyWith(
          isPlacingBet: false,
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiPlaceBetFailureFallback,
          ),
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isPlacingBet: false,
        error: bettingApiErrorDisplayMessage(
          null,
          fallback: bettingApiPlaceBetFailureFallback,
        ),
      );
      return false;
    }
  }

  /// Get cls format for placeBets request (same logic as SingleBetData.cls)
  String _getCls(BettingPopupData data) {
    // For special outright bets (marketId == 0), use selectionCode from points
    // selectionCode is stored in points field when creating BettingPopupData from SpecialOutrightSelection
    if (data.marketData.marketId == 0) {
      final selectionCode = data.oddsData.points;
      // Return selectionCode directly (e.g., "155")
      return selectionCode.isNotEmpty ? selectionCode : '';
    }

    // For normal bets, use points logic
    final points = data.oddsData.points;
    final oddsType = data.oddsType;
    final pointsNumber = double.tryParse(points) ?? 0;
    final pointsAbs = pointsNumber.abs();

    double clsValue = pointsAbs;

    // For Handicap markets, apply negative sign based on odds type
    if (MarketHelper.isHandicap(data.marketData.marketId)) {
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

  /// Check if error is money-related (user can fix by changing stake)
  /// Money errors: show toast only, don't remove bet
  /// Other errors: show toast and remove bet from local
  static bool isMoneyRelatedError(int? errorCode) {
    return bettingApiErrorIsMoneyRelated(errorCode);
  }
}

/// Betting Popup Provider
///
/// Provides access to betting popup state and notifier
final bettingPopupProvider =
    StateNotifierProvider<BettingPopupNotifier, BettingPopupState>((ref) {
      return BettingPopupNotifier(ref);
    });
