import 'package:flutter/widgets.dart';

import '../controllers/controller_dispatcher.dart';
import '../controllers/orientation_controller.dart';
import '../controllers/platform_orientation_controller.dart';
import '../models/orientation_guard_config.dart';
import '../models/orientation_policy.dart';
import 'orientation_guard.dart';

/// Provides [OrientationController] and the active [OrientationPolicy] to the widget tree.
class OrientationScope extends StatefulWidget {
  /// Creates an [OrientationScope] that provides the given [controller] and [currentPolicy].
  ///
  /// If [controller] is omitted, a default platform controller is created and cached.
  const OrientationScope({
    super.key,
    this.controller,
    this.currentPolicy,
    this.config = const OrientationGuardConfig(),
    required this.child,
  });

  /// A convenience constructor that creates a root scope and enforces a [defaultPolicy]
  /// using an [OrientationGuard].
  ///
  /// This replaces the old `OrientationEntryPoint`.
  static Widget root({
    Key? key,
    OrientationController? controller,
    OrientationPolicy defaultPolicy = OrientationPolicy.portrait,
    OrientationGuardConfig config = const OrientationGuardConfig(),
    WidgetBuilder? mismatchBuilder,
    bool blockOnMismatch = false,
    required Widget child,
  }) {
    return OrientationScope(
      key: key,
      controller: controller,
      currentPolicy: defaultPolicy,
      config: config,
      child: OrientationGuard(
        policy: defaultPolicy,
        // The guard will find the controller from the scope above it
        mismatchBuilder: mismatchBuilder,
        blockOnMismatch: blockOnMismatch,
        child: child,
      ),
    );
  }

  /// The controller to use for orientation management.
  final OrientationController? controller;

  /// The currently active policy.
  final OrientationPolicy? currentPolicy;

  /// The global configuration for the guard.
  final OrientationGuardConfig config;

  /// The child widget.
  final Widget child;

  /// Returns the [OrientationController] from the closest [OrientationScope].
  static OrientationController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>();
    if (scope == null) {
      throw FlutterError(
          'OrientationScope.of() called with a context that does not contain an OrientationScope.');
    }
    return scope.controller;
  }

  /// Returns the [OrientationController] from the closest ancestor, or null if none found.
  static OrientationController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>()?.controller;
  }

  /// Returns the current [OrientationPolicy] from the closest [OrientationScope].
  static OrientationPolicy? maybePolicyOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>()?.currentPolicy;
  }

  /// Gets the [OrientationGuardConfig] from the nearest [OrientationScope].
  static OrientationGuardConfig configOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_OrientationScopeProvider>();
    return scope?.config ?? const OrientationGuardConfig();
  }

  @override
  State<OrientationScope> createState() => _OrientationScopeState();
}

class _OrientationScopeState extends State<OrientationScope> {
  OrientationController? _internalController;

  OrientationController get _controller {
    if (widget.controller != null) return widget.controller!;
    _internalController ??= createOrientationControllerV1(config: widget.config);
    return _internalController!;
  }

  @override
  void didUpdateWidget(OrientationScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller || widget.config != oldWidget.config) {
      // If config changed and we are using an internal controller, we need to recreate it
      // to ensure the strategies have the new config.
      if (widget.controller == null && widget.config != oldWidget.config) {
        _internalController = createOrientationControllerV1(config: widget.config);
      }
    }
  }

  @override
  void dispose() {
    // Note: We don't necessarily want to dispose the controller here if it's shared,
    // but if we created it internally for this scope, we should consider it.
    // However, PlatformOrientationController (ChangeNotifier) should be disposed.
    if (_internalController is PlatformOrientationController) {
      (_internalController as PlatformOrientationController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OrientationScopeProvider(
      controller: _controller,
      currentPolicy: widget.currentPolicy,
      config: widget.config,
      child: widget.child,
    );
  }
}

class _OrientationScopeProvider extends InheritedWidget {
  const _OrientationScopeProvider({
    required this.controller,
    this.currentPolicy,
    required this.config,
    required super.child,
  });

  final OrientationController controller;
  final OrientationPolicy? currentPolicy;
  final OrientationGuardConfig config;

  @override
  bool updateShouldNotify(_OrientationScopeProvider oldWidget) {
    return controller != oldWidget.controller ||
        currentPolicy != oldWidget.currentPolicy ||
        config != oldWidget.config;
  }
}
