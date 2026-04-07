import 'dart:async' as async;
import 'dart:isolate';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/app_settings.dart';
import '../core/audio_service.dart';
import '../core/game_history.dart';
import 'board_component.dart';
import 'ai_engine.dart';

// ─── Enums & State ────────────────────────────────────────────────────────────

enum GameStatus { playing, xWins, oWins, draw, timeout }

class GameState {
  final int currentPlayer;
  final GameStatus status;
  final int timeLeft;
  final bool canUndo;

  const GameState({
    required this.currentPlayer,
    required this.status,
    required this.timeLeft,
    required this.canUndo,
  });
}

// ─── Move record for undo ─────────────────────────────────────────────────────

class MoveRecord {
  final int row;
  final int col;
  final int player;
  final int? removedRow;
  final int? removedCol;

  MoveRecord(
    this.row,
    this.col,
    this.player, {
    this.removedRow,
    this.removedCol,
  });
}

// ─── CaroGame ─────────────────────────────────────────────────────────────────

class CaroGame extends FlameGame with TapCallbacks {
  final bool vsAI;
  final int boardSize;
  final int winLength;

  late List<List<int>> board;
  int _currentPlayer = 1;
  GameStatus _status = GameStatus.playing;

  // Scores
  int xScore = 0;
  int oScore = 0;
  int draws = 0;

  // Move history for undo
  final List<MoveRecord> _moves = [];
  final Map<int, List<Point<int>>> _pieceOrder = <int, List<Point<int>>>{
    1: <Point<int>>[],
    2: <Point<int>>[],
  };

  // Winning cells
  List<Point<int>> winningCells = [];

  // Timer
  int _timeLeft = 0;
  async.Timer? _timer;
  DateTime? _gameStartTime;
  int _totalMoves = 0;
  final Random _aiRandom = Random();
  late final List<int> _zobristTable;
  final Map<int, _TranspositionEntry> _transposition = <int, _TranspositionEntry>{};
  static const int _ttMaxEntries = 60000;
  int _aiRequestId = 0;

  // Dùng để tránh gửi notify trùng trong cùng microtask
  bool _pendingNotify = false;

  // Notifier — Flutter UI lắng nghe state từ đây
  final ValueNotifier<GameState> gameStateNotifier = ValueNotifier(
    const GameState(
      currentPlayer: 1,
      status: GameStatus.playing,
      timeLeft: 0,
      canUndo: false,
    ),
  );

  late BoardComponent _boardComponent;

  CaroGame({required this.vsAI})
      : boardSize = AppSettings().boardSizePreset.side,
        winLength = AppSettings().boardSizePreset.winLength,
        _zobristTable = _buildZobristTable(
          AppSettings().boardSizePreset.side,
          seed: 1337,
        );

  int get turnTimeSecs => AppSettings().turnTimeSecs;

  @override
  Color backgroundColor() => const Color(0xFF0f0f1a);

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    _boardComponent = BoardComponent(game: this);
    world.add(_boardComponent);
    // _initBoard gọi SAU khi board component đã add vào world
    _initBoard();
  }

  // ─── Board init ────────────────────────────────────────────────────────────

  void _initBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    _currentPlayer = 1;
    _status = GameStatus.playing;
    winningCells = [];
    _moves.clear();
    _pieceOrder[1]!.clear();
    _pieceOrder[2]!.clear();
    _totalMoves = 0;
    _gameStartTime = DateTime.now();
    _transposition.clear();
    _startTimer();
    _notify();
  }

  bool get _usesSlidingCapRule => boardSize == 3 || boardSize == 4;
  static const int _maxPiecesOnSmallBoards = 4;

  // ─── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    if (turnTimeSecs == 0) {
      _timeLeft = 0;
      return;
    }
    _timeLeft = turnTimeSecs;
    _timer = async.Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status != GameStatus.playing) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      _timeLeft--;
      if (_timeLeft <= 0) {
        _handleTimeout();
      } else {
        _notify();
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    _timer = null;
    _status = GameStatus.timeout;
    AudioService().playTimeout();
    if (_currentPlayer == 1) {
      oScore++;
    } else {
      xScore++;
    }
    _saveHistory(GameResult.timeout);
    _notify();
  }

  // ─── Notify — LUÔN dùng scheduleMicrotask để tránh "setState during build" ─

  void _notify() {
    // Gộp nhiều lần gọi liên tiếp thành 1 lần update duy nhất
    if (_pendingNotify) return;
    _pendingNotify = true;

    async.scheduleMicrotask(() {
      _pendingNotify = false;
      gameStateNotifier.value = GameState(
        currentPlayer: _currentPlayer,
        status: _status,
        timeLeft: _timeLeft,
        canUndo: _canUndo,
      );
    });
  }

  // ─── Undo ──────────────────────────────────────────────────────────────────

  bool get _canUndo {
    if (_moves.isEmpty) return false;
    if (vsAI) return _moves.length >= 2;
    return _moves.isNotEmpty;
  }

  // ─── Reset ─────────────────────────────────────────────────────────────────

  void resetGame() {
    _timer?.cancel();
    _timer = null;
    _initBoard();
    _boardComponent.resetAnimations();
    // _notify() đã được gọi bên trong _initBoard()
  }

  // ─── Undo Move ─────────────────────────────────────────────────────────────

  void undoMove() {
    if (!_canUndo || _status != GameStatus.playing) return;

    if (vsAI) {
      for (int i = 0; i < 2 && _moves.isNotEmpty; i++) {
        final m = _moves.removeLast();
        board[m.row][m.col] = 0;
        _boardComponent.removePiece(m.row, m.col);
        _pieceOrder[m.player]!.removeLast();
        if (_usesSlidingCapRule && m.removedRow != null && m.removedCol != null) {
          final int rr = m.removedRow!;
          final int rc = m.removedCol!;
          board[rr][rc] = m.player;
          _boardComponent.addPiece(rr, rc, m.player);
          _pieceOrder[m.player]!.insert(0, Point(rr, rc));
        }
        _totalMoves--;
      }
      _currentPlayer = 1;
    } else {
      final m = _moves.removeLast();
      board[m.row][m.col] = 0;
      _boardComponent.removePiece(m.row, m.col);
      _totalMoves--;
      _pieceOrder[m.player]!.removeLast();
      if (_usesSlidingCapRule && m.removedRow != null && m.removedCol != null) {
        final int rr = m.removedRow!;
        final int rc = m.removedCol!;
        board[rr][rc] = m.player;
        _boardComponent.addPiece(rr, rc, m.player);
        _pieceOrder[m.player]!.insert(0, Point(rr, rc));
      }
      _currentPlayer = m.player;
    }

    AudioService().playUndo();
    _startTimer();
    _notify();
  }

  // ─── Tap handler ───────────────────────────────────────────────────────────

  void handleTap(int row, int col) {
    if (_status != GameStatus.playing) return;
    if (board[row][col] != 0) return;
    if (vsAI && _currentPlayer == 2) return;
    _placeMove(row, col);
  }

  // ─── Place move ────────────────────────────────────────────────────────────

  void _placeMove(int row, int col) {
    int? removedRow;
    int? removedCol;
    if (_usesSlidingCapRule) {
      final List<Point<int>> order = _pieceOrder[_currentPlayer]!;
      if (order.length >= _maxPiecesOnSmallBoards) {
        final Point<int> oldest = order.removeAt(0);
        removedRow = oldest.x;
        removedCol = oldest.y;
        board[removedRow][removedCol] = 0;
        _boardComponent.removePiece(removedRow, removedCol);
      }
    }
    board[row][col] = _currentPlayer;
    _moves.add(MoveRecord(
      row,
      col,
      _currentPlayer,
      removedRow: removedRow,
      removedCol: removedCol,
    ));
    _pieceOrder[_currentPlayer]!.add(Point(row, col));
    _totalMoves++;
    _boardComponent.addPiece(row, col, _currentPlayer);
    AudioService().playPlace();

    final wins = _checkWin(row, col, _currentPlayer);
    if (wins != null) {
      _timer?.cancel();
      _timer = null;
      winningCells = wins;
      _status = _currentPlayer == 1 ? GameStatus.xWins : GameStatus.oWins;
      if (_currentPlayer == 1) {
        xScore++;
      } else {
        oScore++;
      }
      _boardComponent.highlightWin(winningCells);
      AudioService().playWin();
      _saveHistory(_currentPlayer == 1 ? GameResult.xWins : GameResult.oWins);
      _notify();
      return;
    }

    if (_isBoardFull()) {
      _timer?.cancel();
      _timer = null;
      _status = GameStatus.draw;
      draws++;
      _saveHistory(GameResult.draw);
      _notify();
      return;
    }

    _currentPlayer = _currentPlayer == 1 ? 2 : 1;
    _startTimer();
    _notify();

    if (vsAI && _currentPlayer == 2) {
      // Keep a tiny delay for UX, but don't block timer perception.
      async.Future.delayed(const Duration(milliseconds: 80), _doAIMove);
    }
  }

  // ─── Save history ──────────────────────────────────────────────────────────

  Future<void> _saveHistory(GameResult result) async {
    final duration = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 0;
    await GameHistory().add(GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playedAt: DateTime.now(),
      mode: vsAI ? GameMode.vsAI : GameMode.twoPlayers,
      result: result,
      totalMoves: _totalMoves,
      durationSecs: duration,
      skinName: AppSettings().skin.name,
      boardSide: boardSize,
      winLength: winLength,
    ));
  }

  int get totalMoves => _totalMoves;

  int get gameDurationSecs => _gameStartTime != null
      ? DateTime.now().difference(_gameStartTime!).inSeconds
      : 0;

  // ─── AI ────────────────────────────────────────────────────────────────────

  static const int _aiWinTerminal = 1000000;
  static const int _aiLoseTerminal = -1000000;

  Future<void> _doAIMove() async {
    if (_status != GameStatus.playing) return;
    if (_currentPlayer != 2) return;
    _aiRequestId++;
    final int requestId = _aiRequestId;
    final List<List<int>> snapshot =
        board.map((List<int> row) => List<int>.from(row)).toList();
    final AiDifficulty diff = AppSettings().aiDifficulty;
    try {
      final AiMoveRequest req = AiMoveRequest(
        board: snapshot,
        boardSize: boardSize,
        winLength: winLength,
        difficultyIndex: diff.index,
        randomSeed: _aiRandom.nextInt(1 << 30),
        isSlidingCapRuleEnabled: _usesSlidingCapRule,
        maxPiecesPerPlayer: _maxPiecesOnSmallBoards,
        orderP1: _serializeOrder(_pieceOrder[1]!),
        orderP2: _serializeOrder(_pieceOrder[2]!),
      );
      final List<int>? res = await Isolate.run(() => AiEngine.pickMove(req));
      if (res == null) return;
      if (_status != GameStatus.playing) return;
      if (_currentPlayer != 2) return;
      if (requestId != _aiRequestId) return;
      final int r = res[0];
      final int c = res[1];
      if (r < 0 || r >= boardSize || c < 0 || c >= boardSize) return;
      if (board[r][c] != 0) return;
      _placeMove(r, c);
    } catch (_) {
      final (int, int)? move = _getAIMove();
      if (move != null) {
        _placeMove(move.$1, move.$2);
      }
    }
  }

  static List<int> _serializeOrder(List<Point<int>> points) {
    final List<int> out = <int>[];
    for (final Point<int> p in points) {
      out.add(p.x);
      out.add(p.y);
    }
    return out;
  }

  (int, int)? _getAIMove() {
    final List<(int, int)> candidates = _getCandidateMoves();
    if (candidates.isEmpty) {
      return null;
    }
    final AiDifficulty diff = AppSettings().aiDifficulty;
    final (int, int)? winAi = _findImmediateWinningMove(2);
    if (winAi != null) {
      return winAi;
    }
    final (int, int)? winHuman = _findImmediateWinningMove(1);
    if (winHuman != null) {
      if (diff != AiDifficulty.low || _aiRandom.nextDouble() < 0.55) {
        return winHuman;
      }
    }
    if (diff == AiDifficulty.low) {
      return candidates[_aiRandom.nextInt(candidates.length)];
    }
    if (diff == AiDifficulty.medium) {
      return _bestMoveOnePly(candidates);
    }
    return _bestMoveDeepSearch(candidates, maxPly: _maxAiSearchPly());
  }

  int _maxAiSearchPly() {
    final int cells = boardSize * boardSize;
    if (cells <= 9) {
      return 10;
    }
    if (cells <= 36) {
      return 6;
    }
    return 4;
  }

  (int, int)? _findImmediateWinningMove(int player) {
    for (final (int r, int c) in _getCandidateMoves()) {
      board[r][c] = player;
      final List<Point<int>>? w = _checkWin(r, c, player);
      board[r][c] = 0;
      if (w != null) {
        return (r, c);
      }
    }
    return null;
  }

  (int, int)? _bestMoveOnePly(List<(int, int)> candidates) {
    int bestScore = -999999999;
    (int, int)? bestMove;
    for (final (int r, int c) in candidates) {
      board[r][c] = 2;
      final int score = _evaluateBoard();
      board[r][c] = 0;
      if (score > bestScore) {
        bestScore = score;
        bestMove = (r, c);
      }
    }
    return bestMove;
  }

  (int, int)? _bestMoveDeepSearch(List<(int, int)> candidates, {required int maxPly}) {
    int bestScore = -999999999;
    (int, int)? bestMove;
    int hash = _computeBoardHash();
    final List<(int, int)> ordered = _orderMovesForAi(candidates);
    for (final (int r, int c) in ordered) {
      board[r][c] = 2;
      hash = _applyHash(hash, r, c, 2);
      final int score = -_negamax(
        depth: 0,
        maxDepth: maxPly,
        alpha: -999999999,
        beta: 999999999,
        playerToMove: 1,
        lastMoveRow: r,
        lastMoveCol: c,
        lastMovePlayer: 2,
        hash: hash,
      );
      hash = _applyHash(hash, r, c, 2);
      board[r][c] = 0;
      if (score > bestScore) {
        bestScore = score;
        bestMove = (r, c);
      }
    }
    return bestMove;
  }

  int _negamax({
    required int depth,
    required int maxDepth,
    required int alpha,
    required int beta,
    required int playerToMove,
    required int lastMoveRow,
    required int lastMoveCol,
    required int lastMovePlayer,
    required int hash,
  }) {
    if (_checkWin(lastMoveRow, lastMoveCol, lastMovePlayer) != null) {
      return lastMovePlayer == 2 ? _aiWinTerminal - depth : _aiLoseTerminal + depth;
    }
    if (depth >= maxDepth || _isBoardFull()) {
      return _evaluateBoard();
    }
    final _TranspositionEntry? cached = _transposition[hash];
    if (cached != null && cached.depth >= (maxDepth - depth)) {
      if (cached.flag == _TtFlag.exact) {
        return cached.score;
      }
      if (cached.flag == _TtFlag.lowerBound && cached.score > alpha) {
        alpha = cached.score;
      }
      if (cached.flag == _TtFlag.upperBound && cached.score < beta) {
        beta = cached.score;
      }
      if (alpha >= beta) {
        return cached.score;
      }
    }
    final int alphaOrig = alpha;
    final List<(int, int)> moves = _topCandidateMovesForPlayer(
      playerToMove,
      limit: 14,
    );
    if (moves.isEmpty) {
      return _evaluateBoard();
    }
    final List<(int, int)> ordered =
        playerToMove == 2 ? _orderMovesForAi(moves) : _orderMovesForHuman(moves);
    int best = -999999999;
    int localHash = hash;
    for (final (int r, int c) in ordered) {
      board[r][c] = playerToMove;
      localHash = _applyHash(localHash, r, c, playerToMove);
      final int score = -_negamax(
        depth: depth + 1,
        maxDepth: maxDepth,
        alpha: -beta,
        beta: -alpha,
        playerToMove: playerToMove == 2 ? 1 : 2,
        lastMoveRow: r,
        lastMoveCol: c,
        lastMovePlayer: playerToMove,
        hash: localHash,
      );
      localHash = _applyHash(localHash, r, c, playerToMove);
      board[r][c] = 0;
      if (score > best) {
        best = score;
      }
      if (best > alpha) {
        alpha = best;
      }
      if (alpha >= beta) {
        break;
      }
    }
    if (_transposition.length > _ttMaxEntries) {
      _transposition.clear();
    }
    final _TtFlag flag;
    if (best <= alphaOrig) {
      flag = _TtFlag.upperBound;
    } else if (best >= beta) {
      flag = _TtFlag.lowerBound;
    } else {
      flag = _TtFlag.exact;
    }
    _transposition[hash] = _TranspositionEntry(
      depth: maxDepth - depth,
      score: best,
      flag: flag,
    );
    return best;
  }

  List<(int, int)> _orderMovesForAi(List<(int, int)> moves) {
    final List<({int score, (int, int) m})> scored = <({int score, (int, int) m})>[];
    for (final (int r, int c) in moves) {
      scored.add((score: _scoreMoveHeuristic(r, c, 2), m: (r, c)));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.m).toList();
  }

  List<(int, int)> _orderMovesForHuman(List<(int, int)> moves) {
    final List<({int score, (int, int) m})> scored = <({int score, (int, int) m})>[];
    for (final (int r, int c) in moves) {
      scored.add((score: _scoreMoveHeuristic(r, c, 1), m: (r, c)));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.m).toList();
  }

  int _scoreMoveHeuristic(int r, int c, int player) {
    int score = 0;
    const dirs = [(0, 1), (1, 0), (1, 1), (1, -1)];
    board[r][c] = player;
    for (final d in dirs) {
      score += _evaluateLine(r, c, d.$1, d.$2, player);
    }
    board[r][c] = 0;
    return score;
  }

  static List<int> _buildZobristTable(int side, {required int seed}) {
    final Random rnd = Random(seed);
    final int cells = side * side;
    final List<int> t = List<int>.filled(cells * 2, 0);
    for (int i = 0; i < t.length; i++) {
      final int hi = rnd.nextInt(1 << 30);
      final int lo = rnd.nextInt(1 << 30);
      t[i] = (hi << 32) ^ lo;
    }
    return t;
  }

  int _zIndex(int row, int col, int player) {
    final int cell = row * boardSize + col;
    return cell * 2 + (player - 1);
  }

  int _applyHash(int hash, int row, int col, int player) {
    return hash ^ _zobristTable[_zIndex(row, col, player)];
  }

  int _computeBoardHash() {
    int h = 0;
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        final int p = board[r][c];
        if (p == 0) continue;
        h = _applyHash(h, r, c, p);
      }
    }
    return h;
  }

  List<(int, int)> _topCandidateMovesForPlayer(int forPlayer, {required int limit}) {
    final List<(int, int)> raw = _getCandidateMoves();
    if (raw.length <= limit) {
      return raw;
    }
    final List<({int score, (int, int) m})> scored = [];
    for (final (int r, int c) in raw) {
      board[r][c] = forPlayer;
      final int s = _evaluateBoard();
      board[r][c] = 0;
      scored.add((score: s, m: (r, c)));
    }
    if (forPlayer == 2) {
      scored.sort((a, b) => b.score.compareTo(a.score));
    } else {
      scored.sort((a, b) => a.score.compareTo(b.score));
    }
    return scored.take(limit).map((e) => e.m).toList();
  }

  int _evaluateBoard() {
    int score = 0;
    const dirs = [(0, 1), (1, 0), (1, 1), (1, -1)];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == 0) continue;
        final p = board[r][c];
        for (final d in dirs) {
          final s = _evaluateLine(r, c, d.$1, d.$2, p);
          score += p == 2 ? s : -s;
        }
      }
    }
    return score;
  }

  int _evaluateLine(int r, int c, int dr, int dc, int p) {
    int count = 0;
    int openEnds = 0;
    int nr = r - dr;
    int nc = c - dc;
    if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize && board[nr][nc] == 0) {
      openEnds++;
    }
    for (int i = 0; i < winLength; i++) {
      nr = r + dr * i;
      nc = c + dc * i;
      if (nr < 0 || nr >= boardSize || nc < 0 || nc >= boardSize) {
        break;
      }
      if (board[nr][nc] == p) {
        count++;
      } else {
        break;
      }
    }
    nr = r + dr * count;
    nc = c + dc * count;
    if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize && board[nr][nc] == 0) {
      openEnds++;
    }
    if (count == 0) {
      return 0;
    }
    final int w = winLength;
    if (count >= w) {
      return 10000;
    }
    if (count == w - 1) {
      if (openEnds == 2) {
        return 1000;
      }
      if (openEnds == 1) {
        return 100;
      }
    }
    if (w >= 4 && count == w - 2) {
      if (openEnds == 2) {
        return 100;
      }
      if (openEnds == 1) {
        return 10;
      }
    }
    if (w >= 5 && count == w - 3 && openEnds == 2) {
      return 10;
    }
    if (count >= 2 && openEnds == 2) {
      return 10;
    }
    if (count >= 2 && openEnds == 1) {
      return 5;
    }
    return count;
  }

  List<(int, int)> _getCandidateMoves() {
    final Set<(int, int)> result = {};
    bool hasAny = false;
    for (int r = 0; r < boardSize; r++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[r][col] != 0) {
          hasAny = true;
          for (int dr = -2; dr <= 2; dr++) {
            for (int dc = -2; dc <= 2; dc++) {
              final nr = r + dr, nc = col + dc;
              if (nr >= 0 &&
                  nr < boardSize &&
                  nc >= 0 &&
                  nc < boardSize &&
                  board[nr][nc] == 0) {
                result.add((nr, nc));
              }
            }
          }
        }
      }
    }
    if (!hasAny) return [(boardSize ~/ 2, boardSize ~/ 2)];
    return result.toList();
  }

  bool _isBoardFull() {
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == 0) return false;
      }
    }
    return true;
  }

  List<Point<int>>? _checkWin(int row, int col, int player) {
    const dirs = [(0, 1), (1, 0), (1, 1), (1, -1)];
    for (final dir in dirs) {
      final cells = <Point<int>>[Point(row, col)];
      for (int i = 1; i < winLength; i++) {
        final nr = row + dir.$1 * i, nc = col + dir.$2 * i;
        if (nr < 0 || nr >= boardSize || nc < 0 || nc >= boardSize) break;
        if (board[nr][nc] == player) {
          cells.add(Point(nr, nc));
        } else {
          break;
        }
      }
      for (int i = 1; i < winLength; i++) {
        final nr = row - dir.$1 * i, nc = col - dir.$2 * i;
        if (nr < 0 || nr >= boardSize || nc < 0 || nc >= boardSize) break;
        if (board[nr][nc] == player) {
          cells.add(Point(nr, nc));
        } else {
          break;
        }
      }
      if (cells.length >= winLength) return cells;
    }
    return null;
  }
}

enum _TtFlag { exact, lowerBound, upperBound }

class _TranspositionEntry {
  final int depth;
  final int score;
  final _TtFlag flag;

  const _TranspositionEntry({
    required this.depth,
    required this.score,
    required this.flag,
  });
}
