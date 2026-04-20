/// Direction of odds change for animation
enum OddsDirection {
  /// No change or first value
  none,

  /// Odds increased (better for player on this selection)
  up,

  /// Odds decreased (worse for player on this selection)
  down,
}

/// Odds data model.
///
/// Represents betting odds for a specific selection.
/// Mutable to allow in-place updates for performance.
class OddsData {
  /// Unique offer ID (strOfferId) - use String to avoid int overflow
  final String offerId;

  /// Event ID this odds belongs to
  final int eventId;

  /// Market ID this odds belongs to
  final int marketId;

  /// Time range: "LIVE" or "EARLY"
  final String timeRange;

  /// Handicap/line points (e.g., "-1.5", "+0.5")
  String? points;

  /// Whether this is the main line
  bool isMainLine;

  /// Whether odds are suspended
  bool isSuspended;

  /// Promotion type: 0 = normal, 1 = promotion (kèo rung)
  int promotionType;

  // ===== Current odds values (Decimal format) =====

  /// Home odds in decimal format
  /// NOTE: For Over/Under markets, API sends Under odds in this field (not Over!)
  double? oddsHome;

  /// Away odds in decimal format
  /// NOTE: For Over/Under markets, API sends Over odds in this field (not Under!)
  double? oddsAway;

  /// Draw odds in decimal format (for 1X2 markets)
  double? oddsDraw;

  // ===== Previous values for animation =====

  /// Previous home odds (for detecting direction)
  double? previousHome;

  /// Previous away odds (for detecting direction)
  double? previousAway;

  /// Previous draw odds (for detecting direction)
  double? previousDraw;

  // ===== Alternative formats =====

  /// Home odds in Malay format
  String? malayHome;

  /// Away odds in Malay format
  String? malayAway;

  /// Home odds in Hong Kong format
  String? hkHome;

  /// Away odds in Hong Kong format
  String? hkAway;

  /// Home odds in Indo format
  String? indoHome;

  /// Away odds in Indo format
  String? indoAway;

  // ===== Selection IDs =====

  /// Selection ID for home (or Under for O/U markets - API quirk)
  String? selectionIdHome;

  /// Selection ID for away (or Over for O/U markets - API quirk)
  String? selectionIdAway;

  /// Selection ID for draw
  String? selectionIdDraw;

  // ===== Version tracking =====

  int _version = 0;

  /// Version number, incremented on each update
  int get version => _version;

  OddsData({
    required this.offerId,
    required this.eventId,
    required this.marketId,
    this.timeRange = 'LIVE',
    this.points,
    this.isMainLine = false,
    this.isSuspended = false,
    this.promotionType = 0,
    this.oddsHome,
    this.oddsAway,
    this.oddsDraw,
    this.malayHome,
    this.malayAway,
    this.hkHome,
    this.hkAway,
    this.indoHome,
    this.indoAway,
    this.selectionIdHome,
    this.selectionIdAway,
    this.selectionIdDraw,
  });

  /// Create from parsed JSON data
  factory OddsData.fromJson(
    Map<String, dynamic> json, {
    required int eventId,
    required int marketId,
    String timeRange = 'LIVE',
  }) {
    final offerId = json['strOfferId']?.toString() ??
        json['offerId']?.toString() ??
        '${eventId}_${marketId}_${DateTime.now().microsecondsSinceEpoch}';

    final odds = OddsData(
      offerId: offerId,
      eventId: eventId,
      marketId: marketId,
      timeRange: timeRange,
    );

    odds._applyJson(json);
    return odds;
  }

  /// Update from JSON data
  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    // Points
    if (data.containsKey('points')) {
      points = data['points']?.toString();
    }

    // Flags
    if (data.containsKey('isMainLine')) {
      isMainLine = data['isMainLine'] == true;
    }
    if (data.containsKey('isSuspended')) {
      isSuspended = data['isSuspended'] == true;
    }
    if (data.containsKey('promotionType')) {
      promotionType = _parseInt(data['promotionType']) ?? 0;
    }

    // Decimal odds - save previous values first
    final oddsMap = data['odds'] as Map<String, dynamic>?;
    if (oddsMap != null) {
      _updateOddsFromMap(oddsMap);
    } else {
      // Odds might be at root level
      _updateOddsFromMap(data);
    }

    // Alternative formats
    if (data.containsKey('malayHome')) {
      malayHome = data['malayHome']?.toString();
    }
    if (data.containsKey('malayAway')) {
      malayAway = data['malayAway']?.toString();
    }
    if (data.containsKey('hkHome')) {
      hkHome = data['hkHome']?.toString();
    }
    if (data.containsKey('hkAway')) {
      hkAway = data['hkAway']?.toString();
    }
    if (data.containsKey('indoHome')) {
      indoHome = data['indoHome']?.toString();
    }
    if (data.containsKey('indoAway')) {
      indoAway = data['indoAway']?.toString();
    }

    // Selection IDs
    if (data.containsKey('selectionIdHome')) {
      selectionIdHome = data['selectionIdHome']?.toString();
    }
    if (data.containsKey('selectionIdAway')) {
      selectionIdAway = data['selectionIdAway']?.toString();
    }
    if (data.containsKey('selectionIdDraw')) {
      selectionIdDraw = data['selectionIdDraw']?.toString();
    }
  }

  void _updateOddsFromMap(Map<String, dynamic> data) {
    // Home odds
    final homeData = data['oddsHome'];
    if (homeData != null) {
      previousHome = oddsHome;
      oddsHome = _parseOddsValue(homeData);
    }

    // Away odds
    final awayData = data['oddsAway'];
    if (awayData != null) {
      previousAway = oddsAway;
      oddsAway = _parseOddsValue(awayData);
    }

    // Draw odds
    final drawData = data['oddsDraw'];
    if (drawData != null) {
      previousDraw = oddsDraw;
      oddsDraw = _parseOddsValue(drawData);
    }
  }

  double? _parseOddsValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is Map) {
      // {"decimal": "2.50"}
      final decimal = value['decimal'];
      if (decimal != null) {
        return _parseOddsValue(decimal);
      }
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  // ===== Direction helpers for animation =====

  /// Get direction of home odds change
  OddsDirection get homeDirection {
    if (previousHome == null || oddsHome == null) return OddsDirection.none;
    if (oddsHome! > previousHome!) return OddsDirection.up;
    if (oddsHome! < previousHome!) return OddsDirection.down;
    return OddsDirection.none;
  }

  /// Get direction of away odds change
  OddsDirection get awayDirection {
    if (previousAway == null || oddsAway == null) return OddsDirection.none;
    if (oddsAway! > previousAway!) return OddsDirection.up;
    if (oddsAway! < previousAway!) return OddsDirection.down;
    return OddsDirection.none;
  }

  /// Get direction of draw odds change
  OddsDirection get drawDirection {
    if (previousDraw == null || oddsDraw == null) return OddsDirection.none;
    if (oddsDraw! > previousDraw!) return OddsDirection.up;
    if (oddsDraw! < previousDraw!) return OddsDirection.down;
    return OddsDirection.none;
  }

  /// Clear previous values (e.g., after animation completes)
  void clearPreviousValues() {
    previousHome = null;
    previousAway = null;
    previousDraw = null;
  }

  /// Unique key for this odds
  String get oddsKey => '${eventId}_${marketId}_$offerId';

  /// Market key (eventId_marketId)
  String get marketKey => '${eventId}_$marketId';

  @override
  String toString() {
    return 'OddsData(offerId: $offerId, eventId: $eventId, marketId: $marketId, '
        'home: $oddsHome, away: $oddsAway, draw: $oddsDraw)';
  }
}
