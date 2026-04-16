import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:co_caro_flame/s88/core/error/failures.dart';
import 'package:co_caro_flame/s88/core/misc/semaphore.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/websocket/sb_websocket.dart';
import 'package:co_caro_flame/s88/core/services/websocket/websocket_messages.dart';
import 'package:co_caro_flame/s88/features/home/data/datasources/hot_match_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/bet_statistics_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/entities/hot_match_entity.dart';
import 'package:co_caro_flame/s88/features/home/domain/repositories/hot_match_repository.dart';

/// Statistics result for a match
class _MatchStatisticsResult {
  final String? bettingTrend;
  final int? totalUsers;

  const _MatchStatisticsResult({this.bettingTrend, this.totalUsers});
}

/// Hot Match Repository Implementation
///
/// Implements [HotMatchRepository] interface from domain layer.
/// Handles data transformation and error handling.
class HotMatchRepositoryImpl implements HotMatchRepository {
  final HotMatchRemoteDataSource _remoteDataSource;
  final SbWebSocket _websocket;

  /// Stream controllers for WebSocket events
  final _oddsController = StreamController<OddsUpdateEvent>.broadcast();
  final _scoreController = StreamController<ScoreUpdateEvent>.broadcast();

  /// WebSocket subscriptions
  StreamSubscription<OddsUpdateData>? _oddsSubscription;
  StreamSubscription<ScoreUpdateData>? _scoreSubscription;

  HotMatchRepositoryImpl(this._remoteDataSource, this._websocket) {
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    _oddsSubscription = _websocket.oddsStream.listen((data) {
      final marketId = int.tryParse(data.marketId);
      final odds = double.tryParse(data.odds);
      if (marketId != null && odds != null) {
        _oddsController.add(
          OddsUpdateEvent(
            eventId: data.eventId,
            marketId: marketId,
            selectionId: data.selectionId,
            newOdds: odds,
          ),
        );
      }
    });

    _scoreSubscription = _websocket.scoreStream.listen((data) {
      _scoreController.add(
        ScoreUpdateEvent(
          eventId: data.eventId,
          homeScore: data.home,
          awayScore: data.away,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, List<LeagueModelV2>>> getHotMatches() async {
    try {
      final leagues = await _remoteDataSource.getHotMatches();
      if (kDebugMode) {
        final totalEvents = leagues.fold<int>(
          0,
          (sum, l) => sum + l.events.length,
        );
        debugPrint(
          '[HotMatch] API returned ${leagues.length} leagues, $totalEvents events',
        );
      }
      return Right(leagues);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Map<int, HotMatchEventStatistics>> getBetStatisticsForEvents(
    List<HotMatchEventV2> matches,
    int sportId,
  ) async {
    if (matches.isEmpty) return {};
    try {
      final enriched = await _enrichHotMatchesWithStatistics(matches, sportId);
      final result = <int, HotMatchEventStatistics>{};
      for (final m in enriched) {
        result[m.eventId] = HotMatchEventStatistics(
          bettingTrend: m.bettingTrend,
          totalUsers: m.totalUsers,
        );
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  // ─── STREAM-BASED APPROACH (tối ưu) ───────────────────────────────────────
  /// Gọi cả hai API (/simple + /users) song song cho **mọi** match đồng thời,
  /// giới hạn tối đa [maxConcurrent] match xử lý cùng lúc bằng [Semaphore].
  ///
  /// Emit [MapEntry<eventId, HotMatchEventStatistics>] **ngay khi** từng match
  /// hoàn thành — không phải chờ cả batch — giúp UI cập nhật progressively.
  @override
  Stream<MapEntry<int, HotMatchEventStatistics>> streamBetStatistics(
    List<HotMatchEventV2> matches,
    int sportId, {
    int maxConcurrent = 10,
  }) {
    final controller =
        StreamController<MapEntry<int, HotMatchEventStatistics>>();

    _runStreamedStatistics(matches, sportId, maxConcurrent, controller);

    return controller.stream;
  }

  Future<void> _runStreamedStatistics(
    List<HotMatchEventV2> matches,
    int sportId,
    int maxConcurrent,
    StreamController<MapEntry<int, HotMatchEventStatistics>> controller,
  ) async {
    if (matches.isEmpty) {
      await controller.close();
      return;
    }

    final semaphore = Semaphore(maxConcurrent);

    try {
      // Tất cả match được schedule ngay lập tức; semaphore kiểm soát concurrency.
      await Future.wait(
        matches.map((match) async {
          await semaphore.acquire();
          try {
            final stats = await _callStatisticsApis(match, sportId);
            if (!controller.isClosed) {
              controller.add(
                MapEntry(
                  match.eventId,
                  HotMatchEventStatistics(
                    bettingTrend: stats.bettingTrend,
                    totalUsers: stats.totalUsers,
                  ),
                ),
              );
            }
          } catch (_) {
            // Bỏ qua lỗi từng event; không ảnh hưởng các event còn lại.
          } finally {
            semaphore.release();
          }
        }),
        eagerError: false, // Một future lỗi không hủy các future còn lại.
      );
    } finally {
      if (!controller.isClosed) await controller.close();
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

  Future<List<HotMatchEventV2>> _enrichHotMatchesWithStatistics(
    List<HotMatchEventV2> matches,
    int sportId,
  ) async {
    const concurrencyLimit = 5;
    final enriched = <HotMatchEventV2>[];
    for (var i = 0; i < matches.length; i += concurrencyLimit) {
      final batch = matches.skip(i).take(concurrencyLimit).toList();
      final futures = batch.map((m) async {
        final stats = await _callStatisticsApis(m, sportId);
        return m.copyWith(
          bettingTrend: stats.bettingTrend,
          totalUsers: stats.totalUsers,
        );
      }).toList();
      enriched.addAll(await Future.wait(futures));
    }
    return enriched;
  }

  Future<_MatchStatisticsResult> _callStatisticsApis(
    HotMatchEventV2 match,
    int sportId,
  ) async {
    try {
      final eventId = match.eventId;
      final leagueId = match.leagueId;
      final agentId = SbConfig.agentId;
      final httpManager = SbHttpManager.instance;

      // Call both APIs in parallel for better performance
      final futures = <Future<dynamic>>[];

      // API 1: /api/v2/bet/statistics/simple
      final urlBettingStatisticsSimple =
          '${SbHttpManager.instance.urlHomeExposeService}/api/v1/bet/statistics/simple'
          '?agentId=$agentId'
          '&eventId=$eventId';
      futures.add(
        httpManager
            .send(urlBettingStatisticsSimple, json: true, headerToken: true)
            .catchError((Object e) => null),
      );

      // API 2: /api/v2/bet/statistics/user-details
      final urlUserDetailsReponse =
          '${SbHttpManager.instance.urlHomeExposeService}/api/v1/bet/statistics/users'
          '?agentId=$agentId'
          '&leagueId=$leagueId'
          '&eventId=$eventId'
          '&marketId=0'
          '&filter=latest';
      futures.add(
        httpManager
            .send(urlUserDetailsReponse, json: true, headerToken: true)
            .catchError((Object e) => null),
      );

      // Wait for both APIs to complete
      final results = await Future.wait(futures);
      final response1 = results[0];
      final response2 = results[1];

      String? bettingTrend;
      if (response1 is Map<String, dynamic>) {
        try {
          final statisticsSimple = BetStatisticsSimple.fromJson(response1);
          bettingTrend = _extractBettingTrendV2(
            statisticsSimple,
            match,
            sportId,
          );
        } catch (e) {
          // Silently fail and continue
        }
      }

      // Extract total users from BetStatisticsUserDetails
      int? totalUsers;
      if (response2 is Map<String, dynamic>) {
        try {
          final statisticsUserDetails = BetStatisticsUserDetails.fromJson(
            response2,
          );
          totalUsers = statisticsUserDetails.totalCount;
        } catch (e) {
          // Silently fail and continue
        }
      }

      return _MatchStatisticsResult(
        bettingTrend: bettingTrend,
        totalUsers: totalUsers,
      );
    } catch (e) {
      return const _MatchStatisticsResult();
    }
  }

  String? _extractBettingTrendV2(
    BetStatisticsSimple statistics,
    HotMatchEventV2 match,
    int sportId,
  ) {
    try {
      final marketStatistics = statistics.marketStatistics;
      if (marketStatistics == null || marketStatistics.isEmpty) {
        return null;
      }

      // Trả về % cược vào đội có 3 case (theo thứ tự ưu tiên):
      // - "5": Handicap — dựa vào main line odd trong HotMatchEventV2 (getHandicapMarket), khớp points → tên đội + %.
      // - "1": 1X2 — dựa vào Home hay Away trong statistics → tên đội + %.
      // - "3": Over/Under — dựa vào main line (getOverUnderMarket), khớp Over hay Under → "Over XX%" hoặc "Under XX%".
      final trendFromHandicap = _extractBettingTrendFromMarket5(
        marketStatistics,
        match,
        sportId,
      );
      if (trendFromHandicap != null) return trendFromHandicap;

      // Fallback: market "1" (1X2) - pick selection with highest percentage
      final trendFrom1X2 = _extractBettingTrendFromMarket1(
        marketStatistics,
        match,
      );
      if (trendFrom1X2 != null) return trendFrom1X2;

      // Fallback: market "3" (Over/Under) - dùng main line từ getOverUnderMarket để khớp statistics, trả về Over/Under + %
      // final trendFromOverUnder = _extractBettingTrendFromMarket3(
      //   marketStatistics,
      //   match,
      //   sportId,
      // );
      // if (trendFromOverUnder != null) return trendFromOverUnder;

      return null;
    } catch (e) {
      return null;
    }
  }

  String? _extractBettingTrendFromMarket1(
    Map<String, List<BetStatisticsSelection>> marketStatistics,
    HotMatchEventV2 match,
  ) {
    final selections = marketStatistics['1'];
    if (selections == null || selections.isEmpty) return null;

    BetStatisticsSelection? maxPercentageSelection;
    double maxPercentage = 0;
    for (final selection in selections) {
      final percentage = selection.percentage ?? 0;
      if (percentage > maxPercentage) {
        maxPercentage = percentage;
        maxPercentageSelection = selection;
      }
    }

    if (maxPercentageSelection == null || maxPercentage <= 0) return null;

    final selectionName = maxPercentageSelection.selectionName?.trim() ?? '';
    String favoredTeamName;
    if (selectionName.toLowerCase() == 'away') {
      favoredTeamName = match.awayName;
    } else if (selectionName.toLowerCase() == 'home') {
      favoredTeamName = match.homeName;
    } else {
      favoredTeamName = selectionName.isNotEmpty ? selectionName : '';
    }
    return '$favoredTeamName ${maxPercentage.toStringAsFixed(2)}%';
  }

  /// Market "3" (Over/Under): không hiển thị betting trend cho Over/Under.
  /// Luôn return null để hot match không show "Over XX%" hay "Under XX%".
  String? _extractBettingTrendFromMarket3(
    Map<String, List<BetStatisticsSelection>> marketStatistics,
    HotMatchEventV2 match,
    int sportId,
  ) {
    return null;
  }

  /// Lấy betting trend từ market "5" (handicap) theo main line của trận.
  /// Dựa vào points (key "2") trong response: chọn selection có points trùng hoặc gần nhất với main line
  /// (home = âm, away = dương), rồi trả về đội có % cao hơn trong hai bên.
  /// Main line 0.0: chọn selection có points gần 0 (vd. 0.0, -0.25, 0.25) rồi lấy đội có % cao nhất.
  String? _extractBettingTrendFromMarket5(
    Map<String, List<BetStatisticsSelection>> marketStatistics,
    HotMatchEventV2 match,
    int sportId,
  ) {
    final selections5 = marketStatistics['5'];
    if (selections5 == null || selections5.isEmpty) return null;

    final mainLinePointsStr = match
        .getHandicapMarket(sportId)
        ?.mainLineOdds
        ?.points;
    if (mainLinePointsStr == null || mainLinePointsStr.isEmpty) return null;

    final mainLineValue = double.tryParse(mainLinePointsStr) ?? 0;

    // Main line 0.0: lấy các selection có points trong [-0.5, 0.5] (line draw), chọn đội có % cao nhất
    if (mainLineValue == 0) {
      const tolerance = 0.5;
      BetStatisticsSelection? best;
      for (final s in selections5) {
        final pts = double.tryParse(s.points ?? '') ?? 0;
        if (pts.abs() <= tolerance &&
            (s.percentage ?? 0) > (best?.percentage ?? 0)) {
          best = s;
        }
      }
      if (best == null || (best.percentage ?? 0) <= 0) return null;
      final name = best.selectionName?.trim() ?? '';
      if (name.isEmpty) return null;
      return '$name ${(best.percentage ?? 0).toStringAsFixed(2)}%';
    }

    // Hai phía main line: home = -mainLineValue (e.g. -1), away = +mainLineValue (e.g. 1)
    final homeTarget = -mainLineValue;
    final awayTarget = mainLineValue;

    BetStatisticsSelection? homeSelection;
    BetStatisticsSelection? awaySelection;
    double homeDiff = double.infinity;
    double awayDiff = double.infinity;

    for (final s in selections5) {
      final pts = double.tryParse(s.points ?? '') ?? 0;
      if (pts <= 0) {
        final d = (pts - homeTarget).abs();
        if (d < homeDiff) {
          homeDiff = d;
          homeSelection = s;
        }
      } else {
        final d = (pts - awayTarget).abs();
        if (d < awayDiff) {
          awayDiff = d;
          awaySelection = s;
        }
      }
    }

    // Chọn đội có % cao hơn trong hai bên (tên đội nằm ở key "3" trong API)
    final homePct = homeSelection?.percentage ?? 0;
    final awayPct = awaySelection?.percentage ?? 0;
    final chosen = homePct >= awayPct ? homeSelection : awaySelection;
    if (chosen == null || (chosen.percentage ?? 0) <= 0) return null;

    final name = chosen.selectionName?.trim() ?? '';
    if (name.isEmpty) return null;
    return '$name ${(chosen.percentage ?? 0).toStringAsFixed(2)}%';
  }

  /// Derive "TeamName XX%" from first market's top selection.
  String? _bettingTrendFromSimple(BetStatisticsSimple stat) {
    final markets = stat.marketStatistics;
    if (markets == null || markets.isEmpty) return null;
    final firstMarketSelections = markets.values.first;
    if (firstMarketSelections.isEmpty) return null;
    BetStatisticsSelection? top;
    for (final s in firstMarketSelections) {
      if (top == null || (s.percentage ?? 0) > (top.percentage ?? 0)) {
        top = s;
      }
    }
    if (top == null || top.percentage == null) return null;
    final name = top.selectionName ?? '—';
    final pct = (top.percentage! * 100).toStringAsFixed(1);
    return '$name $pct%';
  }

  @override
  void subscribeToEvents(List<int> eventIds) {
    for (final eventId in eventIds) {
      _websocket.subscribeEvent(eventId);
    }
  }

  @override
  void unsubscribeFromEvents(List<int> eventIds) {
    for (final eventId in eventIds) {
      _websocket.unsubscribeEvent(eventId);
    }
  }

  @override
  Stream<OddsUpdateEvent> get oddsUpdates => _oddsController.stream;

  @override
  Stream<ScoreUpdateEvent> get scoreUpdates => _scoreController.stream;

  /// Dispose resources
  void dispose() {
    _oddsSubscription?.cancel();
    _scoreSubscription?.cancel();
    _oddsController.close();
    _scoreController.close();
  }
}
