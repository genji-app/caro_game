import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import 'league_provider.dart';

/// Holds the currently selected league info for league detail page.
class SelectedLeagueInfo {
  final int sportId;
  final int leagueId;
  final String leagueName;
  final String leagueLogo;

  const SelectedLeagueInfo({
    required this.sportId,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
  });
}

/// Provider to store the selected league info when navigating to league detail.
final selectedLeagueInfoProvider = StateProvider<SelectedLeagueInfo?>(
  (ref) => null,
);

/// Fetches all events for a specific league by leagueId + sportId.
///
/// Uses EventsRequestModel with leagueIds filter and timeRange=4 (all).
/// Returns List<LeagueModelV2> (typically 1 item with all events for that league).
final leagueDetailEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, SelectedLeagueInfo>((ref, info) async {
      final token = CancelToken();
      ref.onDispose(token.cancel);

      final http = ref.read(sbHttpManagerProvider);
      final request = EventsRequestModel(
        sportId: info.sportId,
        timeRange: 4,
        leagueIds: [info.leagueId],
      );
      final leagues = await http.getEventsV2(request, cancelToken: token);

      return leagues;
    });
