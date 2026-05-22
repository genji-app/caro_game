part of 'caxilo_config_presets.dart';

// ==========================================
// GAME CATEGORIES
// ==========================================
const _sharedCategories = [
  {
    "id": "sunwin",
    "group_key": "priority",
    "translation_key": "txt_game_category_sunwin",
    "icon": "ic_sunwin_bw.png",
    "icon_active": "ic_sunwin.png",
    "filter": {"strategy": "in_house"},
  },
  {
    "id": "slots",
    "group_key": "standard",
    "translation_key": "txt_game_slots",
    "icon": "ic_slots.svg",
    "icon_active": "ic_slots_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "slot"},
    },
  },
  {
    "id": "sports",
    // no group_key → excluded from sidebar by fallback type-based logic
    "translation_key": "txt_game_sports",
    "icon": "ic_football.svg",
    "icon_active": "ic_football_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "sport"},
    },
  },
  {
    "id": "jackpot",
    "group_key": "priority",
    "translation_key": "txt_game_jackpot",
    "icon": "ic_jackpot.svg",
    "icon_active": "ic_jackpot_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "jackpot"},
    },
  },
  {
    "id": "cards",
    "group_key": "standard",
    "translation_key": "txt_game_category_cards",
    "icon": "ic_card.svg",
    "icon_active": "ic_card_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "card"},
    },
  },
  {
    "id": "live",
    "group_key": "standard",
    "translation_key": "txt_game_category_live_dealer",
    "icon": "ic_live.svg",
    "icon_active": "ic_live_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "live"},
    },
  },
  {
    "id": "casino",
    "group_key": "standard",
    "translation_key": "txt_game_category_casino",
    "icon": "ic_dice.svg",
    "icon_active": "ic_dice_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "dice"},
    },
  },
  {
    "id": "arcade",
    "group_key": "standard",
    "translation_key": "txt_game_category_arcade",
    "icon": "ic_arcade.svg",
    "icon_active": "ic_arcade_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "miniGame"},
    },
  },
  {
    "id": "lotto",
    "group_key": "standard",
    "translation_key": "txt_game_category_lotto",
    "icon": "ic_roulette.svg",
    "icon_active": "ic_roulette_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "lottery"},
    },
  },
  {
    "id": "fish",
    "group_key": "standard",
    "translation_key": "txt_game_category_fish",
    "icon": "ic_fish.svg",
    "icon_active": "ic_fish_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "fish"},
    },
  },
  {
    "id": "others",
    "group_key": "standard",
    "translation_key": "txt_game_others",
    "icon": "ic_arcade.svg",
    "icon_active": "ic_arcade_yellow.svg",
    "filter": {
      "strategy": "by_game_type",
      "params": {"game_type": "others"},
    },
  },
  {
    "id": "newgames",
    "group_key": "standard",
    "translation_key": "txt_game_category_new_games",
    "icon": "ic_bling.svg",
    "icon_active": "ic_bling_yellow.svg",
    "filter": {
      "strategy": "collection",
      "params": {"id": "new"},
    },
  },
];
