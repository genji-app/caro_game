import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:rive/rive.dart' as rive;
import 'package:co_caro_flame/s88/core/providers/platform_ui_provider.dart';
import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await rive.RiveNative.init();

  // Initialize SportStorage before app runs so sync methods work
  await SportStorage.instance.init();

  // Load brand config trước runApp() để SplashScreen có cdnImages ngay từ frame đầu tiên.
  await SbLogin.loadBrandConfigOnly().catchError((_) {});

  final platformUiController = createPlatformUiController();
  // platformUiController.apply(const PlatformUiConfig.systemDefault());
  // platformUiController.apply(const PlatformUiConfig.systemDefault());

  runApp(
    ProviderScope(
      overrides: [
        platformUiControllerProvider.overrideWith(
          (ref) => platformUiController,
        ),
      ],
      child: const App(),
    ),
  );
}
