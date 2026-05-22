/// Sun Sports — public API for embedding the Sun Sports experience inside
/// another Flutter application.
///
/// Quick start:
///
/// ```dart
/// import 'package:flutter/widgets.dart';
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
/// import 'package:sun_sports/sun_sports.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final overrides = await SunSports.init();
///   runApp(ProviderScope(
///     overrides: overrides,
///     child: const SunSportsApp(),
///   ));
/// }
/// ```
library sun_sports;

export 'app.dart' show App;
export 'sun_sports_init.dart';
export 'sun_sports_root.dart';
