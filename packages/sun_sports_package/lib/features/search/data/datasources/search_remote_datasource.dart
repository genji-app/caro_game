import 'package:dio/dio.dart';

/// Search remote data source (data layer).
abstract class SearchRemoteDataSource {
  /// Call GET /api/app/search?txtSearch=...
  /// Returns raw response map (keys "0", "1").
  Future<Map<String, dynamic>> search(String query, {CancelToken? cancelToken});
}
