import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/live_match_period_resolver.dart';
import 'package:co_caro_flame/s88/core/services/providers/event_live_provider.dart';
import 'package:co_caro_flame/s88/core/services/providers/market_status_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/sport/match/score/basketball_countdown_timer.dart';

/// Consumer widget for displaying live score
///
/// Only rebuilds when the score for this specific event changes.
/// Falls back to initial values if no WebSocket update received yet.
///
/// Usage:
/// ```dart
/// LiveScoreConsumer(
///   eventId: event.eventId,
///   initialHome: event.homeScore,
///   initialAway: event.awayScore,
///   builder: (context, homeScore, awayScore) => Text('$homeScore - $awayScore'),
/// )
/// ```
class LiveScoreConsumer extends StatelessWidget {
  final int eventId;
  final int initialHome;
  final int initialAway;
  final Widget Function(BuildContext context, int homeScore, int awayScore)
  builder;

  const LiveScoreConsumer({
    super.key,
    required this.eventId,
    this.initialHome = 0,
    this.initialAway = 0,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Use Consumer for localized rebuild scope
    return Consumer(
      builder: (context, ref, _) {
        // Use select to only rebuild when this specific score changes
        final score = ref.watch(
          eventLiveProvider.select((state) => state.getScore(eventId)),
        );

        final homeScore = score?.$1 ?? initialHome;
        final awayScore = score?.$2 ?? initialAway;

        return builder(context, homeScore, awayScore);
      },
    );
  }
}

/// Consumer widget for displaying a single score value
///
/// Useful when you need to display home and away scores separately.
/// Uses select to only rebuild when the specific score (home or away) changes.
class LiveSingleScoreConsumer extends StatelessWidget {
  final int eventId;
  final bool isHome;
  final int initialValue;
  final Widget Function(BuildContext context, int score) builder;

  const LiveSingleScoreConsumer({
    super.key,
    required this.eventId,
    required this.isHome,
    this.initialValue = 0,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Select only the specific score value to minimize rebuilds
        final value = ref.watch(
          eventLiveProvider.select((state) {
            final score = state.getScore(eventId);
            return isHome
                ? (score?.$1 ?? initialValue)
                : (score?.$2 ?? initialValue);
          }),
        );
        return builder(context, value);
      },
    );
  }
}

/// Consumer widget for displaying live game time/status
///
/// Only rebuilds when the game time for this specific event changes.
///
/// Usage:
/// ```dart
/// LiveStatusConsumer(
///   eventId: event.eventId,
///   initialStatus: event.liveStatusDisplay,
///   builder: (context, status) => Text(status ?? ''),
/// )
/// ```
class LiveStatusConsumer extends StatelessWidget {
  final int eventId;
  final String? initialStatus;
  final Widget Function(BuildContext context, String? status) builder;

  const LiveStatusConsumer({
    super.key,
    required this.eventId,
    this.initialStatus,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final status = ref.watch(
          eventLiveProvider.select((state) => state.getLiveStatus(eventId)),
        );
        return builder(context, status ?? initialStatus);
      },
    );
  }
}

/// Consumer widget that checks if a market is suspended
///
/// Only rebuilds when the suspended status for this specific market changes.
///
/// Usage:
/// ```dart
/// MarketSuspendedConsumer(
///   eventId: event.eventId,
///   marketId: market.marketId,
///   builder: (context, isSuspended) => Opacity(
///     opacity: isSuspended ? 0.5 : 1.0,
///     child: OddsButton(...),
///   ),
/// )
/// ```
class MarketSuspendedConsumer extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget Function(BuildContext context, bool isSuspended) builder;

  const MarketSuspendedConsumer({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );
        return builder(context, isSuspended);
      },
    );
  }
}

/// Consumer widget that checks if a market is available for betting
///
/// Market is available when: not suspended AND active
class MarketAvailableConsumer extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget Function(BuildContext context, bool isAvailable) builder;

  const MarketAvailableConsumer({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isAvailable = ref.watch(
          isMarketAvailableProvider((eventId, marketId)),
        );
        return builder(context, isAvailable);
      },
    );
  }
}

/// Consumer widget that checks if an entire event is suspended
class EventSuspendedConsumer extends StatelessWidget {
  final int eventId;
  final Widget Function(BuildContext context, bool isSuspended) builder;

  const EventSuspendedConsumer({
    super.key,
    required this.eventId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(isEventSuspendedProvider(eventId));
        return builder(context, isSuspended);
      },
    );
  }
}

// ===== READY-TO-USE WIDGETS =====

/// Pre-styled score display widget
///
/// Shows "homeScore - awayScore" with consistent styling.
/// Automatically updates when score changes via WebSocket.
class LiveScoreDisplay extends StatelessWidget {
  final int eventId;
  final int initialHome;
  final int initialAway;
  final TextStyle? style;
  final Color? color;

  const LiveScoreDisplay({
    super.key,
    required this.eventId,
    this.initialHome = 0,
    this.initialAway = 0,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final score = ref.watch(
          eventLiveProvider.select((state) => state.getScore(eventId)),
        );
        final homeScore = score?.$1 ?? initialHome;
        final awayScore = score?.$2 ?? initialAway;

        return Text(
          '$homeScore - $awayScore',
          style:
              style ??
              AppTextStyles.textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFFFFFEF5),
              ),
        );
      },
    );
  }
}

/// Single score value display (home or away)
/// Uses select to only rebuild when the specific score changes.
class LiveSingleScoreDisplay extends StatelessWidget {
  final int eventId;
  final bool isHome;
  final int initialValue;
  final TextStyle? style;

  const LiveSingleScoreDisplay({
    super.key,
    required this.eventId,
    required this.isHome,
    this.initialValue = 0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Select only the specific score (home or away) to minimize rebuilds
        final value = ref.watch(
          eventLiveProvider.select((state) {
            final score = state.getScore(eventId);
            return isHome
                ? (score?.$1 ?? initialValue)
                : (score?.$2 ?? initialValue);
          }),
        );

        return Text(
          '$value',
          style:
              style ??
              AppTextStyles.textStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFFFFEF5),
              ),
        );
      },
    );
  }
}

/// Game status badge (e.g., "1H 45'", "HT", "2H 60'")
class LiveStatusBadge extends StatelessWidget {
  final int eventId;
  final String? initialStatus;
  final TextStyle? style;

  const LiveStatusBadge({
    super.key,
    required this.eventId,
    this.initialStatus,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final status = ref.watch(
          eventLiveProvider.select((state) => state.getLiveStatus(eventId)),
        );
        final displayStatus = status ?? initialStatus ?? '';

        if (displayStatus.isEmpty) return const SizedBox.shrink();

        return Text(
          displayStatus,
          style:
              style ??
              AppTextStyles.textStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFFFFEF5),
              ),
        );
      },
    );
  }
}

/// Live match time display with minute and period
/// Format: "45'" for minute, "Hiệp 1" for period
/// Uses select to only rebuild when gameTime or gamePart changes.
class LiveMatchTimeDisplay extends StatelessWidget {
  final int eventId;
  final String? initialMinute;
  final String? initialPeriod;
  final TextStyle? style;
  final Widget? separator;

  /// Sport ID for sport-specific time formatting.
  /// 0 or 1 = soccer (default), 2 = basketball (countdown), etc.
  final int sportId;

  /// Current set/game number from score model (volleyball field 506, badminton field 706).
  /// gamePart is a status code for these sports, so we pass currentSet from parent.
  final int? initialCurrentSet;

  /// Set/game wins for set-based sports — displayed as "2-1" after period.
  /// Used by volleyball ("Set 3 | 2-1") and badminton ("Game 2 | 1-0").
  final (int, int)? initialSetScore;

  const LiveMatchTimeDisplay({
    super.key,
    required this.eventId,
    this.initialMinute,
    this.initialPeriod,
    this.style,
    this.separator,
    this.sportId = 0,
    this.initialCurrentSet,
    this.initialSetScore,
  });

  @override
  Widget build(BuildContext context) {
    // Basketball uses countdown timer — delegate to dedicated path
    if (sportId == 2) return _buildBasketball(context);

    // Tennis: gamePart = set number, tie-break, break, etc.
    if (sportId == 4) return _buildTennis(context);

    // Volleyball: gamePart is status code → use currentSet from score for "Set N"
    if (sportId == 5) return _buildVolleyball(context);

    // Table Tennis: gamePart = set number
    if (sportId == 6) return _buildTableTennis(context);

    // Badminton: display based on currentSet from score model
    if (sportId == 7) return _buildBadminton(context);

    return _buildDefault(context);
  }

  /// Basketball: countdown timer + quarter period (Q1, Q2, HT, etc.)
  Widget _buildBasketball(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final (gameTimeMs, gamePart) = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return (data?.gameTimeMs ?? 0, data?.gamePart ?? 0);
          }),
        );

        final resolved = LiveMatchPeriodResolver.resolve(
          sportId: 2,
          gamePart: gamePart,
        );
        final period =
            resolved.isNotEmpty ? resolved : _formatRawPeriod(initialPeriod);

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (period != null) ...[
              Flexible(
                child: Text(
                  period,
                  style: defaultStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              separator ??
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                  ),
            ],
            BasketballCountdownTimer(
              eventId: eventId,
              initialTimeMs: gameTimeMs,
              style: defaultStyle,
            ),
          ],
        );
      },
    );
  }

  /// Tennis: gamePart → "Set N", "Tie-break", "Nghỉ", "Hết trận", etc.
  Widget _buildTennis(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gamePart = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return data?.gamePart ?? 0;
          }),
        );

        final resolved = LiveMatchPeriodResolver.resolve(
          sportId: 4,
          gamePart: gamePart,
        );
        final period =
            resolved.isNotEmpty ? resolved : _formatRawPeriod(initialPeriod);

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return _buildPeriodScoreRow(
          period: period,
          scoreText: null,
          style: defaultStyle,
        );
      },
    );
  }

  /// Volleyball: watch gamePart for special cases (golden set, full time),
  /// use initialCurrentSet from parent for "Set N" display.
  Widget _buildVolleyball(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gamePart = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return data?.gamePart ?? 0;
          }),
        );

        final resolved = LiveMatchPeriodResolver.resolve(
          sportId: 5,
          gamePart: gamePart,
          currentSet: initialCurrentSet,
        );

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return _buildPeriodScoreRow(
          period: resolved.isNotEmpty ? resolved : null,
          scoreText: null,
          style: defaultStyle,
        );
      },
    );
  }

  /// Badminton: display based on currentSet from score model (field 706).
  Widget _buildBadminton(BuildContext context) {
    final resolved = LiveMatchPeriodResolver.resolve(
      sportId: 7,
      gamePart: 0,
      currentSet: initialCurrentSet,
    );

    final defaultStyle =
        style ??
        AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFFFFEF5),
        );

    return _buildPeriodScoreRow(
      period: resolved.isNotEmpty ? resolved : null,
      scoreText: null,
      style: defaultStyle,
    );
  }

  /// Table Tennis: gamePart → "Set N", "Hết trận", etc.
  Widget _buildTableTennis(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final gamePart = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return data?.gamePart ?? 0;
          }),
        );

        final resolved = LiveMatchPeriodResolver.resolve(
          sportId: 6,
          gamePart: gamePart,
        );
        final period =
            resolved.isNotEmpty ? resolved : _formatRawPeriod(initialPeriod);

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return _buildPeriodScoreRow(
          period: period,
          scoreText: null,
          style: defaultStyle,
        );
      },
    );
  }

  /// Shared layout: "Period" | "Score" with vertical line separator
  Widget _buildPeriodScoreRow({
    String? period,
    String? scoreText,
    required TextStyle style,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (period != null) Text(period, style: style),
        if (period != null && scoreText != null)
          separator ??
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 1,
                  height: 10,
                  color: const Color(0xFF74736F),
                ),
              ),
        if (scoreText != null)
          Flexible(
            child: Text(
              scoreText,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  /// Default (soccer and other sports): count-up minute + period
  Widget _buildDefault(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Select only gameTime and gamePart to minimize rebuilds
        final (gameTime, gamePart) = ref.watch(
          eventLiveProvider.select((state) {
            final data = state.getEvent(eventId);
            return (data?.gameTime ?? 0, data?.gamePart ?? 0);
          }),
        );

        // Format minute (gameTime is already in minutes from EventLiveProvider)
        String? minute;
        if (gameTime > 0) {
          minute = "$gameTime'";
        } else {
          minute = _isValidMinuteString(initialMinute) ? initialMinute : null;
        }

        // Format period (pass gameTime for inference when gamePart is unknown)
        String? period;
        if (gamePart > 0) {
          period = _formatPeriod(gamePart, gameTime);
        } else {
          // Format raw initialPeriod from API (e.g., "Running", "1H", "2H")
          period = _formatRawPeriod(initialPeriod);
        }

        final defaultStyle =
            style ??
            AppTextStyles.textStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFFFFEF5),
            );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (minute != null) Text(minute, style: defaultStyle),
            if (minute != null && period != null) ...[
              separator ??
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 1,
                      height: 10,
                      color: const Color(0xFF74736F),
                    ),
                  ),
            ],
            if (period != null)
              Flexible(
                child: Text(
                  period,
                  style: defaultStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatPeriod(int gamePart, int gameTime) {
    // Handle both sport_socket format (0-7) and legacy bit flags format (2^n)
    //
    // sport_socket format: 0=notStarted, 1=firstHalf, 2=secondHalf, 3=halfTime,
    //                      4=extraTime, 5=penalties, 6=fullTime, 7=breakTime
    //
    // Legacy bit flags:    2=firstHalf, 4=halfTime, 8=secondHalf, 16=finished,
    //                      32=regulaTimeFinished, 64=firstHalfExtraTime, etc.

    switch (gamePart) {
      // sport_socket format (0-7)
      case 1: // firstHalf (sport_socket)
        return 'Hiệp 1';
      case 3: // halfTime (sport_socket)
        return 'Nghỉ giữa hiệp';
      case 7: // breakTime (sport_socket)
        return 'Nghỉ';

      // Shared values (need context to distinguish)
      case 2: // secondHalf (sport_socket) OR firstHalf (legacy)
        // sport_socket uses 0-7, legacy uses powers of 2
        // If we have gameTime > 45, it's likely secondHalf from sport_socket
        if (gameTime > 45) return 'Hiệp 2';
        return 'Hiệp 1'; // Assume legacy firstHalf

      case 4: // extraTime (sport_socket) OR halfTime (legacy)
        // If gameTime > 90, it's likely extraTime from sport_socket
        if (gameTime > 90) return 'Hiệp phụ';
        return 'Hết hiệp 1'; // Assume legacy halfTime

      case 5: // penalties (sport_socket)
        return 'Pen';
      case 6: // fullTime (sport_socket)
        return 'Trận đấu kết thúc';

      // Legacy bit flags format only (8+)
      case 8: // secondHalf (legacy)
        return 'Hiệp 2';
      case 16: // finished (legacy)
        return 'Trận đấu kết thúc';
      case 32: // regulaTimeFinished (legacy)
        return "90'";
      case 64: // firstHalfExtraTime (legacy)
        return 'Bù giờ H1';
      case 128: // halfTimeOfExtraTime (legacy)
        return 'Nghỉ HP';
      case 256: // secondHalfExtraTime (legacy)
        return 'Bù giờ H2';
      case 512: // extraTimeFinished (legacy)
        return 'AET';
      case 1024: // penalties (legacy)
        return 'Pen';

      default:
        // Unknown gamePart - infer period from gameTime for football
        if (gameTime > 0) {
          if (gameTime <= 45) return 'Hiệp 1';
          if (gameTime <= 90) return 'Hiệp 2';
          return 'Hiệp phụ';
        }
        return '';
    }
  }

  /// Check if the string is a valid minute value (numeric, e.g. "45'", "90+3")
  /// Returns false for non-time strings like "LIVE", "Live", "Running", etc.
  bool _isValidMinuteString(String? value) {
    if (value == null || value.isEmpty) return false;
    // Valid minute strings contain at least one digit (e.g. "45'", "90+3'", "12")
    return value.contains(RegExp(r'\d'));
  }

  /// Format raw period string from API to Vietnamese
  /// Handles values like "Running", "1H", "2H", "HT", "ET1", etc.
  /// Returns null if input is empty or represents "not started"
  String? _formatRawPeriod(String? rawPeriod) {
    if (rawPeriod == null || rawPeriod.isEmpty) return null;

    final normalized = rawPeriod.trim().toUpperCase();
    switch (normalized) {
      case '1H':
      case 'FIRST HALF':
      case '1ST HALF':
        return 'Hiệp 1';
      case '2H':
      case 'SECOND HALF':
      case '2ND HALF':
        return 'Hiệp 2';
      case 'HT':
      case 'HALF TIME':
      case 'HALFTIME':
        return 'Hết hiệp 1';
      case 'FT':
      case 'FULL TIME':
      case 'FULLTIME':
      case 'FINISHED':
        return 'Trận đấu kết thúc';
      case 'ET':
      case 'EXTRA TIME':
      case 'EXTRATIME':
        return 'Hiệp phụ';
      case 'ET1':
      case 'ET 1ST':
      case 'FIRST HALF EXTRA TIME':
        return 'Bù giờ H1';
      case 'ET2':
      case 'ET 2ND':
      case 'SECOND HALF EXTRA TIME':
        return 'Bù giờ H2';
      case 'ET-HT':
      case 'EXTRA TIME HALF TIME':
        return 'Hết H.Phụ 1';
      case 'AET':
      case 'AFTER EXTRA TIME':
        return 'Hết H.Phụ 2';
      case 'PEN':
      case 'PENALTIES':
      case 'PENALTY':
        return 'Pen';
      case 'RUNNING':
      case 'LIVE':
      case 'IN PLAY':
        return null;
      case 'NOT STARTED':
      case 'NS':
        return null;
      case 'BRK':
      case 'BREAK':
        return 'Nghỉ';
      default:
        // Return original if no match (might be already formatted)
        return rawPeriod;
    }
  }
}

/// Widget wrapper that applies opacity when market is suspended
class SuspendedOpacityWrapper extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget child;
  final double suspendedOpacity;

  const SuspendedOpacityWrapper({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.child,
    this.suspendedOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );

        return Opacity(
          opacity: isSuspended ? suspendedOpacity : 1.0,
          child: child,
        );
      },
    );
  }
}

/// Widget that shows a "SUSPENDED" overlay when market is suspended
class SuspendedOverlay extends StatelessWidget {
  final int eventId;
  final int marketId;
  final Widget child;

  const SuspendedOverlay({
    super.key,
    required this.eventId,
    required this.marketId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isSuspended = ref.watch(
          isMarketSuspendedProvider((eventId, marketId)),
        );

        return Stack(
          children: [
            child,
            if (isSuspended)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    'Tạm ngưng',
                    style: AppTextStyles.textStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
