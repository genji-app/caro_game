import '../../proto/proto.dart';

/// Outright event data model.
///
/// Represents an outright betting event (e.g., tournament winner).
/// Mutable to allow in-place updates for performance.
class OutrightEventData {
  /// Event ID
  final int eventId;

  /// Sport ID
  final int sportId;

  /// League ID
  final int leagueId;

  /// Event name
  String eventName;

  /// League name
  String leagueName;

  /// League name in English
  String leagueNameEn;

  /// League logo URL
  String? leagueLogo;

  /// League order
  int leagueOrder;

  /// League priority order
  int leaguePriorityOrder;

  /// End date string
  String? endDate;

  /// End time (unix timestamp)
  int endTime;

  /// Whether event is suspended
  bool isSuspended;

  /// Outright odds list
  List<OutrightOddsData> oddsList;

  OutrightEventData({
    required this.eventId,
    required this.sportId,
    required this.leagueId,
    required this.eventName,
    required this.leagueName,
    this.leagueNameEn = '',
    this.leagueLogo,
    this.leagueOrder = 0,
    this.leaguePriorityOrder = 0,
    this.endDate,
    this.endTime = 0,
    this.isSuspended = false,
    this.oddsList = const [],
  });

  /// Create from Proto OutrightEventResponse
  factory OutrightEventData.fromProto(OutrightEventResponse proto) {
    return OutrightEventData(
      eventId: proto.eventId.toInt(),
      sportId: proto.sportId,
      leagueId: proto.leagueId,
      eventName: proto.eventName,
      leagueName: proto.leagueName,
      leagueNameEn: proto.leagueNameEn,
      leagueLogo: proto.leagueLogo.isEmpty ? null : proto.leagueLogo,
      leagueOrder: proto.leagueOrder,
      leaguePriorityOrder: proto.leaguePriorityOrder,
      endDate: proto.endDate.isEmpty ? null : proto.endDate,
      endTime: proto.endTime.toInt(),
      isSuspended: proto.isSuspended,
      oddsList:
          proto.oddsList.map((o) => OutrightOddsData.fromProto(o)).toList(),
    );
  }

  /// Update from Proto
  void updateFromProto(OutrightEventResponse proto) {
    eventName = proto.eventName;
    leagueName = proto.leagueName;
    leagueNameEn = proto.leagueNameEn;
    if (proto.leagueLogo.isNotEmpty) leagueLogo = proto.leagueLogo;
    leagueOrder = proto.leagueOrder;
    leaguePriorityOrder = proto.leaguePriorityOrder;
    if (proto.endDate.isNotEmpty) endDate = proto.endDate;
    endTime = proto.endTime.toInt();
    isSuspended = proto.isSuspended;
    oddsList =
        proto.oddsList.map((o) => OutrightOddsData.fromProto(o)).toList();
  }
}

/// Outright odds data
class OutrightOddsData {
  /// Selection ID
  final String selectionId;

  /// Selection name
  String selectionName;

  /// Selection logo URL
  String? selectionLogo;

  /// Offer ID
  String offerId;

  /// Odds value
  double odds;

  /// Classification/Category
  String? cls;

  /// Whether suspended
  bool isSuspended;

  /// Previous odds (for direction indicator)
  double? previousOdds;

  OutrightOddsData({
    required this.selectionId,
    required this.selectionName,
    this.selectionLogo,
    required this.offerId,
    required this.odds,
    this.cls,
    this.isSuspended = false,
    this.previousOdds,
  });

  /// Create from Proto OutrightOddsResponse
  factory OutrightOddsData.fromProto(OutrightOddsResponse proto) {
    return OutrightOddsData(
      selectionId: proto.selectionId,
      selectionName: proto.selectionName,
      selectionLogo: proto.selectionLogo.isEmpty ? null : proto.selectionLogo,
      offerId: proto.offerId,
      odds: proto.odds,
      cls: proto.cls.isEmpty ? null : proto.cls,
      isSuspended: proto.isSuspended,
    );
  }
}
