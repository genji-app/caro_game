import 'package:flutter/foundation.dart';

/// Whitelist of supported games that are confirmed to work
/// Games are organized by provider for easy maintenance
///
/// Data structure matches BE response:
/// - providerId: The provider identifier (e.g., "amb-vn", "via-casino-vn", "vivo", "lcevo")
/// - gameCode: The game code within that provider
///
/// ## Configuration Modes:
///
///  /// Production Mode (Filtering Enabled)
/// ```dart
/// static const bool TEST_MODE = false;
/// ```
/// Only whitelisted games will be shown to users.
///
///  /// Test Mode (No Filtering)
/// ```dart
/// static const bool TEST_MODE = true;
/// ```
/// All games from API will be shown, useful for testing new games.
class SupportedGamesWhitelist {
  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  /// Constructor with optional testMode parameter
  /// Default test mode setting (can be overridden via constructor)
  /// Set to `true` to disable filtering (show all games from API)
  /// Set to `false` to enable filtering (show only whitelisted games)
  /// **IMPORTANT**: Always set to `false` before production release!
  ///
  /// Parameters:
  /// - [testMode]: If provided, overrides DEFAULT_TEST_MODE
  ///   - `true`: Disable filtering (show all games)
  ///   - `false`: Enable filtering (show only whitelisted games)
  ///
  /// Example:
  /// ```dart
  /// // Use default mode
  /// final whitelist = SupportedGamesWhitelist();
  ///
  /// // Force production mode
  /// final prodWhitelist = SupportedGamesWhitelist(testMode: false);
  ///
  /// // Force test mode
  /// final testWhitelist = SupportedGamesWhitelist(testMode: true);
  /// ```
  SupportedGamesWhitelist({bool testMode = false}) : _testMode = testMode;

  /// Instance test mode setting
  final bool _testMode;

  /// Current filter mode description
  String get filterMode =>
      _testMode ? 'TEST MODE (All games)' : 'PRODUCTION MODE (Filtered)';

  /// Current test mode value
  bool get testMode => _testMode;

  // ============================================================================
  // WHITELIST CHECK
  // ============================================================================

  /// Check if a game is supported (whitelisted)
  ///
  /// Parameters:
  /// - [providerId]: Provider ID from BE (case-insensitive)
  /// - [gameCode]: Game code from BE (case-insensitive)
  ///
  /// Returns:
  /// - In TEST_MODE: Always returns `true` (all games allowed)
  /// - In PRODUCTION MODE: Returns `true` only if game is in whitelist
  bool isSupported({required String providerId, required String gameCode}) {
    // TEST MODE: Accept all games
    if (_testMode) return true;

    // PRODUCTION MODE: Check whitelist
    final normalizedProviderId = providerId.toLowerCase().trim();
    final normalizedGameCode = gameCode.toLowerCase().trim();

    final providerGames = _whitelist[normalizedProviderId];
    if (providerGames == null) return false;

    return providerGames.contains(normalizedGameCode);
  }

  /// Whitelist mapping: providerId -> Set of supported gameCodes
  /// All keys and values are lowercase for case-insensitive matching
  static final Map<String, Set<String>> _whitelist = {
    // ============================================================================
    // AMB-VN Provider (SEXY Gaming - Vietnamese)
    // ============================================================================
    'amb-vn': {
      'mx-live-001', // Baccarat Classic
      'mx-live-015', // Fish Prawn Crab (Bầu Cua)
      'mx-live-006', // DragonTiger (Rồng Hổ)
      'mx-live-009', // Roulette
    },

    // ============================================================================
    // Via Casino Provider (Vietnamese)
    // ============================================================================
    'via-casino-vn': {
      'baccarat60s', // Baccarat
      'ltbaccarat', // Lotto Baccarat
      // 'sb60s', // Classic Sicbo
      'tx60s', // Tài Xỉu
      'dt60s', // Rồng Hổ
      'xd60s', // Xóc Dĩa
      'wwmb', // Bi Lốc Xoáy (Đua Bi)
    },

    // ============================================================================
    // Vivo Gaming Provider
    // ============================================================================
    'vivo': {
      // 'baccarat', // Baccarat
      '353', // Baccarat Dance
      // 'roulette', // Roulette`
      '1', // Galactic VIP Roulette
      // 'sicbo', // SicBo
      '420', // Sic Bo
      // 'dragontiger', // DragonTiger (Rồng Hổ)
      '425', // Dragon Tiger Jade
      // 'blackjack', // Blackjack
      '16', // Oceania VIP Blackjack
    },

    // ============================================================================
    // Evolution Provider (lcevo)
    // ============================================================================
    'lcevo': {
      'baccarat', // Baccarat Siêu Tốc A
      'bacbo', // Bac Bo
      'sicbo', // Siêu Tài Xỉu (Super Sic Bo)
      // 'scalableblackjack', // Blackjack Vô Cực
      'scalablebetstackerbj', // Blackjack Chồng Phỉnh Cược Vô Cực
      'holdem', // Poker
      // 'thb', // Texas Hold'em Bonus Poker
      'fantan', // Fan Tan
      'dragontiger', // Rồng Hổ
      'roulette', // Roulette Tự Động
      // 'crazytime', // Thời Gian Điên Rồ (Crazy Time)
      // 'lightningdice', // Lightning Dice
      'moneywheel', // Imperial Quest
    },
  };

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get all supported providers
  /// In testMode, this returns empty set since all providers are allowed
  Set<String> get supportedProviders =>
      _testMode ? {} : _whitelist.keys.toSet();

  /// Get supported games count for a provider
  /// In testMode, returns 0 since filtering is disabled
  int getSupportedGamesCount(String providerId) {
    if (_testMode) return 0;
    final normalizedProviderId = providerId.toLowerCase().trim();
    return _whitelist[normalizedProviderId]?.length ?? 0;
  }

  /// Get total number of supported games across all providers
  /// In testMode, returns 0 since filtering is disabled
  int get totalSupportedGames {
    if (_testMode) return 0;
    return _whitelist.values.fold(0, (sum, games) => sum + games.length);
  }

  /// Check if a provider is supported
  /// In testMode, always returns true
  bool isProviderSupported(String providerId) {
    if (_testMode) return true;
    final normalizedProviderId = providerId.toLowerCase().trim();
    return _whitelist.containsKey(normalizedProviderId);
  }

  /// Get list of supported game codes for a provider (for debugging)
  /// In testMode, returns null since all games are allowed
  Set<String>? getSupportedGameCodes(String providerId) {
    if (_testMode) return null;
    final normalizedProviderId = providerId.toLowerCase().trim();
    return _whitelist[normalizedProviderId];
  }

  // ============================================================================
  // DEBUG & MONITORING
  // ============================================================================

  /// Get configuration info for debugging
  /// Useful for logging and monitoring current filtering state
  Map<String, dynamic> getConfigInfo() {
    return {
      'mode': filterMode,
      'testMode': _testMode,
      'whitelistEnabled': !_testMode,
      'totalWhitelistedGames': _whitelist.values.fold(
        0,
        (sum, games) => sum + games.length,
      ),
      'whitelistedProviders': _whitelist.keys.toList(),
      'providerCount': _whitelist.length,
    };
  }

  /// Print configuration info to console (for debugging)
  void printConfigInfo() {
    final info = getConfigInfo();
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🎮 Supported Games Whitelist Configuration');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('Mode: ${info['mode']}');
    debugPrint('Test Mode: ${info['testMode']}');
    debugPrint('Whitelist Enabled: ${info['whitelistEnabled']}');
    if (!_testMode) {
      debugPrint('Total Whitelisted Games: ${info['totalWhitelistedGames']}');
      debugPrint('Whitelisted Providers: ${info['whitelistedProviders']}');
      debugPrint('Provider Count: ${info['providerCount']}');
    } else {
      debugPrint('⚠️  All games from API will be shown (no filtering)');
    }
    debugPrint('═══════════════════════════════════════════════════════');
  }
}
