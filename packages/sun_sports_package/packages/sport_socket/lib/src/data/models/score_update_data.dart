/// Data emitted when score_up or event_up (with score) message received.
///
/// Used by consumers to update score displays without polling the DataStore.
class ScoreUpdateData {
  /// Event ID
  final int eventId;

  /// Sport ID
  final int sportId;

  /// Home team score
  final int homeScore;

  /// Away team score
  final int awayScore;

  /// Timestamp when update was received
  final DateTime timestamp;

  const ScoreUpdateData({
    required this.eventId,
    required this.sportId,
    required this.homeScore,
    required this.awayScore,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ScoreUpdateData(eventId: $eventId, score: $homeScore-$awayScore)';
  }
}
