import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/event_live_provider.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';

/// Basketball countdown timer widget.
///
/// Counts down locally via Timer.periodic(1s) and resyncs
/// when the server value diverges by more than 2 seconds.
/// Uses ref.listen (not ref.watch) to avoid rebuilding the
/// entire widget on every WebSocket push.
class BasketballCountdownTimer extends ConsumerStatefulWidget {
  final int eventId;
  final int initialTimeMs;
  final TextStyle? style;

  const BasketballCountdownTimer({
    super.key,
    required this.eventId,
    this.initialTimeMs = 0,
    this.style,
  });

  @override
  ConsumerState<BasketballCountdownTimer> createState() =>
      _BasketballCountdownTimerState();
}

class _BasketballCountdownTimerState
    extends ConsumerState<BasketballCountdownTimer> {
  int _remainingMs = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingMs = widget.initialTimeMs;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remainingMs <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingMs <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _remainingMs = max(0, _remainingMs - 1000);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // listen — resync only when server delta >2s, does NOT rebuild widget
    ref.listen(eventGameTimeMsProvider(widget.eventId), (prev, next) {
      if (next != null && (next - _remainingMs).abs() > 2000) {
        setState(() => _remainingMs = next);
        // Restart timer if it was cancelled
        if (_remainingMs > 0 && !(_timer?.isActive ?? false)) {
          _startTimer();
        }
      }
    });

    final totalSeconds = (_remainingMs / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    final textStyle = widget.style ??
        AppTextStyles.textStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFFFFEF5),
        );

    return Text(
      '$minutes:${seconds.toString().padLeft(2, '0')}',
      style: textStyle,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
