import 'package:dartz/dartz.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/features/home/domain/repositories/hot_match_repository.dart';

/// Fetch Hot Matches Use Case
///
/// Single responsibility: Fetch hot matches from repository.
/// Returns [Right] with list of [LeagueModelV2] on success.
class FetchHotMatchesUseCase {
  final HotMatchRepository _repository;

  FetchHotMatchesUseCase(this._repository);

  Future<Either<Failure, List<LeagueModelV2>>> call() async {
    return _repository.getHotMatches();
  }
}
