/// Favorite data model
///
/// Represents favorite leagues and events for a specific sport.
class FavoriteData {
  final int sportId;
  final List<int> leagueIds;
  final List<int> eventIds;

  const FavoriteData({
    required this.sportId,
    required this.leagueIds,
    required this.eventIds,
  });

  /// Create from API response
  ///
  /// Response format:
  /// {
  ///   "1": {
  ///     "0": [339, 123, 60],           // league IDs
  ///     "1": [4465636, 4549777, ...], // event IDs
  ///     "2": []
  ///   }
  /// }
  factory FavoriteData.fromJson(Map<String, dynamic> json, int sportId) {
    final sportData = json[sportId.toString()];
    if (sportData is Map<String, dynamic>) {
      final leagueIds =
          (sportData['0'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [];
      final eventIds =
          (sportData['1'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [];

      return FavoriteData(
        sportId: sportId,
        leagueIds: leagueIds,
        eventIds: eventIds,
      );
    }

    // Return empty if parsing fails
    return FavoriteData(sportId: sportId, leagueIds: [], eventIds: []);
  }

  /// Check if league is favorite
  bool isLeagueFavorite(int leagueId) => leagueIds.contains(leagueId);

  /// Check if event is favorite
  bool isEventFavorite(int eventId) => eventIds.contains(eventId);

  /// Check if empty (no favorites)
  bool get isEmpty => leagueIds.isEmpty && eventIds.isEmpty;

  /// Get total favorite count
  int get totalCount => leagueIds.length + eventIds.length;
}
