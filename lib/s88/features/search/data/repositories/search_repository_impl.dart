import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/search/data/datasources/search_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_response_model.dart';
import 'package:co_caro_flame/s88/features/search/domain/repositories/search_repository.dart';

/// Implements [SearchRepository]; uses [SearchRemoteDataSource] and maps to [SearchResponseModel].
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._dataSource);

  final SearchRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, SearchResponseModel>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    try {
      final raw = await _dataSource.search(query, cancelToken: cancelToken);
      return Right(SearchResponseModel.fromJson(raw));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
