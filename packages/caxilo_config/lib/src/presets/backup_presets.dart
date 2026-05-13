part of 'caxilo_config_presets.dart';

/* ==========================================
 * GOLDEN COPY BACKUP (DATA PRESERVATION)
 * The entire sample JSON string from the legacy file is preserved below for reference.
 * ==========================================
 * 
 * [COPY OF kCasinoSettingsJson FROM remote_config_mock.dart]
 * 
{
  "version": 2,
  "updated_at": "2026-04-21T10:00:00Z",
  "environments": {
    "avenger_base_url": "https://avenger.sunwin.live",
    "pirates_base_url": "https://haitac.sunwin.live",
    "table_games_base_url": "https://gamebai.sunwin.live",
    "fish88_base_url": "https://fish-s88.sandboxg1.win",
    "aquarium_base_url": "https://thuycung.sunwin.live",
    "thantai_base_url": "https://thantai.sunwin.live"
  },
  "display": {
    "order": [
      "SC", "SP", "VT", "VTS", "SR", "SB88", "XD-TL", "TX-LIVE", "XD-LIVE", "BC-LT", "XD-TT-LIVE",
      "AVENGER", "PIRATES", "AQUARIUM", "THAN_TAI", "TIENLEN-SUN", "SAM-SUN", "POKER-SUN",
      "BLACK_JACK-SUN", "PHOM-SUN", "BINH-SUN", "LIENG-SUN", "XOCDIA-SUN", "PKR-AOF", "LODE"
    ],
    "featured": [
      "SC", "AVENGER", "PIRATES", "AQUARIUM", "THAN_TAI", "SP", "VT", "VTS", "SR", "SB88",
      "TX-LIVE", "XD-LIVE", "BC-LT", "LODE", "XD-TL", "XD-TT-LIVE", "PKR-AOF", "BINH-SUN",
      "TIENLEN-SUN", "POKER-SUN", "LIENG-SUN", "SAM-SUN", "XOCDIA-SUN", "PHOM-SUN", "BLACK_JACK-SUN"
    ],
    "new": ["AQUARIUM", "XD-LIVE"]
  },
  "lobby_sections": [
    { "type": "strategy", "title": "Casino nổi bật", "strategy_id": "popular", "params": { "min_play_count": 100 }, "limit": 12 },
    { "type": "strategy", "title": "Mới ra mắt", "strategy_id": "new", "params": { "days_ago": 30 }, "limit": 8 },
    { "type": "in_house", "title": "Game Sunwin", "limit": -1 },
    { "type": "banner", "banner_id": "providersBanner" },
    { "type": "game_type", "title": "Live", "game_type_id": "live", "limit": -1 },
    { "type": "game_type", "title": "Slots", "game_type_id": "slot", "limit": -1 },
    { "type": "game_type", "title": "Game bài", "game_type_id": "card", "limit": -1 },
    { "type": "game_type", "title": "Jackpots", "game_type_id": "jackpot", "limit": -1 }
  ],
  "categories": [
    { "type": "inHouse", "id": "sunwin", "translation_key": "txt_game_category_sunwin", "icon": "ic_sunwin_bw.png", "icon_active": "ic_sunwin.png" },
    { "type": "gameType", "id": "slots", "game_type": "slot", "translation_key": "txt_game_slots", "icon": "ic_slots.svg", "icon_active": "ic_slots_yellow.svg" },
    { "type": "gameType", "id": "sports", "game_type": "sport", "translation_key": "txt_game_sports", "icon": "ic_football.svg", "icon_active": "ic_football_yellow.svg" },
    { "type": "gameType", "id": "jackpot", "game_type": "jackpot", "translation_key": "txt_game_jackpot", "icon": "ic_jackpot.svg", "icon_active": "ic_jackpot_yellow.svg" },
    { "type": "gameType", "id": "cards", "game_type": "card", "translation_key": "txt_game_category_cards", "icon": "ic_card.svg", "icon_active": "ic_card_yellow.svg" },
    { "type": "gameType", "id": "live", "game_type": "live", "translation_key": "txt_game_category_live_dealer", "icon": "ic_live.svg", "icon_active": "ic_live_yellow.svg" },
    { "type": "gameType", "id": "casino", "game_type": "dice", "translation_key": "txt_game_category_casino", "icon": "ic_dice.svg", "icon_active": "ic_dice_yellow.svg" },
    { "type": "gameType", "id": "arcade", "game_type": "miniGame", "translation_key": "txt_game_category_arcade", "icon": "ic_arcade.svg", "icon_active": "ic_arcade_yellow.svg" },
    { "type": "gameType", "id": "lotto", "game_type": "lottery", "translation_key": "txt_game_category_lotto", "icon": "ic_roulette.svg", "icon_active": "ic_roulette_yellow.svg" },
    { "type": "gameType", "id": "fish", "game_type": "fish", "translation_key": "txt_game_category_fish", "icon": "ic_fish.svg", "icon_active": "ic_fish_yellow.svg" },
    { "type": "gameType", "id": "others", "game_type": "others", "translation_key": "txt_game_others", "icon": "ic_arcade.svg", "icon_active": "ic_arcade_yellow.svg" },
    { "type": "custom", "id": "newgames", "translation_key": "txt_game_category_new_games", "icon": "ic_bling.svg", "icon_active": "ic_bling_yellow.svg", "filter_strategy": "new", "filter_params": { "days_ago": 30 } }
  ],
  "in_house": {
    "catalog": [
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_AVENGER", "game_code": "AVENGER", "game_name": "Avenger", "image": "sunwin_AVENGER_avenger_thumb.webp", "lang": "vi", "game_type": "slot", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "avenger_base_url", "launch_strategy": "standard", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_PIRATES", "game_code": "PIRATES", "game_name": "Hải Tặc", "image": "sunwin_PIRATES_haitac_thumb.webp", "lang": "vi", "game_type": "slot", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "pirates_base_url", "launch_strategy": "standard", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_SC", "game_code": "SC", "game_name": "Sun cá", "image": "sunwin_SC_sun-ca_thumb.webp", "lang": "vi", "game_type": "fish", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "fish88_base_url", "launch_strategy": "fish", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_AQUARIUM", "game_code": "AQUARIUM", "game_name": "Thủy Cung", "image": "sunwin_AQUARIUM_thuy-cung_thumb.webp", "lang": "vi", "game_type": "slot", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "aquarium_base_url", "launch_strategy": "standard", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_THAN_TAI", "game_code": "THAN_TAI", "game_name": "Thần Tài", "image": "sunwin_THAN_TAI_than-tai_thumb.webp", "lang": "vi", "game_type": "slot", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "thantai_base_url", "launch_strategy": "standard", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_SP", "game_code": "SP", "game_name": "Sun phụng", "image": "sunwin_SP_sun-phung_thumb.webp", "lang": "vi", "game_type": "miniGame", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_VT", "game_code": "VT", "game_name": "Volta", "image": "sunwin_VT_volta_thumb.webp", "lang": "vi", "game_type": "miniGame", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_VTS", "game_code": "VTS", "game_name": "Volta S", "image": "sunwin_VTS_volta-s_thumb.webp", "lang": "vi", "game_type": "miniGame", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_SR", "game_code": "SR", "game_name": "Sun rồng", "image": "sunwin_SR_sun-rong_thumb.webp", "lang": "vi", "game_type": "miniGame", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_SB88", "game_code": "SB88", "game_name": "Sicbo88", "image": "sunwin_SB88_sicbo88_thumb.webp", "lang": "vi", "game_type": "live", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_TX-LIVE", "game_code": "TX-LIVE", "game_name": "Tài Xỉu Live", "image": "sunwin_TX-LIVE_tai-xiu-live_thumb.webp", "lang": "vi", "game_type": "live", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_XD-LIVE", "game_code": "XD-LIVE", "game_name": "Xóc Đĩa Live", "image": "sunwin_XD-LIVE_xoc-dia-live_thumb.webp", "lang": "vi", "game_type": "live", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_BC-LT", "game_code": "BC-LT", "game_name": "Bầu Cua Lộc Thú", "image": "sunwin_BC-LT_bau-cua-loc-thu_thumb.webp", "lang": "vi", "game_type": "miniGame", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_LODE", "game_code": "LODE", "game_name": "Lô Đề", "image": "sunwin_LODE_lo-de_thumb.webp", "lang": "vi", "game_type": "lottery", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_XD-TL", "game_code": "XD-TL", "game_name": "Xóc Đĩa Tứ Linh", "image": "sunwin_XD-TL_xoc-dia-tu-linh_thumb.webp", "lang": "vi", "game_type": "miniGame", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_XD-TT-LIVE", "game_code": "XD-TT-LIVE", "game_name": "Xóc Đĩa Thủy Tinh Live", "image": "sunwin_XD-TT-LIVE_xoc-dia-thuy-tinh-live_thumb.webp", "lang": "vi", "game_type": "live", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_PKR-AOF", "game_code": "PKR-AOF", "game_name": "Poker All-in or Fold", "image": "sunwin_PKR-AOF_poker-all-in-or-fold_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "launch_strategy": "underDevelopment", "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_BINH-SUN", "game_code": "BINH-SUN", "game_name": "Mậu Binh", "image": "sunwin_BINH-SUN_mau-binh_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 4, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_TIENLEN-SUN", "game_code": "TIENLEN-SUN", "game_name": "Tiến Lên", "image": "sunwin_TIENLEN-SUN_tien-len_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 1, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_POKER-SUN", "game_code": "POKER-SUN", "game_name": "Poker", "image": "sunwin_POKER-SUN_poker_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 6, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_LIENG-SUN", "game_code": "LIENG-SUN", "game_name": "Liêng", "image": "sunwin_LIENG-SUN_lieng_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 5, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_SAM-SUN", "game_code": "SAM-SUN", "game_name": "Sâm Lốc", "image": "sunwin_SAM-SUN_sam-loc_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 2, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_XOCDIA-SUN", "game_code": "XOCDIA-SUN", "game_name": "Xóc Đĩa", "image": "sunwin_XOCDIA-SUN_xoc-dia_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 9, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_PHOM-SUN", "game_code": "PHOM-SUN", "game_name": "Phỏm", "image": "sunwin_PHOM-SUN_phom_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 8, "enable_host_message": true },
      { "provider_id": "sunwin", "provider_name": "Sunwin", "product_id": "sunwin_BLACK_JACK-SUN", "game_code": "BLACK_JACK-SUN", "game_name": "Blackjack", "image": "sunwin_BLACK_JACK-SUN_blackjack_thumb.webp", "lang": "vi", "game_type": "card", "mobile_orientation": ["landscape"], "tablet_orientation": ["landscape"], "base_url_key": "table_games_base_url", "launch_strategy": "standard", "game_id": 13, "enable_host_message": true }
    ],
    "visibility": {
      "AVENGER": { "is_visible": true, "status": "active" }, "PIRATES": { "is_visible": true, "status": "active" }, "SC": { "is_visible": true, "status": "active" }, "AQUARIUM": { "is_visible": true, "status": "active" }, "THAN_TAI": { "is_visible": true, "status": "active" },
      "SP": { "is_visible": true, "status": "active" }, "VT": { "is_visible": true, "status": "active" }, "VTS": { "is_visible": true, "status": "active" }, "SR": { "is_visible": true, "status": "active" }, "SB88": { "is_visible": true, "status": "active" },
      "TX-LIVE": { "is_visible": true, "status": "active" }, "XD-LIVE": { "is_visible": true, "status": "active" }, "BC-LT": { "is_visible": true, "status": "active" }, "LODE": { "is_visible": true, "status": "active" }, "XD-TL": { "is_visible": true, "status": "active" },
      "XD-TT-LIVE": { "is_visible": true, "status": "active" }, "PKR-AOF": { "is_visible": true, "status": "active" }, "BINH-SUN": { "is_visible": true, "status": "active" }, "TIENLEN-SUN": { "is_visible": true, "status": "active" }, "POKER-SUN": { "is_visible": true, "status": "active" },
      "LIENG-SUN": { "is_visible": true, "status": "active" }, "SAM-SUN": { "is_visible": true, "status": "active" }, "XOCDIA-SUN": { "is_visible": true, "status": "active" }, "PHOM-SUN": { "is_visible": true, "status": "active" }, "BLACK_JACK-SUN": { "is_visible": true, "status": "active" }
    }
  },
  "external": {
    "provider_configs": {
      "amb-vn": {
        "game_type": "live",
        "mobile_orientation": ["portraitUp", "portraitDown"],
        "open_in_new_tab_on_ios_safari_web": true,
        "requires_session_guard": true,
        "load_stop_debounce_ms": 777,
        "games": [
          { "game_code": "mx-live-001", "image": "amb-vn_MX-LIVE-001_baccarat-classic_thumb.webp" },
          { "game_code": "mx-live-015", "image": "amb-vn_MX-LIVE-015_fish-prawn-crab_thumb.webp" },
          { "game_code": "mx-live-006", "image": "amb-vn_MX-LIVE-006_dragontiger_thumb.webp" },
          { "game_code": "mx-live-009", "image": "amb-vn_MX-LIVE-009_roulette_thumb.webp" }
        ]
      },
      "via-casino-vn": {
        "game_type": "live",
        "mobile_orientation": ["portraitUp", "portraitDown"],
        "tablet_orientation": ["landscapeRight"],
        "force_landscape_viewport_on_ipad": true,
        "open_in_new_tab_on_ios_safari_web": true,
        "games": [
          { "game_code": "baccarat60s", "image": "via-casino-vn_BACCARAT60S_baccarat_thumb.webp" },
          { "game_code": "ltbaccarat", "image": "via-casino-vn_LTBACCARAT_lotto-baccarat_thumb.webp" },
          { "game_code": "tx60s", "image": "via-casino-vn_TX60S_tai-xiu_thumb.webp" },
          { "game_code": "dt60s", "image": "via-casino-vn_DT60S_rong-ho_thumb.webp" },
          { "game_code": "xd60s", "image": "via-casino-vn_XD60S_xoc-dia_thumb.webp" },
          { "game_code": "wwmb", "image": "via-casino-vn_WWMB_bi-loc-xoay_thumb.webp" }
        ]
      },
      "vivo": {
        "game_type": "live",
        "mobile_orientation": ["portraitUp", "portraitDown"],
        "open_in_new_tab_on_ios_safari_web": true,
        "games": [
          { "game_code": "353", "image": "vivo_353_baccarat-dance_thumb.webp" },
          { "game_code": "1", "image": "vivo_1_galactic-vip-roulette_thumb.webp" },
          { "game_code": "420", "image": "vivo_420_sic-bo_thumb.webp" },
          { "game_code": "425", "image": "vivo_425_dragon-tiger-jade_thumb.webp" },
          { "game_code": "16", "image": "vivo_16_oceania-vip-blackjack_thumb.webp" }
        ]
      },
      "lcevo": {
        "game_type": "live",
        "mobile_orientation": ["portraitUp", "portraitDown"],
        "open_in_new_tab_on_ios_safari_web": true,
        "games": [
          { "game_code": "baccarat", "image": "lcevo_baccarat_baccarat-sieu-toc-a_thumb.webp" },
          { "game_code": "bacbo", "image": "lcevo_bacbo_bac-bo_thumb.webp" },
          { "game_code": "sicbo", "image": "lcevo_sicbo_sieu-tai-xiu_thumb.webp" },
          { "game_code": "scalablebetstackerbj", "image": "lcevo_scalablebetstackerbj_blackjack-chong-phinh-cuoc-vo-cuc_thumb.webp" },
          { "game_code": "holdem", "image": "lcevo_holdem_poker_thumb.webp" },
          { "game_code": "fantan", "image": "lcevo_fantan_fan-tan_thumb.webp" },
          { "game_code": "dragontiger", "image": "lcevo_dragontiger_rong-ho_thumb.webp" },
          { "game_code": "roulette", "image": "lcevo_roulette_roulette-tu-dong_thumb.webp" },
          { "game_code": "moneywheel", "image": "lcevo_moneywheel_imperial-quest_thumb.webp" }
        ]
      }
    }
  }
}
 */
