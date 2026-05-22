import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/game_orientation.dart';
import '../common/game_type.dart';
import 'external_game.dart';

part 'external_config.freezed.dart';
part 'external_config.g.dart';

/// {@template external_provider_config}
/// Configuration overrides for a specific remote game provider.
///
/// Allows dynamic control over how games from this provider are rendered
/// and handled (e.g., orientation, session guards).
/// {@endtemplate}
@freezed
abstract class ExternalProviderConfig with _$ExternalProviderConfig {
  const factory ExternalProviderConfig({
    /// Optional override for the game category.
    @JsonKey(name: 'game_type') GameType? gameType,

    /// Allowed orientations on mobile phones.
    @JsonKey(name: 'mobile_orientation')
    @GameOrientationListConverter()
    List<GameOrientation>? mobileOrientation,

    /// Allowed orientations on tablets.
    @JsonKey(name: 'tablet_orientation')
    @GameOrientationListConverter()
    List<GameOrientation>? tabletOrientation,

    /// Allowed orientations on desktops.
    @JsonKey(name: 'desktop_orientation')
    @GameOrientationListConverter()
    List<GameOrientation>? desktopOrientation,

    /// Whether this provider should forcefully render in landscape on iPad.
    @JsonKey(name: 'force_landscape_viewport_on_ipad') bool? forceLandscapeViewportOnIpad,

    /// Whether games from this provider should be opened in a new tab to avoid crashes.
    @JsonKey(name: 'open_in_new_tab_on_ios_safari_web') bool? openInNewTabOnIOSSafariWeb,

    /// Whether a session cooldown guard is required before launching.
    @JsonKey(name: 'requires_session_guard') bool? requiresSessionGuard,

    /// Debounce duration (in milliseconds) for the load stop event.
    @JsonKey(name: 'load_stop_debounce_ms') int? loadStopDebounceMs,

    /// The list of supported games and their specific overrides for this provider.
    @JsonKey(name: 'games') @Default([]) List<ExternalGame> games,
  }) = _ExternalProviderConfig;

  factory ExternalProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$ExternalProviderConfigFromJson(json);
}

/// {@template external_config}
/// Configuration for 3rd-party (remote) game providers.
///
/// Manages the whitelist of supported games and specific provider overrides.
/// {@endtemplate}
@freezed
abstract class ExternalConfig with _$ExternalConfig {
  const factory ExternalConfig({
    /// Whether to show all games ignoring the whitelist (Debug/Test only).
    @JsonKey(name: 'test_mode') @Default(false) bool testMode,

    /// Map of providerId to their respective configuration overrides and game lists.
    @JsonKey(name: 'provider_configs')
    @Default({})
    Map<String, ExternalProviderConfig> providerConfigs,
  }) = _ExternalConfig;

  factory ExternalConfig.fromJson(Map<String, dynamic> json) => _$ExternalConfigFromJson(json);
}

/// Helper extensions for [ExternalConfig] to simplify querying with Fallback support.
extension ExternalConfigX on ExternalConfig {
  /// Checks if a specific game from a provider is supported (whitelisted).
  ///
  /// Logic: TestMode > Remote Config Games > Local Fallback Games.
  bool isSupported(String providerId, String gameCode) {
    if (testMode) return true;

    final id = providerId.toLowerCase().trim();
    final code = gameCode.toLowerCase().trim();

    final config = getConfigForProvider(id);
    return config.games.any((g) => g.gameCode.toLowerCase().trim() == code);
  }

  /// Retrieves the image for a specific game, prioritizing remote config then local fallback.
  String? getGameImage(String providerId, String gameCode) {
    final id = providerId.toLowerCase().trim();
    final code = gameCode.toLowerCase().trim();

    final config = getConfigForProvider(id);
    final game = config.games.firstWhere(
      (g) => g.gameCode.toLowerCase().trim() == code,
      orElse: () => const ExternalGame(gameCode: ''),
    );

    return game.image;
  }

  /// Returns a list of provider IDs that have at least one game configured.
  List<String> getWhitelistedProviders() {
    final allIds = <String>{...providerConfigs.keys, ..._kDefaultProviderConfigs.keys};
    return allIds.where((id) => getConfigForProvider(id).games.isNotEmpty).toList();
  }

  /// Returns the complete list of supported games for a given provider.
  List<ExternalGame> getGamesForProvider(String providerId) {
    return getConfigForProvider(providerId).games;
  }

  /// Returns the configuration overrides for a specific provider.
  ///
  /// Logic: Merges Remote Config overrides onto Local Fallback defaults.
  ExternalProviderConfig getConfigForProvider(String providerId) {
    final id = providerId.toLowerCase().trim();

    final remote = providerConfigs[id];
    final fallback = _kDefaultProviderConfigs[id];

    if (remote == null) return fallback ?? const ExternalProviderConfig();
    if (fallback == null) return remote;

    return remote.copyWith(
      gameType: remote.gameType ?? fallback.gameType,
      mobileOrientation: remote.mobileOrientation ?? fallback.mobileOrientation,
      tabletOrientation: remote.tabletOrientation ?? fallback.tabletOrientation,
      desktopOrientation: remote.desktopOrientation ?? fallback.desktopOrientation,
      forceLandscapeViewportOnIpad:
          remote.forceLandscapeViewportOnIpad ?? fallback.forceLandscapeViewportOnIpad,
      openInNewTabOnIOSSafariWeb:
          remote.openInNewTabOnIOSSafariWeb ?? fallback.openInNewTabOnIOSSafariWeb,
      requiresSessionGuard: remote.requiresSessionGuard ?? fallback.requiresSessionGuard,
      loadStopDebounceMs: remote.loadStopDebounceMs ?? fallback.loadStopDebounceMs,
      games: remote.games.isNotEmpty ? remote.games : fallback.games,
    );
  }
}

// ============================================================================
// DEFAULT FALLBACK DATA (Migrated from App)
// ============================================================================

/// Default provider configuration overrides and fallback games whitelist.
const Map<String, ExternalProviderConfig> _kDefaultProviderConfigs = {
  /*
  ============================================================================
  AMB-VN Provider (SEXY Gaming - Vietnamese)
  ============================================================================
  'amb-vn': {
    'mx-live-001', // Baccarat Classic
    'mx-live-015', // Fish Prawn Crab (Bầu Cua)
    'mx-live-006', // DragonTiger (Rồng Hổ)
    'mx-live-009', // Roulette
  },
  */
  'amb-vn': ExternalProviderConfig(
    gameType: GameType.live,
    mobileOrientation: [GameOrientation.portraitUp, GameOrientation.portraitDown],
    tabletOrientation: [GameOrientation.landscapeLeft, GameOrientation.landscapeRight],
    desktopOrientation: GameOrientation.all,
    openInNewTabOnIOSSafariWeb: true,
    requiresSessionGuard: true,
    loadStopDebounceMs: 777,
    games: [
      ExternalGame(
        gameCode: 'mx-live-001', // Baccarat Classic
        image: 'amb-vn_MX-LIVE-001_baccarat-classic_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'mx-live-015', // Fish Prawn Crab (Bầu Cua)
        image: 'amb-vn_MX-LIVE-015_fish-prawn-crab_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'mx-live-006', // DragonTiger (Rồng Hổ)
        image: 'amb-vn_MX-LIVE-006_dragontiger_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'mx-live-009', // Roulette
        image: 'amb-vn_MX-LIVE-009_roulette_thumb.webp',
      ),
    ],
  ),

  /*
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
  */
  'via-casino-vn': ExternalProviderConfig(
    gameType: GameType.live,
    mobileOrientation: [GameOrientation.portraitUp, GameOrientation.portraitDown],
    tabletOrientation: [GameOrientation.landscapeRight],
    desktopOrientation: GameOrientation.all,
    forceLandscapeViewportOnIpad: true,
    openInNewTabOnIOSSafariWeb: true,
    games: [
      ExternalGame(
        gameCode: 'baccarat60s', // Baccarat
        image: 'via-casino-vn_BACCARAT60S_baccarat_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'ltbaccarat', // Lotto Baccarat
        image: 'via-casino-vn_LTBACCARAT_lotto-baccarat_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'tx60s', // Tài Xỉu
        image: 'via-casino-vn_TX60S_tai-xiu_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'dt60s', // Rồng Hổ
        image: 'via-casino-vn_DT60S_rong-ho_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'xd60s', // Xóc Dĩa
        image: 'via-casino-vn_XD60S_xoc-dia_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'wwmb', // Bi Lốc Xoáy (Đua Bi)
        image: 'via-casino-vn_WWMB_bi-loc-xoay_thumb.webp',
      ),
    ],
  ),

  /*
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
  */
  'vivo': ExternalProviderConfig(
    gameType: GameType.live,
    mobileOrientation: [GameOrientation.portraitUp, GameOrientation.portraitDown],
    tabletOrientation: [GameOrientation.landscapeLeft, GameOrientation.landscapeRight],
    desktopOrientation: GameOrientation.all,
    openInNewTabOnIOSSafariWeb: true,
    games: [
      ExternalGame(
        gameCode: '353', // Baccarat Dance
        image: 'vivo_353_baccarat-dance_thumb.webp',
      ),
      ExternalGame(
        gameCode: '1', // Galactic VIP Roulette
        image: 'vivo_1_galactic-vip-roulette_thumb.webp',
      ),
      ExternalGame(
        gameCode: '420', // Sic Bo
        image: 'vivo_420_sic-bo_thumb.webp',
      ),
      ExternalGame(
        gameCode: '425', // Dragon Tiger Jade
        image: 'vivo_425_dragon-tiger-jade_thumb.webp',
      ),
      ExternalGame(
        gameCode: '16', // Oceania VIP Blackjack
        image: 'vivo_16_oceania-vip-blackjack_thumb.webp',
      ),
    ],
  ),

  /*
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
  */
  'lcevo': ExternalProviderConfig(
    gameType: GameType.live,
    mobileOrientation: [GameOrientation.portraitUp, GameOrientation.portraitDown],
    tabletOrientation: GameOrientation.all,
    desktopOrientation: GameOrientation.all,
    openInNewTabOnIOSSafariWeb: true,
    games: [
      ExternalGame(
        gameCode: 'baccarat', // Baccarat Siêu Tốc A
        image: 'lcevo_baccarat_baccarat-sieu-toc-a_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'bacbo', // Bac Bo
        image: 'lcevo_bacbo_bac-bo_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'sicbo', // Siêu Tài Xỉu (Super Sic Bo)
        image: 'lcevo_sicbo_sieu-tai-xiu_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'scalablebetstackerbj', // Blackjack Chồng Phỉnh Cược Vô Cực
        image: 'lcevo_scalablebetstackerbj_blackjack-chong-phinh-cuoc-vo-cuc_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'holdem', // Poker
        image: 'lcevo_holdem_poker_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'fantan', // Fan Tan
        image: 'lcevo_fantan_fan-tan_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'dragontiger', // Rồng Hổ
        image: 'lcevo_dragontiger_rong-ho_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'roulette', // Roulette Tự Động
        image: 'lcevo_roulette_roulette-tu-dong_thumb.webp',
      ),
      ExternalGame(
        gameCode: 'moneywheel', // Imperial Quest
        image: 'lcevo_moneywheel_imperial-quest_thumb.webp',
      ),
    ],
  ),
};
