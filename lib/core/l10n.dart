import 'app_settings.dart';
import 'game_history.dart';

class L10n {
  static final L10n _i = L10n._();
  factory L10n() => _i;
  L10n._();

  AppLanguage _lang = AppLanguage.vietnamese;
  void setLanguage(AppLanguage l) => _lang = l;

  static const Map<String, Map<String, String>> _strings = {
    // ── App ──
    'appTitle': {
      'vi': 'CARO',
      'en': 'CARO',
      'ja': '五目並べ',
      'zh': '五子棋',
    },
    'tagline': {
      'vi': 'CARO CLASSIC',
      'en': 'CARO CLASSIC',
      'ja': 'クラシック五目並べ',
      'zh': '经典五子棋',
    },
    // ── Home ──
    'twoPlayers': {
      'vi': 'HAI NGƯỜI CHƠI',
      'en': 'TWO PLAYERS',
      'ja': '二人プレイ',
      'zh': '双人游戏',
    },
    'twoPlayersSub': {
      'vi': 'Chơi cùng bạn bè',
      'en': 'Play with a friend',
      'ja': '友達と遊ぶ',
      'zh': '和朋友一起玩',
    },
    'vsAI': {
      'vi': 'CHƠI VỚI AI',
      'en': 'VS AI',
      'ja': 'AIと対戦',
      'zh': '对战电脑',
    },
    'vsAISub': {
      'vi': 'Thách đấu AI',
      'en': 'Challenge the AI',
      'ja': 'AIに挑戦',
      'zh': '挑战AI',
    },
    'settings': {
      'vi': 'CÀI ĐẶT',
      'en': 'SETTINGS',
      'ja': '設定',
      'zh': '设置',
    },
    'history': {
      'vi': 'LỊCH SỬ',
      'en': 'HISTORY',
      'ja': '履歴',
      'zh': '历史',
    },
    // ── Game ──
    'yourTurn': {
      'vi': 'Lượt của bạn (X)',
      'en': 'Your turn (X)',
      'ja': 'あなたの番 (X)',
      'zh': '你的回合 (X)',
    },
    'aiThinking': {
      'vi': 'Máy đang suy nghĩ...',
      'en': 'AI is thinking...',
      'ja': 'AIが考えています...',
      'zh': '电脑思考中...',
    },
    'turnX': {
      'vi': 'Lượt của X',
      'en': 'X\'s turn',
      'ja': 'Xの番',
      'zh': 'X的回合',
    },
    'turnO': {
      'vi': 'Lượt của O',
      'en': 'O\'s turn',
      'ja': 'Oの番',
      'zh': 'O的回合',
    },
    'youWin': {
      'vi': 'Bạn thắng!',
      'en': 'You win!',
      'ja': 'あなたの勝ち！',
      'zh': '你赢了！',
    },
    'aiWins': {
      'vi': 'Máy thắng!',
      'en': 'AI wins!',
      'ja': 'AIの勝ち！',
      'zh': '电脑赢了！',
    },
    'xWins': {
      'vi': 'X thắng!',
      'en': 'X wins!',
      'ja': 'Xの勝ち！',
      'zh': 'X赢了！',
    },
    'oWins': {
      'vi': 'O thắng!',
      'en': 'O wins!',
      'ja': 'Oの勝ち！',
      'zh': 'O赢了！',
    },
    'draw': {
      'vi': 'Hòa!',
      'en': 'Draw!',
      'ja': '引き分け！',
      'zh': '平局！',
    },
    'timeout': {
      'vi': 'Hết giờ!',
      'en': 'Time\'s up!',
      'ja': '時間切れ！',
      'zh': '时间到！',
    },
    'you': {
      'vi': 'BẠN (X)',
      'en': 'YOU (X)',
      'ja': 'あなた(X)',
      'zh': '你 (X)',
    },
    'ai': {
      'vi': 'MÁY (O)',
      'en': 'AI (O)',
      'ja': 'AI (O)',
      'zh': '电脑 (O)',
    },
    'draw_label': {
      'vi': 'HÒA',
      'en': 'DRAW',
      'ja': '引分',
      'zh': '平局',
    },
    // ── Settings ──
    'settingsTitle': {
      'vi': 'CÀI ĐẶT',
      'en': 'SETTINGS',
      'ja': '設定',
      'zh': '设置',
    },
    'turnTime': {
      'vi': 'Thời gian mỗi lượt',
      'en': 'Turn time limit',
      'ja': '1手の制限時間',
      'zh': '每回合时间',
    },
    'noLimit': {
      'vi': 'Không giới hạn',
      'en': 'No limit',
      'ja': '無制限',
      'zh': '无限制',
    },
    'skin': {
      'vi': 'Skin quân cờ',
      'en': 'Piece skin',
      'ja': '駒のスキン',
      'zh': '棋子外观',
    },
    'boardBackground': {
      'vi': 'Nền bàn cờ',
      'en': 'Board background',
      'ja': '盤の背景',
      'zh': '棋盘背景',
    },
    'boardSize': {
      'vi': 'Cỡ bàn cờ',
      'en': 'Board size',
      'ja': '盤のサイズ',
      'zh': '棋盘大小',
    },
    'boardPreset_n3': {
      'vi': '3×3 — 3 quân liên tiếp',
      'en': '3×3 — 3 in a row',
      'ja': '3×3 — 3連',
      'zh': '3×3 — 连三',
    },
    'boardPreset_n4': {
      'vi': '4×4 — 4 quân liên tiếp',
      'en': '4×4 — 4 in a row',
      'ja': '4×4 — 4連',
      'zh': '4×4 — 连四',
    },
    'boardPreset_n6': {
      'vi': '6×6 — 4 quân liên tiếp',
      'en': '6×6 — 4 in a row',
      'ja': '6×6 — 4連',
      'zh': '6×6 — 连四',
    },
    'boardPreset_n9': {
      'vi': '9×9 — 5 quân liên tiếp',
      'en': '9×9 — 5 in a row',
      'ja': '9×9 — 5連',
      'zh': '9×9 — 连五',
    },
    'boardPreset_n13': {
      'vi': '13×13 — 5 quân liên tiếp',
      'en': '13×13 — 5 in a row',
      'ja': '13×13 — 5連',
      'zh': '13×13 — 连五',
    },
    'boardPreset_n15': {
      'vi': '15×15 — 5 quân liên tiếp',
      'en': '15×15 — 5 in a row',
      'ja': '15×15 — 5連',
      'zh': '15×15 — 连五',
    },
    'skin_neon': {
      'vi': 'Neon',
      'en': 'Neon',
      'ja': 'ネオン',
      'zh': '霓虹',
    },
    'skin_fire': {
      'vi': 'Lửa',
      'en': 'Fire',
      'ja': '炎',
      'zh': '火焰',
    },
    'skin_forest': {
      'vi': 'Rừng',
      'en': 'Forest',
      'ja': '森',
      'zh': '森林',
    },
    'skin_royal': {
      'vi': 'Hoàng gia',
      'en': 'Royal',
      'ja': 'ロイヤル',
      'zh': '皇家',
    },
    'skin_mono': {
      'vi': 'Mono',
      'en': 'Mono',
      'ja': 'モノクロ',
      'zh': '单色',
    },
    'board_midnight': {
      'vi': 'Đêm',
      'en': 'Midnight',
      'ja': '夜',
      'zh': '午夜',
    },
    'board_ocean': {
      'vi': 'Đại dương',
      'en': 'Ocean',
      'ja': '海',
      'zh': '海洋',
    },
    'board_deepForest': {
      'vi': 'Rừng sâu',
      'en': 'Deep forest',
      'ja': '深い森',
      'zh': '深林',
    },
    'board_sunset': {
      'vi': 'Hoàng hôn',
      'en': 'Sunset',
      'ja': '夕焼け',
      'zh': '日落',
    },
    'board_wood': {
      'vi': 'Gỗ cổ',
      'en': 'Wood',
      'ja': '木目',
      'zh': '木纹',
    },
    'board_charcoal': {
      'vi': 'Than',
      'en': 'Charcoal',
      'ja': 'チャコール',
      'zh': '炭灰',
    },
    'language': {
      'vi': 'Ngôn ngữ',
      'en': 'Language',
      'ja': '言語',
      'zh': '语言',
    },
    'sound': {
      'vi': 'Âm thanh',
      'en': 'Sound',
      'ja': 'サウンド',
      'zh': '声音',
    },
    'soundOn': {
      'vi': 'Bật',
      'en': 'On',
      'ja': 'オン',
      'zh': '开启',
    },
    'soundOff': {
      'vi': 'Tắt',
      'en': 'Off',
      'ja': 'オフ',
      'zh': '关闭',
    },
    'aiDifficulty': {
      'vi': 'Độ khó AI',
      'en': 'AI difficulty',
      'ja': 'AIの難易度',
      'zh': 'AI 难度',
    },
    'aiDifficultyLow': {
      'vi': 'Dễ',
      'en': 'Easy',
      'ja': 'かんたん',
      'zh': '简单',
    },
    'aiDifficultyMedium': {
      'vi': 'Trung bình',
      'en': 'Normal',
      'ja': 'ふつう',
      'zh': '普通',
    },
    'aiDifficultyHigh': {
      'vi': 'Khó',
      'en': 'Hard',
      'ja': 'むずかしい',
      'zh': '困难',
    },
    // ── History ──
    'historyTitle': {
      'vi': 'LỊCH SỬ VÁN ĐẤU',
      'en': 'GAME HISTORY',
      'ja': '対局履歴',
      'zh': '对局历史',
    },
    'noHistory': {
      'vi': 'Chưa có ván đấu nào',
      'en': 'No games played yet',
      'ja': 'まだ対局がありません',
      'zh': '还没有对局记录',
    },
    'clearHistory': {
      'vi': 'Xóa lịch sử',
      'en': 'Clear history',
      'ja': '履歴をクリア',
      'zh': '清除历史',
    },
    'moves': {
      'vi': 'nước',
      'en': 'moves',
      'ja': '手',
      'zh': '步',
    },
    // Short marks for history / result badge (no emoji; safe fonts).
    'resultMarkX': {
      'vi': 'X',
      'en': 'X',
      'ja': 'X',
      'zh': 'X',
    },
    'resultMarkO': {
      'vi': 'O',
      'en': 'O',
      'ja': 'O',
      'zh': 'O',
    },
    'resultMarkDraw': {
      'vi': '=',
      'en': '=',
      'ja': '分',
      'zh': '平',
    },
    'resultMarkTimeout': {
      'vi': 'T',
      'en': 'T',
      'ja': '時',
      'zh': '时',
    },
    // ── Result ──
    'playAgain': {
      'vi': 'CHƠI LẠI',
      'en': 'PLAY AGAIN',
      'ja': 'もう一度',
      'zh': '再来一局',
    },
    'backHome': {
      'vi': 'VỀ TRANG CHỦ',
      'en': 'HOME',
      'ja': 'ホーム',
      'zh': '回主页',
    },
    'winner': {
      'vi': 'NGƯỜI CHIẾN THẮNG',
      'en': 'WINNER',
      'ja': '勝者',
      'zh': '获胜者',
    },
    'totalMoves': {
      'vi': 'Tổng số nước',
      'en': 'Total moves',
      'ja': '総手数',
      'zh': '总步数',
    },
    'duration': {
      'vi': 'Thời gian',
      'en': 'Duration',
      'ja': '対局時間',
      'zh': '时长',
    },
  };

  String get(String key) {
    return _strings[key]?[_lang.code] ?? _strings[key]?['vi'] ?? key;
  }

  /// History row: "N moves" with natural spacing (ja/zh attach the counter to the number).
  String formatHistoryMoveCount(int totalMoves) {
    switch (_lang) {
      case AppLanguage.vietnamese:
        return '$totalMoves nước';
      case AppLanguage.english:
        return '$totalMoves moves';
      case AppLanguage.japanese:
        return '$totalMoves手';
      case AppLanguage.chinese:
        return '$totalMoves步';
    }
  }

  /// Compact result glyph for list rows and result dialog (text only, no emoji).
  String resultListMark(GameResult result) {
    switch (result) {
      case GameResult.xWins:
        return get('resultMarkX');
      case GameResult.oWins:
        return get('resultMarkO');
      case GameResult.draw:
        return get('resultMarkDraw');
      case GameResult.timeout:
        return get('resultMarkTimeout');
    }
  }

  String skinLabel(PieceSkin skin) {
    switch (skin) {
      case PieceSkin.neon:
        return get('skin_neon');
      case PieceSkin.fire:
        return get('skin_fire');
      case PieceSkin.forest:
        return get('skin_forest');
      case PieceSkin.royal:
        return get('skin_royal');
      case PieceSkin.mono:
        return get('skin_mono');
    }
  }

  String boardBackgroundLabel(BoardBackground bg) {
    switch (bg) {
      case BoardBackground.midnight:
        return get('board_midnight');
      case BoardBackground.ocean:
        return get('board_ocean');
      case BoardBackground.deepForest:
        return get('board_deepForest');
      case BoardBackground.sunset:
        return get('board_sunset');
      case BoardBackground.wood:
        return get('board_wood');
      case BoardBackground.charcoal:
        return get('board_charcoal');
    }
  }

  String boardSizePresetLabel(BoardSizePreset preset) {
    switch (preset) {
      case BoardSizePreset.n3:
        return get('boardPreset_n3');
      case BoardSizePreset.n4:
        return get('boardPreset_n4');
      case BoardSizePreset.n6:
        return get('boardPreset_n6');
      case BoardSizePreset.n9:
        return get('boardPreset_n9');
      case BoardSizePreset.n13:
        return get('boardPreset_n13');
      case BoardSizePreset.n15:
        return get('boardPreset_n15');
    }
  }

  /// History row fragment: board dimensions and win rule.
  String formatHistoryBoardLine(int side, int winLength) {
    switch (_lang) {
      case AppLanguage.vietnamese:
        return '$side×$side · $winLength liên tiếp';
      case AppLanguage.english:
        return '$side×$side · $winLength in a row';
      case AppLanguage.japanese:
        return '$side×$side · $winLength連';
      case AppLanguage.chinese:
        return '$side×$side · 连$winLength';
    }
  }

  // Convenience getters
  String get appTitle => get('appTitle');
  String get tagline => get('tagline');
  String get twoPlayers => get('twoPlayers');
  String get twoPlayersSub => get('twoPlayersSub');
  String get vsAI => get('vsAI');
  String get vsAISub => get('vsAISub');
  String get settings => get('settings');
  String get history => get('history');
  String get yourTurn => get('yourTurn');
  String get aiThinking => get('aiThinking');
  String get turnX => get('turnX');
  String get turnO => get('turnO');
  String get youWin => get('youWin');
  String get aiWins => get('aiWins');
  String get xWins => get('xWins');
  String get oWins => get('oWins');
  String get draw => get('draw');
  String get timeout => get('timeout');
  String get you => get('you');
  String get ai => get('ai');
  String get drawLabel => get('draw_label');
  String get settingsTitle => get('settingsTitle');
  String get turnTime => get('turnTime');
  String get noLimit => get('noLimit');
  String get skin => get('skin');
  String get boardBackground => get('boardBackground');
  String get boardSize => get('boardSize');
  String get language => get('language');
  String get sound => get('sound');
  String get soundOn => get('soundOn');
  String get soundOff => get('soundOff');
  String get aiDifficulty => get('aiDifficulty');
  String get aiDifficultyLow => get('aiDifficultyLow');
  String get aiDifficultyMedium => get('aiDifficultyMedium');
  String get aiDifficultyHigh => get('aiDifficultyHigh');
  String get historyTitle => get('historyTitle');
  String get noHistory => get('noHistory');
  String get clearHistory => get('clearHistory');
  String get moves => get('moves');
  String get playAgain => get('playAgain');
  String get backHome => get('backHome');
  String get winner => get('winner');
  String get totalMoves => get('totalMoves');
  String get duration => get('duration');
}

// Global instance
final l10n = L10n();
