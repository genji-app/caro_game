import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:unlock_shorebird_kit/unlock_shorebird_kit.dart';

import 'splash_screen.dart';

/// Root that runs [SplashModeScreen] (remote unlock + Shorebird gate) before
/// the normal [SplashScreen] → home flow.
class CaroUnlockLaunchRoot extends StatelessWidget {
  const CaroUnlockLaunchRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashModeScreen(
      bettingScreenBuilder: () => const SplashScreen(),
      fakeScreenBuilder: () => const SplashScreen(),
      executeRestartWithFade: executeShorebirdRestartWithFade,
      initialFlowDelay: Duration.zero,
    );
  }
}

/// Placeholder when the unlock kit keeps the app in [AppMode.fake].
class CaroFakeLimitedModeScreen extends StatelessWidget {
  const CaroFakeLimitedModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ứng dụng đang ở chế độ giới hạn.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

Future<bool> executeShorebirdRestartWithFade(BuildContext context) async {
  if (!context.mounted) {
    return false;
  }
  final NavigatorState navigator = Navigator.of(context);
  unawaited(
    navigator.push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF070714)),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 420));
  if (kIsWeb) {
    return true;
  }
  Restart.restartApp();
  return true;
}
