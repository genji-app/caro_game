import 'package:dio/dio.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/features/search/data/datasources/search_remote_datasource.dart';

/// Implementation of [SearchRemoteDataSource] using [SbHttpManager].
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._http);

  final SbHttpManager _http;

  @override
  Future<Map<String, dynamic>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    return _http.getSearch(query, cancelToken: cancelToken);
  }
}
