// THIS FILE IS AUTO-GENERATED from `lib/main.dart` by
// `convert_to_package.sh`. Do not edit directly — edit `lib/main.dart` in
// the source repo and re-run the convert script.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fullscreen_guard/fullscreen_guard.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sun_sports/core/providers/platform_ui_provider.dart';
import 'package:sun_sports/core/services/auth/sb_login.dart';
import 'package:sun_sports/core/services/storage/sport_storage.dart';

/// Bootstrap helpers for embedding Sun Sports as a package.
///
/// Call [SunSports.init] before [runApp] in the host and pass the returned
/// overrides into the host's [ProviderScope]. The host owns the root
/// [ProviderScope] — this package no longer creates its own.
class SunSports {
  SunSports._();

  /// Initializes Sun Sports runtime dependencies. The body below is
  /// extracted from `void main()` of the source app's `lib/main.dart`,
  /// with `WidgetsFlutterBinding.ensureInitialized()` removed (host calls
  /// it) and `runApp(ProviderScope(...))` replaced by returning the
  /// overrides list.
  static Future<List<Override>> init() async {
    try {
      await rive.RiveNative.init();
    } catch (e) {
      debugPrint('[init] Rive error: ${e.toString()}');
    }
    // Initialize SportStorage before app runs so sync methods work
    await SportStorage.instance.init().catchError((_){});

    // Load brand config trước runApp() để SplashScreen có cdnImages ngay từ frame đầu tiên.
    await SbLogin.loadBrandConfigOnly().catchError((_) {});

    final platformUiController = createPlatformUiController();
    // platformUiController.apply(const PlatformUiConfig.systemDefault());
    // platformUiController.apply(const PlatformUiConfig.systemDefault());

    return <Override>[
          platformUiControllerProvider.overrideWith(
            (ref) => platformUiController,
          ),
        ];
  }
}
