import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

final betPreferencesProvider =
    StateNotifierProvider.autoDispose<BetPreferencesNotifier, BetPreferences>((
      ref,
    ) {
      final storage = ref.read(sportStorageProvider);
      final leagueNotifier = ref.read(leagueProvider.notifier);
      return BetPreferencesNotifier(
        sportStorage: storage,
        leagueNotifier: leagueNotifier,
      )..loadInitial();
    }, name: 'BetPreferencesProvider');

class BetPreferencesNotifier extends StateNotifier<BetPreferences> {
  BetPreferencesNotifier({
    required this.sportStorage,
    required this.leagueNotifier,
  }) : super(const BetPreferences.initial());

  final SportStorage sportStorage;
  final LeagueNotifier leagueNotifier;

  void updateOddsStyle(OddsStyle value) {
    state = state.copyWith(oddsStyle: value);
    sportStorage.saveOddsStyle(value.shortName);
    // Sync odds style to LeagueNotifier so UI updates everywhere
    leagueNotifier.changeOddsStyle(value);
  }

  void loadInitial() {
    // Use sync method to avoid race condition where UI renders
    // with default value before async load completes
    final styleName = sportStorage.getOddsStyleSync();
    final style = OddsStyle.fromShortName(styleName);
    state = state.copyWith(oddsStyle: style);
  }
}

@immutable
class BetPreferences {
  const BetPreferences({required this.oddsStyle});

  const BetPreferences.initial({this.oddsStyle = OddsStyle.decimal});

  final OddsStyle oddsStyle;

  @override
  String toString() => 'BetPreferences(oddsStyle: $oddsStyle)';

  @override
  bool operator ==(covariant BetPreferences other) {
    if (identical(this, other)) return true;

    return other.oddsStyle == oddsStyle;
  }

  @override
  int get hashCode => oddsStyle.hashCode;

  BetPreferences copyWith({OddsStyle? oddsStyle}) =>
      BetPreferences(oddsStyle: oddsStyle ?? this.oddsStyle);
}
