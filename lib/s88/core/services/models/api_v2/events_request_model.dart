import 'package:freezed_annotation/freezed_annotation.dart';

part 'events_request_model.freezed.dart';

/// Request parameters for Events API
///
/// Used to build query parameters for GET /api/app/events
@freezed
sealed class EventsRequestModel with _$EventsRequestModel {
  const factory EventsRequestModel({
    /// Sport ID (required)
    /// 1=Soccer, 2=Basketball, 3=Boxing, 5=Tennis, etc.
    required int sportId,

    /// Time range: 0=Live, 1=Today, 2=Early, 3=Today+Early
    @Default(0) int timeRange,

    /// Sport type ID (only for Boxing sportId=3)
    /// 1=Muay Thai, 2=MMA/UFC, 3=Boxing
    int? sportTypeId,

    /// Filter by team ID
    int? teamId,

    /// Filter by league IDs
    List<int>? leagueIds,

    /// Filter by date (format: yyyy-M-d)
    String? date,

    /// Timezone offset in minutes
    /// Default: -420 = UTC+7 (Vietnam)
    @Default(-420) int tzOffset,

    /// Is mobile device
    @Default(true) bool isMobile,

    /// Sort by start time
    @Default(false) bool sortByTime,

    /// Only pinned leagues
    @Default(false) bool onlyPinLeague,

    /// Only parlay events
    @Default(false) bool onlyParlay,

    /// Only GS events
    @Default(false) bool onlyGs,

    /// Filter: has live stream
    @Default(false) bool isLiveStream,

    /// Filter: has live tracker
    @Default(false) bool isLiveTracker,

    /// Filter: has statistics
    @Default(false) bool isSportRadar,

    /// Filter: has cash out
    @Default(false) bool isCashOut,
  }) = _EventsRequestModel;

  const EventsRequestModel._();

  /// Convert to query parameters map
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'sportId': sportId,
      'timeRange': timeRange,
      'tzOffset': tzOffset,
      'isMobile': isMobile,
    };

    // Add optional boolean filters only if true
    if (sortByTime) params['sortByTime'] = sortByTime;
    if (onlyPinLeague) params['onlyPinLeague'] = onlyPinLeague;
    if (onlyParlay) params['onlyParlay'] = onlyParlay;
    if (onlyGs) params['onlyGs'] = onlyGs;
    if (isLiveStream) params['isLiveStream'] = isLiveStream;
    if (isLiveTracker) params['isLiveTracker'] = isLiveTracker;
    if (isSportRadar) params['isSportRadar'] = isSportRadar;
    if (isCashOut) params['isCashOut'] = isCashOut;

    // Add optional parameters if provided
    if (sportTypeId != null) params['sportTypeId'] = sportTypeId;
    if (teamId != null) params['teamId'] = teamId;
    if (leagueIds != null && leagueIds!.isNotEmpty) {
      params['leagueIds'] = leagueIds!.join(',');
    }
    if (date != null) params['date'] = date;

    return params;
  }

  /// Create request for Live tab
  factory EventsRequestModel.live(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 0,
        sportTypeId: sportTypeId,
        // sortByTime: true,
      );

  /// Create request for Today tab
  factory EventsRequestModel.today(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 1,
        sportTypeId: sportTypeId,
        // sortByTime: true,
      );

  /// Create request for Early tab
  factory EventsRequestModel.early(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 2,
        sportTypeId: sportTypeId,
        // sortByTime: true,
      );

  /// Create request for Today + Early combined
  factory EventsRequestModel.all(int sportId, {int? sportTypeId}) =>
      EventsRequestModel(
        sportId: sportId,
        timeRange: 3,
        sportTypeId: sportTypeId,
        // sortByTime: true,
      );
}
