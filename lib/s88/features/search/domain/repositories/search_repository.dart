import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/features/search/data/models/search_response_model.dart';

/// Search repository interface (domain layer).
abstract class SearchRepository {
  /// Search by query string.
  /// Returns [Right] with [SearchResponseModel] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, SearchResponseModel>> search(
    String query, {
    CancelToken? cancelToken,
  });
}
