/// Settings Info Model
///
/// Brand Settings Info loaded from server settings API.

/// Domain Settings
class DomainSettings {
  final String exposeDomain;
  final String bettingDomain;
  final String authDomain;
  final String websocketDomain;
  final String videoDomain;
  final String virtualVideoDomain;
  final String statisticsDomain;

  const DomainSettings({
    this.exposeDomain = '',
    this.bettingDomain = '',
    this.authDomain = '',
    this.websocketDomain = '',
    this.videoDomain = '',
    this.virtualVideoDomain = '',
    this.statisticsDomain = '',
  });

  /// Parse from JSON with numeric keys
  /// Format: {"0": "exposeDomain", "1": "bettingDomain", ...}
  factory DomainSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DomainSettings();
    return DomainSettings(
      exposeDomain: json['0'] as String? ?? '',
      bettingDomain: json['1'] as String? ?? '',
      authDomain: json['2'] as String? ?? '',
      websocketDomain: json['3'] as String? ?? '',
      videoDomain: json['4'] as String? ?? '',
      virtualVideoDomain: json['5'] as String? ?? '',
      statisticsDomain: json['6'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '0': exposeDomain,
    '1': bettingDomain,
    '2': authDomain,
    '3': websocketDomain,
    '4': videoDomain,
    '5': virtualVideoDomain,
    '6': statisticsDomain,
  };

  DomainSettings copyWith({
    String? exposeDomain,
    String? bettingDomain,
    String? authDomain,
    String? websocketDomain,
    String? videoDomain,
    String? virtualVideoDomain,
    String? statisticsDomain,
  }) {
    return DomainSettings(
      exposeDomain: exposeDomain ?? this.exposeDomain,
      bettingDomain: bettingDomain ?? this.bettingDomain,
      authDomain: authDomain ?? this.authDomain,
      websocketDomain: websocketDomain ?? this.websocketDomain,
      videoDomain: videoDomain ?? this.videoDomain,
      virtualVideoDomain: virtualVideoDomain ?? this.virtualVideoDomain,
      statisticsDomain: statisticsDomain ?? this.statisticsDomain,
    );
  }

  bool get isEmpty =>
      exposeDomain.isEmpty &&
      bettingDomain.isEmpty &&
      authDomain.isEmpty &&
      websocketDomain.isEmpty &&
      videoDomain.isEmpty &&
      virtualVideoDomain.isEmpty &&
      statisticsDomain.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

/// Balance Settings
class BalanceSettings {
  /// Refresh time in seconds
  final int refreshTime;

  /// If true, refresh balance by calling API
  final bool isRefreshAPI;

  const BalanceSettings({this.refreshTime = 5, this.isRefreshAPI = false});

  /// Parse from JSON with numeric keys
  /// Format: {"0": refreshTime, "1": isRefreshAPI}
  factory BalanceSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BalanceSettings();
    return BalanceSettings(
      refreshTime: json['0'] as int? ?? 5,
      isRefreshAPI: json['1'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'0': refreshTime, '1': isRefreshAPI};

  BalanceSettings copyWith({int? refreshTime, bool? isRefreshAPI}) {
    return BalanceSettings(
      refreshTime: refreshTime ?? this.refreshTime,
      isRefreshAPI: isRefreshAPI ?? this.isRefreshAPI,
    );
  }
}

/// Performance Settings
class PerformanceSettings {
  /// Memory size limit
  final int memSize;

  const PerformanceSettings({this.memSize = 0});

  /// Parse from JSON with numeric keys
  /// Format: {"0": memSize}
  factory PerformanceSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PerformanceSettings();
    return PerformanceSettings(memSize: json['0'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() => {'0': memSize};

  PerformanceSettings copyWith({int? memSize}) {
    return PerformanceSettings(memSize: memSize ?? this.memSize);
  }
}

/// Settings Info - Main model
///
/// Contains all brand settings loaded from server.
class SettingsInfo {
  final DomainSettings domains;
  final BalanceSettings balanceSettings;
  final PerformanceSettings performanceSettings;
  final Set<int> hiddenLeagueIds;

  const SettingsInfo({
    this.domains = const DomainSettings(),
    this.balanceSettings = const BalanceSettings(),
    this.performanceSettings = const PerformanceSettings(),
    this.hiddenLeagueIds = const {},
  });

  /// Parse from JSON with numeric keys
  /// Format: {"0": DomainSettings, "1": BalanceSettings, "2": PerformanceSettings, "3": hiddenLeagueIds}
  factory SettingsInfo.fromJson(Map<String, dynamic> json) {
    // Parse hiddenLeagueIds from list to Set (key "3")
    final hiddenList = json['3'] as List<dynamic>?;
    final hiddenSet = hiddenList != null
        ? hiddenList.map((e) => e as int).toSet()
        : <int>{};

    return SettingsInfo(
      domains: DomainSettings.fromJson(json['0'] as Map<String, dynamic>?),
      balanceSettings: BalanceSettings.fromJson(
        json['1'] as Map<String, dynamic>?,
      ),
      performanceSettings: PerformanceSettings.fromJson(
        json['2'] as Map<String, dynamic>?,
      ),
      hiddenLeagueIds: hiddenSet,
    );
  }

  Map<String, dynamic> toJson() => {
    '0': domains.toJson(),
    '1': balanceSettings.toJson(),
    '2': performanceSettings.toJson(),
    '3': hiddenLeagueIds.toList(),
  };

  SettingsInfo copyWith({
    DomainSettings? domains,
    BalanceSettings? balanceSettings,
    PerformanceSettings? performanceSettings,
    Set<int>? hiddenLeagueIds,
  }) {
    return SettingsInfo(
      domains: domains ?? this.domains,
      balanceSettings: balanceSettings ?? this.balanceSettings,
      performanceSettings: performanceSettings ?? this.performanceSettings,
      hiddenLeagueIds: hiddenLeagueIds ?? this.hiddenLeagueIds,
    );
  }

  /// Check if a league is hidden
  bool isLeagueHidden(int leagueId) => hiddenLeagueIds.contains(leagueId);
}
