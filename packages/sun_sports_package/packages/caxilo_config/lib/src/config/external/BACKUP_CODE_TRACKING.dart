// ============================================================================
// BACKUP CODE TRACKING (ORIGINAL APP LOGIC - DO NOT REMOVE)
// ============================================================================

/*
// 1. FROM: lib/core/services/repositories/game_repository/src/supported_games_whitelist.dart
/*
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
*/

// 2. FROM: lib/core/services/repositories/game_repository/src/models/game_block_mapper.dart (_LocalProviderFallback)
/*
  factory _LocalProviderFallback.resolve(String providerId) {
    switch (providerId.toLowerCase().trim()) {
      case 'vivo':
        return const _LocalProviderFallback(
          gameType: GameType.live,
          mobileOrientation: GameOrientation.portrait,
          tabletOrientation: GameOrientation.landscape,
          desktopOrientation: GameOrientation.all,
          openInNewTabOnIOSSafariWeb: true,
        );

      case 'amb-vn':
        return const _LocalProviderFallback(
          gameType: GameType.live,
          mobileOrientation: GameOrientation.portrait,
          tabletOrientation: GameOrientation.landscape,
          desktopOrientation: GameOrientation.all,
          openInNewTabOnIOSSafariWeb: true,
          requiresSessionGuard: true,
          loadStopDebounceMs: 777,
        );

      case 'lcevo':
        return const _LocalProviderFallback(
          gameType: GameType.live,
          mobileOrientation: GameOrientation.portrait,
          tabletOrientation: GameOrientation.all,
          desktopOrientation: GameOrientation.all,
          openInNewTabOnIOSSafariWeb: true,
        );

      case 'via-casino-vn':
        return const _LocalProviderFallback(
          gameType: GameType.live,
          mobileOrientation: GameOrientation.portrait,
          tabletOrientation: [GameOrientation.landscapeRight],
          desktopOrientation: GameOrientation.all,
          forceLandscapeViewportOnIpad: true,
          openInNewTabOnIOSSafariWeb: true,
        );

      default:
        return const _LocalProviderFallback();
    }
  }
*/
*/
