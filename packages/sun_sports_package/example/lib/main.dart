// Example host: how a host Flutter app embeds Sun Sports.
//
// Run with:
//   flutter run --dart-define=APP_ENV=staging
//   flutter run --dart-define=APP_ENV=prod
//
// If you forget --dart-define, the package silently defaults to staging.
// See README.md → "Environment variables" for the full story.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/sun_sports.dart';
// ignore: implementation_imports
import 'package:sun_sports/core/env/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await SunSports.init();

  // Sanity check — confirm APP_ENV propagated from host's --dart-define
  // into the package. Remove for production builds.
  debugPrint('SunSports starting as: ${AppEnv.current.name}');

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const SunSportsExampleHost(),
    ),
  );
}

/// Minimal host. Replace this with your real host app's wrapping (theme,
/// navigation shell, analytics, etc.). Sun Sports lives inside SunSportsApp.
class SunSportsExampleHost extends StatelessWidget {
  const SunSportsExampleHost({super.key});

  @override
  Widget build(BuildContext context) => const SunSportsApp();
}
