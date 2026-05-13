import 'package:flutter/foundation.dart';

import '../platform_ui/platform_ui.dart';
import 'strategies/strategies.dart';

/// {@template fullscreen_gate_request}
/// Describes a request to show the fullscreen gate overlay.
///
/// Each request carries a string [tag] that identifies which
/// feature triggered it (e.g., `'gamePlayer'`, `'liveStream'`).
/// Tags are app-defined — the package does not enforce a fixed
/// set of values.
///
/// ## Blocking vs informational
///
/// - [isRequired] = `true` (default): the gate blocks all
///   interaction until the user taps to enter fullscreen, or
///   cancels (which pops the route).
/// - [isRequired] = `false`: the gate is shown as a suggestion
///   but does not block underlying content.
///
/// ## Example
///
/// ```dart
/// FullscreenGuard.of(context).request(
///   const FullscreenGateRequest(tag: 'gamePlayer'),
/// );
/// ```
/// {@endtemplate}
@immutable
class FullscreenGateRequest {
  /// {@macro fullscreen_gate_request}
  const FullscreenGateRequest({
    required this.tag,
    this.isRequired = true,
    this.requiresGestureOnIosSafari = false,
  });

  /// Request identifier — app-defined string.
  final String tag;

  /// If true, gate blocks interaction until satisfied.
  /// If false, gate is informational.
  final bool isRequired;

  /// When `true`, shows the swipe-up gate overlay on iOS Safari instead of
  /// auto-satisfying immediately.
  ///
  /// By default (`false`), on iOS Safari the gate is auto-satisfied and the
  /// scroll trick (Minimal UI) runs programmatically. This is simpler but may
  /// not reliably collapse the Safari toolbar on all iOS versions.
  ///
  /// Set to `true` for screens where reliable toolbar hiding matters (e.g.
  /// game player). The user sees a "Swipe up" gate overlay; when they swipe,
  /// `PlatformUiController.apply` is called from within the user gesture
  /// context — improving iOS Safari's willingness to collapse the toolbar.
  ///
  /// Has no effect on non-iOS-Safari platforms (gate behaviour on those
  /// platforms is unchanged).
  final bool requiresGestureOnIosSafari;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FullscreenGateRequest &&
          runtimeType == other.runtimeType &&
          tag == other.tag &&
          isRequired == other.isRequired &&
          requiresGestureOnIosSafari == other.requiresGestureOnIosSafari;

  @override
  int get hashCode => tag.hashCode ^ isRequired.hashCode ^ requiresGestureOnIosSafari.hashCode;

  @override
  String toString() => 'FullscreenGateRequest(tag: $tag, '
      'isRequired: $isRequired, '
      'requiresGestureOnIosSafari: $requiresGestureOnIosSafari)';
}

/// {@template fullscreen_guard_controller}
/// Gate state machine that manages the fullscreen gesture requirement.
///
/// This controller delegates the actual fullscreen implementation to a
/// [FullscreenStrategy], which is selected based on the platform and browser.
/// {@endtemplate}
class FullscreenGuardController extends ChangeNotifier {
  /// {@macro fullscreen_guard_controller}
  FullscreenGuardController({
    PlatformUiController? platformUiController,
    FullscreenStrategy? strategy,
  })  : _platformUiController = platformUiController ?? createPlatformUiController(),
        _ownsController = platformUiController == null {
    _strategy = strategy ?? createFullscreenStrategy(_platformUiController);
    _strategy.isFullscreen.addListener(_onFullscreenStateChanged);
  }

  final PlatformUiController _platformUiController;
  final bool _ownsController;
  late final FullscreenStrategy _strategy;

  FullscreenGateRequest? _activeRequest;
  bool _isSatisfied = false;

  // ============================================================================
  // Public API
  // ============================================================================

  /// Current active gate request.
  FullscreenGateRequest? get activeRequest => _activeRequest;

  /// Whether the gate has been satisfied by user.
  bool get isSatisfied => _isSatisfied;

  /// Whether the gate overlay should be visible.
  bool get shouldShowGate => _activeRequest != null && !_isSatisfied;

  /// Whether the gate is blocking (required and showing).
  bool get isBlocking => shouldShowGate && (_activeRequest?.isRequired ?? false);

  /// Public accessor to platform controller for direct UI manipulation.
  PlatformUiController get platformUiController => _platformUiController;

  /// The strategy used to achieve fullscreen.
  FullscreenStrategy get strategy => _strategy;

  /// Reactive fullscreen state from the active strategy.
  ValueListenable<bool> get isFullscreen => _strategy.isFullscreen;

  /// Show the fullscreen gate.
  void request(FullscreenGateRequest req) {
    _activeRequest = req;
    _isSatisfied = false;

    // Auto-satisfy if the strategy doesn't require a gesture.
    // (Native immersive, PWA, or Web Mobile Bypass)
    if (!_strategy.needsUserGesture) {
      _strategy.enter();
      _isSatisfied = true;
    }

    notifyListeners();
  }

  /// Mark gate as satisfied (user tapped).
  ///
  /// Calls the strategy's [enter] method.
  Future<void> satisfy() async {
    final success = await _strategy.enter();
    if (success) {
      _isSatisfied = true;
      notifyListeners();
    }
  }

  /// Dismiss gate and optionally restore system UI.
  void clear({bool restoreSystemUi = true}) {
    _activeRequest = null;
    _isSatisfied = false;

    // Cleanup any strategy-specific gate artifacts (e.g. HTML overlays).
    _strategy.teardownGate();

    if (restoreSystemUi) {
      // Exit fullscreen mode in the strategy.
      _strategy.exit();
      // Restore core system UI defaults.
      _platformUiController.restore();
    }

    notifyListeners();
  }

  // ============================================================================
  // Private — State machine
  // ============================================================================

  void _onFullscreenStateChanged() {
    // Re-gate: fullscreen lost while request active, required, and satisfied.
    // (e.g., user pressed Escape on Desktop Web).
    if (!_strategy.isFullscreen.value &&
        _activeRequest != null &&
        _activeRequest!.isRequired &&
        _isSatisfied) {
      _isSatisfied = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _strategy.isFullscreen.removeListener(_onFullscreenStateChanged);
    _strategy.dispose();
    if (_ownsController) {
      _platformUiController.dispose();
    }
    super.dispose();
  }
}
