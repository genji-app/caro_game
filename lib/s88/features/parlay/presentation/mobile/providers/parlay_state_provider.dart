import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/models/bet_model.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/user_provider/user_provider.dart';
import 'package:co_caro_flame/s88/core/services/repositories/betting_repository.dart';
import 'package:co_caro_flame/s88/core/services/storage/parlay_storage.dart';
import 'package:co_caro_flame/s88/core/services/websocket/betslip_subscription_manager.dart';
import 'package:co_caro_flame/s88/core/services/websocket/subscription_manager.dart';
import 'package:co_caro_flame/s88/features/parlay/domain/models/single_bet_data.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';

enum ParlayTab { single, combo, multi }

class ParlayState {
  final ParlayTab tab;
  final int stake;
  final double price;
  final double totalOdds;
  final int minStake;
  final int maxStake;
  final int comboCount;
  final List<ParlayMultiBet> multiBets;

  /// Single bets list - holds multiple single bet selections
  final List<SingleBetData> singleBets;

  /// Combo bets list - holds selections for parlay bet
  final List<SingleBetData> comboBets;

  /// Min/max matches for parlay (from API)
  final int minMatches;
  final int maxMatches;

  /// Is calculating combo parlay in progress
  final bool isCalculatingCombo;

  /// Is placing bet in progress
  final bool isPlacingBet;

  /// Last place bet result
  final PlaceBetResponse? lastPlaceBetResult;

  /// Error message
  final String? error;

  /// Count of odds that have changed (for notification)
  final int changedOddsCount;

  /// Whether to show odds changed notification
  final bool showOddsChangedNotification;

  const ParlayState({
    this.tab = ParlayTab.single,
    this.stake = 0,
    this.price = 0.95,
    this.totalOdds = 1.0,
    this.minStake = 0,
    this.maxStake = 0,
    this.comboCount = 5,
    this.multiBets = ParlayMultiBet.defaultBets,
    this.singleBets = const [],
    this.comboBets = const [],
    this.minMatches = 2,
    this.maxMatches = 10,
    this.isCalculatingCombo = false,
    this.isPlacingBet = false,
    this.lastPlaceBetResult,
    this.error,
    this.changedOddsCount = 0,
    this.showOddsChangedNotification = false,
  });

  /// Get total bet amount based on current tab
  /// Note: Skip disabled bets from total calculation
  double get totalBet {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.fold<double>(
          0,
          (sum, bet) => bet.isDisabled ? sum : sum + bet.stake.toDouble(),
        );
      case ParlayTab.multi:
        return multiBets.fold<double>(
          0,
          (sum, bet) => sum + bet.stake.toDouble(),
        );
      case ParlayTab.combo:
        return stake.toDouble();
    }
  }

  /// Get potential winnings based on current tab
  double get potentialWin {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.fold<double>(
          0,
          (sum, bet) => sum + bet.potentialWinnings,
        );
      case ParlayTab.multi:
        return multiBets.fold<double>(
          0,
          (sum, bet) => sum + (bet.stake * bet.odd),
        );
      case ParlayTab.combo:
        return stake * totalOdds;
    }
  }

  /// Check if can place bet based on current tab
  bool get canPlaceBet {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.any((bet) => bet.canPlaceBet);
      case ParlayTab.multi:
        return multiBets.any((bet) => bet.stake > 0);
      case ParlayTab.combo:
        // Use validComboBetsCount to exclude disabled bets
        final validCount = comboBets.where((bet) => !bet.isDisabled).length;
        return validCount >= minMatches &&
            validCount <= maxMatches &&
            stake > 0 &&
            stake >= minStake &&
            stake <= maxStake &&
            !isCalculatingCombo;
    }
  }

  /// Get count of valid (non-disabled) combo bets
  int get validComboBetsCount =>
      comboBets.where((bet) => !bet.isDisabled).length;

  /// Check if combo has enough valid matches (excluding disabled bets)
  bool get hasEnoughMatches => validComboBetsCount >= minMatches;

  /// Get combo bets count (total, including disabled)
  int get comboBetsCount => comboBets.length;

  /// Check if a VALID bet exists in combo (by eventId)
  /// Excludes disabled bets - if a bet is disabled, user can add another selection from same event
  bool isBetInCombo(int eventId) => comboBets.any(
    (bet) => !bet.isDisabled && bet.eventData.eventId == eventId,
  );

  /// Check if a specific VALID selection is in combo (by selectionId)
  /// Excludes disabled bets
  bool isSelectionInCombo(String? selectionId) {
    if (selectionId == null) return false;
    return comboBets.any(
      (bet) => !bet.isDisabled && bet.selectionId == selectionId,
    );
  }

  /// Check if event has another VALID selection in combo (not this selectionId)
  /// Excludes disabled bets - if a bet is disabled, user can add another selection from same event
  bool hasOtherSelectionInCombo(int eventId, String? selectionId) {
    return comboBets.any(
      (bet) =>
          !bet.isDisabled &&
          bet.eventData.eventId == eventId &&
          bet.selectionId != selectionId,
    );
  }

  /// Get current min stake based on tab (use first single bet or default)
  int get currentMinStake {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.isNotEmpty
            ? singleBets.first.minStakeActual
            : minStake;
      default:
        return minStake;
    }
  }

  /// Get current max stake based on tab (use first single bet or default)
  int get currentMaxStake {
    switch (tab) {
      case ParlayTab.single:
        return singleBets.isNotEmpty
            ? singleBets.first.maxStakeActual
            : maxStake;
      default:
        return maxStake;
    }
  }

  /// Check if has any single bets
  bool get hasSingleBets => singleBets.isNotEmpty;

  /// Get count of single bets
  int get singleBetsCount => singleBets.length;

  ParlayState copyWith({
    ParlayTab? tab,
    int? stake,
    double? price,
    double? totalOdds,
    int? minStake,
    int? maxStake,
    int? comboCount,
    List<ParlayMultiBet>? multiBets,
    List<SingleBetData>? singleBets,
    List<SingleBetData>? comboBets,
    int? minMatches,
    int? maxMatches,
    bool? isCalculatingCombo,
    bool? isPlacingBet,
    PlaceBetResponse? lastPlaceBetResult,
    String? error,
    bool clearError = false,
    int? changedOddsCount,
    bool? showOddsChangedNotification,
  }) => ParlayState(
    tab: tab ?? this.tab,
    stake: stake ?? this.stake,
    price: price ?? this.price,
    totalOdds: totalOdds ?? this.totalOdds,
    minStake: minStake ?? this.minStake,
    maxStake: maxStake ?? this.maxStake,
    comboCount: comboCount ?? this.comboCount,
    multiBets: multiBets ?? this.multiBets,
    singleBets: singleBets ?? this.singleBets,
    comboBets: comboBets ?? this.comboBets,
    minMatches: minMatches ?? this.minMatches,
    maxMatches: maxMatches ?? this.maxMatches,
    isCalculatingCombo: isCalculatingCombo ?? this.isCalculatingCombo,
    isPlacingBet: isPlacingBet ?? this.isPlacingBet,
    lastPlaceBetResult: lastPlaceBetResult ?? this.lastPlaceBetResult,
    error: clearError ? null : error,
    changedOddsCount: changedOddsCount ?? this.changedOddsCount,
    showOddsChangedNotification:
        showOddsChangedNotification ?? this.showOddsChangedNotification,
  );
}

class ParlayStateNotifier extends StateNotifier<ParlayState> {
  final BettingRepository _repository;
  final Ref _ref;
  final ParlayStorage _storage = ParlayStorage.instance;

  /// Subscriptions for library streams
  StreamSubscription<socket.OddsUpdateData>? _oddsSubscription;
  StreamSubscription<socket.ScoreUpdateData>? _scoreSubscription;

  /// Timer for debouncing odds change notification
  Timer? _oddsChangedDebounceTimer;

  /// Set of unique bet selection IDs that changed (before debounce completes)
  final Set<String> _pendingChangedBetIds = {};

  ParlayStateNotifier(this._repository, this._ref)
    : super(const ParlayState()) {
    _subscribeToLibrary();
    _loadFromStorage();
  }

  @override
  void dispose() {
    _oddsSubscription?.cancel();
    _scoreSubscription?.cancel();
    _oddsChangedDebounceTimer?.cancel();
    super.dispose();
  }

  // ===== Subscription Management =====

  /// Extract unique sportIds from all bets (single + combo)
  Set<int> _extractBetSlipSportIds() {
    final sportIds = <int>{};
    for (final bet in state.singleBets) {
      sportIds.add(bet.sportId);
    }
    for (final bet in state.comboBets) {
      sportIds.add(bet.sportId);
    }
    return sportIds;
  }

  /// Notify SubscriptionManager about BetSlip sports change
  void _notifySubscriptionManager() {
    final sportIds = _extractBetSlipSportIds();
    SubscriptionManager.instance?.syncBetSlipSports(sportIds);
  }

  /// Load saved bets from local storage
  /// Note: Does NOT call calculate APIs - call recalculateAllBets() when betting is ready
  Future<void> _loadFromStorage() async {
    try {
      // Load single bets (mark as calculating, waiting for recalculateAllBets)
      final savedBets = await _storage.loadSingleBets();
      if (savedBets.isNotEmpty) {
        final betsWithCalculating = savedBets
            .map((bet) => bet.copyWith(isCalculating: true))
            .toList();
        state = state.copyWith(singleBets: betsWithCalculating);
        debugPrint(
          '[ParlayState] Loaded ${savedBets.length} single bets from storage (waiting for betting ready)',
        );
      }

      // Load combo bets (waiting for recalculateAllBets)
      final savedComboBets = await _storage.loadComboBets();
      if (savedComboBets.isNotEmpty) {
        final combineOdds = _calculateCombineOdds(savedComboBets);
        state = state.copyWith(
          comboBets: savedComboBets,
          totalOdds: combineOdds,
          isCalculatingCombo: true,
        );
        debugPrint(
          '[ParlayState] Loaded ${savedComboBets.length} combo bets from storage (waiting for betting ready)',
        );
      }

      // Notify subscription manager about BetSlip sports (may be pending until WebSocket connects)
      _notifySubscriptionManager();

      // Restore event-level subscriptions for betslip odds updates
      final eventIds = <int>[];
      for (final bet in savedBets) {
        eventIds.add(bet.eventData.eventId);
      }
      for (final bet in savedComboBets) {
        eventIds.add(bet.eventData.eventId);
      }
      if (eventIds.isNotEmpty) {
        BetslipSubscriptionManager.instance?.restoreSubscriptions(eventIds);
        debugPrint(
          '[ParlayState] Restored ${eventIds.length} event subscriptions',
        );
      }
    } catch (e) {
      debugPrint('[ParlayState] Error loading from storage: $e');
    }
  }

  /// Recalculate all bets when betting is ready (token + websocket connected)
  /// Call this method when isBettingReadyProvider becomes true
  Future<void> recalculateAllBets() async {
    debugPrint('[ParlayState] recalculateAllBets called - betting is ready');

    // Recalculate all single bets
    for (int i = 0; i < state.singleBets.length; i++) {
      calculateSingleBetAt(i);
    }

    // Recalculate all combo bets individually (check if each selection is valid)
    for (int i = 0; i < state.comboBets.length; i++) {
      calculateComboBetAt(i);
    }

    // Only calculate combo parlay if user is on combo tab (lazy load optimization)
    // If user is on single tab, calculateComboParlay will be called when switching to combo tab
    if (state.tab == ParlayTab.combo) {
      // Use hasEnoughMatches which checks validComboBetsCount (excludes disabled bets)
      if (state.hasEnoughMatches) {
        calculateComboParlay();
      } else if (state.comboBets.isNotEmpty) {
        // Not enough valid matches, just clear calculating state
        state = state.copyWith(isCalculatingCombo: false);
      }
    } else {
      // Not on combo tab, clear calculating state if needed
      if (state.isCalculatingCombo) {
        state = state.copyWith(isCalculatingCombo: false);
      }
    }
  }

  /// Sync scores from events cache
  /// Call this when opening bottom sheet to get latest scores
  void syncScoresFromCache(Map<int, ({int home, int away})> scoresMap) {
    if (scoresMap.isEmpty) return;

    var hasChanges = false;

    // Update single bets scores
    final updatedSingleBets = state.singleBets.map((bet) {
      final eventId = bet.eventData.eventId;
      final cachedScore = scoresMap[eventId];
      if (cachedScore != null) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;
        if (currentHome != cachedScore.home ||
            currentAway != cachedScore.away) {
          debugPrint(
            '[ParlayState] Syncing score for event $eventId: $currentHome-$currentAway -> ${cachedScore.home}-${cachedScore.away}',
          );
          hasChanges = true;
          final updatedEventData = bet.eventData.copyWith(
            homeScore: cachedScore.home,
            awayScore: cachedScore.away,
          );
          return bet.copyWith(eventData: updatedEventData);
        }
      }
      return bet;
    }).toList();

    // Update combo bets scores
    final updatedComboBets = state.comboBets.map((bet) {
      final eventId = bet.eventData.eventId;
      final cachedScore = scoresMap[eventId];
      if (cachedScore != null) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;
        if (currentHome != cachedScore.home ||
            currentAway != cachedScore.away) {
          debugPrint(
            '[ParlayState] Syncing combo score for event $eventId: $currentHome-$currentAway -> ${cachedScore.home}-${cachedScore.away}',
          );
          hasChanges = true;
          final updatedEventData = bet.eventData.copyWith(
            homeScore: cachedScore.home,
            awayScore: cachedScore.away,
          );
          return bet.copyWith(eventData: updatedEventData);
        }
      }
      return bet;
    }).toList();

    if (hasChanges) {
      state = state.copyWith(
        singleBets: updatedSingleBets,
        comboBets: updatedComboBets,
      );
    }
  }

  /// Save single bets to local storage
  /// If [bets] is provided, saves that list directly (avoids race conditions)
  /// Otherwise reads from current state
  Future<void> _saveToStorage([List<SingleBetData>? bets]) async {
    try {
      await _storage.saveSingleBets(bets ?? state.singleBets);
    } catch (e) {
      debugPrint('[ParlayState] Error saving to storage: $e');
    }
  }

  /// Save combo bets to local storage
  /// If [bets] is provided, saves that list directly (avoids race conditions)
  /// Otherwise reads from current state
  Future<void> _saveComboToStorage([List<SingleBetData>? bets]) async {
    try {
      await _storage.saveComboBets(bets ?? state.comboBets);
    } catch (e) {
      debugPrint('[ParlayState] Error saving combo bets to storage: $e');
    }
  }

  /// Save all bets to local storage (call when bottom sheet closes)
  Future<void> saveAllToStorage() async {
    debugPrint('[ParlayState] saveAllToStorage called');
    await Future.wait([_saveToStorage(), _saveComboToStorage()]);
  }

  /// Reset placing state flags (useful when closing overlays)
  void resetPlacingState() {
    if (!state.isPlacingBet) return;
    state = state.copyWith(isPlacingBet: false, clearError: true);
  }

  /// Subscribe to library streams for real-time updates (odds + score)
  void _subscribeToLibrary() {
    final adapter = _ref.read(sportSocketAdapterProvider);

    // Subscribe to odds updates
    _oddsSubscription = adapter.onOddsUpdate.listen(
      _handleOddsUpdateFromLibrary,
    );

    // Subscribe to score updates
    _scoreSubscription = adapter.onScoreUpdate.listen(
      _handleScoreUpdateFromLibrary,
    );
  }

  /// Handle score update from library
  void _handleScoreUpdateFromLibrary(socket.ScoreUpdateData data) {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;

    // debugPrint(
    //   '[ParlayState] Score update: eventId=${data.eventId}, score=${data.homeScore}-${data.awayScore}',
    // );

    // Update single bets with matching eventId
    _updateSingleBetsScore(data.eventId, data.homeScore, data.awayScore);

    // Update combo bets with matching eventId
    _updateComboBetsScore(data.eventId, data.homeScore, data.awayScore);
  }

  /// Update single bets score from WebSocket data
  void _updateSingleBetsScore(int eventId, int homeScore, int awayScore) {
    if (state.singleBets.isEmpty) return;

    final updatedBets = <SingleBetData>[];
    var hasChanges = false;

    for (final bet in state.singleBets) {
      if (bet.eventData.eventId == eventId) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;

        if (currentHome != homeScore || currentAway != awayScore) {
          debugPrint(
            '[ParlayState] Updating single bet score for event $eventId: $currentHome-$currentAway -> $homeScore-$awayScore',
          );
          // Create updated eventData with new score
          final updatedEventData = bet.eventData.copyWith(
            homeScore: homeScore,
            awayScore: awayScore,
          );
          updatedBets.add(bet.copyWith(eventData: updatedEventData));
          hasChanges = true;
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (hasChanges) {
      state = state.copyWith(singleBets: updatedBets);
      // Note: Don't save score to storage - will be refreshed from WebSocket on app restart
    }
  }

  /// Update combo bets score from WebSocket data
  void _updateComboBetsScore(int eventId, int homeScore, int awayScore) {
    if (state.comboBets.isEmpty) return;

    final updatedBets = <SingleBetData>[];
    var hasChanges = false;

    for (final bet in state.comboBets) {
      if (bet.eventData.eventId == eventId) {
        final currentHome = bet.eventData.homeScore;
        final currentAway = bet.eventData.awayScore;

        if (currentHome != homeScore || currentAway != awayScore) {
          debugPrint(
            '[ParlayState] Updating combo bet score for event $eventId: $currentHome-$currentAway -> $homeScore-$awayScore',
          );
          final updatedEventData = bet.eventData.copyWith(
            homeScore: homeScore,
            awayScore: awayScore,
          );
          updatedBets.add(bet.copyWith(eventData: updatedEventData));
          hasChanges = true;
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (hasChanges) {
      state = state.copyWith(comboBets: updatedBets);
      // Note: Don't save score to storage - will be refreshed from WebSocket on app restart
    }
  }

  /// Handle odds update from library
  void _handleOddsUpdateFromLibrary(socket.OddsUpdateData update) {
    if (state.singleBets.isEmpty && state.comboBets.isEmpty) return;

    final eventId = update.eventId;
    final marketId = update.marketId;
    final offerId = update.offerId;
    final odds = update.odds;

    // Find matching single bets and update their odds (match by offerId)
    _updateSingleBetsOddsFromLibrary(eventId, marketId, offerId, odds);

    // Find matching combo bets and update their odds (match by offerId)
    _updateComboBetsOddsFromLibrary(eventId, marketId, offerId, odds);
  }

  /// Fallback matching by selectionId when offerId is null (legacy data)
  bool _matchesBySelection(SingleBetData bet, socket.OddsData odds) {
    final selectionId = bet.selectionId;
    if (selectionId == null) return false;

    // Check if selectionId matches any selection in the odds
    return selectionId == odds.selectionIdHome ||
        selectionId == odds.selectionIdAway ||
        selectionId == odds.selectionIdDraw;
  }

  /// Update combo bets odds from library OddsData
  void _updateComboBetsOddsFromLibrary(
    int eventId,
    int marketId,
    String offerId,
    socket.OddsData odds,
  ) {
    if (state.comboBets.isEmpty) return;

    final updatedBets = <SingleBetData>[];
    final changedSelectionIds = <String>[];

    for (final bet in state.comboBets) {
      // Skip disabled bets
      if (bet.isDisabled) {
        updatedBets.add(bet);
        continue;
      }

      // Match by offerId, fallback to selectionId if bet.offerId is null
      final matchesOffer = bet.offerId != null
          ? bet.offerId == offerId
          : _matchesBySelection(bet, odds);

      if (bet.eventData.eventId == eventId &&
          bet.marketData.marketId == marketId &&
          matchesOffer) {
        final newOddsValue = _getOddsValueFromLibrary(
          odds,
          bet.oddsType,
          bet.oddsStyle,
        );

        if (newOddsValue != null && newOddsValue != bet.displayOdds) {
          debugPrint(
            '[ParlayState] Updating combo bet odds: ${bet.selectionName} from ${bet.displayOdds} to $newOddsValue (style: ${bet.oddsStyle})',
          );
          updatedBets.add(bet.copyWith(updatedOdds: newOddsValue));
          if (bet.selectionId != null) {
            changedSelectionIds.add(bet.selectionId!);
          }
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (changedSelectionIds.isNotEmpty) {
      final combineOdds = _calculateCombineOdds(updatedBets);
      state = state.copyWith(comboBets: updatedBets, totalOdds: combineOdds);

      // Trigger odds changed notification with debounce
      _onOddsChanged(changedSelectionIds);

      // Recalculate stake limits with new odds
      calculateComboParlay();
    }
  }

  /// Update single bets odds from library OddsData
  void _updateSingleBetsOddsFromLibrary(
    int eventId,
    int marketId,
    String offerId,
    socket.OddsData odds,
  ) {
    final updatedBets = <SingleBetData>[];
    final changedIndices = <int>[];
    final changedSelectionIds = <String>[];

    for (int i = 0; i < state.singleBets.length; i++) {
      final bet = state.singleBets[i];

      // Skip disabled bets
      if (bet.isDisabled) {
        updatedBets.add(bet);
        continue;
      }

      // Match by offerId, fallback to selectionId if bet.offerId is null
      final matchesOffer = bet.offerId != null
          ? bet.offerId == offerId
          : _matchesBySelection(bet, odds);

      if (bet.eventData.eventId == eventId &&
          bet.marketData.marketId == marketId &&
          matchesOffer) {
        // Get updated odds value based on bet's oddsType and oddsStyle
        final newOddsValue = _getOddsValueFromLibrary(
          odds,
          bet.oddsType,
          bet.oddsStyle,
        );

        if (newOddsValue != null && newOddsValue != bet.displayOdds) {
          debugPrint(
            '[ParlayState] Updating odds for bet: ${bet.selectionName} from ${bet.displayOdds} to $newOddsValue (style: ${bet.oddsStyle})',
          );
          updatedBets.add(bet.copyWith(updatedOdds: newOddsValue));
          changedIndices.add(i);
          if (bet.selectionId != null) {
            changedSelectionIds.add(bet.selectionId!);
          }
        } else {
          updatedBets.add(bet);
        }
      } else {
        updatedBets.add(bet);
      }
    }

    if (changedIndices.isNotEmpty) {
      state = state.copyWith(singleBets: updatedBets);

      // Trigger odds changed notification with debounce
      _onOddsChanged(changedSelectionIds);

      // Recalculate stake limits for bets with changed odds
      for (final index in changedIndices) {
        debugPrint(
          '[ParlayState] Recalculating stake limits for bet at index $index',
        );
        calculateSingleBetAt(index);
      }
    }
  }

  /// Get odds value from library OddsData based on oddsType and oddsStyle
  /// Respects user's oddsStyle preference
  double? _getOddsValueFromLibrary(
    socket.OddsData odds,
    OddsType oddsType,
    OddsStyle oddsStyle,
  ) {
    // Get decimal and alternative formats based on oddsType
    double? decimal;
    String? malay;
    String? indo;
    String? hk;

    switch (oddsType) {
      case OddsType.home:
        decimal = odds.oddsHome;
        malay = odds.malayHome;
        indo = odds.indoHome;
        hk = odds.hkHome;
        break;
      case OddsType.away:
        decimal = odds.oddsAway;
        malay = odds.malayAway;
        indo = odds.indoAway;
        hk = odds.hkAway;
        break;
      case OddsType.draw:
        decimal = odds.oddsDraw;
        // Library doesn't have malay/indo/hk for draw
        malay = null;
        indo = null;
        hk = null;
        break;
      default:
        return null;
    }

    // Return value based on user's preferred oddsStyle
    switch (oddsStyle) {
      case OddsStyle.malay:
        if (malay != null) return double.tryParse(malay);
        return decimal; // Fallback to decimal
      case OddsStyle.indo:
        if (indo != null) return double.tryParse(indo);
        return decimal;
      case OddsStyle.hongKong:
        if (hk != null) return double.tryParse(hk);
        return decimal;
      case OddsStyle.decimal:
        return decimal;
    }
  }

  // ===== TAB MANAGEMENT =====

  void selectTab(ParlayTab tab) {
    final previousTab = state.tab;
    state = state.copyWith(tab: tab);

    // Lazy load: Calculate combo parlay when switching to combo tab
    // Only call API if we have enough VALID bets (non-disabled) AND haven't calculated yet
    if (tab == ParlayTab.combo && previousTab != ParlayTab.combo) {
      // Use hasEnoughMatches which checks validComboBetsCount (excludes disabled bets)
      final needsCalculation = state.minStake == 0 && state.maxStake == 0;

      if (state.hasEnoughMatches && needsCalculation) {
        debugPrint(
          '[ParlayState] Lazy loading calculateComboParlay on tab switch',
        );
        calculateComboParlay();
      }
    }
  }

  // ===== SINGLE BETS MANAGEMENT =====

  /// Add single bet from BettingPopupData
  /// Calls calculateBet API first - only adds to local if successful
  /// Returns AddBetResult for UI to show toast on error
  Future<AddBetResult> addSingleBetFromPopupData(
    BettingPopupData popupData,
  ) async {
    // Create new bet from popup data
    final newBet = SingleBetData.fromBettingPopupData(popupData);

    // Check if bet already exists (same event + selection)
    final existingIndex = state.singleBets.indexWhere(
      (bet) =>
          bet.eventData.eventId == newBet.eventData.eventId &&
          bet.selectionId == newBet.selectionId,
    );

    // If bet already exists, just switch to single tab (no need to recalculate)
    if (existingIndex >= 0) {
      state = state.copyWith(tab: ParlayTab.single);
      return const AddBetResult.success();
    }

    // Call calculateBet API first to validate the bet
    try {
      final request = CalculateBetRequest(
        leagueId: newBet.leagueIdString,
        matchTime: newBet.matchTimeISO,
        isLive: newBet.isLive,
        offerId: newBet.offerId ?? '',
        selectionId: newBet.selectionId ?? '',
        displayOdds: newBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(newBet.oddsStyle),
      );

      debugPrint(
        '[ParlayState] addSingleBetFromPopupData: Calling calculateBet API...',
      );
      final response = await _repository.calculateBet(request);
      debugPrint(
        '[ParlayState] calculateBet response: errorCode=${response.errorCode}',
      );

      // Check for API errors
      if (response.errorCode != 0) {
        final errorMessage = bettingApiErrorDisplayMessage(
          response.errorCode,
          serverMessage: response.message,
          fallback: bettingApiCalculateBetFailureFallback,
        );
        debugPrint('[ParlayState] calculateBet ERROR: $errorMessage');
        return AddBetResult.failure(
          errorMessage: errorMessage,
          errorCode: response.errorCode,
        );
      }

      // Success - add bet to local with min/max values
      final betWithLimits = newBet.copyWith(
        minStake: response.minStake,
        maxStake: response.maxStake,
        maxPayout: response.maxPayout,
        isCalculating: false,
      );

      state = state.copyWith(
        singleBets: [...state.singleBets, betWithLimits],
        tab: ParlayTab.single,
        clearError: true,
      );

      // Save to local storage
      _saveToStorage();

      // Notify subscription manager about BetSlip sports change
      _notifySubscriptionManager();

      // Subscribe to event-level updates for betslip
      BetslipSubscriptionManager.instance?.onBetAdded(
        popupData.eventData.eventId,
      );

      debugPrint(
        '[ParlayState] addSingleBetFromPopupData: SUCCESS - bet added',
      );
      return const AddBetResult.success();
    } catch (e, stackTrace) {
      debugPrint('[ParlayState] addSingleBetFromPopupData EXCEPTION: $e');
      debugPrint('[ParlayState] StackTrace: $stackTrace');
      return const AddBetResult.failure(
        errorMessage: 'Không thể thêm cược. Vui lòng thử lại!',
      );
    }
  }

  /// Legacy method - redirects to addSingleBetFromPopupData
  Future<AddBetResult> setSingleBetFromPopupData(BettingPopupData popupData) {
    return addSingleBetFromPopupData(popupData);
  }

  /// Add single bet from V2 popup data
  /// Converts V2 data to legacy and delegates to existing method
  Future<AddBetResult> addSingleBetFromPopupDataV2(
    BettingPopupDataV2 popupDataV2,
  ) async {
    // Convert V2 data to legacy BettingPopupData
    final legacyData = BettingPopupData(
      sportId: popupDataV2.sportId,
      oddsData: popupDataV2.oddsData.toLegacy(),
      marketData: popupDataV2.marketData.toLegacy(),
      eventData: popupDataV2.eventData.toLegacy(),
      oddsType: popupDataV2.oddsType,
      leagueData: popupDataV2.leagueData?.toLegacy(),
      oddsStyle: _convertOddsFormatToStyle(popupDataV2.oddsFormat),
      minStake: popupDataV2.minStake,
      maxStake: popupDataV2.maxStake,
      maxPayout: popupDataV2.maxPayout,
    );

    // Delegate to existing method
    return addSingleBetFromPopupData(legacyData);
  }

  /// Convert OddsFormatV2 to OddsStyle
  OddsStyle _convertOddsFormatToStyle(dynamic oddsFormat) {
    final formatStr = oddsFormat.toString();
    if (formatStr.contains('malay')) return OddsStyle.malay;
    if (formatStr.contains('indo')) return OddsStyle.indo;
    if (formatStr.contains('hk')) return OddsStyle.hongKong;
    return OddsStyle.decimal;
  }

  /// Update single bet stake at index
  void setSingleBetStakeAt(int index, int value) {
    if (index < 0 || index >= state.singleBets.length) return;

    final bet = state.singleBets[index];
    final clamped = value.clamp(0, bet.maxStakeActual);
    final updatedBets = [...state.singleBets];
    updatedBets[index] = bet.copyWith(stake: clamped);

    state = state.copyWith(singleBets: updatedBets);
    // Note: Don't save here - will be saved when bottom sheet closes
  }

  /// Add to single bet stake at index
  void addSingleBetStakeAt(int index, int delta) {
    if (index < 0 || index >= state.singleBets.length) return;
    setSingleBetStakeAt(index, state.singleBets[index].stake + delta);
  }

  /// Set single bet stake to max at index
  void setSingleBetStakeMaxAt(int index) {
    if (index < 0 || index >= state.singleBets.length) return;
    setSingleBetStakeAt(index, state.singleBets[index].maxStakeActual);
  }

  /// Clear single bet stake at index
  void clearSingleBetStakeAt(int index) {
    if (index < 0 || index >= state.singleBets.length) return;
    final updatedBets = [...state.singleBets];
    updatedBets[index] = state.singleBets[index].copyWith(stake: 0);
    state = state.copyWith(singleBets: updatedBets);
  }

  /// Remove single bet at index
  Future<void> removeSingleBetAt(int index) async {
    if (index < 0 || index >= state.singleBets.length) return;

    // Get eventId before removing for subscription cleanup
    final eventId = state.singleBets[index].eventData.eventId;

    final updatedBets = [...state.singleBets]..removeAt(index);

    // Recalculate changed odds count from remaining bets
    final newChangedCount = _countBetsWithChangedOdds(
      updatedBets,
      state.comboBets,
    );
    // final shouldShowNotification = newChangedCount > 0;

    state = state.copyWith(
      singleBets: updatedBets,
      changedOddsCount: newChangedCount,
      // showOddsChangedNotification: shouldShowNotification,
    );

    // Clear pending changed IDs if notification is hidden
    // if (!shouldShowNotification) {
    //   _pendingChangedBetIds.clear();
    //   _oddsChangedDebounceTimer?.cancel();
    // }

    // Save to local storage immediately with updated list (avoid race condition)
    await _saveToStorage(updatedBets);

    // Notify subscription manager about BetSlip sports change
    _notifySubscriptionManager();

    // Unsubscribe from event-level updates (uses reference counting)
    BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
  }

  /// Add a single bet directly to the list
  /// Used for "Dùng lại phiếu" (reuse bets) feature
  void addSingleBetDirect(SingleBetData bet) {
    // Check if bet already exists (by selectionId)
    final exists = state.singleBets.any(
      (b) => b.selectionId == bet.selectionId,
    );
    if (exists) {
      debugPrint('[ParlayState] Bet already exists in single bets list');
      return;
    }

    final updatedBets = [...state.singleBets, bet];
    state = state.copyWith(singleBets: updatedBets);
    _saveToStorage(updatedBets);

    // Subscribe to event-level updates for betslip
    BetslipSubscriptionManager.instance?.onBetAdded(bet.eventData.eventId);
  }

  /// Add a combo bet directly to the list
  /// Used for "Dùng lại phiếu" (reuse combo bets) feature
  void addComboBetDirect(SingleBetData bet) {
    // Check if event already exists in combo (one selection per event)
    final exists = state.comboBets.any(
      (b) => b.eventData.eventId == bet.eventData.eventId,
    );
    if (exists) {
      debugPrint('[ParlayState] Event already exists in combo bets list');
      return;
    }

    final updatedComboBets = [...state.comboBets, bet];
    final combineOdds = _calculateCombineOdds(updatedComboBets);
    state = state.copyWith(comboBets: updatedComboBets, totalOdds: combineOdds);
    _saveComboToStorage(updatedComboBets);

    // Notify subscription manager about BetSlip sports change
    _notifySubscriptionManager();

    // Subscribe to event-level updates for betslip
    BetslipSubscriptionManager.instance?.onBetAdded(bet.eventData.eventId);
  }

  /// Clear all single bets
  void clearAllSingleBets() {
    // Get eventIds before clearing for subscription cleanup
    final eventIds = state.singleBets
        .map((bet) => bet.eventData.eventId)
        .toList();

    // Recalculate changed odds count (only combo bets remain)
    final newChangedCount = _countBetsWithChangedOdds([], state.comboBets);
    // final shouldShowNotification = newChangedCount > 0;

    state = state.copyWith(
      singleBets: [],
      changedOddsCount: newChangedCount,
      // showOddsChangedNotification: shouldShowNotification,
    );

    // Clear pending changed IDs if notification is hidden
    // if (!shouldShowNotification) {
    //   _pendingChangedBetIds.clear();
    //   _oddsChangedDebounceTimer?.cancel();
    // }

    // Clear from local storage immediately with empty list
    _saveToStorage([]);

    // Notify subscription manager about BetSlip sports change
    _notifySubscriptionManager();

    // Unsubscribe from event-level updates (uses reference counting)
    for (final eventId in eventIds) {
      BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
    }
  }

  /// Calculate bet limits from API for bet at index
  Future<void> calculateSingleBetAt(int index) async {
    if (index < 0 || index >= state.singleBets.length) {
      debugPrint('[ParlayState] calculateSingleBetAt: invalid index $index');
      return;
    }

    final singleBet = state.singleBets[index];

    // Skip disabled bets - they don't need recalculation
    if (singleBet.isDisabled) {
      debugPrint(
        '[ParlayState] calculateSingleBetAt[$index]: Skipping disabled bet',
      );
      return;
    }

    debugPrint('[ParlayState] calculateSingleBetAt[$index]: Starting...');
    debugPrint('[ParlayState] leagueId: ${singleBet.leagueIdString}');
    debugPrint('[ParlayState] offerId: ${singleBet.offerId}');
    debugPrint('[ParlayState] selectionId: ${singleBet.selectionId}');
    debugPrint('[ParlayState] displayOdds: ${singleBet.displayOddsString}');
    debugPrint('[ParlayState] isLive: ${singleBet.isLive}');

    // Set loading state
    final loadingBets = [...state.singleBets];
    loadingBets[index] = singleBet.copyWith(isCalculating: true);
    state = state.copyWith(singleBets: loadingBets);

    try {
      final request = CalculateBetRequest(
        leagueId: singleBet.leagueIdString,
        matchTime: singleBet.matchTimeISO,
        isLive: singleBet.isLive,
        offerId: singleBet.offerId ?? '',
        selectionId: singleBet.selectionId ?? '',
        displayOdds: singleBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(singleBet.oddsStyle),
      );

      debugPrint('[ParlayState] Calling calculateBet API...');
      final response = await _repository.calculateBet(request);
      debugPrint('[ParlayState] Response errorCode: ${response.errorCode}');
      debugPrint('[ParlayState] Response minStake: ${response.minStake}');
      debugPrint('[ParlayState] Response maxStake: ${response.maxStake}');

      // Use current state to preserve any changes made while API was running
      if (index >= state.singleBets.length) {
        debugPrint('[ParlayState] Bet was removed while calculating');
        return;
      }

      final currentBet = state.singleBets[index];
      final updatedBets = [...state.singleBets];

      if (response.errorCode == 0) {
        // Success - update min/max while preserving user's stake
        // NOTE: Don't set updatedOdds here - odds change notification should only
        // be triggered by WebSocket updates (realtime changes), not initial calculate
        debugPrint('[ParlayState] calculateBet SUCCESS');
        debugPrint(
          '[ParlayState] minStake: ${response.minStake}, maxStake: ${response.maxStake}',
        );

        updatedBets[index] = currentBet.copyWith(
          minStake: response.minStake,
          maxStake: response.maxStake,
          maxPayout: response.maxPayout,
          isCalculating: false,
        );
        state = state.copyWith(singleBets: updatedBets, clearError: true);
        // Note: Don't save here - storage is saved when user changes stake or adds/removes bets
      } else {
        // API error
        debugPrint('[ParlayState] calculateBet ERROR: ${response.errorCode}');

        // Error 607 = odds not found, disable the bet permanently
        final shouldDisable = response.errorCode == 607;
        if (shouldDisable) {
          debugPrint(
            '[ParlayState] Disabling bet due to error 607 (odds not found)',
          );
        }

        final calcErr = bettingApiErrorDisplayMessage(
          response.errorCode,
          serverMessage: response.message,
          fallback: bettingApiCalculateBetFailureFallback,
        );
        updatedBets[index] = currentBet.copyWith(
          isCalculating: false,
          errorMessage: calcErr,
          isDisabled: shouldDisable,
          stake: shouldDisable
              ? 0
              : null, // Reset stake về 0 nếu bet bị disable
        );

        state = state.copyWith(
          singleBets: updatedBets,
          error: shouldDisable ? null : calcErr,
        );

        // Save to storage if bet was disabled
        if (shouldDisable) {
          _saveToStorage();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[ParlayState] calculateBet EXCEPTION: $e');
      debugPrint('[ParlayState] StackTrace: $stackTrace');

      // Check if bet still exists
      if (index >= state.singleBets.length) {
        debugPrint('[ParlayState] Bet was removed while calculating');
        return;
      }

      final currentBet = state.singleBets[index];
      final updatedBets = [...state.singleBets];
      updatedBets[index] = currentBet.copyWith(
        isCalculating: false,
        errorMessage: bettingApiCalculateBetFailureFallback,
      );
      state = state.copyWith(
        singleBets: updatedBets,
        error: bettingApiCalculateBetFailureFallback,
      );
    }
  }

  /// Place single bet at index
  Future<bool> placeSingleBetAt(int index) async {
    if (index < 0 || index >= state.singleBets.length) return false;

    final singleBet = state.singleBets[index];
    if (!singleBet.canPlaceBet) return false;

    state = state.copyWith(isPlacingBet: true, clearError: true);

    try {
      // Build selection for API
      final selection = BetSelectionModel(
        eventId: singleBet.eventData.eventId,
        eventName: '${singleBet.homeName} vs ${singleBet.awayName}',
        selectionId: singleBet.selectionId ?? '',
        selectionName: singleBet.selectionName,
        offerId: singleBet.offerId ?? '',
        displayOdds: singleBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(singleBet.oddsStyle),
        cls: singleBet.cls,
        leagueId: singleBet.leagueIdString,
        matchTime: singleBet.matchTimeISO,
        isLive: singleBet.isLive,
        sportId: singleBet.sportId,
        homeScore: singleBet.eventData.homeScore,
        awayScore: singleBet.eventData.awayScore,
        stake: singleBet.stake
            .toDouble(), // VND (will be converted to int in toRequestJson)
        winnings: singleBet
            .potentialWinnings, // VND (will be rounded in toRequestJson)
      );

      final request = PlaceBetRequest(
        matchId: singleBet.eventData.eventId,
        selections: [selection],
        singleBet: true,
      );

      final response = await _repository.placeBet(request);

      state = state.copyWith(isPlacingBet: false, lastPlaceBetResult: response);

      if (response.isSuccess) {
        // Remove successful bet from list
        removeSingleBetAt(index);
        // Refresh user balance after successful bet
        _ref.read(userProvider.notifier).refreshBalance();
        return true;
      } else {
        state = state.copyWith(
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiPlaceBetFailureFallback,
          ),
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

  /// Place all valid single bets
  Future<int> placeAllSingleBets() async {
    int successCount = 0;
    // Place bets in reverse order to maintain indices
    for (int i = state.singleBets.length - 1; i >= 0; i--) {
      if (state.singleBets[i].canPlaceBet) {
        final success = await placeSingleBetAt(i);
        if (success) successCount++;
      }
    }
    return successCount;
  }

  /// Result of placing multiple single bets
  /// Contains list of successful bets and total stake
  PlaceMultipleBetsResult? _lastPlaceMultipleResult;

  PlaceMultipleBetsResult? get lastPlaceMultipleResult =>
      _lastPlaceMultipleResult;

  /// Place all valid single bets in parallel for better performance
  /// Returns a result containing successful bets and total stake
  Future<PlaceMultipleBetsResult> placeAllSingleBetsParallel() async {
    final betsToPlace = state.singleBets
        .where((bet) => bet.canPlaceBet)
        .toList();

    if (betsToPlace.isEmpty) {
      return const PlaceMultipleBetsResult(
        successfulBets: [],
        failedBets: [],
        totalStake: 0,
      );
    }

    state = state.copyWith(isPlacingBet: true, clearError: true);

    // Create futures for all bets
    final futures = betsToPlace.map((singleBet) async {
      try {
        // Build selection for API
        final selection = BetSelectionModel(
          eventId: singleBet.eventData.eventId,
          eventName: '${singleBet.homeName} vs ${singleBet.awayName}',
          selectionId: singleBet.selectionId ?? '',
          selectionName: singleBet.selectionName,
          offerId: singleBet.offerId ?? '',
          displayOdds: singleBet.displayOddsString,
          oddsStyle: _getOddsStyleCode(singleBet.oddsStyle),
          cls: singleBet.cls,
          leagueId: singleBet.leagueIdString,
          matchTime: singleBet.matchTimeISO,
          isLive: singleBet.isLive,
          sportId: singleBet.sportId,
          homeScore: singleBet.eventData.homeScore,
          awayScore: singleBet.eventData.awayScore,
          stake: singleBet.stake
              .toDouble(), // VND (will be converted to int in toRequestJson)
          winnings: singleBet
              .potentialWinnings, // VND (will be rounded in toRequestJson)
        );

        final request = PlaceBetRequest(
          matchId: singleBet.eventData.eventId,
          selections: [selection],
          singleBet: true,
        );

        final response = await _repository.placeBet(request);

        // Debug log response
        debugPrint(
          '[ParlayState] placeBet response: status=${response.status}, errorCode=${response.errorCode}, message=${response.message}, ticketId=${response.ticketId}',
        );

        return _SingleBetPlaceResult(
          bet: singleBet,
          success: response.isSuccess,
          response: response,
        );
      } catch (e) {
        debugPrint(
          '[ParlayState] placeBet error for ${singleBet.selectionName}: $e',
        );
        return _SingleBetPlaceResult(
          bet: singleBet,
          success: false,
          error: e.toString(),
        );
      }
    }).toList();

    // Wait for all API calls to complete in parallel
    final results = await Future.wait(futures);

    // Separate successful and failed bets
    final successfulBets = <SingleBetData>[];
    final failedBets = <SingleBetData>[];
    final betsToRemove =
        <SingleBetData>[]; // Non-money errors - remove from local
    final betsToKeep = <SingleBetData>[]; // Money errors - keep in local
    final errorMessages = <String>[];
    int totalStake = 0;

    for (final result in results) {
      if (result.success) {
        successfulBets.add(result.bet);
        totalStake += result.bet.stake;
      } else {
        failedBets.add(result.bet);
        // Collect error message from API response or exception
        final errorCode = result.response?.errorCode;
        if (result.response != null) {
          errorMessages.add(
            bettingApiErrorDisplayMessage(
              errorCode,
              serverMessage: result.response!.message,
              fallback: bettingApiPlaceBetFailureFallback,
            ),
          );
        } else if (result.error != null) {
          errorMessages.add('Lỗi kết nối máy chủ!');
        }

        // Separate bets based on error type
        if (bettingApiErrorIsMoneyRelated(errorCode)) {
          // Money error - keep bet, user can adjust stake
          betsToKeep.add(result.bet);
        } else {
          // Non-money error - remove bet from local
          betsToRemove.add(result.bet);
        }
      }
    }

    debugPrint(
      '[ParlayState] Place bets result: ${successfulBets.length} success, ${failedBets.length} failed (${betsToRemove.length} to remove, ${betsToKeep.length} to keep)',
    );

    // Remove successful bets AND non-money-error bets from state
    final betsToRemoveFromState = [...successfulBets, ...betsToRemove];
    if (betsToRemoveFromState.isNotEmpty) {
      final selectionIdsToRemove = betsToRemoveFromState
          .map((b) => b.selectionId)
          .toSet();
      final remainingBets = state.singleBets
          .where((bet) => !selectionIdsToRemove.contains(bet.selectionId))
          .toList();

      state = state.copyWith(singleBets: remainingBets, isPlacingBet: false);

      // Save to storage
      _saveToStorage();

      // Refresh user balance if any bets were successful
      if (successfulBets.isNotEmpty) {
        _ref.read(userProvider.notifier).refreshBalance();
      }
    } else {
      state = state.copyWith(isPlacingBet: false);
    }

    final result = PlaceMultipleBetsResult(
      successfulBets: successfulBets,
      failedBets: failedBets,
      totalStake: totalStake,
      errorMessages: errorMessages,
      betsToRemove: betsToRemove,
      betsToKeep: betsToKeep,
    );

    _lastPlaceMultipleResult = result;
    return result;
  }

  // ===== COMBO PARLAY MANAGEMENT =====

  /// Add single bet to combo parlay (keeps in single tab, adds to combo)
  Future<bool> addToComboParlay(int singleBetIndex) async {
    if (singleBetIndex < 0 || singleBetIndex >= state.singleBets.length) {
      return false;
    }

    final singleBet = state.singleBets[singleBetIndex];

    // Check if this exact selection already exists in combo
    if (state.isBetInCombo(singleBet.eventData.eventId)) {
      debugPrint('[ParlayState] Event already exists in combo parlay');
      return false;
    }

    // Check if max matches reached (use default 20 if not set yet)
    final maxMatches = state.maxMatches > 0 ? state.maxMatches : 20;
    if (state.comboBets.length >= maxMatches) {
      debugPrint('[ParlayState] Max matches reached: $maxMatches');
      state = state.copyWith(
        error: 'Đã đạt số trận tối đa ($maxMatches trận) cho cược xiên',
      );
      return false;
    }

    // Check if market supports parlay (only check marketData.isParlay to match bet_details_content.dart)
    if (!singleBet.marketData.isParlay) {
      debugPrint('[ParlayState] Market does not support parlay');
      state = state.copyWith(error: 'Kèo này không hỗ trợ cược xiên');
      return false;
    }

    // 1. Add to combo list (DO NOT remove from single bets)
    final updatedComboBets = [...state.comboBets, singleBet];

    // 2. Calculate combine odds
    final combineOdds = _calculateCombineOdds(updatedComboBets);

    // 3. Update state - keep single bets unchanged
    state = state.copyWith(
      comboBets: updatedComboBets,
      totalOdds: combineOdds,
      clearError: true,
    );

    // 4. Save to local storage
    _saveComboToStorage();

    // 5. Only call API if user is on combo tab AND has enough valid matches
    // (lazy load optimization - if on single tab, will calculate when switching to combo)
    if (state.tab == ParlayTab.combo && state.hasEnoughMatches) {
      await calculateComboParlay();
    } else {
      debugPrint(
        '[ParlayState] Skip calculateComboParlay: tab=${state.tab}, hasEnoughMatches=${state.hasEnoughMatches}',
      );
    }

    // Subscribe to event-level updates for betslip (increments ref count)
    BetslipSubscriptionManager.instance?.onBetAdded(
      singleBet.eventData.eventId,
    );

    return true;
  }

  /// Calculate bet validity for combo bet at index
  /// Similar to calculateSingleBetAt but for combo bets
  Future<void> calculateComboBetAt(int index) async {
    if (index < 0 || index >= state.comboBets.length) {
      debugPrint('[ParlayState] calculateComboBetAt: invalid index $index');
      return;
    }

    final comboBet = state.comboBets[index];

    // Skip disabled bets - they don't need recalculation
    if (comboBet.isDisabled) {
      debugPrint(
        '[ParlayState] calculateComboBetAt[$index]: Skipping disabled bet',
      );
      return;
    }

    debugPrint(
      '[ParlayState] calculateComboBetAt[$index]: Checking validity...',
    );

    try {
      final request = CalculateBetRequest(
        leagueId: comboBet.leagueIdString,
        matchTime: comboBet.matchTimeISO,
        isLive: comboBet.isLive,
        offerId: comboBet.offerId ?? '',
        selectionId: comboBet.selectionId ?? '',
        displayOdds: comboBet.displayOddsString,
        oddsStyle: _getOddsStyleCode(comboBet.oddsStyle),
      );

      final response = await _repository.calculateBet(request);

      // Check if bet still exists
      if (index >= state.comboBets.length) {
        debugPrint('[ParlayState] Combo bet was removed while calculating');
        return;
      }

      final currentBet = state.comboBets[index];
      final updatedBets = [...state.comboBets];

      if (response.errorCode == 0) {
        // Success - combo bet is valid
        // NOTE: Don't set updatedOdds here - odds change notification should only
        // be triggered by WebSocket updates (realtime changes), not initial calculate
        debugPrint('[ParlayState] calculateComboBetAt[$index] SUCCESS');
      } else {
        // API error - check if should disable
        debugPrint(
          '[ParlayState] calculateComboBetAt[$index] ERROR: ${response.errorCode}',
        );

        // Error 607 = odds not found, disable the bet
        final shouldDisable = response.errorCode == 607;
        if (shouldDisable) {
          debugPrint('[ParlayState] Disabling combo bet due to error 607');
          updatedBets[index] = currentBet.copyWith(isDisabled: true);
          final combineOdds = _calculateCombineOdds(updatedBets);
          state = state.copyWith(
            comboBets: updatedBets,
            totalOdds: combineOdds,
          );
          _saveComboToStorage();
        }
      }
    } catch (e) {
      debugPrint('[ParlayState] calculateComboBetAt[$index] EXCEPTION: $e');
    }
  }

  /// Remove bet from combo parlay at index
  void removeFromComboParlay(int index) {
    if (index < 0 || index >= state.comboBets.length) return;

    // Get eventId before removing for subscription cleanup
    final eventId = state.comboBets[index].eventData.eventId;

    final updatedComboBets = [...state.comboBets]..removeAt(index);
    final combineOdds = _calculateCombineOdds(updatedComboBets);

    // Recalculate changed odds count from remaining bets
    final newChangedCount = _countBetsWithChangedOdds(
      state.singleBets,
      updatedComboBets,
    );
    // final shouldShowNotification = newChangedCount > 0;

    state = state.copyWith(
      comboBets: updatedComboBets,
      totalOdds: combineOdds,
      // Reset min/max if list becomes empty
      minStake: updatedComboBets.isEmpty ? 0 : state.minStake,
      maxStake: updatedComboBets.isEmpty ? 0 : state.maxStake,
      changedOddsCount: newChangedCount,
      // showOddsChangedNotification: shouldShowNotification,
      clearError: true,
    );

    // Clear pending changed IDs if notification is hidden
    // if (!shouldShowNotification) {
    //   _pendingChangedBetIds.clear();
    //   _oddsChangedDebounceTimer?.cancel();
    // }

    // Save to local storage immediately with updated list (avoid race condition)
    _saveComboToStorage(updatedComboBets);

    // Notify subscription manager about BetSlip sports change
    _notifySubscriptionManager();

    // Unsubscribe from event-level updates (uses reference counting)
    BetslipSubscriptionManager.instance?.onBetRemoved(eventId);

    // Only recalculate if user is on combo tab AND still has enough valid matches
    // (lazy load optimization - if on single tab, will calculate when switching to combo)
    if (state.tab == ParlayTab.combo && state.hasEnoughMatches) {
      calculateComboParlay();
    }
  }

  /// Remove bet from combo parlay by selectionId
  void removeFromComboBySelectionId(String? selectionId) {
    if (selectionId == null) return;

    final index = state.comboBets.indexWhere(
      (bet) => bet.selectionId == selectionId,
    );
    if (index >= 0) {
      removeFromComboParlay(index);
    }
  }

  /// Clear all combo bets
  void clearAllComboBets() {
    // Get eventIds before clearing for subscription cleanup
    final eventIds = state.comboBets
        .map((bet) => bet.eventData.eventId)
        .toList();

    // Recalculate changed odds count (only single bets remain)
    final newChangedCount = _countBetsWithChangedOdds(state.singleBets, []);
    // final shouldShowNotification = newChangedCount > 0;

    state = state.copyWith(
      comboBets: [],
      totalOdds: 1.0,
      minStake: 0,
      maxStake: 0,
      stake: 0,
      changedOddsCount: newChangedCount,
      // showOddsChangedNotification: shouldShowNotification,
      clearError: true,
    );

    // Clear pending changed IDs if notification is hidden
    // if (!shouldShowNotification) {
    //   _pendingChangedBetIds.clear();
    //   _oddsChangedDebounceTimer?.cancel();
    // }

    // Clear from local storage immediately with empty list
    _saveComboToStorage([]);

    // Notify subscription manager about BetSlip sports change
    _notifySubscriptionManager();

    // Unsubscribe from event-level updates (uses reference counting)
    for (final eventId in eventIds) {
      BetslipSubscriptionManager.instance?.onBetRemoved(eventId);
    }
  }

  /// Calculate combine odds from combo bets
  double _calculateCombineOdds(List<SingleBetData> comboBets) {
    if (comboBets.isEmpty) return 1.0;
    return comboBets.fold(1.0, (total, bet) => total * bet.displayOdds);
  }

  /// Call API to calculate parlay min/max stakes
  Future<void> calculateComboParlay() async {
    if (state.comboBets.isEmpty) return;

    state = state.copyWith(isCalculatingCombo: true);

    try {
      final oddsStyle = state.comboBets.isNotEmpty
          ? _getOddsStyleCode(state.comboBets.first.oddsStyle)
          : 'de';

      debugPrint('[ParlayState] calculateComboParlay request:');
      debugPrint('  comboBets count: ${state.comboBets.length}');
      for (final bet in state.comboBets) {
        debugPrint('  - selectionId: ${bet.selectionId}');
        debugPrint('    offerId: ${bet.offerId}');
        debugPrint('    displayOdds: ${bet.displayOddsString}');
        debugPrint('    leagueId: ${bet.leagueIdString}');
        debugPrint('    matchTime: ${bet.matchTimeISO}');
        debugPrint('    isLive: ${bet.isLive}');
      }
      debugPrint('  oddsStyle: $oddsStyle');

      final response = await _repository.calculateParlayBet(
        state.comboBets,
        oddsStyle,
      );

      debugPrint('[ParlayState] calculateComboParlay response:');
      debugPrint('  minStake: ${response.minStake}');
      debugPrint('  maxStake: ${response.maxStake}');
      debugPrint('  minMatches: ${response.minMatches}');
      debugPrint('  maxMatches: ${response.maxMatches}');

      if (response.errorCode == 0) {
        // NOTE: Don't set updatedOdds here - odds change notification should only
        // be triggered by WebSocket updates (realtime changes), not from calculate API

        final combineOdds = _calculateCombineOdds(state.comboBets);

        // API returns stakes in units of 1000 VND, convert to actual VND
        final minStakeVnd = response.minStake * 1000;
        final maxStakeVnd = response.maxStake * 1000;

        state = state.copyWith(
          minStake: minStakeVnd,
          maxStake: maxStakeVnd,
          minMatches: response.minMatches,
          maxMatches: response.maxMatches,
          totalOdds: combineOdds,
          isCalculatingCombo: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isCalculatingCombo: false,
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiCalculateParlayFailureFallback,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[ParlayState] calculateComboParlay error: $e');
      debugPrint('[ParlayState] stackTrace: $stackTrace');
      state = state.copyWith(
        isCalculatingCombo: false,
        error: bettingApiCalculateParlayFailureFallback,
      );
    }
  }

  /// Place combo parlay bet
  Future<bool> placeComboParlay() async {
    if (!state.canPlaceBet || state.tab != ParlayTab.combo) return false;

    state = state.copyWith(isPlacingBet: true, clearError: true);

    try {
      final oddsStyle = state.comboBets.isNotEmpty
          ? _getOddsStyleCode(state.comboBets.first.oddsStyle)
          : 'de';

      // API expects stake in actual VND (not divided by 1000)
      // state.stake is already in actual VND
      final response = await _repository.placeParlayBet(
        state.comboBets,
        state.stake,
        oddsStyle,
      );

      state = state.copyWith(isPlacingBet: false, lastPlaceBetResult: response);

      if (response.isSuccess) {
        // Clear combo bets on success
        clearAllComboBets();
        // Refresh user balance after successful bet
        _ref.read(userProvider.notifier).refreshBalance();
        return true;
      } else {
        state = state.copyWith(
          error: bettingApiErrorDisplayMessage(
            response.errorCode,
            serverMessage: response.message,
            fallback: bettingApiParlayComboFailureFallback,
          ),
        );
        return false;
      }
    } catch (e) {
      debugPrint('[ParlayState] placeComboParlay error: $e');
      state = state.copyWith(
        isPlacingBet: false,
        error: bettingApiErrorDisplayMessage(
          null,
          fallback: bettingApiParlayComboFailureFallback,
        ),
      );
      return false;
    }
  }

  // ===== COMBO STAKE MANAGEMENT =====

  void setStake(int value) {
    final maxStake = state.maxStake > 0 ? state.maxStake : 750000000;
    state = state.copyWith(stake: value.clamp(0, maxStake));
  }

  void addStake(int delta) => setStake(state.stake + delta);

  void setStakeFromInput(String rawValue) {
    final numeric = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      state = state.copyWith(stake: 0);
      return;
    }
    setStake(int.parse(numeric));
  }

  void clearStake() => state = state.copyWith(stake: 0);

  // ===== MULTI BET MANAGEMENT =====

  void setMultiStake(int index, int value) {
    if (index < 0 || index >= state.multiBets.length) {
      return;
    }
    final bet = state.multiBets[index];
    final clamped = value.clamp(bet.minStake, bet.maxStake);
    final updated = [...state.multiBets]
      ..[index] = bet.copyWith(stake: clamped);
    state = state.copyWith(multiBets: updated);
  }

  void clearMultiStake(int index) {
    if (index < 0 || index >= state.multiBets.length) {
      return;
    }
    final bet = state.multiBets[index];
    final updated = [...state.multiBets]..[index] = bet.copyWith(stake: 0);
    state = state.copyWith(multiBets: updated);
  }

  // ===== ODDS CHANGED NOTIFICATION =====

  /// Called when odds change - starts/resets 3s debounce timer
  /// [changedSelectionIds] - list of unique selection IDs that changed
  void _onOddsChanged(List<String> changedSelectionIds) {
    if (changedSelectionIds.isEmpty) return;

    // If notification is already showing, reset count and start fresh
    // BUT keep notification visible - user must click "Chấp nhận thay đổi" to dismiss
    if (state.showOddsChangedNotification) {
      // Reset pending set and add new IDs
      _pendingChangedBetIds.clear();
      _pendingChangedBetIds.addAll(changedSelectionIds);

      // Cancel existing timer
      _oddsChangedDebounceTimer?.cancel();

      // Start new 3s debounce timer - after 3s, update the count (keep notification visible)
      _oddsChangedDebounceTimer = Timer(const Duration(seconds: 3), () {
        if (_pendingChangedBetIds.isNotEmpty) {
          state = state.copyWith(
            changedOddsCount: _pendingChangedBetIds.length,
            // Keep showOddsChangedNotification = true (don't change it)
          );
          _pendingChangedBetIds.clear();
        }
      });
      return;
    }

    // Notification not showing - use debounce logic
    // Add unique selection IDs to the set (duplicates are ignored)
    _pendingChangedBetIds.addAll(changedSelectionIds);

    // Cancel existing timer
    _oddsChangedDebounceTimer?.cancel();

    // Start new 3 second debounce timer
    _oddsChangedDebounceTimer = Timer(const Duration(seconds: 3), () {
      // After 3s of no changes, show notification
      if (_pendingChangedBetIds.isNotEmpty) {
        state = state.copyWith(
          changedOddsCount: _pendingChangedBetIds.length,
          showOddsChangedNotification: true,
        );
        // Clear pending set after showing notification
        _pendingChangedBetIds.clear();
      }
    });
  }

  /// Count bets with changed odds (updatedOdds != null) from both lists
  int _countBetsWithChangedOdds(
    List<SingleBetData> singleBets,
    List<SingleBetData> comboBets,
  ) {
    int count = 0;
    for (final bet in singleBets) {
      if (bet.updatedOdds != null) count++;
    }
    for (final bet in comboBets) {
      if (bet.updatedOdds != null) count++;
    }
    return count;
  }

  /// Accept odds changes - hide notification and clear updatedOdds
  void acceptOddsChanges() {
    // Reset notification state
    _pendingChangedBetIds.clear();
    _oddsChangedDebounceTimer?.cancel();

    // Clear updatedOdds from all single bets (accept new odds as current)
    final updatedSingleBets = state.singleBets.map((bet) {
      if (bet.updatedOdds != null) {
        // Create new oddsData with updated odds values
        return bet.copyWith(updatedOdds: null);
      }
      return bet;
    }).toList();

    // Clear updatedOdds from all combo bets
    final updatedComboBets = state.comboBets.map((bet) {
      if (bet.updatedOdds != null) {
        return bet.copyWith(updatedOdds: null);
      }
      return bet;
    }).toList();

    state = state.copyWith(
      singleBets: updatedSingleBets,
      comboBets: updatedComboBets,
      changedOddsCount: 0,
      showOddsChangedNotification: false,
    );
  }

  // ===== ERROR HANDLING =====

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get odds style code for API (de, ma, in, hk)
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
}

final parlayStateProvider =
    StateNotifierProvider<ParlayStateNotifier, ParlayState>((ref) {
      final repository = BettingRepositoryImpl();
      return ParlayStateNotifier(repository, ref);
    });

// ===== DERIVED PROVIDERS =====

/// Provider for single bets list
final singleBetsProvider = Provider<List<SingleBetData>>((ref) {
  return ref.watch(parlayStateProvider).singleBets;
});

/// Provider for checking if any single bet is calculating
final isSingleBetCalculatingProvider = Provider<bool>((ref) {
  return ref
      .watch(parlayStateProvider)
      .singleBets
      .any((bet) => bet.isCalculating);
});

/// Provider for single bets count
final singleBetsCountProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider).singleBets.length;
});

/// Provider for checking if placing bet
final isPlacingBetProvider = Provider<bool>((ref) {
  return ref.watch(parlayStateProvider).isPlacingBet;
});

/// Provider for error message
final parlayErrorProvider = Provider<String?>((ref) {
  return ref.watch(parlayStateProvider).error;
});

/// Provider to check if a specific bet is in the slip
/// Key format: "eventId_selectionId"
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final isBetInSlipProvider = Provider.autoDispose.family<bool, String>((
  ref,
  key,
) {
  final singleBets = ref.watch(singleBetsProvider);
  final parts = key.split('_');
  if (parts.length != 2) return false;

  final eventId = int.tryParse(parts[0]);
  final selectionId = parts[1];

  return singleBets.any(
    (bet) => bet.eventData.eventId == eventId && bet.selectionId == selectionId,
  );
});

/// Provider to get bet index in slip (for removal)
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final betIndexInSlipProvider = Provider.autoDispose.family<int, String>((
  ref,
  key,
) {
  final singleBets = ref.watch(singleBetsProvider);
  final parts = key.split('_');
  if (parts.length != 2) return -1;

  final eventId = int.tryParse(parts[0]);
  final selectionId = parts[1];

  return singleBets.indexWhere(
    (bet) => bet.eventData.eventId == eventId && bet.selectionId == selectionId,
  );
});

// ===== MULTI BETS PROVIDERS =====

/// Provider for multi bets list - optimized with select
final multiBetsProvider = Provider<List<ParlayMultiBet>>((ref) {
  return ref.watch(parlayStateProvider.select((s) => s.multiBets));
});

// ===== COMBO BETS PROVIDERS =====

/// Provider for combo bets list
final comboBetsProvider = Provider<List<SingleBetData>>((ref) {
  return ref.watch(parlayStateProvider).comboBets;
});

/// Provider for combo bets count
final comboBetsCountProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider).comboBetsCount;
});

/// Provider for checking if combo is calculating
final isCalculatingComboProvider = Provider<bool>((ref) {
  return ref.watch(parlayStateProvider).isCalculatingCombo;
});

/// Provider for combo total odds
final comboTotalOddsProvider = Provider<double>((ref) {
  return ref.watch(parlayStateProvider).totalOdds;
});

/// Provider for combo min/max stakes
final comboMinStakeProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider).minStake;
});

final comboMaxStakeProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider).maxStake;
});

/// Provider for min/max matches
final minMatchesProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider).minMatches;
});

final maxMatchesProvider = Provider<int>((ref) {
  return ref.watch(parlayStateProvider).maxMatches;
});

/// Provider to check if combo has enough matches
final hasEnoughMatchesProvider = Provider<bool>((ref) {
  return ref.watch(parlayStateProvider).hasEnoughMatches;
});

/// Provider to check if bet is in combo parlay
///
/// 🔧 MEMORY LEAK FIX: Added .autoDispose to cleanup listeners when widget unmounts
final isBetInComboProvider = Provider.autoDispose.family<bool, int>((
  ref,
  eventId,
) {
  return ref.watch(parlayStateProvider).isBetInCombo(eventId);
});

/// Provider kiểm tra selection có trong combo hay không
/// Sử dụng .select() để chỉ rebuild khi giá trị thực sự thay đổi
///
/// 🔧 PERFORMANCE FIX: Thay vì watch toàn bộ parlayStateProvider, chỉ watch kết quả của isSelectionInCombo
final isSelectionInComboProvider = Provider.autoDispose.family<bool, String?>((
  ref,
  selectionId,
) {
  if (selectionId == null) return false;
  return ref.watch(
    parlayStateProvider.select(
      (state) => state.isSelectionInCombo(selectionId),
    ),
  );
});

/// Provider kiểm tra event có selection khác trong combo không
/// Parameters: (eventId, selectionId)
/// Sử dụng .select() để chỉ rebuild khi giá trị thực sự thay đổi
///
/// 🔧 PERFORMANCE FIX: Thay vì watch toàn bộ parlayStateProvider, chỉ watch kết quả của hasOtherSelectionInCombo
final hasOtherSelectionInComboProvider = Provider.autoDispose
    .family<bool, (int, String?)>((ref, params) {
      final (eventId, selectionId) = params;
      return ref.watch(
        parlayStateProvider.select(
          (state) => state.hasOtherSelectionInCombo(eventId, selectionId),
        ),
      );
    });

/// Provider for odds changed notification count (tab-aware)
/// Returns count of changed odds for current tab only
final changedOddsCountProvider = Provider<int>((ref) {
  final state = ref.watch(parlayStateProvider);

  // Calculate count based on current tab
  switch (state.tab) {
    case ParlayTab.single:
      return state.singleBets.where((bet) => bet.updatedOdds != null).length;
    case ParlayTab.combo:
      return state.comboBets.where((bet) => bet.updatedOdds != null).length;
    case ParlayTab.multi:
      return 0; // Multi tab doesn't track odds changes
  }
});

/// Provider for total bet count (single bets + valid combo)
/// Uses select to only rebuild when specific values change
/// This is optimized for ParlayHeader badge display
final totalBetCountProvider = Provider<int>((ref) {
  final singleBetsCount = ref.watch(
    parlayStateProvider.select((state) => state.singleBets.length),
  );
  final comboBetsCount = ref.watch(
    parlayStateProvider.select((state) => state.comboBetsCount),
  );
  final minMatches = ref.watch(
    parlayStateProvider.select((state) => state.minMatches),
  );

  // Combo only counts as 1 valid ticket if it has enough matches
  final hasValidCombo = comboBetsCount >= minMatches;
  return singleBetsCount + (hasValidCombo ? 1 : 0);
});

/// Provider for showing odds changed notification (tab-aware)
/// Returns true if current tab has any changed odds
final showOddsChangedNotificationProvider = Provider<bool>((ref) {
  final state = ref.watch(parlayStateProvider);

  // Only show if base notification is enabled AND current tab has changes
  if (!state.showOddsChangedNotification) return false;

  switch (state.tab) {
    case ParlayTab.single:
      return state.singleBets.any((bet) => bet.updatedOdds != null);
    case ParlayTab.combo:
      return state.comboBets.any((bet) => bet.updatedOdds != null);
    case ParlayTab.multi:
      return false;
  }
});

/// Provider to check if betting is ready (auth + library initialized and connected)
/// Use this to show shimmer loading while waiting for connection
final isBettingReadyProvider = Provider<bool>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final adapter = ref.watch(sportSocketAdapterProvider);
  final isReady = adapter.isInitialized && adapter.isConnected;
  return isAuthenticated && isReady;
});

class ParlayMultiBet {
  final String status;
  final String title;
  final String market;
  final String pick;
  final double odd;
  final bool isLive;
  final int stake;
  final int minStake;
  final int maxStake;

  const ParlayMultiBet({
    required this.status,
    required this.title,
    required this.market,
    required this.pick,
    required this.odd,
    this.isLive = false,
    this.stake = 0,
    this.minStake = 50000,
    this.maxStake = 750000000,
  });

  ParlayMultiBet copyWith({
    String? status,
    String? title,
    String? market,
    String? pick,
    double? odd,
    bool? isLive,
    int? stake,
    int? minStake,
    int? maxStake,
  }) => ParlayMultiBet(
    status: status ?? this.status,
    title: title ?? this.title,
    market: market ?? this.market,
    pick: pick ?? this.pick,
    odd: odd ?? this.odd,
    isLive: isLive ?? this.isLive,
    stake: stake ?? this.stake,
    minStake: minStake ?? this.minStake,
    maxStake: maxStake ?? this.maxStake,
  );

  static const defaultBets = [
    ParlayMultiBet(
      status: '24" Hiệp 1',
      title: 'Bayern Munich 2 - 0 Paris Saint-Germain',
      market: 'Hiệp 1 - Chấp',
      pick: 'PSG (0.5)',
      odd: 0.95,
      isLive: true,
      stake: 10000000,
    ),
    ParlayMultiBet(
      status: '2:00PM - Thứ 6, 24 Th 12, 2025',
      title: 'Bayern Munich - Paris Saint-Germain',
      market: 'Toàn trận - 1x2',
      pick: 'Bayern',
      odd: 0.95,
      stake: 500000,
    ),
    ParlayMultiBet(
      status: '2:00PM - Thứ 6, 24 Th 12, 2025',
      title: 'Bayern Munich - Paris Saint-Germain',
      market: 'Toàn trận - 1x2',
      pick: 'Bayern',
      odd: 0.95,
    ),
  ];
}

/// Result of placing multiple single bets
class PlaceMultipleBetsResult {
  final List<SingleBetData> successfulBets;
  final List<SingleBetData> failedBets;
  final int totalStake;
  final List<String> errorMessages;

  /// Bets that failed due to non-money errors (should be removed from local)
  final List<SingleBetData> betsToRemove;

  /// Bets that failed due to money errors (keep in local, user can adjust stake)
  final List<SingleBetData> betsToKeep;

  const PlaceMultipleBetsResult({
    required this.successfulBets,
    required this.failedBets,
    required this.totalStake,
    this.errorMessages = const [],
    this.betsToRemove = const [],
    this.betsToKeep = const [],
  });

  bool get hasSuccessfulBets => successfulBets.isNotEmpty;
  bool get hasFailedBets => failedBets.isNotEmpty;
  int get successCount => successfulBets.length;
  int get failedCount => failedBets.length;

  /// Get first error message for display
  String? get firstErrorMessage =>
      errorMessages.isNotEmpty ? errorMessages.first : null;
}

/// Internal class for tracking individual bet place results
class _SingleBetPlaceResult {
  final SingleBetData bet;
  final bool success;
  final PlaceBetResponse? response;
  final String? error;

  const _SingleBetPlaceResult({
    required this.bet,
    required this.success,
    this.response,
    this.error,
  });
}

/// Result of adding a bet to the slip
/// Used to communicate success/failure back to UI for toast display
class AddBetResult {
  final bool success;
  final String? errorMessage;
  final int? errorCode;

  const AddBetResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  /// Create a success result
  const AddBetResult.success()
    : success = true,
      errorMessage = null,
      errorCode = null;

  /// Create a failure result
  const AddBetResult.failure({this.errorMessage, this.errorCode})
    : success = false;
}
