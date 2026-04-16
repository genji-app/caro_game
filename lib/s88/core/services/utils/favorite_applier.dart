import 'package:flutter/foundation.dart';

import '../models/api_v2/event_model_v2.dart';
import '../models/api_v2/league_model_v2.dart';
import '../models/favorite_data.dart';

/// Utility class to apply favorite status to leagues and events
class FavoriteApplier {
  /// Apply favorite status to leagues and events based on favorite data
  ///
  /// Logic:
  /// 1. League: isFavorited = true chỉ khi leagueId nằm trong FavoriteData.leagueIds.
  /// 2. Nếu league có isFavorited = true → tất cả event trong league đó isFavorited = true.
  /// 3. Nếu event có eventId nằm trong FavoriteData.eventIds → event đó isFavorited = true
  ///    (dù league không nằm trong leagueIds thì league vẫn isFavorited = false).
  static List<LeagueModelV2> applyFavorites(
    List<LeagueModelV2> leagues,
    FavoriteData? favoriteData,
  ) {
    if (favoriteData == null || favoriteData.isEmpty) {
      // No favorites → all isFavorited = false (default)
      return leagues;
    }

    final favoriteLeagueIds = favoriteData.leagueIds.toSet();
    final favoriteEventIds = favoriteData.eventIds.toSet();

    return leagues.map((league) {
      // Check if league is favorite
      final isLeagueFavorite = favoriteLeagueIds.contains(league.leagueId);

      // Update events
      final updatedEvents = league.events.map((event) {
        // Event is favorite if:
        // 1. League is favorite (all events in favorite league are favorite)
        // 2. OR event ID is in favorite event IDs
        final isEventFavorite =
            isLeagueFavorite || favoriteEventIds.contains(event.eventId);

        // Only update if different to avoid unnecessary copies
        if (event.isFavorited == isEventFavorite) {
          return event;
        }

        return event.copyWith(isFavorited: isEventFavorite);
      }).toList();

      // Update league (isFavorited = true if league is in favorites)
      final updatedLeague = league.copyWith(
        isFavorited: isLeagueFavorite,
        events: updatedEvents,
      );

      // Debug: Log if league is favorite but events are not
      if (kDebugMode && isLeagueFavorite) {
        final eventsNotFavorite = updatedEvents
            .where((e) => !e.isFavorited)
            .length;
        if (eventsNotFavorite > 0) {
          debugPrint(
            '[FavoriteApplier] WARNING: League ${league.leagueId} is favorite '
            'but $eventsNotFavorite events are not favorite!',
          );
        } else {
          debugPrint(
            '[FavoriteApplier] League ${league.leagueId} is favorite '
            'with ${updatedEvents.length} events (all favorite)',
          );
        }
      }

      return updatedLeague;
    }).toList();
  }

  /// Apply favorite status to a single league
  static LeagueModelV2 applyFavoritesToLeague(
    LeagueModelV2 league,
    FavoriteData? favoriteData,
  ) {
    if (favoriteData == null || favoriteData.isEmpty) {
      return league;
    }

    final favoriteLeagueIds = favoriteData.leagueIds.toSet();
    final favoriteEventIds = favoriteData.eventIds.toSet();

    final isLeagueFavorite = favoriteLeagueIds.contains(league.leagueId);

    final updatedEvents = league.events.map((event) {
      final isEventFavorite =
          isLeagueFavorite || favoriteEventIds.contains(event.eventId);
      return event.copyWith(isFavorited: isEventFavorite);
    }).toList();

    return league.copyWith(
      isFavorited: isLeagueFavorite,
      events: updatedEvents,
    );
  }

  /// Apply favorite status to a single event
  static EventModelV2 applyFavoritesToEvent(
    EventModelV2 event,
    FavoriteData? favoriteData,
  ) {
    if (favoriteData == null || favoriteData.isEmpty) {
      return event;
    }

    final favoriteEventIds = favoriteData.eventIds.toSet();
    final isEventFavorite = favoriteEventIds.contains(event.eventId);

    return event.copyWith(isFavorited: isEventFavorite);
  }
}
