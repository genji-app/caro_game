import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/features/sport/data/model/special_outright_model.dart';
import 'package:co_caro_flame/s88/features/sport/domain/repositories/sport_repository.dart';

/// Fetch Leagues Use Case
///
/// Single responsibility: Fetch leagues from repository.
class FetchLeaguesUseCase {
  final SportRepository _repository;

  FetchLeaguesUseCase(this._repository);

  /// Execute the use case
  ///
  /// [sportId] - Optional sport type ID
  /// [days] - Filter by day (0=today, 1=tomorrow)
  /// [isLive] - Filter live matches only
  Future<Either<Failure, List<LeagueData>>> call({
    int? sportId,
    int? days,
    bool? isLive,
  }) async {
    return await _repository.getLeagues(
      sportId: sportId,
      days: days,
      isLive: isLive,
    );
  }
}

/// Fetch Live Leagues Use Case
class FetchLiveLeaguesUseCase {
  final SportRepository _repository;

  FetchLiveLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getLiveLeagues();
  }
}

/// Fetch Today Leagues Use Case
class FetchTodayLeaguesUseCase {
  final SportRepository _repository;

  FetchTodayLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getTodayLeagues();
  }
}

/// Fetch Hot Leagues Use Case
class FetchHotLeaguesUseCase {
  final SportRepository _repository;

  FetchHotLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getHotLeagues();
  }
}

/// Fetch Outright Leagues Use Case
class FetchOutrightLeaguesUseCase {
  final SportRepository _repository;

  FetchOutrightLeaguesUseCase(this._repository);

  Future<Either<Failure, List<LeagueData>>> call() async {
    return await _repository.getOutrightLeagues();
  }
}

/// Fetch Special Outright Use Case
///
/// Fetches special outright data for the special tab for the given [sportId].
class FetchSpecialOutrightUseCase {
  final SportRepository _repository;

  FetchSpecialOutrightUseCase(this._repository);

  Future<Either<Failure, List<SpecialOutrightModel>>> call(int sportId) async {
    return await _repository.getSpecialOutright(sportId);
  }
}
