import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/error/betting_api_error_messages.dart';
import 'package:co_caro_flame/s88/core/services/repositories/betting_repository.dart';
import 'package:co_caro_flame/s88/core/services/models/bet_model.dart';
import 'package:co_caro_flame/s88/core/services/models/event_model.dart';
import 'package:co_caro_flame/s88/core/services/models/market_model.dart';

/// Bet Slip Item
class BetSlipItem {
  final EventModel event;
  final MarketModel market;
  final SelectionModel selection;
  final double stake;
  final CalculateBetResponse? calculation;

  const BetSlipItem({
    required this.event,
    required this.market,
    required this.selection,
    this.stake = 0,
    this.calculation,
  });

  BetSlipItem copyWith({
    EventModel? event,
    MarketModel? market,
    SelectionModel? selection,
    double? stake,
    CalculateBetResponse? calculation,
  }) => BetSlipItem(
    event: event ?? this.event,
    market: market ?? this.market,
    selection: selection ?? this.selection,
    stake: stake ?? this.stake,
    calculation: calculation ?? this.calculation,
  );

  /// Get potential winnings
  double get potentialWinnings {
    final odds = double.tryParse(selection.displayOdds) ?? 0;
    return stake * odds;
  }

  /// Convert to BetSelectionModel for API
  BetSelectionModel toBetSelection() => BetSelectionModel(
    eventId: event.id,
    eventName: event.name,
    selectionId: selection.selectionId,
    selectionName: selection.name,
    offerId: selection.offerId,
    displayOdds: selection.displayOdds,
    cls: market.cls,
    leagueId: event.leagueId.toString(),
    matchTime: event.startDate,
    isLive: event.isLive,
    sportId: 1,
    homeScore: event.score?.home,
    awayScore: event.score?.away,
    stake: stake,
    winnings: potentialWinnings,
  );
}

/// Betting State
class BettingState {
  final List<BetSlipItem> betSlip;
  final bool isCalculating;
  final bool isPlacing;
  final PlaceBetResponse? lastPlaceBetResult;
  final String? error;

  const BettingState({
    this.betSlip = const [],
    this.isCalculating = false,
    this.isPlacing = false,
    this.lastPlaceBetResult,
    this.error,
  });

  BettingState copyWith({
    List<BetSlipItem>? betSlip,
    bool? isCalculating,
    bool? isPlacing,
    PlaceBetResponse? lastPlaceBetResult,
    String? error,
  }) => BettingState(
    betSlip: betSlip ?? this.betSlip,
    isCalculating: isCalculating ?? this.isCalculating,
    isPlacing: isPlacing ?? this.isPlacing,
    lastPlaceBetResult: lastPlaceBetResult,
    error: error,
  );

  double get totalStake => betSlip.fold(0, (sum, item) => sum + item.stake);
  double get totalPotentialWinnings =>
      betSlip.fold(0, (sum, item) => sum + item.potentialWinnings);
  bool get isEmpty => betSlip.isEmpty;
  bool get isValid =>
      betSlip.isNotEmpty && betSlip.every((item) => item.stake > 0);
}

/// Betting Notifier
class BettingNotifier extends StateNotifier<BettingState> {
  final BettingRepository _repository;

  BettingNotifier(this._repository) : super(const BettingState());

  /// Add selection to bet slip
  void addSelection(
    EventModel event,
    MarketModel market,
    SelectionModel selection,
  ) {
    final exists = state.betSlip.any(
      (item) =>
          item.event.id == event.id &&
          item.selection.selectionId == selection.selectionId,
    );

    if (exists) {
      removeSelection(event.id, selection.selectionId);
      return;
    }

    final newItem = BetSlipItem(
      event: event,
      market: market,
      selection: selection,
    );
    state = state.copyWith(betSlip: [...state.betSlip, newItem], error: null);
  }

  /// Remove selection from bet slip
  void removeSelection(int eventId, String selectionId) {
    final newBetSlip = state.betSlip
        .where(
          (item) =>
              !(item.event.id == eventId &&
                  item.selection.selectionId == selectionId),
        )
        .toList();
    state = state.copyWith(betSlip: newBetSlip);
  }

  /// Update stake for a selection
  void updateStake(int eventId, String selectionId, double stake) {
    final newBetSlip = state.betSlip.map((item) {
      if (item.event.id == eventId &&
          item.selection.selectionId == selectionId) {
        return item.copyWith(stake: stake);
      }
      return item;
    }).toList();
    state = state.copyWith(betSlip: newBetSlip);
  }

  /// Calculate bet limits
  Future<void> calculateBet(BetSlipItem item) async {
    state = state.copyWith(isCalculating: true, error: null);

    try {
      final request = CalculateBetRequest(
        leagueId: item.event.leagueId.toString(),
        matchTime: item.event.startDate,
        isLive: item.event.isLive,
        offerId: item.selection.offerId,
        selectionId: item.selection.selectionId,
        displayOdds: item.selection.displayOdds,
      );

      final calculation = await _repository.calculateBet(request);

      final newBetSlip = state.betSlip.map((i) {
        if (i.event.id == item.event.id &&
            i.selection.selectionId == item.selection.selectionId) {
          return i.copyWith(calculation: calculation);
        }
        return i;
      }).toList();

      state = state.copyWith(betSlip: newBetSlip, isCalculating: false);
    } catch (e) {
      state = state.copyWith(isCalculating: false, error: e.toString());
    }
  }

  /// Place bet
  Future<bool> placeBet({
    bool acceptBetterOdds = true,
    bool acceptMaxStake = true,
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Bet slip không hợp lệ');
      return false;
    }

    state = state.copyWith(isPlacing: true, error: null);

    try {
      final selections = state.betSlip
          .map((item) => item.toBetSelection())
          .toList();

      final request = PlaceBetRequest(
        acceptBetterOdds: acceptBetterOdds,
        acceptMaxStake: acceptMaxStake,
        matchId: state.betSlip.first.event.id,
        selections: selections,
        singleBet: state.betSlip.length == 1,
      );

      final result = await _repository.placeBet(request);

      state = state.copyWith(isPlacing: false, lastPlaceBetResult: result);

      if (result.isSuccess) {
        state = state.copyWith(betSlip: []);
        return true;
      } else {
        state = state.copyWith(
          error: bettingApiErrorDisplayMessage(
            result.errorCode,
            serverMessage: result.message,
            fallback: bettingApiPlaceBetFailureFallback,
          ),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isPlacing: false,
        error: bettingApiErrorDisplayMessage(
          null,
          fallback: bettingApiPlaceBetFailureFallback,
        ),
      );
      return false;
    }
  }

  /// Clear bet slip
  void clearBetSlip() {
    state = const BettingState();
  }

  /// Check if selection is in bet slip
  bool isInBetSlip(int eventId, String selectionId) => state.betSlip.any(
    (item) =>
        item.event.id == eventId && item.selection.selectionId == selectionId,
  );
}

/// Betting Repository Provider
final bettingRepositoryProvider = Provider<BettingRepository>(
  (ref) => BettingRepositoryImpl(),
);

/// Betting Provider
final bettingProvider = StateNotifierProvider<BettingNotifier, BettingState>((
  ref,
) {
  final repository = ref.watch(bettingRepositoryProvider);
  return BettingNotifier(repository);
});

/// Derived providers
final betSlipCountProvider = Provider<int>(
  (ref) => ref.watch(bettingProvider).betSlip.length,
);

final totalStakeProvider = Provider<double>(
  (ref) => ref.watch(bettingProvider).totalStake,
);

final totalPotentialWinningsProvider = Provider<double>(
  (ref) => ref.watch(bettingProvider).totalPotentialWinnings,
);

final isPlacingBetProvider = Provider<bool>(
  (ref) => ref.watch(bettingProvider).isPlacing,
);

final isInBetSlipProvider =
    Provider.family<bool, ({int eventId, String selectionId})>(
      (ref, params) => ref
          .watch(bettingProvider)
          .betSlip
          .any(
            (item) =>
                item.event.id == params.eventId &&
                item.selection.selectionId == params.selectionId,
          ),
    );
