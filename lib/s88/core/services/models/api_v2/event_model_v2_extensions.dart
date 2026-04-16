import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/score_model_v2.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

/// Extension methods for EventModelV2 to add UI helper methods
/// These mirror the functionality of LeagueEventDataX extension
extension EventModelV2UIExtension on EventModelV2 {
  /// Get formatted time (dd/MM/yyyy | HH:mm)
  String get formattedTime {
    final dt = startDateTime;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year | $hour:$minute';
  }

  /// Get formatted date (dd/MM)
  String get formattedDate {
    final dt = startDateTime;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  /// Get home score as int
  int get homeScoreInt {
    if (score == null) return 0;
    return int.tryParse(score!.homeScore) ?? 0;
  }

  /// Get away score as int
  int get awayScoreInt {
    if (score == null) return 0;
    return int.tryParse(score!.awayScore) ?? 0;
  }

  /// Get score string
  String get scoreString => '${homeScoreInt} - ${awayScoreInt}';

  /// Get match minute string for live matches
  /// Converts gameTime from milliseconds to minutes
  String get minuteString {
    if (!isLive) return '';

    // Convert gameTime from milliseconds to minutes
    final minutes = gameTime > 0 ? (gameTime / 1000 / 60).ceil() : 0;

    // If we have valid gameTime, use it
    if (minutes > 0) {
      return "$minutes'";
    }

    return 'LIVE';
  }

  /// Get game part display enum
  GamePart get gamePartEnum => GamePart.fromInt(gamePart);

  /// Get yellow cards home (from soccer score)
  int get yellowCardsHome {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).yellowCardsHome;
    }
    return 0;
  }

  /// Get yellow cards away (from soccer score)
  int get yellowCardsAway {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).yellowCardsAway;
    }
    return 0;
  }

  /// Get red cards home (from soccer score)
  int get redCardsHome {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).redCardsHome;
    }
    return 0;
  }

  /// Get red cards away (from soccer score)
  int get redCardsAway {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).redCardsAway;
    }
    return 0;
  }

  /// Get corners home (from soccer score)
  int get cornersHome {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).homeCorner;
    }
    return 0;
  }

  /// Get corners away (from soccer score)
  int get cornersAway {
    if (score is SoccerScoreModelV2) {
      return (score as SoccerScoreModelV2).awayCorner;
    }
    return 0;
  }

  /// Check if event can be bet on
  bool get canBet => !isSuspended;

  /// Check if has any valid markets
  bool get hasMarkets => markets.isNotEmpty;

  /// Get total cards (red + yellow)
  int get totalCardsHome => redCardsHome + yellowCardsHome;
  int get totalCardsAway => redCardsAway + yellowCardsAway;
}
