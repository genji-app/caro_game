import 'package:flutter/material.dart';
import 'package:terminate_restart/terminate_restart.dart';

/// Wraps the app and exposes [executeRestartApp].
///
/// A widget-only remount does **not** reload Dart code from a Shorebird patch:
/// the VM still runs the pre-patch snapshot until the **OS process** restarts.
/// [executeProcessRestartOnly] uses [TerminateRestart.instance.restartApp] with
/// [TerminateRestartOptions.terminate] so the next launch loads the patched
/// [libapp.so].
///
/// Before calling native restart, a short **fade-to-black** runs in Flutter.
class RestartScope extends StatefulWidget {
  const RestartScope({required this.child, super.key});
  final Widget child;

  static const Duration _fadeOutDuration = Duration(milliseconds: 300);

  /// Full process restart (**no** fade). Prefer [executeRestartApp] from UI;
  /// used internally after the fade delay.
  static Future<bool> executeProcessRestartOnly() async {
    return TerminateRestart.instance.restartApp(
      options: const TerminateRestartOptions(terminate: true),
    );
  }

  /// Restarts the app process so Shorebird patches take effect. Falls back to
  /// remounting the widget subtree only if native restart fails.
  ///
  /// Returns `true` if a **process** restart was started; `false` if native
  /// restart failed and the subtree remount fallback ran.
  static Future<bool> executeRestartApp(BuildContext context) async {
    final _RestartScopeState? state = context
        .findAncestorStateOfType<_RestartScopeState>();
    if (state != null) {
      return state.executeRestartWithFadeOut();
    }
    return executeProcessRestartOnly();
  }

  @override
  State<RestartScope> createState() => _RestartScopeState();
}

class _RestartScopeState extends State<RestartScope> {
  Key appKey = UniqueKey();
  bool _fadeToBlack = false;

  Future<bool> executeRestartWithFadeOut() async {
    setState(() {
      _fadeToBlack = true;
    });
    await Future<void>.delayed(RestartScope._fadeOutDuration);
    if (!mounted) {
      return false;
    }
    final bool didStartProcessRestart =
        await RestartScope.executeProcessRestartOnly();
    if (didStartProcessRestart) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    setState(() {
      _fadeToBlack = false;
    });
    executeRemountSubtree();
    return false;
  }

  void executeRemountSubtree() {
    setState(() {
      appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topLeft,
      children: [
        KeyedSubtree(key: appKey, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_fadeToBlack,
            child: AnimatedOpacity(
              duration: RestartScope._fadeOutDuration,
              opacity: _fadeToBlack ? 1.0 : 0.0,
              child: const ColoredBox(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
