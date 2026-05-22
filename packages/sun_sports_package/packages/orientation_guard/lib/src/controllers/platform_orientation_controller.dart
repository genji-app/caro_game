import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../models/orientation_apply_result.dart';
import '../models/orientation_policy.dart';
import '../strategies/orientation_strategy.dart';
import 'orientation_controller.dart';

/// A concrete implementation of [OrientationController] that delegates
/// all platform-specific logic to an [OrientationStrategy].
class PlatformOrientationController extends ChangeNotifier implements OrientationController {
  /// Creates a new [PlatformOrientationController].
  PlatformOrientationController(this._strategy);

  final OrientationStrategy _strategy;

  OrientationPolicy? _lastAppliedPolicy;
  bool _isApplying = false;

  @override
  bool get isApplying => _isApplying;

  @override
  Future<OrientationApplyResult> apply(OrientationPolicy policy) async {
    if (_lastAppliedPolicy == policy) {
      debugPrint(
          '[OrientationController] apply: skipped (already active: ${policy.debugLabel ?? 'unnamed'})');
      return OrientationApplyResult.matched(policy);
    }

    debugPrint('[OrientationController] apply: ${policy.debugLabel ?? 'unnamed'}');
    _isApplying = true;
    _lastAppliedPolicy = policy;
    _safeNotifyListeners();

    try {
      final result = await _strategy.apply(policy);
      return result;
    } finally {
      _isApplying = false;
      _safeNotifyListeners();
    }
  }

  @override
  Future<OrientationApplyResult> restore([OrientationPolicy? previousPolicy]) async {
    // If we are restoring to the SAME policy that is already active, we can skip.
    // However, if previousPolicy is null, we should almost always proceed to ensure
    // the device is unlocked, unless we were already in a null/default state.
    if (_lastAppliedPolicy == previousPolicy && previousPolicy != null) {
      debugPrint(
          '[OrientationController] restore: skipped (already active: ${previousPolicy.debugLabel ?? 'none'})');
      return OrientationApplyResult.matched(previousPolicy);
    }

    debugPrint(
        '[OrientationController] restore (previous: ${previousPolicy?.debugLabel ?? 'none'})');
    _isApplying = true;
    _lastAppliedPolicy = previousPolicy;
    _safeNotifyListeners();

    try {
      final result = await _strategy.restore(previousPolicy);
      return result;
    } finally {
      _isApplying = false;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    // If we have no listeners, nothing to do.
    if (!hasListeners) return;

    // We use a small delay if we are in the middle of a build or layout phase
    // to avoid "setState() or markNeedsBuild() called when widget tree was locked".
    // Since _isApplying and _lastAppliedPolicy are already updated synchronously,
    // any widget that builds naturally in this frame will see the new values.
    // The notification is only needed to trigger builds for other listeners.
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase != SchedulerPhase.idle) {
      debugPrint('[OrientationController] deferring notifyListeners (phase: ${scheduler.schedulerPhase})');
      Future.microtask(() {
        if (hasListeners) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  @override
  bool isMatched({
    required OrientationPolicy policy,
    required Orientation currentOrientation,
  }) {
    return _strategy.isMatched(
      policy: policy,
      currentOrientation: currentOrientation,
    );
  }

  @override
  OrientationPolicy? get activePolicy => _lastAppliedPolicy;
}
