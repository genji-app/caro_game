/// Market status enum
///
/// Maps to API status codes 0-4
enum MarketStatus {
  /// Normal, can bet (code: 0)
  active(0),

  /// Manually suspended (code: 1)
  suspended(1),

  /// Manually hidden (code: 2)
  hidden(2),

  /// Auto-suspended by system (code: 3)
  autoSuspended(3),

  /// Auto-hidden by system (code: 4)
  autoHidden(4);

  final int code;

  const MarketStatus(this.code);

  /// Create from API code
  static MarketStatus fromCode(dynamic code) {
    final intCode =
        code is String ? int.tryParse(code) ?? 0 : (code as int?) ?? 0;
    return MarketStatus.values.firstWhere(
      (s) => s.code == intCode,
      orElse: () => MarketStatus.active,
    );
  }

  /// Whether betting is allowed on this market
  bool get canBet => this == MarketStatus.active;

  /// Whether market should be visible
  bool get isVisible =>
      this != MarketStatus.hidden && this != MarketStatus.autoHidden;

  /// Whether market is suspended (any type)
  bool get isSuspended =>
      this == MarketStatus.suspended || this == MarketStatus.autoSuspended;
}

/// Market data model.
///
/// Represents a betting market (e.g., Handicap, Over/Under, 1X2).
/// Mutable to allow in-place updates for performance.
class MarketData {
  /// Market ID
  final int marketId;

  /// Event ID this market belongs to
  final int eventId;

  /// Market name (e.g., "Asian Handicap", "Over/Under")
  String? name;

  /// Market type/class (e.g., "ah" for Asian Handicap)
  String? marketType;

  /// Current market status
  MarketStatus status;

  /// Whether market is suspended (derived from status)
  bool get isSuspended => status.isSuspended;

  /// Whether market is visible
  bool get isVisible => status.isVisible;

  /// Whether betting is allowed
  bool get canBet => status.canBet;

  // ===== Version tracking =====

  int _version = 0;

  /// Version number, incremented on each update
  int get version => _version;

  MarketData({
    required this.marketId,
    required this.eventId,
    this.name,
    this.marketType,
    this.status = MarketStatus.active,
  });

  /// Create from parsed JSON data
  factory MarketData.fromJson(
    Map<String, dynamic> json, {
    required int eventId,
  }) {
    final marketId = json['marketId'] as int? ??
        json['domainMarketId'] as int? ??
        json['mi'] as int? ??
        0;

    final market = MarketData(
      marketId: marketId,
      eventId: eventId,
    );

    market._applyJson(json);
    return market;
  }

  /// Update from JSON data
  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    // Name
    if (data.containsKey('marketName') || data.containsKey('mn')) {
      name = data['marketName']?.toString() ?? data['mn']?.toString();
    }

    // Market type
    if (data.containsKey('marketType') || data.containsKey('mt')) {
      marketType = data['marketType']?.toString() ?? data['mt']?.toString();
    }

    // Status
    if (data.containsKey('status')) {
      status = MarketStatus.fromCode(data['status']);
    }
  }

  /// Unique key for this market
  String get marketKey => '${eventId}_$marketId';

  @override
  String toString() {
    return 'MarketData(marketId: $marketId, eventId: $eventId, '
        'status: $status, name: $name)';
  }
}
