import 'dart:async';

import 'package:co_caro_flame/core/restart_scope.dart';
import 'package:co_caro_flame/screens/default_splash_screen.dart';
import 'package:co_caro_flame/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/app.dart';
import 'package:sun_sports/sun_sports_init.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:unlock_shorebird_kit/screens/splash_mode_screen.dart';
import 'core/app_settings.dart';
import 'core/audio_service.dart';
import 'core/text_app_style.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4fc3f7),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF070714),
  );
}

Future<void> _bootstrap() async {
  await AppSettings().load();
  await AudioService().init();
  TextAppStyle.precacheMultilingualFonts();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

void main() async {
  // QUAN TRỌNG: ensureInitialized() PHẢI chạy ĐẦU TIÊN, trước bất kỳ API nào
  // dùng ServicesBinding (SystemChrome, HapticFeedback, SharedPreferences...).
  // Không được gọi SystemChrome trước dòng này — sẽ crash
  // "ServicesBinding has not yet been initialized".
  WidgetsFlutterBinding.ensureInitialized();

  // QUAN TRỌNG: Initialize TerminateRestart TRƯỚC khi runApp. Nếu không,
  // restartApp(terminate: true) sẽ fail silently trên iOS → fallback widget
  // remount → Shorebird patch không apply → infinite loop.
  //
  // Cấu hình đi kèm (bắt buộc):
  // - ios/Runner/Info.plist phải có CFBundleURLTypes với URL scheme =
  //   $(PRODUCT_BUNDLE_IDENTIFIER) để iOS reopen app sau khi plugin exit().
  TerminateRestart.instance.initialize();

  await _bootstrap();
  final overrides = await SunSports.init();
  runApp(
    // khi build patch thì dùng code dưới này
    ProviderScope(
      overrides: overrides,
      child: RestartScope(
        child: MaterialApp(
          title: 'Cờ Caro',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: SplashModeScreen(
            bettingScreenBuilder: () => const App(),
            fakeScreenBuilder: () => const CaroApp(),
            executeRestartWithFade: RestartScope.executeRestartApp,
            splashScreenBuilder: () => const DefaultSplashScreen(),
          ),
        ),
      ),
    ),
    // khi build release thì dùng code dưới này
    // RestartScope(
    //   child: MaterialApp(
    //     title: 'Cờ Caro',
    //     debugShowCheckedModeBanner: false,
    //     theme: buildAppTheme(),
    //     home: SplashModeScreen(
    //       bettingScreenBuilder: () => const CaroApp(),
    //       fakeScreenBuilder: () => const CaroApp(),
    //       executeRestartWithFade: RestartScope.executeRestartApp,
    //       splashScreenBuilder: () => const DefaultSplashScreen(),
    //     ),
    //   ),
    // ),
  );
}

/// Game shell after unlock flow; uses the root [MaterialApp] from [main].
class CaroApp extends StatefulWidget {
  const CaroApp({super.key});

  @override
  State<CaroApp> createState() => _CaroAppState();
}

class _CaroAppState extends State<CaroApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (kDebugMode) {
      debugPrint('🧹 [App] Disposing subscriptions...');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
