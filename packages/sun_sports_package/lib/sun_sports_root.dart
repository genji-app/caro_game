import 'package:flutter/widgets.dart';

import 'app.dart';

/// Public-facing widget that hosts the Sun Sports experience.
///
/// This is a thin alias for [App] with a clearer public name. The host app
/// may use either; prefer [SunSportsApp] when consuming from outside.
class SunSportsApp extends StatelessWidget {
  const SunSportsApp({super.key});

  @override
  Widget build(BuildContext context) => const App();
}
