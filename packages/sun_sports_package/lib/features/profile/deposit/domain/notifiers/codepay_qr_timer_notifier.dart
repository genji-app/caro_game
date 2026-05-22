import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Codepay QR timer state
class CodepayQrTimerState {
  final int remainingSeconds;
  final bool isExpired;

  const CodepayQrTimerState({
    required this.remainingSeconds,
    this.isExpired = false,
  });

  CodepayQrTimerState copyWith({int? remainingSeconds, bool? isExpired}) {
    return CodepayQrTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  /// Format timer based on remaining time (in seconds)
  /// - If more than 24 hours: Shows "X ngày HH:MM:SS"
  /// - If more than 1 hour: Shows "HH:MM:SS"
  /// - Otherwise: Shows "MM:SS"
  /// Note: remainingSeconds is converted from milliseconds (API returns milliseconds)
  /// Example: 1799643 ms = 1799.643 seconds = "29:59" (MM:SS)
  String get formattedTime {
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final secs = remainingSeconds % 60;

    // Otherwise show MM:SS
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Codepay QR timer notifier - manages countdown timer for QR code
/// Note: initialMilliseconds will be converted to seconds for countdown
class CodepayQrTimerNotifier extends StateNotifier<CodepayQrTimerState> {
  Timer? _timer;

  /// Constructor accepts milliseconds and converts to seconds
  /// remainingTime from API is in milliseconds (e.g., 1799643 ms)
  CodepayQrTimerNotifier(int initialMilliseconds)
    : super(
        CodepayQrTimerState(remainingSeconds: initialMilliseconds ~/ 1000),
      ) {
    _startTimer();
  }

  /// Start countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Check if notifier is still mounted before updating state
      // This prevents "Bad state" error when timer callback runs after dispose
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(isExpired: true);
        // TODO: Handle QR code expiry
      }
    });
  }

  /// Reset timer with new initial milliseconds
  /// Converts milliseconds to seconds for countdown
  void reset(int initialMilliseconds) {
    _timer?.cancel();
    state = CodepayQrTimerState(remainingSeconds: initialMilliseconds ~/ 1000);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
