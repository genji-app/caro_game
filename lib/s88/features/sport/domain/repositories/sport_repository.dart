import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/sport/data/model/special_outright_model.dart';

/// Sport Repository Interface
///
/// Abstract interface defining contract for sport data operations.
/// Follows Clean Architecture - domain layer defines interface,
/// data layer provides implementation.
abstract class SportRepository {
  /// Fetch leagues for a specific sport
  ///
  /// [sportId] - The sport type ID
  /// [days] - Filter by day (0=today, 1=tomorrow)
  /// [isLive] - Filter live matches only
  ///
  /// Returns [Right] with list of [LeagueData] on success
  /// Returns [Left] with [Failure] on error
  Future<Either<Failure, List<LeagueData>>> getLeagues({
    int? sportId,
    int? days,
    bool? isLive,
  });

  /// Fetch live leagues only
  Future<Either<Failure, List<LeagueData>>> getLiveLeagues();

  /// Fetch today's leagues
  Future<Either<Failure, List<LeagueData>>> getTodayLeagues();

  /// Fetch hot/featured leagues
  Future<Either<Failure, List<LeagueData>>> getHotLeagues();

  /// Fetch outright leagues (championship bets)
  Future<Either<Failure, List<LeagueData>>> getOutrightLeagues();

  /// Fetch special outright data for special tab for [sportId].
  /// Returns [Right] with list of [SpecialOutrightModel] on success
  /// Returns [Left] with [Failure] on error
  Future<Either<Failure, List<SpecialOutrightModel>>> getSpecialOutright(
    int sportId,
  );

  /// Change current sport
  Future<void> changeSport(int sportId);

  /// Get current sport ID
  int get currentSportId;
}
