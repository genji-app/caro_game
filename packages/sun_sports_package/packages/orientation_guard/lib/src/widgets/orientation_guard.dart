import 'package:flutter/widgets.dart';

import '../controllers/orientation_controller.dart';
import '../models/orientation_policy.dart';
import 'orientation_mismatch_view.dart';
import 'orientation_scope.dart';

/// A widget that enforces a specific [OrientationPolicy] on the platform.
///
/// It automatically applies the policy when mounted and restores the previous
/// state when disposed. If the current orientation doesn't match the policy,
/// it can optionally block the [child] and show a mismatch UI.
class OrientationGuard extends StatefulWidget {
  /// Creates a new [OrientationGuard].
  const OrientationGuard({
    super.key,
    required this.policy,
    required this.child,
    this.controller,
    this.mismatchBuilder,
    this.blockOnMismatch,
    this.onMismatchChanged,
  });

  /// The policy to enforce.
  final OrientationPolicy policy;

  /// The widget to display if the orientation matches the policy
  /// (or if [blockOnMismatch] is false).
  final Widget child;

  /// An optional controller to use. If null, it will be looked up
  /// from the closest [OrientationScope].
  final OrientationController? controller;

  /// An optional builder to customize the UI shown when the orientation
  /// doesn't match the policy.
  final WidgetBuilder? mismatchBuilder;

  /// Whether to block the [child] and show a mismatch UI when the orientation
  /// doesn't match.
  ///
  /// Defaults to [OrientationPolicy.blockOnMismatch].
  final bool? blockOnMismatch;

  /// An optional callback triggered when the mismatch status changes.
  final ValueChanged<bool>? onMismatchChanged;

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard> {
  OrientationController? _resolvedController;
  OrientationPolicy? _lastAppliedPolicy;
  OrientationPolicy? _previousPolicy;
  bool _capturedPrevious = false;
  final ValueNotifier<bool> _isApplying = ValueNotifier(false);
  bool? _lastMatched;

  @override
  void initState() {
    super.initState();
    // No need to manually listen to _isApplying anymore, will use ListenableBuilder
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveAndApply();
    _notifyMismatchChanged();
  }

  @override
  void didUpdateWidget(OrientationGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.policy != oldWidget.policy || widget.controller != oldWidget.controller) {
      _resolveAndApply();
      _notifyMismatchChanged();
    }
  }

  @override
  void dispose() {
    if (_resolvedController != null) {
      final controller = _resolvedController!;
      final previous = _previousPolicy;

      // Optimization: Only trigger restore if the current active policy matches 
      // the one this guard applied, AND it's different from the previous one.
      // This prevents double-restoration when external logic (like MockGameNotifier)
      // already manually restored the orientation before popping.
      if (controller.activePolicy == widget.policy && controller.activePolicy != previous) {
        debugPrint(
          '[OrientationGuard] disposing: ${widget.policy.debugLabel ?? 'unnamed'}, restoring: ${previous?.debugLabel ?? 'none'}',
        );
        controller.restore(previous);
      } else {
        debugPrint(
          '[OrientationGuard] disposing: ${widget.policy.debugLabel ?? 'unnamed'}, restore skipped (already matched or overridden)',
        );
      }
    }
    _isApplying.dispose();
    super.dispose();
  }

  void _resolveAndApply() {
    final controller = widget.controller ?? OrientationScope.of(context);
    _resolvedController = controller;

    if (!_capturedPrevious) {
      _previousPolicy = OrientationScope.maybePolicyOf(context);
      _capturedPrevious = true;
      debugPrint(
        '[OrientationGuard] Captured previous policy: ${_previousPolicy?.debugLabel ?? 'none'} for ${widget.policy.debugLabel ?? 'unnamed'}',
      );
    }

    if (_lastAppliedPolicy != widget.policy) {
      _lastAppliedPolicy = widget.policy;

      // Optimization: If current orientation already satisfies the policy,
      // we can apply silently without showing the transition/matched-assume state.
      final currentOrientation = MediaQuery.of(context).orientation;
      final alreadyMatched = controller.isMatched(
        policy: widget.policy,
        currentOrientation: currentOrientation,
      );

      debugPrint(
        '[OrientationGuard] _resolveAndApply: ${widget.policy.debugLabel ?? 'unnamed'}, alreadyMatched: $alreadyMatched',
      );

      if (alreadyMatched) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.apply(widget.policy);
            _notifyMismatchChanged();
          }
        });
        return;
      }

      _isApplying.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await controller.apply(widget.policy);
          // Wait another frame for MediaQuery to update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _isApplying.value = false;
              _notifyMismatchChanged();
            }
          });
        }
      });
    }
  }

  void _notifyMismatchChanged() {
    if (widget.onMismatchChanged == null) return;

    // Use a small delay to ensure all dependencies (OrientationScope, MediaQuery) are stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentOrientation = MediaQuery.of(context).orientation;
      final controller = _resolvedController ?? widget.controller ?? OrientationScope.of(context);

      final isMatched = _isApplying.value
          ? true
          : controller.isMatched(
              policy: widget.policy,
              currentOrientation: currentOrientation,
            );

      if (_lastMatched != isMatched) {
        _lastMatched = isMatched;
        widget.onMismatchChanged?.call(!isMatched);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _resolvedController ?? widget.controller ?? OrientationScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([controller, _isApplying]),
      builder: (context, _) {
        final currentOrientation = MediaQuery.of(context).orientation;
        final isApplying = _isApplying.value || controller.isApplying;

        // When transition is in progress, we assume it's matched to prevent flicker.
        final isMatched = isApplying
            ? true
            : controller.isMatched(policy: widget.policy, currentOrientation: currentOrientation);

        final shouldBlock = widget.blockOnMismatch ?? widget.policy.blockOnMismatch;
        final activePolicy = controller.activePolicy;
        final isOverridden = activePolicy != null && activePolicy != widget.policy;

        debugPrint(
          '[OrientationGuard] build (${widget.policy.debugLabel}): '
          'orientation=$currentOrientation, '
          'activePolicy=${activePolicy?.debugLabel}, '
          'isOverridden=$isOverridden, '
          'isMatched=$isMatched, '
          'shouldBlock=$shouldBlock',
        );

        if (shouldBlock && !isMatched && !isOverridden) {
          debugPrint(
            '[OrientationGuard] Mismatch detected (${widget.policy.debugLabel}): '
            'orientation=$currentOrientation, activePolicy=${activePolicy?.debugLabel}, '
            'isOverridden=$isOverridden',
          );
          if (widget.mismatchBuilder != null) {
            return widget.mismatchBuilder!(context);
          }
          return OrientationMismatchView(policy: widget.policy);
        }

        if (!isMatched && isOverridden) {
          debugPrint(
            '[OrientationGuard] Mismatch suppressed by override (${widget.policy.debugLabel}): '
            'activePolicy=${activePolicy.debugLabel}',
          );
        }

        return OrientationScope(
          controller: controller,
          currentPolicy: widget.policy,
          child: widget.child,
        );
      },
    );
  }
}
