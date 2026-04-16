import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/providers.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/parlay/presentation/mobile/providers/parlay_state_provider.dart';

class MyBetState {
  final int betSlipCount;
  final int myBetsCount;

  const MyBetState({this.betSlipCount = 0, this.myBetsCount = 0});

  MyBetState copyWith({int? betSlipCount, int? myBetsCount}) {
    return MyBetState(
      betSlipCount: betSlipCount ?? this.betSlipCount,
      myBetsCount: myBetsCount ?? this.myBetsCount,
    );
  }
}

class MyBetNotifier extends Notifier<MyBetState> {
  @override
  MyBetState build() {
    // 1. Calculate Bet Slip Count (Cart)
    final singleBetsCount = ref.watch(singleBetsCountProvider);
    final comboBetsCount = ref.watch(comboBetsCountProvider);

    // Get minMatches from parlay state (default is 2)
    final parlayState = ref.watch(parlayStateProvider);
    final minMatches = parlayState.minMatches > 0 ? parlayState.minMatches : 2;

    // Combo only counts as 1 valid ticket if it has enough matches
    final hasValidCombo = comboBetsCount >= minMatches;
    final betSlipCount = singleBetsCount + (hasValidCombo ? 1 : 0);

    // 2. Get My Bets Count (Active Bets)
    // Subscribe to the repository's stream for real-time updates via StreamProvider
    final activeCountAsync = ref.watch(activeBetCountProvider);

    // Fallback to current cached value if stream has no data yet
    // Notice: We need to access repo to get currentActiveCount as fallback
    final repo = ref.watch(myBetRepositoryProvider);
    final myBetsCount = activeCountAsync.valueOrNull ?? repo.currentActiveCount;

    return MyBetState(betSlipCount: betSlipCount, myBetsCount: myBetsCount);
  }
}
