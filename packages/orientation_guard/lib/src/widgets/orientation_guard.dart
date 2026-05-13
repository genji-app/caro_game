import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';
import 'package:orientation_guard/src/widgets/orientation_mismatch_view.dart';
import 'package:orientation_guard/src/widgets/orientation_provider.dart';

/// A widget that enforces a specific [OrientationPolicy].
///
/// It maintains the desired orientation while mounted and restores
/// previous state when disposed.
class OrientationGuard extends StatefulWidget {
  /// Creates an [OrientationGuard].
  const OrientationGuard({
    required this.policy,
    required this.child,
    this.controller,
    super.key,
  });

  /// The policy to enforce.
  final OrientationPolicy policy;

  /// The child widget to display.
  final Widget child;

  /// Optional [OrientationController].
  /// If null, it tries to find one via [OrientationProvider].
  final OrientationController? controller;

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard> {
  bool _isDisposed = false;
  OrientationController? _effectiveController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = widget.controller ?? OrientationProvider.of(context);

    if (newController != _effectiveController) {
      _effectiveController = newController;
      if (_effectiveController != null) {
        _applyPolicy();
      }
    }
  }

  Future<void> _applyPolicy() async {
    final controller = _effectiveController;
    if (controller == null) return;

    // Use post-frame callback to ensure platform commands are sent
    // after the frame is built and layout is stable.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isDisposed || !mounted) return;

      final result = await controller.apply(widget.policy);

      if (!_isDisposed && mounted) {
        debugPrint(
          'OrientationGuard: Applied policy "${widget.policy.debugLabel ?? ''}". '
          'Targets: ${widget.policy.targets.length}, '
          'Status: ${result.status.name}',
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant OrientationGuard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for any relevant change in the policy object
    if (oldWidget.policy != widget.policy || oldWidget.controller != widget.controller) {
      _applyPolicy();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _effectiveController?.restore().catchError((Object e, StackTrace s) {
      debugPrint('OrientationGuard: Failed to restore orientation: $e');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;

    if (controller == null) {
      if (kDebugMode) {
        return const Material(
          color: Colors.red,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Error: OrientationGuard requires an OrientationController.\n'
                'Provide one via constructor or wrap with OrientationProvider.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
      return widget.child;
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return widget.child;

    final currentOrientation = mediaQuery.orientation;
    final isMatched = controller.isMatched(
      policy: widget.policy,
      currentOrientation: currentOrientation,
    );

    // Only block if we have a valid non-zero size and explicitly requested.
    final hasValidSize = mediaQuery.size.width > 0 && mediaQuery.size.height > 0;
    final shouldBlock = hasValidSize &&
        !isMatched &&
        kIsWeb &&
        widget.policy.blockOnWebMismatch &&
        _isMobileOrTabletWeb(mediaQuery.size);

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (shouldBlock)
          Positioned.fill(
            child: OrientationMismatchView(policy: widget.policy),
          ),
      ],
    );
  }

  bool _isMobileOrTabletWeb(Size size) {
    return size.shortestSide < 900;
  }
}
