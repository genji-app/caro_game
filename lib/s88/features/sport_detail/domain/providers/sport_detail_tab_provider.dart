import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/enums/sport_filter_enums.dart';

/// Provider to store the selected tab in Sport Detail screen
/// This allows the tab state to persist when navigating to Bet Detail and back
///
/// NOTE: This syncs with LeagueState.currentTimeRange
/// Default is LIVE to match LeagueState default
final sportDetailTabProvider = StateProvider<SportDetailFilterType>(
  (ref) => SportDetailFilterType.live,
);
