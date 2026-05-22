import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import '../models/api_v2/league_pin_item.dart';
import 'league_provider.dart';

/// Fetches pinned leagues for a sport, then events V2 for those league IDs.
/// Merges result: keeps pin order; leagues with no events show name only (no event list).
/// When pin returns empty: fallback to getPopularLeagues() filtered by sportId.
///
/// Flow: GET /api/v1/leagues/pin?sportId=X → GET events V2 with those leagueIds
/// → merge. If pin empty → getPopularLeagues() filtered by sportId.
final topLeagueEventsProvider = FutureProvider.autoDispose
    .family<List<LeagueModelV2>, int>((ref, sportId) async {
      // Keep provider alive to prevent data loss during rapid rebuilds
      // (e.g. when sidebar triggers multiple provider changes at once).
      // Without this, autoDispose can briefly dispose the provider between
      // frames in release mode, causing the sidebar leagues to disappear.
      ref.keepAlive();

      final token = CancelToken();
      ref.onDispose(token.cancel);

      final http = ref.read(sbHttpManagerProvider);
      final pinList = await http.getLeaguesPin(sportId, cancelToken: token);

      if (pinList.isEmpty) {
        final popular = await http.getPopularLeagues();
        return popular.where((l) => l.sportId == sportId).take(20).toList();
      }

      final leagueIds = pinList.map((e) => e.leagueId).toList();
      final request = EventsRequestModel(
        sportId: sportId,
        timeRange: 4,
        leagueIds: leagueIds,
      );
      final leaguesFromApi = await http.getEventsV2(
        request,
        cancelToken: token,
      );
      final byId = {for (final l in leaguesFromApi) l.leagueId: l};

      // Preserve pin order; for leagues with no events use pin name/logo, show no event list
      return pinList.map((pin) {
        final existing = byId[pin.leagueId];
        if (existing != null) {
          return existing; // may have events or empty
        }
        return LeagueModelV2(
          sportId: sportId,
          leagueId: pin.leagueId,
          leagueName: pin.name,
          leagueNameEn: pin.name,
          leagueLogo: pin.logoUrl,
          priorityOrder: pin.sortOrder,
          events: const [],
        );
      }).toList();
    });
