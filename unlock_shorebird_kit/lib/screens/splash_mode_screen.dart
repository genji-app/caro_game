import 'dart:async';

import 'package:unlock_shorebird_kit/flow/unlock_flow_coordinator.dart';
import 'package:unlock_shorebird_kit/flow/unlock_shorebird_launch_coordinator.dart';
import 'package:unlock_shorebird_kit/shorebird/shorebird_patch_preferences.dart';
import 'package:unlock_shorebird_kit/shorebird/update/shorebird_restart_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Host provides [executeRestartWithFade] → fade-out then [Restart.restartApp]
/// (typically [RestartScope.executeRestartApp]). First patch: same animation,
/// no snackbar; later patches: snackbar then same callback on tap.
class SplashModeScreen extends StatefulWidget {
  const SplashModeScreen({
    super.key,
    required this.bettingScreenBuilder,
    required this.fakeScreenBuilder,
    required this.executeRestartWithFade,
    this.splashScreenBuilder,
    this.initialFlowDelay = const Duration(seconds: 2),
  });

  final Widget Function() bettingScreenBuilder;
  final Widget Function() fakeScreenBuilder;
  final Future<bool> Function(BuildContext context) executeRestartWithFade;

  /// Tuỳ chỉnh màn hình splash. Nếu null, mặc định dùng [SplashView].
  final Widget Function()? splashScreenBuilder;

  final Duration initialFlowDelay;

  @override
  State<SplashModeScreen> createState() => _SplashModeScreenState();
}

class _SplashModeScreenState extends State<SplashModeScreen> {
  AppMode currentMode = AppMode.splash;
  bool isExecutingFlow = false;
  // bool _shorebirdSyncInProgress = false;
  final UnlockShorebirdLaunchCoordinator _launchCoordinator =
      UnlockShorebirdLaunchCoordinator();

  @override
  void dispose() {
    unawaited(_launchCoordinator.executeCloseResources());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    executeStartFlowAfterDelay();
  }

  Future<void> executeStartFlowAfterDelay() async {
    await Future<void>.delayed(widget.initialFlowDelay);
    if (!mounted) {
      return;
    }
    if (isExecutingFlow) {
      return;
    }
    isExecutingFlow = true;
    try {
      await _launchCoordinator.executeUnlockFlowWithShorebirdGate(
        onAppModeSet: executeSetMode,
        onConnectionErrorPrompt: executeShowRetryDialog,
        isActive: () => mounted,
        onShorebirdSyncVisibilityChanged: ({required bool isShorebirdSyncing}) {
          if (!mounted) {
            return;
          }
          // setState(() {
          //   _shorebirdSyncInProgress = isShorebirdSyncing;
          // });
        },
        onShorebirdRestartRequired: executeHandleShorebirdRestartRequired,
      );
    } finally {
      isExecutingFlow = false;
    }
  }

  void executeSetMode(AppMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      currentMode = mode;
    });
  }

  /// When [UpdateFlowStatus.restartRequired]: first time set prefs and restart
  /// with fade (no snackbar); later show snackbar; tap uses the same fade + restart.
  Future<void> executeHandleShorebirdRestartRequired() async {
    if (!mounted) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool consumed =
        prefs.getBool(
          ShorebirdPatchPreferences.firstPostPatchAutoRestartConsumedKey,
        ) ??
        false;
    if (!consumed) {
      await prefs.setBool(
        ShorebirdPatchPreferences.firstPostPatchAutoRestartConsumedKey,
        true,
      );
      if (!mounted) {
        return;
      }
      await widget.executeRestartWithFade(context);
      return;
    }
    if (!mounted) {
      return;
    }
    final int? minPatchForceUpdate = _launchCoordinator.minPatchForceUpdate;
    final int? pendingPatchNumber =
        await _launchCoordinator.executeReadPendingPatchNumber();
    if (!mounted) {
      return;
    }
    if (minPatchForceUpdate != null && pendingPatchNumber != null) {
      if (pendingPatchNumber >= minPatchForceUpdate) {
        executeSetMode(AppMode.betting);
        return;
      }
    }
    executeShowShorebirdRestartSnackbar(
      context,
      executeRestartWithFade: widget.executeRestartWithFade,
    );
  }

  Future<bool> executeShowRetryDialog() async {
    if (!mounted) {
      return false;
    }
    final bool? shouldRetry = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi Internet'),
          content: const Text('Không thể kết nối đến server. Thử lại?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
    return shouldRetry ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (currentMode == AppMode.fake) {
      return widget.fakeScreenBuilder();
    }
    if (currentMode == AppMode.betting) {
      return widget.bettingScreenBuilder();
    }
    return widget.splashScreenBuilder?.call() ?? const SplashView();
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
