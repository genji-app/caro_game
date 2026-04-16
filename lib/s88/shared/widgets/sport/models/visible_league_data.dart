import 'package:co_caro_flame/s88/core/services/models/league_model.dart';

/// Helper class for pagination - tracks visible leagues and match counts
class VisibleLeagueData {
  final LeagueData league;
  final int visibleMatchCount;

  const VisibleLeagueData({
    required this.league,
    required this.visibleMatchCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibleLeagueData &&
          league.leagueId == other.league.leagueId &&
          visibleMatchCount == other.visibleMatchCount;

  @override
  int get hashCode => Object.hash(league.leagueId, visibleMatchCount);
}

/// Extension for pagination calculations
extension LeagueListPagination on List<LeagueData> {
  /// Paginate leagues based on visible matches count
  List<VisibleLeagueData> paginate(int visibleMatchesCount) {
    final result = <VisibleLeagueData>[];
    int matchCount = 0;

    for (final league in this) {
      if (league.events.isEmpty) continue;

      final remainingSlots = visibleMatchesCount - matchCount;
      if (remainingSlots <= 0) break;

      final matchesToShow = league.events.length.clamp(0, remainingSlots);
      result.add(
        VisibleLeagueData(league: league, visibleMatchCount: matchesToShow),
      );

      matchCount += matchesToShow;
    }

    return result;
  }

  /// Get total match count across all leagues
  int get totalMatchCount => fold<int>(0, (sum, l) => sum + l.events.length);
}
