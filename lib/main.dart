import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/core/services/system_ui/system_ui_provider.dart';
import 'package:co_caro_flame/s88/core/services/system_ui/system_ui_service.dart';
import 'package:co_caro_flame/s88/shared/widgets/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:unlock_shorebird_kit/unlock_shorebird_kit.dart';
import 'core/app_settings.dart';
import 'core/audio_service.dart';
import 'core/restart_scope.dart';
import 'core/text_app_style.dart';
import 'screens/default_splash_screen.dart';
import 'screens/fake_mode_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  WidgetsFlutterBinding.ensureInitialized();

  final systemUi = SystemUiService();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set system UI overlay style early to prevent white screen flash
  systemUi.setSplashSystemUIOverlayStyle();

  await rive.RiveNative.init();

  // Initialize SportStorage before app runs so sync methods work
  await SportStorage.instance.init();

  // Load brand config trước runApp() để SplashScreen có cdnImages ngay từ frame đầu tiên.
  await SbLogin.loadBrandConfigOnly().catchError((_) {});
  runApp(
    ProviderScope(
      overrides: [systemUiProvider.overrideWithValue(systemUi)],
      child: const CaroApp(),
    ),
  );
}

class CaroApp extends StatefulWidget {
  const CaroApp({super.key});

  @override
  State<CaroApp> createState() => _CaroAppState();
}

class _CaroAppState extends State<CaroApp> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartScope(
      child: MaterialApp(
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
          bettingScreenBuilder: () => const S88SplashScreen(),
          fakeScreenBuilder: () => const SplashScreen(),
          executeRestartWithFade: RestartScope.executeRestartApp,
          splashScreenBuilder: () => const DefaultSplashScreen(),
        ),
      ),
    );
  }
}
