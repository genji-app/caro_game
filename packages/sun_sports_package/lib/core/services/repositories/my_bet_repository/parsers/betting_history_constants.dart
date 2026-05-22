/// Constants for Bet History feature
///
/// Centralized constants to avoid magic values and improve maintainability
class BettingHistoryConstants {
  // Private constructor to prevent instantiation
  BettingHistoryConstants._();

  // --- API Fixed Values ---
  static const String apiStatusActive = 'Active';
  static const String apiStatusPending = 'Pending';
  static const String apiStatusSettled = 'Settled';
  static const String apiStatusDeclined = 'Declined';
  static const String apiStatusAll = 'All';

  // --- Default Values (Fallback) ---
  static const String defaultCurrency = 'VND';
  static const String defaultMatchType = 'Normal';

  // --- Score Parsing & Formatting ---
  static const String defaultScore = '[0-0]';
  static const String scoreSeparatorApi = ':';
  static const String scoreBracketStart = '[';
  static const String scoreBracketEnd = ']';
  static const String scoreDash = '-';
}
