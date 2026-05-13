part of 'caxilo_config_presets.dart';

// ==========================================
// EXTERNAL PROVIDER GAMES
// ==========================================
const _sharedExternal = {
  "provider_configs": {
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
    "amb-vn": {
      "game_type": "live",
      "mobile_orientation": ["portraitUp", "portraitDown"],
      "open_in_new_tab_on_ios_safari_web": true,
      "requires_session_guard": true,
      "load_stop_debounce_ms": 777,
      "games": [
        {
          "game_code": "mx-live-001", // Baccarat Classic
          "image": "amb-vn_MX-LIVE-001_baccarat-classic_thumb.webp",
        },
        {
          "game_code": "mx-live-015", // Fish Prawn Crab (Bầu Cua)
          "image": "amb-vn_MX-LIVE-015_fish-prawn-crab_thumb.webp",
        },
        {
          "game_code": "mx-live-006", // DragonTiger (Rồng Hổ)
          "image": "amb-vn_MX-LIVE-006_dragontiger_thumb.webp",
        },
        {
          "game_code": "mx-live-009", // Roulette
          "image": "amb-vn_MX-LIVE-009_roulette_thumb.webp",
        },
      ],
    },

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
    "via-casino-vn": {
      "game_type": "live",
      "mobile_orientation": ["portraitUp", "portraitDown"],
      "tablet_orientation": ["landscapeRight"],
      "force_landscape_viewport_on_ipad": true,
      "open_in_new_tab_on_ios_safari_web": true,
      "games": [
        {
          "game_code": "baccarat60s", // Baccarat
          "image": "via-casino-vn_BACCARAT60S_baccarat_thumb.webp",
        },
        {
          "game_code": "ltbaccarat", // Lotto Baccarat
          "image": "via-casino-vn_LTBACCARAT_lotto-baccarat_thumb.webp",
        },
        {
          "game_code": "tx60s", // Tài Xỉu
          "image": "via-casino-vn_TX60S_tai-xiu_thumb.webp",
        },
        {
          "game_code": "dt60s", // Rồng Hổ
          "image": "via-casino-vn_DT60S_rong-ho_thumb.webp",
        },
        {
          "game_code": "xd60s", // Xóc Dĩa
          "image": "via-casino-vn_XD60S_xoc-dia_thumb.webp",
        },
        {
          "game_code": "wwmb", // Bi Lốc Xoáy (Đua Bi)
          "image": "via-casino-vn_WWMB_bi-loc-xoay_thumb.webp",
        },
      ],
    },

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
    "vivo": {
      "game_type": "live",
      "mobile_orientation": ["portraitUp", "portraitDown"],
      "open_in_new_tab_on_ios_safari_web": true,
      "games": [
        {
          "game_code": "353", // Baccarat Dance
          "image": "vivo_353_baccarat-dance_thumb.webp",
        },
        {
          "game_code": "1", // Galactic VIP Roulette
          "image": "vivo_1_galactic-vip-roulette_thumb.webp",
        },
        {
          "game_code": "420", // Sic Bo
          "image": "vivo_420_sic-bo_thumb.webp",
        },
        {
          "game_code": "425", // Dragon Tiger Jade
          "image": "vivo_425_dragon-tiger-jade_thumb.webp",
        },
        {
          "game_code": "16", // Oceania VIP Blackjack
          "image": "vivo_16_oceania-vip-blackjack_thumb.webp",
        },
      ],
    },

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
    "lcevo": {
      "game_type": "live",
      "mobile_orientation": ["portraitUp", "portraitDown"],
      "open_in_new_tab_on_ios_safari_web": true,
      "games": [
        {
          "game_code": "baccarat", // Baccarat Siêu Tốc A
          "image": "lcevo_baccarat_baccarat-sieu-toc-a_thumb.webp",
        },
        {
          "game_code": "bacbo", // Bac Bo
          "image": "lcevo_bacbo_bac-bo_thumb.webp",
        },
        {
          "game_code": "sicbo", // Siêu Tài Xỉu (Super Sic Bo)
          "image": "lcevo_sicbo_sieu-tai-xiu_thumb.webp",
        },
        {
          "game_code": "scalablebetstackerbj", // Blackjack Chồng Phỉnh Cược Vô Cực
          "image": "lcevo_scalablebetstackerbj_blackjack-chong-phinh-cuoc-vo-cuc_thumb.webp",
        },
        {
          "game_code": "holdem", // Poker
          "image": "lcevo_holdem_poker_thumb.webp",
        },
        {
          "game_code": "fantan", // Fan Tan
          "image": "lcevo_fantan_fan-tan_thumb.webp",
        },
        {
          "game_code": "dragontiger", // Rồng Hổ
          "image": "lcevo_dragontiger_rong-ho_thumb.webp",
        },
        {
          "game_code": "roulette", // Roulette Tự Động
          "image": "lcevo_roulette_roulette-tu-dong_thumb.webp",
        },
        {
          "game_code": "moneywheel", // Imperial Quest
          "image": "lcevo_moneywheel_imperial-quest_thumb.webp",
        },
      ],
    },
  },
};
