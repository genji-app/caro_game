import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/core/services/system_ui/system_ui.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final systemUi = SystemUiService();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
      child: const App(),
    ),
  );
}
