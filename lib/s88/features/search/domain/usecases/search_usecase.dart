import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_response_model.dart';
import 'package:co_caro_flame/s88/features/search/domain/repositories/search_repository.dart';

/// Search use case: executes search via [SearchRepository].
class SearchUseCase {
  final SearchRepository _repository;

  SearchUseCase(this._repository);

  Future<Either<Failure, SearchResponseModel>> call(
    String query, {
    CancelToken? cancelToken,
  }) async {
    return _repository.search(query, cancelToken: cancelToken);
  }
}
