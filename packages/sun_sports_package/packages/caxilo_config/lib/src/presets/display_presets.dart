part of 'caxilo_config_presets.dart';

// ==========================================
// LOBBY (category tab + SDUI sections)
// ==========================================
const _sharedLobby = {
  "translation_key": "txt_game_category_all",
  "icon": "ic_home.svg",
  "icon_active": "ic_home_yellow.svg",
  "sections": _sharedLobbySections,
};

// ==========================================
// SHARED APP DATA (DISPLAY & LOBBY)
// ==========================================
const _sharedDisplay = {
  "order": [
    "SC",
    "SP",
    "VT",
    "VTS",
    "SR",
    "SB88",
    "XD-TL",
    "TX-LIVE",
    "XD-LIVE",
    "BC-LT",
    "XD-TT-LIVE",
    "AVENGER",
    "PIRATES",
    "AQUARIUM",
    "THAN_TAI",
    "TIENLEN-SUN",
    "SAM-SUN",
    "POKER-SUN",
    "BLACK_JACK-SUN",
    "PHOM-SUN",
    "BINH-SUN",
    "LIENG-SUN",
    "XOCDIA-SUN",
    "PKR-AOF",
    "LODE",
  ],
  "collections": {
    "featured": [
      "SC",
      "SP",
      "VT",
      "VTS",
      "SR",
      "SB88",
      "XD-TL",
      "TX-LIVE",
      "XD-LIVE",
      "BC-LT",
      "XD-TT-LIVE",
      "AVENGER",
      "PIRATES",
      "AQUARIUM",
      "THAN_TAI",
      "TIENLEN-SUN",
      "SAM-SUN",
      "POKER-SUN",
      "BLACK_JACK-SUN",
      "PHOM-SUN",
      "BINH-SUN",
      "LIENG-SUN",
      "XOCDIA-SUN",
      "PKR-AOF",
      "LODE",
    ],
    "popular": ["SC", "SP", "VT", "VTS", "SR"],
    "new": [
      "SC",
      "SP",
      "VT",
      "VTS",
      "SR",
      "SB88",
      "XD-TL",
      "TX-LIVE",
      "XD-LIVE",
      "BC-LT",
      "XD-TT-LIVE",
      "AVENGER",
      "PIRATES",
      "AQUARIUM",
      "THAN_TAI",
      "TIENLEN-SUN",
      "SAM-SUN",
      "POKER-SUN",
      "BLACK_JACK-SUN",
      "PHOM-SUN",
      "BINH-SUN",
      "LIENG-SUN",
      "XOCDIA-SUN",
      "PKR-AOF",
      "LODE",
    ],
  },
};

const _sharedLobbySections = [
  {
    "title": "Casino nổi bật",
    "limit": -1,
    // "limit": 12,
    "filter": {
      "strategy": "collection",
      "params": {"id": "featured"},
    },
  },
  {
    "title": "Mới ra mắt",
    "limit": -1,
    // "limit": 8,
    "filter": {
      "strategy": "collection",
      "params": {"id": "new"},
    },
  },
  {
    "title": "Game Sunwin",
    "limit": -1,
    "filter": {"strategy": "in_house"},
  },
  {"banner_id": "providersBanner"},
  {
    "title": "Live",
    "limit": -1,
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "live"},
    },
  },
  {
    "title": "Slots",
    "limit": -1,
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "slot"},
    },
  },
  {
    "title": "Game bài",
    "limit": -1,
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "card"},
    },
  },
  {
    "title": "Jackpots",
    "limit": -1,
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "jackpot"},
    },
  },
];
