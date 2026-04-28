import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum GameResult { xWins, oWins, draw, timeout }
enum GameMode { twoPlayers, vsAI }

/// Thông tin 1 nước đi được lưu vào lịch sử để replay lại game.
///
/// [removedRow]/[removedCol] chỉ có giá trị khi áp dụng luật sliding-cap
/// (board 3x3 / 4x4) và nước đi này đã đẩy 1 quân cũ ra khỏi bàn.
class MoveLog {
  final int row;
  final int col;
  final int player;
  final int? removedRow;
  final int? removedCol;

  const MoveLog({
    required this.row,
    required this.col,
    required this.player,
    this.removedRow,
    this.removedCol,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'r': row,
        'c': col,
        'p': player,
        if (removedRow != null) 'rr': removedRow,
        if (removedCol != null) 'rc': removedCol,
      };

  factory MoveLog.fromJson(Map<String, dynamic> json) => MoveLog(
        row: json['r'] as int,
        col: json['c'] as int,
        player: json['p'] as int,
        removedRow: json['rr'] as int?,
        removedCol: json['rc'] as int?,
      );
}

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

  /// Index của [AiDifficulty] khi [mode] là vsAI. -1 khi không dùng (PvP).
  final int aiDifficultyIndex;

  /// Danh sách nước đi theo thứ tự — dùng để replay. Rỗng với record cũ
  /// được tạo trước khi tính năng replay ra đời → replay button sẽ ẩn đi.
  final List<MoveLog> moves;

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
    this.aiDifficultyIndex = -1,
    this.moves = const <MoveLog>[],
  });

  bool get canReplay => moves.isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'playedAt': playedAt.toIso8601String(),
        'mode': mode.index,
        'result': result.index,
        'totalMoves': totalMoves,
        'durationSecs': durationSecs,
        'skinName': skinName,
        'boardSide': boardSide,
        'winLength': winLength,
        'aiDifficultyIndex': aiDifficultyIndex,
        'moves': moves.map((MoveLog m) => m.toJson()).toList(),
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        id: json['id'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
        mode: GameMode.values[json['mode'] as int],
        result: GameResult.values[json['result'] as int],
        totalMoves: json['totalMoves'] as int,
        durationSecs: json['durationSecs'] as int,
        skinName: (json['skinName'] as String?) ?? 'neon',
        boardSide: (json['boardSide'] as int?) ?? 15,
        winLength: (json['winLength'] as int?) ?? 5,
        aiDifficultyIndex: (json['aiDifficultyIndex'] as int?) ?? -1,
        moves: (json['moves'] as List<dynamic>?)
                ?.map((dynamic e) => MoveLog.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <MoveLog>[],
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
