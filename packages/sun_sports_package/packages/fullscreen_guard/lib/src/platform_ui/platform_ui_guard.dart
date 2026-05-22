import 'package:flutter/widgets.dart';

import 'platform_ui_config.dart';
import 'platform_ui_controller.dart';
import 'platform_ui_controller_factory.dart';

/// {@template platform_ui_guard}
/// A widget that manages the lifecycle and initial configuration of a
/// [PlatformUiController].
///
/// Use this widget to centralize system UI management (status bar, navigation
/// bar) within the widget tree. It handles initializing the controller,
/// applying an [initialConfig], and disposing of the controller when no
/// longer needed.
///
/// ## Auto-restore mechanism
///
/// This widget acts as the source of truth for the "base" system UI state. If
/// another component (like `FullscreenGuard`) changes the system UI and then
/// restores it to defaults, this guard will detect the change and re-apply its
/// [initialConfig] to maintain the app's branded look.
/// {@endtemplate}
class PlatformUiGuard extends StatefulWidget {
  /// {@macro platform_ui_guard}
  const PlatformUiGuard({
    required this.child,
    this.initialConfig,
    this.controller,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional configuration to apply as soon as the controller is ready.
  final PlatformUiConfig? initialConfig;

  /// Optional externally-created [PlatformUiController].
  ///
  /// When provided, this widget will **not** dispose of it. If null, a new
  /// controller is created and managed by this widget's state.
  final PlatformUiController? controller;

  /// Gets the [PlatformUiController] from the nearest [PlatformUiGuard].
  static PlatformUiController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PlatformUiScope>();
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'PlatformUiGuard.of() called with a context that does not '
          'contain a PlatformUiGuard widget.',
        ),
      ]);
    }
    return scope.controller;
  }

  @override
  State<PlatformUiGuard> createState() => _PlatformUiGuardState();
}

class _PlatformUiGuardState extends State<PlatformUiGuard> with WidgetsBindingObserver {
  late final PlatformUiController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? createPlatformUiController();

    _applyInitialConfig();
  }

  @override
  void didUpdateWidget(PlatformUiGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialConfig != null && widget.initialConfig != oldWidget.initialConfig) {
      _applyInitialConfig();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app returns to foreground, ensure our config is still applied.
    if (state == AppLifecycleState.resumed) {
      _applyInitialConfig();
    }
  }

  void _applyInitialConfig() {
    if (widget.initialConfig != null) {
      _controller.apply(widget.initialConfig!).ignore();
    }
  }

  /// Public method to force re-application of the guard's base config.
  /// Useful for FullscreenGuard to call when it exits.
  void restoreBaseConfig() => _applyInitialConfig();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PlatformUiScope(
      controller: _controller,
      guardState: this,
      child: widget.child,
    );
  }
}

class _PlatformUiScope extends InheritedWidget {
  const _PlatformUiScope({
    required this.controller,
    required this.guardState,
    required super.child,
  });

  final PlatformUiController controller;
  final _PlatformUiGuardState guardState;

  @override
  bool updateShouldNotify(_PlatformUiScope oldWidget) =>
      controller != oldWidget.controller || guardState != oldWidget.guardState;
}
