import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scroll-driven hide/show controller for header and bottom navigation.
///
/// Uses [ValueNotifier] for per-frame updates — more efficient than Riverpod
/// [StateNotifier] for scroll-driven animations that update every ~16ms.
///
/// [progress]: 0.0 = fully visible, 1.0 = hidden ([minVisibleHeight] residual).
class ScrollHideNotifier {
  // === Config ===
  static const double headerHeight = 68.0;
  static const double minVisibleHeight = 1.0;
  static const double maxOffset = headerHeight - minVisibleHeight; // 67.0
  static const double snapThreshold = 0.5;
  static const Duration snapDuration = Duration(milliseconds: 200);
  static const Duration _startupPause = Duration(milliseconds: 1000);

  // === State ===
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  DateTime? _pauseUntil;
  Timer? _snapTimer;

  ScrollHideNotifier() {
    // Pause on startup to avoid collapse from initial render scroll events
    _pauseUntil = DateTime.now().add(_startupPause);
  }

  // === Scroll metrics (content size) handling ===
  //
  // NOTE: [ScrollMetricsNotification] does NOT extend [ScrollNotification] —
  // it only mixes in `ViewportNotificationMixin`. A
  // `NotificationListener<ScrollNotification>` will never receive it, so a
  // separate `NotificationListener<ScrollMetricsNotification>` must forward
  // events to this method.
  void handleScrollMetricsNotification(ScrollMetricsNotification notification) {
    if (_isBeforePauseUntil()) return;
    if (notification.depth != 0) return;
    ensureRevealableOrShow(notification.metrics);
  }

  /// Ensures the header is reachable by the current scrollable. If the
  /// scroll range is smaller than [maxOffset], the user can never scroll up
  /// far enough to drive [progress] back to 0 on their own, so the header is
  /// animated back into view.
  ///
  /// Covers two cases:
  ///   - `maxScrollExtent == minScrollExtent` (content fits the viewport)
  ///   - `maxScrollExtent - minScrollExtent < maxOffset` (slightly scrollable
  ///     but not enough headroom to reveal a hidden header)
  ///
  /// Returns `true` if a snap-animation was triggered.
  bool ensureRevealableOrShow(ScrollMetrics metrics) {
    final scrollRange = metrics.maxScrollExtent - metrics.minScrollExtent;
    if (scrollRange < maxOffset && progress.value != 0.0) {
      _animateSnapTo(0.0);
      return true;
    }
    return false;
  }

  // === Scroll handling ===
  void handleScrollNotification(ScrollNotification notification) {
    if (_isBeforePauseUntil()) return;
    if (notification.depth != 0) return;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      final metrics = notification.metrics;

      // Viewport chứa hết content → force show, bỏ qua update.
      // (Safety net phòng trường hợp ScrollMetricsNotification không fire.)
      final canScroll = metrics.maxScrollExtent > metrics.minScrollExtent;
      if (!canScroll) {
        if (progress.value != 0.0) {
          _snapTimer?.cancel();
          progress.value = 0.0;
        }
        return;
      }

      // Skip iOS bounce / overscroll
      if (metrics.outOfRange) return;

      // Skip when at edges
      if (delta > 0 && metrics.pixels >= metrics.maxScrollExtent) return;
      if (delta < 0 && metrics.pixels <= metrics.minScrollExtent) return;

      final progressDelta = delta / maxOffset;
      final newProgress = (progress.value + progressDelta).clamp(0.0, 1.0);

      // Only update if change is significant (> 0.005 ≈ 0.3px) to avoid micro-updates
      if ((newProgress - progress.value).abs() > 0.005) {
        _snapTimer?.cancel();
        progress.value = newProgress;
      }
    }

    if (notification is ScrollEndNotification) {
      _snap();
    }
  }

  // === Snap ===
  void _snap() {
    // Already near an endpoint — skip snap
    if (progress.value <= 0.05 || progress.value >= 0.95) return;
    final target = progress.value < snapThreshold ? 0.0 : 1.0;
    _animateSnapTo(target);
  }

  void _animateSnapTo(double target) {
    _snapTimer?.cancel();
    final start = progress.value;
    final startTime = DateTime.now();

    _snapTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final t = (elapsed / snapDuration.inMilliseconds).clamp(0.0, 1.0);

      if (t >= 1.0) {
        progress.value = target;
        timer.cancel();
        return;
      }

      // Ease-out curve: 1 - (1 - t)²
      final eased = 1.0 - (1.0 - t) * (1.0 - t);
      progress.value = start + (target - start) * eased;
    });
  }

  // === Control methods ===
  void show() {
    _snapTimer?.cancel();
    progress.value = 0.0;
  }

  void pauseDetection([Duration duration = const Duration(milliseconds: 500)]) {
    _pauseUntil = DateTime.now().add(duration);
  }

  bool _isBeforePauseUntil() {
    if (_pauseUntil == null) return false;
    if (DateTime.now().isBefore(_pauseUntil!)) return true;
    _pauseUntil = null;
    return false;
  }

  void dispose() {
    _snapTimer?.cancel();
    progress.dispose();
  }
}

/// Riverpod provider wrapping ScrollHideNotifier.
final scrollHideProvider = Provider<ScrollHideNotifier>((ref) {
  final notifier = ScrollHideNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
