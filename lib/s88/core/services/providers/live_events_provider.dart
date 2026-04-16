import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import 'league_provider.dart';

/// Fetches live events V2 for a given sportId.
///
/// Uses EventsRequestModel.live(sportId) with timeRange=0 (Live).
/// Returns List<LeagueModelV2> containing only leagues with live events.
final liveLeagueEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, int>((ref, sportId) async {
      final token = CancelToken();
      ref.onDispose(token.cancel);

      final http = ref.read(sbHttpManagerProvider);
      final request = EventsRequestModel.live(sportId);
      final leagues = await http.getEventsV2(request, cancelToken: token);

      return leagues;
    });
