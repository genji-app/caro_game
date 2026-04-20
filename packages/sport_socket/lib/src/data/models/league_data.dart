/// League data model.
///
/// Represents a sports league/competition.
/// Mutable to allow in-place updates for performance.
class LeagueData {
  /// League ID
  final int leagueId;

  /// Sport ID this league belongs to
  final int sportId;

  /// League name
  String name;

  /// Priority order for sorting
  int priorityOrder;

  /// League order for sorting
  int leagueOrder;

  /// League name in English
  String? nameEn;

  /// League logo URL
  String? logoUrl;

  /// Whether cashout is enabled for this league
  bool cashout;

  /// Country/region code
  String? countryCode;

  // ===== Version tracking =====

  int _version = 0;

  /// Version number, incremented on each update
  int get version => _version;

  LeagueData({
    required this.leagueId,
    required this.sportId,
    required this.name,
    this.priorityOrder = 0,
    this.leagueOrder = 0,
    this.nameEn,
    this.logoUrl,
    this.cashout = false,
    this.countryCode,
  });

  /// Create from parsed JSON data
  factory LeagueData.fromJson(Map<String, dynamic> json) {
    final leagueId = _parseInt(json['leagueId'] ?? json['li']) ?? 0;
    final sportId = _parseInt(json['sportId'] ?? json['s']) ?? 0;

    final league = LeagueData(
      leagueId: leagueId,
      sportId: sportId,
      name: json['leagueName']?.toString() ?? json['ln']?.toString() ?? '',
    );

    league._applyJson(json);
    return league;
  }

  /// Update from JSON data
  void updateFrom(Map<String, dynamic> data) {
    _applyJson(data);
    _version++;
  }

  void _applyJson(Map<String, dynamic> data) {
    // Name
    if (data.containsKey('leagueName') || data.containsKey('ln')) {
      name = data['leagueName']?.toString() ?? data['ln']?.toString() ?? name;
    }

    // Priority
    if (data.containsKey('leaguePriorityOrder') || data.containsKey('lpo')) {
      priorityOrder = _parseInt(data['leaguePriorityOrder'] ?? data['lpo']) ??
          priorityOrder;
    }

    // League order
    if (data.containsKey('leagueOrder') || data.containsKey('lo')) {
      leagueOrder = _parseInt(data['leagueOrder'] ?? data['lo']) ?? leagueOrder;
    }

    // Name in English
    if (data.containsKey('leagueNameEn') || data.containsKey('lne')) {
      nameEn = data['leagueNameEn']?.toString() ?? data['lne']?.toString();
    }

    // Logo
    if (data.containsKey('leagueLogo') || data.containsKey('lg')) {
      logoUrl = data['leagueLogo']?.toString() ?? data['lg']?.toString();
    }

    // Cashout
    if (data.containsKey('cashout')) {
      cashout = _parseBool(data['cashout']);
    }

    // Country code
    if (data.containsKey('countryCode') || data.containsKey('cc')) {
      countryCode = data['countryCode']?.toString() ?? data['cc']?.toString();
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  String toString() {
    return 'LeagueData(leagueId: $leagueId, sportId: $sportId, name: $name)';
  }
}
