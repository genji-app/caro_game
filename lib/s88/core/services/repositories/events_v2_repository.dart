import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/events_v2_remote_datasource.dart';
import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';

/// Provider for EventsV2Repository
final eventsV2RepositoryProvider = Provider<EventsV2Repository>((ref) {
  final remoteDataSource = ref.watch(eventsV2RemoteDataSourceProvider);
  return EventsV2RepositoryImpl(remoteDataSource);
});

/// Abstract repository for Events V2
///
/// Defines the contract for fetching events data.
/// Can be extended to include caching/local storage in the future.
abstract class EventsV2Repository {
  /// Get events with custom request parameters
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request);

  /// Get events with cancel token support
  Future<List<LeagueModelV2>> getEventsWithCancel(
    EventsRequestModel request,
    CancelToken cancelToken,
  );

  /// Get live events for a sport
  Future<List<LeagueModelV2>> getLiveEvents(int sportId, {int? sportTypeId});

  /// Get today's events for a sport
  Future<List<LeagueModelV2>> getTodayEvents(int sportId, {int? sportTypeId});

  /// Get early/upcoming events for a sport
  Future<List<LeagueModelV2>> getEarlyEvents(int sportId, {int? sportTypeId});
}

/// Implementation of EventsV2Repository
///
/// Currently uses only remote data source.
/// Can be extended to include caching/local storage.
class EventsV2RepositoryImpl implements EventsV2Repository {
  final EventsV2RemoteDataSource _remoteDataSource;

  EventsV2RepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request) {
    return _remoteDataSource.getEvents(request);
  }

  @override
  Future<List<LeagueModelV2>> getEventsWithCancel(
    EventsRequestModel request,
    CancelToken cancelToken,
  ) {
    return _remoteDataSource.getEventsWithCancel(request, cancelToken);
  }

  @override
  Future<List<LeagueModelV2>> getLiveEvents(int sportId, {int? sportTypeId}) {
    return _remoteDataSource.getLiveEvents(sportId, sportTypeId: sportTypeId);
  }

  @override
  Future<List<LeagueModelV2>> getTodayEvents(int sportId, {int? sportTypeId}) {
    return _remoteDataSource.getTodayEvents(sportId, sportTypeId: sportTypeId);
  }

  @override
  Future<List<LeagueModelV2>> getEarlyEvents(int sportId, {int? sportTypeId}) {
    return _remoteDataSource.getEarlyEvents(sportId, sportTypeId: sportTypeId);
  }
}
