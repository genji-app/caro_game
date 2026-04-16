import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_model_v2.freezed.dart';

/// Abstract base class for Score Response
/// Different sports have different score structures
sealed class ScoreModelV2 {
  int get sportId;
  String get homeScore;
  String get awayScore;

  /// Factory method to create appropriate score model based on sportId
  static ScoreModelV2? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final sportId = _parseInt(json['0']);

    switch (sportId) {
      case 1: // Soccer
        return SoccerScoreModelV2.fromJson(json);
      case 2: // Basketball
        return BasketballScoreModelV2.fromJson(json);
      case 4: // Tennis
        return TennisScoreModelV2.fromJson(json);
      case 5: // Volleyball
        return VolleyballScoreModelV2.fromJson(json);
      case 6: // Table Tennis
        return TableTennisScoreModelV2.fromJson(json);
      case 7: // Badminton
        return BadmintonScoreModelV2.fromJson(json);
      default:
        return GenericScoreModelV2.fromJson(json);
    }
  }
}

/// Soccer Score Model V2
@freezed
sealed class SoccerScoreModelV2
    with _$SoccerScoreModelV2
    implements ScoreModelV2 {
  const factory SoccerScoreModelV2({
    /// Sport ID (always 1 for Soccer)
    @Default(1) int sportId,

    /// Home score full time
    @Default(0) int homeScoreFT,

    /// Away score full time
    @Default(0) int awayScoreFT,

    /// Home score second half
    @Default(0) int homeScoreH2,

    /// Away score second half
    @Default(0) int awayScoreH2,

    /// Home team corner count
    @Default(0) int homeCorner,

    /// Away team corner count
    @Default(0) int awayCorner,

    /// Home score overtime
    @Default(0) int homeScoreOT,

    /// Away score overtime
    @Default(0) int awayScoreOT,

    /// Home score penalty
    @Default(0) int homeScorePen,

    /// Away score penalty
    @Default(0) int awayScorePen,

    /// Home yellow cards
    @Default(0) int yellowCardsHome,

    /// Away yellow cards
    @Default(0) int yellowCardsAway,

    /// Home red cards
    @Default(0) int redCardsHome,

    /// Away red cards
    @Default(0) int redCardsAway,
  }) = _SoccerScoreModelV2;

  const SoccerScoreModelV2._();

  factory SoccerScoreModelV2.fromJson(Map<String, dynamic> json) {
    return SoccerScoreModelV2(
      sportId: _parseInt(json['0']),
      homeScoreFT: _parseInt(json['100']),
      awayScoreFT: _parseInt(json['101']),
      homeScoreH2: _parseInt(json['102']),
      awayScoreH2: _parseInt(json['103']),
      homeCorner: _parseInt(json['104']),
      awayCorner: _parseInt(json['105']),
      homeScoreOT: _parseInt(json['106']),
      awayScoreOT: _parseInt(json['107']),
      homeScorePen: _parseInt(json['108']),
      awayScorePen: _parseInt(json['109']),
      yellowCardsHome: _parseInt(json['110']),
      yellowCardsAway: _parseInt(json['111']),
      redCardsHome: _parseInt(json['112']),
      redCardsAway: _parseInt(json['113']),
    );
  }

  @override
  String get homeScore => homeScoreFT.toString();

  @override
  String get awayScore => awayScoreFT.toString();

  /// Get first half score for home team
  int get homeScoreH1 => homeScoreFT - homeScoreH2;

  /// Get first half score for away team
  int get awayScoreH1 => awayScoreFT - awayScoreH2;

  /// Total corners in the match
  int get totalCorners => homeCorner + awayCorner;

  /// Total goals
  int get totalGoals => homeScoreFT + awayScoreFT;

  /// Check if match has overtime
  bool get hasOvertime => homeScoreOT > 0 || awayScoreOT > 0;

  /// Check if match has penalty shootout
  bool get hasPenalty => homeScorePen > 0 || awayScorePen > 0;

  /// Get display score string
  String get displayScore => '$homeScoreFT - $awayScoreFT';

  /// Get first half display score
  String get firstHalfScore => '$homeScoreH1 - $awayScoreH1';

  /// Get corner display score
  String get cornerScore => '$homeCorner - $awayCorner';

  /// Total yellow cards
  int get totalYellowCards => yellowCardsHome + yellowCardsAway;

  /// Total red cards
  int get totalRedCards => redCardsHome + redCardsAway;
}

/// Basketball Score Model V2
@freezed
sealed class BasketballScoreModelV2
    with _$BasketballScoreModelV2
    implements ScoreModelV2 {
  const factory BasketballScoreModelV2({
    /// Sport ID (2 for Basketball)
    @Default(2) int sportId,

    /// Live scores per quarter - list of HomeAwayScoreV2 pairs
    @Default([]) List<HomeAwayScoreV2> liveScores,

    /// Home score full time
    @Default(0) int homeScoreFT,

    /// Away score full time
    @Default(0) int awayScoreFT,

    /// Home score overtime
    @Default(0) int homeScoreOT,

    /// Away score overtime
    @Default(0) int awayScoreOT,
  }) = _BasketballScoreModelV2;

  const BasketballScoreModelV2._();

  factory BasketballScoreModelV2.fromJson(Map<String, dynamic> json) {
    final liveScores = <HomeAwayScoreV2>[];
    final rawScores = json['200'];
    if (rawScores is List) {
      for (final item in rawScores) {
        if (item is Map) {
          liveScores.add(
            HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return BasketballScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeScoreFT: _parseInt(json['201']),
      awayScoreFT: _parseInt(json['202']),
      homeScoreOT: _parseInt(json['203']),
      awayScoreOT: _parseInt(json['204']),
    );
  }

  @override
  String get homeScore => homeScoreFT.toString();

  @override
  String get awayScore => awayScoreFT.toString();

  /// Get current quarter
  int get currentQuarter => liveScores.length;

  /// Check if in overtime
  bool get isOvertime => homeScoreOT > 0 || awayScoreOT > 0;

  /// Get display score
  String get displayScore => '$homeScoreFT - $awayScoreFT';
}

/// Tennis Score Model V2
@freezed
sealed class TennisScoreModelV2
    with _$TennisScoreModelV2
    implements ScoreModelV2 {
  const factory TennisScoreModelV2({
    /// Sport ID (4 for Tennis)
    @Default(4) int sportId,

    /// Games won per set — 5 slots, empty string = set chưa diễn ra
    @Default([]) List<HomeAwayScoreV2> liveScores,

    /// Số set đã thắng — tỉ số chính "1 - 1"
    @Default(0) int homeSetScore,
    @Default(0) int awaySetScore,

    // 403/404 (homeGameScore/awayGameScore) — ABSENT in server data, skipped

    /// Điểm trong game hiện tại
    /// Regular: "0","15","30","40","Ad" — Tie-break: "1","2","3"...
    String? homeCurrentPoint,
    String? awayCurrentPoint,

    /// Bên đang giao bóng: "1" = home, "2" = away
    String? servingSide,

    /// Set đang đấu (1-based)
    @Default(0) int currentSet,

    // 409 (numOfSets) — ABSENT in server data, skipped
  }) = _TennisScoreModelV2;

  const TennisScoreModelV2._();

  factory TennisScoreModelV2.fromJson(Map<String, dynamic> json) {
    final rawList = json['400'] as List? ?? [];
    final liveScores = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => HomeAwayScoreV2.fromJson(e))
        .toList();

    return TennisScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeSetScore: _parseInt(json['401']),
      awaySetScore: _parseInt(json['402']),
      // 403/404 intentionally skipped
      homeCurrentPoint: json['405']?.toString(),
      awayCurrentPoint: json['406']?.toString(),
      servingSide: json['407']?.toString(),
      currentSet: _parseInt(json['408']),
      // 409 intentionally skipped
    );
  }

  @override
  String get homeScore => homeSetScore.toString();

  @override
  String get awayScore => awaySetScore.toString();

  /// "1" = home serving, "2" = away serving
  bool? get isHomeServing => switch (servingSide) {
    '1' => true,
    '2' => false,
    _ => null,
  };

  /// Current game point display — null if no data
  (String, String)? get currentPointDisplay {
    final h = homeCurrentPoint;
    final a = awayCurrentPoint;
    if (h == null || a == null) return null;
    return (h, a);
  }
}

/// Volleyball Score Model V2
@freezed
sealed class VolleyballScoreModelV2
    with _$VolleyballScoreModelV2
    implements ScoreModelV2 {
  const factory VolleyballScoreModelV2({
    /// Sport ID (5 for Volleyball)
    @Default(5) int sportId,

    /// Live scores per set
    @Default([]) List<HomeAwayScoreV2> liveScores,

    /// Home number of set wins
    @Default(0) int homeSetScore,

    /// Away number of set wins
    @Default(0) int awaySetScore,

    /// Home total points
    @Default(0) int homeTotalPoint,

    /// Away total points
    @Default(0) int awayTotalPoint,

    /// Serving side
    @Default('') String servingSide,

    /// Current set
    @Default(0) int currentSet,

    /// Number of sets
    @Default('') String numOfSets,
  }) = _VolleyballScoreModelV2;

  const VolleyballScoreModelV2._();

  factory VolleyballScoreModelV2.fromJson(Map<String, dynamic> json) {
    final liveScores = <HomeAwayScoreV2>[];
    final rawScores = json['500'];
    if (rawScores is List) {
      for (final item in rawScores) {
        if (item is Map) {
          liveScores.add(
            HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return VolleyballScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeSetScore: _parseInt(json['501']),
      awaySetScore: _parseInt(json['502']),
      homeTotalPoint: _parseInt(json['503']),
      awayTotalPoint: _parseInt(json['504']),
      servingSide: json['505']?.toString() ?? '',
      currentSet: _parseInt(json['506']),
      numOfSets: json['507']?.toString() ?? '',
    );
  }

  @override
  String get homeScore => homeSetScore.toString();

  @override
  String get awayScore => awaySetScore.toString();

  /// Get display score (sets)
  String get displayScore => '$homeSetScore - $awaySetScore';
}

/// Badminton Score Model V2
@freezed
sealed class BadmintonScoreModelV2
    with _$BadmintonScoreModelV2
    implements ScoreModelV2 {
  const factory BadmintonScoreModelV2({
    /// Sport ID (7 for Badminton)
    @Default(7) int sportId,

    /// Array 5 slots from server, only max 3 meaningful (numOfGames = "3")
    @Default([]) List<HomeAwayScoreV2> liveScores,

    /// Number of games won — main score "1 - 0"
    @Default(0) int homeGameScore,
    @Default(0) int awayGameScore,

    /// Total points across all games
    @Default(0) int homeTotalPoint,
    @Default(0) int awayTotalPoint,

    /// Serving side — nullable (705 absent in sample data)
    String? servingSide,

    /// Current set/game being played (1-based) — USE THIS for display, NOT gamePart
    @Default(0) int currentSet,

    /// Total number of sets: always "3" for badminton
    @Default('3') String numOfSets,
  }) = _BadmintonScoreModelV2;

  const BadmintonScoreModelV2._();

  factory BadmintonScoreModelV2.fromJson(Map<String, dynamic> json) {
    final rawList = json['700'] as List? ?? [];
    final liveScores = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return BadmintonScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeGameScore: _parseInt(json['701']),
      awayGameScore: _parseInt(json['702']),
      homeTotalPoint: _parseInt(json['703']),
      awayTotalPoint: _parseInt(json['704']),
      servingSide: json['705']?.toString(),
      currentSet: _parseInt(json['706']),
      numOfSets: json['707']?.toString() ?? '3',
    );
  }

  @override
  String get homeScore => homeGameScore.toString();

  @override
  String get awayScore => awayGameScore.toString();
}

/// Table Tennis Score Model V2
@freezed
sealed class TableTennisScoreModelV2
    with _$TableTennisScoreModelV2
    implements ScoreModelV2 {
  const factory TableTennisScoreModelV2({
    /// Sport ID (6 for Table Tennis)
    @Default(6) int sportId,

    /// Scores per set
    @Default([]) List<HomeAwayScoreV2> liveScores,

    /// Number of sets won — main score "3 - 1"
    @Default(0) int homeSetScore,
    @Default(0) int awaySetScore,

    /// Total points across all sets
    @Default(0) int homeTotalPoint,
    @Default(0) int awayTotalPoint,

    /// Serving side
    String? servingSide,

    /// Current set being played (1-based)
    @Default(0) int currentSet,

    /// Total number of sets
    @Default('7') String numOfSets,
  }) = _TableTennisScoreModelV2;

  const TableTennisScoreModelV2._();

  factory TableTennisScoreModelV2.fromJson(Map<String, dynamic> json) {
    final rawList = json['600'] as List? ?? [];
    final liveScores = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => HomeAwayScoreV2.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return TableTennisScoreModelV2(
      sportId: _parseInt(json['0']),
      liveScores: liveScores,
      homeSetScore: _parseInt(json['601']),
      awaySetScore: _parseInt(json['602']),
      homeTotalPoint: _parseInt(json['603']),
      awayTotalPoint: _parseInt(json['604']),
      servingSide: json['605']?.toString(),
      currentSet: _parseInt(json['606']),
      numOfSets: json['607']?.toString() ?? '7',
    );
  }

  @override
  String get homeScore => homeSetScore.toString();

  @override
  String get awayScore => awaySetScore.toString();
}

/// Generic Score Model for unsupported sports
@freezed
sealed class GenericScoreModelV2
    with _$GenericScoreModelV2
    implements ScoreModelV2 {
  const factory GenericScoreModelV2({
    @Default(0) int sportId,
    @Default('0') String homeScoreValue,
    @Default('0') String awayScoreValue,
  }) = _GenericScoreModelV2;

  const GenericScoreModelV2._();

  factory GenericScoreModelV2.fromJson(Map<String, dynamic> json) {
    return GenericScoreModelV2(
      sportId: _parseInt(json['0']),
      homeScoreValue: json['100']?.toString() ?? '0',
      awayScoreValue: json['101']?.toString() ?? '0',
    );
  }

  @override
  String get homeScore => homeScoreValue;

  @override
  String get awayScore => awayScoreValue;
}

/// Home Away Score pair DTO
@freezed
sealed class HomeAwayScoreV2 with _$HomeAwayScoreV2 {
  const factory HomeAwayScoreV2({
    @Default('') String homeScore,
    @Default('') String awayScore,
  }) = _HomeAwayScoreV2;

  const HomeAwayScoreV2._();

  factory HomeAwayScoreV2.fromJson(Map<String, dynamic> json) {
    return HomeAwayScoreV2(
      homeScore: json['0']?.toString() ?? '',
      awayScore: json['1']?.toString() ?? '',
    );
  }

  int get homeScoreInt => int.tryParse(homeScore) ?? 0;
  int get awayScoreInt => int.tryParse(awayScore) ?? 0;
}

/// Helper function to safely parse int
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}
