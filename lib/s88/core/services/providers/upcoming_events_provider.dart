import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import 'league_provider.dart';

/// Fetches upcoming events V2 (Today + Early) for a given sportId.
///
/// Uses EventsRequestModel with timeRange=3 (Today + Early).
/// Returns List<LeagueModelV2> containing leagues with upcoming events.
final upcomingLeagueEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, int>((ref, sportId) async {
      final token = CancelToken();
      ref.onDispose(token.cancel);

      final http = ref.read(sbHttpManagerProvider);
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: 3, // 3 = Today + Early
      );
      final leagues = await http.getEventsV2(request, cancelToken: token);

      return leagues;
    });
