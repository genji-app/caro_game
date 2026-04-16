import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import '../network/sb_http_manager.dart';

/// Provider for EventsV2RemoteDataSource
final eventsV2RemoteDataSourceProvider = Provider<EventsV2RemoteDataSource>((
  ref,
) {
  return EventsV2RemoteDataSourceImpl(SbHttpManager.instance);
});

/// Abstract class defining Events V2 API operations
abstract class EventsV2RemoteDataSource {
  /// Fetch events from new API endpoint
  ///
  /// Returns list of [LeagueModelV2] containing events with markets and odds
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request);

  /// Fetch events with cancel token support
  ///
  /// Allows cancelling the request when user navigates away or filters change
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

/// Implementation of EventsV2RemoteDataSource
class EventsV2RemoteDataSourceImpl implements EventsV2RemoteDataSource {
  final SbHttpManager _httpManager;

  EventsV2RemoteDataSourceImpl(this._httpManager);

  @override
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request) {
    return getEventsWithCancel(request, CancelToken());
  }

  @override
  Future<List<LeagueModelV2>> getEventsWithCancel(
    EventsRequestModel request,
    CancelToken cancelToken,
  ) async {
    try {
      return await _httpManager.getEventsV2(request, cancelToken: cancelToken);
    } on DioException catch (e) {
      // Let cancelled requests propagate
      if (e.type == DioExceptionType.cancel) {
        throw const CancelledException('Request cancelled');
      }
      // Handle other Dio errors
      throw _handleDioError(e);
    } catch (e) {
      // Handle parsing or other errors
      if (e is ApiException) rethrow;
      throw UnknownException('Failed to fetch events: $e', originalError: e);
    }
  }

  @override
  Future<List<LeagueModelV2>> getLiveEvents(int sportId, {int? sportTypeId}) {
    return getEvents(
      EventsRequestModel.live(sportId, sportTypeId: sportTypeId),
    );
  }

  @override
  Future<List<LeagueModelV2>> getTodayEvents(int sportId, {int? sportTypeId}) {
    return getEvents(
      EventsRequestModel.today(sportId, sportTypeId: sportTypeId),
    );
  }

  @override
  Future<List<LeagueModelV2>> getEarlyEvents(int sportId, {int? sportTypeId}) {
    return getEvents(
      EventsRequestModel.early(sportId, sportTypeId: sportTypeId),
    );
  }

  /// Convert DioException to ApiException
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');

      case DioExceptionType.badResponse:
        return ServerException(
          'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return const CancelledException('Request cancelled');

      default:
        return UnknownException(
          e.message ?? 'Unknown error occurred',
          originalError: e,
        );
    }
  }
}

// ===== API Exceptions =====

/// Base class for API exceptions
abstract class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Timeout exception
class TimeoutException extends ApiException {
  const TimeoutException(super.message);
}

/// Network exception (no connection)
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// Server exception (5xx errors)
class ServerException extends ApiException {
  final int? statusCode;

  const ServerException(super.message, {this.statusCode});
}

/// Request cancelled exception
class CancelledException extends ApiException {
  const CancelledException(super.message);
}

/// Unknown/unexpected exception
class UnknownException extends ApiException {
  final Object? originalError;

  const UnknownException(super.message, {this.originalError});
}

/// Bad request exception (400)
class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

/// Forbidden exception (403)
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

/// Not found exception (404)
class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}
