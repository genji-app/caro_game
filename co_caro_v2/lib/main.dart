import 'dart:async';

import 'package:co_caro_flame/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:unlock_shorebird_kit/unlock_shorebird_kit.dart';
import 'core/text_app_style.dart';
import 'screens/default_splash_screen.dart';
import 'screens/fake_mode_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TextAppStyle.precacheMultilingualFonts();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CaroApp());
}

class CaroApp extends StatelessWidget {
  const CaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cờ Caro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4fc3f7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF070714),
      ),
      home: SplashModeScreen(
        bettingScreenBuilder: () => const FakeModeScreen(),
        fakeScreenBuilder: () => const SplashScreen(),
        executeRestartWithFade: _executeRestartWithFade,
        splashScreenBuilder: () => const DefaultSplashScreen(),
      ),
    );
  }
}

Future<bool> _executeRestartWithFade(BuildContext context) async {
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
