/// Event status enum
///
/// Maps to status field in event_up message
enum EventStatus {
  /// Event is active, can bet normally
  active('ACTIVE'),

  /// Event is temporarily suspended
  suspended('SUSPENDED'),

  /// Event is manually hidden
  hidden('HIDDEN'),

  /// Event is automatically hidden
  autoHidden('AUTO_HIDDEN'),

  /// Event has finished
  finished('FINISHED');

  final String value;
  const EventStatus(this.value);

  /// Parse from string value
  static EventStatus fromString(String? value) {
    if (value == null) return EventStatus.active;
    final upperValue = value.toUpperCase();
    return EventStatus.values.firstWhere(
      (s) => s.value == upperValue,
      orElse: () => EventStatus.active,
    );
  }

  /// Whether betting is allowed on this event
  bool get canBet => this == EventStatus.active;

  /// Whether event should be visible
  bool get isVisible =>
      this != EventStatus.hidden && this != EventStatus.autoHidden;

  /// Whether event is locked (any non-active status)
  bool get isLocked => this != EventStatus.active;

  /// Whether event is suspended specifically
  bool get isSuspendedStatus => this == EventStatus.suspended;

  /// Whether event is hidden (any type)
  bool get isHiddenStatus =>
      this == EventStatus.hidden || this == EventStatus.autoHidden;
}

/// Event data model.
///
/// Represents a sports event/match.
/// Mutable to allow in-place updates for performance.
class EventData {
  /// Event ID
  final int eventId;

  /// League ID this event belongs to
  final int leagueId;

  /// Sport ID
  final int sportId;

  // ===== Team info =====

  /// Home team name
  String homeName;

  /// Away team name
  String awayName;

  /// Home team ID
  int homeId;

  /// Away team ID
  int awayId;

  /// Home team logo URL
  String? homeLogo;

  /// Away team logo URL
  String? awayLogo;

  // ===== Event status =====

  /// Event status string (e.g., "ACTIVE", "SUSPENDED", "FINISHED")
  String status;

  /// Get status as enum
  EventStatus get statusEnum => EventStatus.fromString(status);

  /// Whether betting is allowed (derived from status)
  bool get canBet => statusEnum.canBet;

  /// Whether event is locked (derived from status)
  bool get isLocked => statusEnum.isLocked;

  /// Whether event is live
  bool isLive;

  /// Whether event is about to go live
  bool isGoingLive;

  /// Whether livestream is available
  bool isLiveStream;

  /// Whether event is suspended
  bool isSuspended;

  /// Start date/time
  DateTime? startDate;

  /// Event stats ID for tracker
  int? eventStatsId;

  // ===== Live data (nullable, only when isLive = true) =====

  /// Home team score
  int? homeScore;

  /// Away team score
  int? awayScore;

  /// Previous home score (for animation)
  int? previousHomeScore;

  /// Previous away score (for animation)
  int? previousAwayScore;

  /// Game time in milliseconds
  int? gameTime;

  /// Current game part/period (1 = 1st half, 2 = 2nd half, etc.)
  int? gamePart;

  /// Stoppage/injury time in milliseconds
  int? stoppageTime;

  /// Home team red cards
  int? redCardsHome;

  /// Away team red cards
  int? redCardsAway;

  /// Home team yellow cards
  int? yellowCardsHome;

  /// Away team yellow cards
  int? yellowCardsAway;

  /// Home team corners
  int? cornersHome;

  /// Away team corners
  int? cornersAway;

  /// Home 1st half score
  String? homeScoreH1;

  /// Away 1st half score
  String? awayScoreH1;

  // ===== Additional info =====

  /// Total markets count
  int totalMarketsCount;

  /// Whether parlay is enabled
  bool isParlay;

  // ===== Version tracking =====

  int _version = 0;

  /// Version number, incremented on each update
  int get version => _version;

  EventData({
    required this.eventId,
    required this.leagueId,
    required this.sportId,
    required this.homeName,
    required this.awayName,
    this.homeId = 0,
    this.awayId = 0,
    this.homeLogo,
    this.awayLogo,
    this.status = 'ACTIVE',
    this.isLive = false,
    this.isGoingLive = false,
    this.isLiveStream = false,
    this.isSuspended = false,
    this.startDate,
    this.eventStatsId,
    this.homeScore,
    this.awayScore,
    this.gameTime,
    this.gamePart,
    this.stoppageTime,
    this.redCardsHome,
    this.redCardsAway,
    this.yellowCardsHome,
    this.yellowCardsAway,
    this.cornersHome,
    this.cornersAway,
    this.homeScoreH1,
    this.awayScoreH1,
    this.totalMarketsCount = 0,
    this.isParlay = false,
  });

  /// Create from parsed JSON data
  factory EventData.fromJson(Map<String, dynamic> json) {
    final eventId = _parseInt(json['eventId'] ?? json['ei']) ?? 0;
    final leagueId = _parseInt(json['leagueId'] ?? json['li']) ?? 0;
    final sportId = _parseInt(json['sportId'] ?? json['s']) ?? 0;

    final event = EventData(
      eventId: eventId,
      leagueId: leagueId,
      sportId: sportId,
      homeName: json['homeName']?.toString() ?? json['hn']?.toString() ?? '',
      awayName: json['awayName']?.toString() ?? json['an']?.toString() ?? '',
    );

    event._applyJson(json);
    return event;
  }

  /// Update from JSON data
  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    // Team info
    if (data.containsKey('homeName') || data.containsKey('hn')) {
      homeName =
          data['homeName']?.toString() ?? data['hn']?.toString() ?? homeName;
    }
    if (data.containsKey('awayName') || data.containsKey('an')) {
      awayName =
          data['awayName']?.toString() ?? data['an']?.toString() ?? awayName;
    }
    if (data.containsKey('homeId') || data.containsKey('hi')) {
      homeId = _parseInt(data['homeId'] ?? data['hi']) ?? homeId;
    }
    if (data.containsKey('awayId') || data.containsKey('ai')) {
      awayId = _parseInt(data['awayId'] ?? data['ai']) ?? awayId;
    }

    // Logos - follow web logic: hf || hl, af || al
    if (data.containsKey('hf') || data.containsKey('hl')) {
      homeLogo = data['hf']?.toString() ?? data['hl']?.toString();
    }
    if (data.containsKey('af') || data.containsKey('al')) {
      awayLogo = data['af']?.toString() ?? data['al']?.toString();
    }

    // Status
    if (data.containsKey('status') || data.containsKey('es')) {
      status = data['status']?.toString() ?? data['es']?.toString() ?? status;
    }
    if (data.containsKey('isLive') || data.containsKey('l')) {
      isLive = _parseBool(data['isLive'] ?? data['l']);
    }
    if (data.containsKey('isGoingLive') || data.containsKey('gl')) {
      isGoingLive = _parseBool(data['isGoingLive'] ?? data['gl']);
    }
    if (data.containsKey('isLiveStream') || data.containsKey('ls')) {
      isLiveStream = _parseBool(data['isLiveStream'] ?? data['ls']);
    }
    if (data.containsKey('isSuspended') || data.containsKey('s')) {
      isSuspended = _parseBool(data['isSuspended'] ?? data['s']);
    }

    // Start date
    if (data.containsKey('startDate') ||
        data.containsKey('st') ||
        data.containsKey('et')) {
      final dateValue = data['startDate'] ?? data['st'] ?? data['et'];
      startDate = _parseDateTime(dateValue);
    }

    // Event stats ID
    if (data.containsKey('eventStatsId') || data.containsKey('esi')) {
      eventStatsId = _parseInt(data['eventStatsId'] ?? data['esi']);
    }

    // Live data
    if (data.containsKey('homeScore') || data.containsKey('hs')) {
      homeScore = _parseInt(data['homeScore'] ?? data['hs']);
    }
    if (data.containsKey('awayScore') || data.containsKey('as')) {
      awayScore = _parseInt(data['awayScore'] ?? data['as']);
    }
    if (data.containsKey('gameTime') || data.containsKey('gt')) {
      gameTime = _parseInt(data['gameTime'] ?? data['gt']);
    }
    if (data.containsKey('gamePart') || data.containsKey('gp')) {
      gamePart = _parseInt(data['gamePart'] ?? data['gp']);
    }
    if (data.containsKey('stoppageTime') || data.containsKey('stm')) {
      stoppageTime = _parseInt(data['stoppageTime'] ?? data['stm']);
    }

    // Cards
    if (data.containsKey('redCardsHome') || data.containsKey('rch')) {
      redCardsHome = _parseInt(data['redCardsHome'] ?? data['rch']);
    }
    if (data.containsKey('redCardsAway') || data.containsKey('rca')) {
      redCardsAway = _parseInt(data['redCardsAway'] ?? data['rca']);
    }
    if (data.containsKey('yellowCardsHome') || data.containsKey('ych')) {
      yellowCardsHome = _parseInt(data['yellowCardsHome'] ?? data['ych']);
    }
    if (data.containsKey('yellowCardsAway') || data.containsKey('yca')) {
      yellowCardsAway = _parseInt(data['yellowCardsAway'] ?? data['yca']);
    }

    // Corners
    if (data.containsKey('cornersHome') || data.containsKey('hc')) {
      cornersHome = _parseInt(data['cornersHome'] ?? data['hc']);
    }
    if (data.containsKey('cornersAway') || data.containsKey('ac')) {
      cornersAway = _parseInt(data['cornersAway'] ?? data['ac']);
    }

    // Half scores
    if (data.containsKey('homeScoreH1')) {
      homeScoreH1 = data['homeScoreH1']?.toString();
    }
    if (data.containsKey('awayScoreH1')) {
      awayScoreH1 = data['awayScoreH1']?.toString();
    }

    // Additional
    if (data.containsKey('totalMarketsCount') || data.containsKey('mc')) {
      totalMarketsCount = _parseInt(data['totalMarketsCount'] ?? data['mc']) ??
          totalMarketsCount;
    }
    if (data.containsKey('isParlay') || data.containsKey('ip')) {
      isParlay = _parseBool(data['isParlay'] ?? data['ip']);
    }
  }

  // ===== Helper methods =====

  /// Get display score string
  String get scoreDisplay {
    if (homeScore == null || awayScore == null) return '-';
    return '$homeScore - $awayScore';
  }

  /// Get display time string (in minutes)
  String get timeDisplay {
    if (gameTime == null) return '';
    final minutes = (gameTime! / 60000).floor();
    if (stoppageTime != null && stoppageTime! > 0) {
      final stoppageMinutes = (stoppageTime! / 60000).floor();
      return "$minutes'+$stoppageMinutes";
    }
    return "$minutes'";
  }

  /// Get game part display
  String get periodDisplay {
    switch (gamePart) {
      case 1:
        return '1H';
      case 2:
        return '2H';
      case 3:
        return 'HT'; // Half time
      case 4:
        return 'ET'; // Extra time
      case 5:
        return 'PEN'; // Penalties
      default:
        return '';
    }
  }

  /// Full event name
  String get fullName => '$homeName vs $awayName';

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final asInt = int.tryParse(value);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  String toString() {
    return 'EventData(eventId: $eventId, $homeName vs $awayName, '
        'isLive: $isLive, score: $scoreDisplay)';
  }
}
