/// Type of match betting
enum MatchType {
  normal,
  leagueBetting,
  unknown;

  /// Parse from API string value
  factory MatchType.fromString(String? value) {
    if (value == null || value.isEmpty) return MatchType.unknown;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'normal') return MatchType.normal;
    if (normalized == 'league betting') return MatchType.leagueBetting;
    return MatchType.unknown;
  }

  /// Convert to API string value
  String toApiString() => switch (this) {
    MatchType.normal => 'Normal',
    MatchType.leagueBetting => 'League Betting',
    MatchType.unknown => 'Unknown',
  };
}
