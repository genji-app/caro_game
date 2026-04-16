import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';

/// Shared animation state manager cho odds flash animations.
///
/// Thay vì mỗi BetCard có riêng AnimationController, sử dụng singleton này
/// để quản lý trạng thái animation tập trung, giảm số lượng tickers.
///
/// ## Performance Benefits:
/// - Single source of truth cho animation state
/// - Auto-cleanup với configurable timeout
/// - Memory efficient với lazy ValueNotifier creation
/// - No AnimationController overhead per card
///
/// ## Usage:
/// ```dart
/// // In widget:
/// ValueListenableBuilder<OddsFlashState>(
///   valueListenable: OddsFlashManager.instance.getNotifier(selectionId),
///   builder: (context, state, child) {
///     // Use state.direction and state.flashOpacity
///   },
/// )
/// ```
class OddsFlashManager {
  static final OddsFlashManager instance = OddsFlashManager._();

  OddsFlashManager._() {
    // 🔧 MEMORY LEAK FIX: Periodic cleanup every 30s
    _periodicCleanupTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _periodicCleanup(),
    );
  }

  /// Map of active flash states
  final Map<String, ValueNotifier<OddsFlashState>> _notifiers = {};

  /// Map of reset timers (reset flash after duration)
  final Map<String, Timer> _timers = {};

  /// 🔧 MEMORY LEAK FIX: Map of cleanup timers (cleanup after flash ends)
  final Map<String, Timer> _cleanupTimers = {};

  /// Flash duration (how long the indicator shows)
  static const Duration flashDuration = Duration(seconds: 5);

  /// Cleanup interval for unused notifiers
  static const Duration cleanupInterval = Duration(minutes: 1);

  /// 🔧 MEMORY LEAK FIX: Lower threshold from 200 to 100
  static const int maxNotifiers = 100;

  Timer? _cleanupTimer;

  /// 🔧 MEMORY LEAK FIX: Periodic cleanup timer
  Timer? _periodicCleanupTimer;

  /// 🔧 MEMORY LEAK FIX: Getter for monitoring
  int get notifierCount => _notifiers.length;

  /// Get or create a notifier for a selection
  ValueNotifier<OddsFlashState> getNotifier(String selectionId) {
    return _notifiers.putIfAbsent(
      selectionId,
      () => ValueNotifier(const OddsFlashState()),
    );
  }

  /// Trigger flash animation for a selection
  void triggerFlash(String selectionId, OddsChangeDirection direction) {
    if (selectionId.isEmpty || direction == OddsChangeDirection.none) return;

    final notifier = getNotifier(selectionId);

    // Set new flash state
    notifier.value = OddsFlashState(
      direction: direction,
      flashOpacity: 1.0,
      isActive: true,
      timestamp: DateTime.now(),
    );

    // 🔧 MEMORY LEAK FIX: Cancel existing timers (both reset and cleanup)
    _timers[selectionId]?.cancel();
    _cleanupTimers[selectionId]?.cancel();

    // Schedule reset
    _timers[selectionId] = Timer(flashDuration, () {
      _resetFlash(selectionId);

      // 🔧 MEMORY LEAK FIX: Schedule cleanup if too many notifiers
      if (_notifiers.length > maxNotifiers ~/ 2) {
        _cleanupTimers[selectionId] = Timer(
          const Duration(seconds: 10),
          () => _tryDisposeSelection(selectionId),
        );
      }
    });

    // Check if cleanup needed
    _maybeCleanup();
  }

  /// Reset flash state for a selection
  void _resetFlash(String selectionId) {
    final notifier = _notifiers[selectionId];
    if (notifier == null) return;

    notifier.value = const OddsFlashState();
    _timers.remove(selectionId)?.cancel();
  }

  /// 🔧 MEMORY LEAK FIX: Safe cleanup - only dispose if not actively flashing
  void _tryDisposeSelection(String selectionId) {
    final notifier = _notifiers[selectionId];
    if (notifier != null && !notifier.value.isActive) {
      disposeSelection(selectionId);
    }
  }

  /// Manual dispose for a selection (call when widget unmounts)
  void disposeSelection(String selectionId) {
    _timers.remove(selectionId)?.cancel();
    _cleanupTimers.remove(selectionId)?.cancel();
    _notifiers.remove(selectionId)?.dispose();
  }

  /// Check and cleanup old notifiers
  void _maybeCleanup() {
    if (_notifiers.length < maxNotifiers) return;

    // Start periodic cleanup if not already running
    _cleanupTimer ??= Timer.periodic(cleanupInterval, (_) => _cleanup());
    _cleanup();
  }

  /// Remove inactive notifiers
  void _cleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _notifiers.entries) {
      final state = entry.value.value;

      // Remove if:
      // 1. Not active AND
      // 2. Older than flashDuration * 2
      if (!state.isActive) {
        final age = state.timestamp != null
            ? now.difference(state.timestamp!)
            : flashDuration * 3;

        if (age > flashDuration * 2) {
          keysToRemove.add(entry.key);
        }
      }
    }

    for (final key in keysToRemove) {
      disposeSelection(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint(
        '[OddsFlashManager] Cleaned up ${keysToRemove.length} notifiers. Remaining: ${_notifiers.length}',
      );
    }
  }

  /// 🔧 MEMORY LEAK FIX: Periodic cleanup to prevent accumulation
  void _periodicCleanup() {
    if (_notifiers.length <= maxNotifiers ~/ 2) return;

    final toRemove = <String>[];
    for (final entry in _notifiers.entries) {
      if (!entry.value.value.isActive) {
        toRemove.add(entry.key);
      }
      // Stop if we've found enough to cleanup
      if (_notifiers.length - toRemove.length <= maxNotifiers ~/ 2) break;
    }

    for (final key in toRemove) {
      disposeSelection(key);
    }

    if (kDebugMode && toRemove.isNotEmpty) {
      debugPrint(
        '[OddsFlashManager] Periodic cleanup: ${toRemove.length} notifiers. Remaining: ${_notifiers.length}',
      );
    }
  }

  /// Dispose all resources
  void dispose() {
    _cleanupTimer?.cancel();
    _periodicCleanupTimer?.cancel();

    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();

    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
  }

  /// Get current state for a selection (snapshot, not reactive)
  OddsFlashState? getState(String selectionId) {
    return _notifiers[selectionId]?.value;
  }

  /// Check if a selection has active flash
  bool isFlashing(String selectionId) {
    return _notifiers[selectionId]?.value.isActive ?? false;
  }
}

/// Immutable flash state
class OddsFlashState {
  final OddsChangeDirection direction;
  final double flashOpacity;
  final bool isActive;
  final DateTime? timestamp;

  const OddsFlashState({
    this.direction = OddsChangeDirection.none,
    this.flashOpacity = 0.0,
    this.isActive = false,
    this.timestamp,
  });

  OddsFlashState copyWith({
    OddsChangeDirection? direction,
    double? flashOpacity,
    bool? isActive,
    DateTime? timestamp,
  }) {
    return OddsFlashState(
      direction: direction ?? this.direction,
      flashOpacity: flashOpacity ?? this.flashOpacity,
      isActive: isActive ?? this.isActive,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OddsFlashState &&
        other.direction == direction &&
        other.flashOpacity == flashOpacity &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(direction, flashOpacity, isActive);
}

/// Extension to integrate with existing OddsChangeProvider
extension OddsFlashManagerExtension on OddsFlashManager {
  /// Sync flash state from OddsChangeProvider
  /// Call this when odds direction changes
  void syncFromOddsChange(String selectionId, OddsChangeDirection direction) {
    if (direction != OddsChangeDirection.none) {
      triggerFlash(selectionId, direction);
    }
  }
}
