import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum GameResult { xWins, oWins, draw, timeout }
enum GameMode { twoPlayers, vsAI }

class GameRecord {
  final String id;
  final DateTime playedAt;
  final GameMode mode;
  final GameResult result;
  final int totalMoves;
  final int durationSecs;
  final String skinName;
  final int boardSide;
  final int winLength;

  GameRecord({
    required this.id,
    required this.playedAt,
    required this.mode,
    required this.result,
    required this.totalMoves,
    required this.durationSecs,
    required this.skinName,
    required this.boardSide,
    required this.winLength,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'playedAt': playedAt.toIso8601String(),
    'mode': mode.index,
    'result': result.index,
    'totalMoves': totalMoves,
    'durationSecs': durationSecs,
    'skinName': skinName,
    'boardSide': boardSide,
    'winLength': winLength,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    id: json['id'],
    playedAt: DateTime.parse(json['playedAt']),
    mode: GameMode.values[json['mode']],
    result: GameResult.values[json['result']],
    totalMoves: json['totalMoves'],
    durationSecs: json['durationSecs'],
    skinName: json['skinName'] ?? 'neon',
    boardSide: json['boardSide'] ?? 15,
    winLength: json['winLength'] ?? 5,
  );

  String get durationText {
    final m = durationSecs ~/ 60;
    final s = durationSecs % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }
}

class GameHistory {
  static final GameHistory _i = GameHistory._();
  factory GameHistory() => _i;
  GameHistory._();

  static const _key = 'game_history';
  List<GameRecord> _records = [];
  List<GameRecord> get records => List.unmodifiable(_records);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _records = raw
        .map((s) => GameRecord.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  Future<void> add(GameRecord record) async {
    _records.insert(0, record);
    if (_records.length > 100) _records = _records.take(100).toList();
    await _save();
  }

  Future<void> clear() async {
    _records = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _records.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }
}
