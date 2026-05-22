/// Data emitted when event_up message received with status/time changes.
///
/// Contains all live event state including status, timing, and stats.
class EventStatusData {
  /// Event ID
  final int eventId;

  /// Sport ID
  final int sportId;

  // ===== Status =====

  /// Status string ("ACTIVE", "SUSPENDED", "HIDDEN", "FINISHED")
  final String? status;

  /// Whether event is suspended
  final bool isSuspended;

  /// Whether event is currently live (from 'l' field)
  final bool? isLive;

  /// Whether event has livestream available (from 'ls' field)
  final bool? isLivestream;

  /// Detailed event status string (from 'es' field)
  final String? eventStatus;

  // ===== Live timing =====

  /// Game time in milliseconds
  final int? gameTime;

  /// Current game part/period (1=1H, 2=2H, 3=HT, etc.)
  final int? gamePart;

  /// Stoppage/injury time in milliseconds
  final int? stoppageTime;

  // ===== Stats =====

  /// Home team corners
  final int? cornersHome;

  /// Away team corners
  final int? cornersAway;

  /// Home team yellow cards
  final int? yellowCardsHome;

  /// Away team yellow cards
  final int? yellowCardsAway;

  /// Home team red cards
  final int? redCardsHome;

  /// Away team red cards
  final int? redCardsAway;

  // ===== Score (also in event_up) =====

  /// Home team score
  final int? homeScore;

  /// Away team score
  final int? awayScore;

  /// Timestamp when update was received
  final DateTime timestamp;

  const EventStatusData({
    required this.eventId,
    required this.sportId,
    this.status,
    this.isSuspended = false,
    this.isLive,
    this.isLivestream,
    this.eventStatus,
    this.gameTime,
    this.gamePart,
    this.stoppageTime,
    this.cornersHome,
    this.cornersAway,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.redCardsHome,
    this.redCardsAway,
    this.homeScore,
    this.awayScore,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'EventStatusData(eventId: $eventId, status: $status, '
        'gameTime: $gameTime, gamePart: $gamePart)';
  }
}
