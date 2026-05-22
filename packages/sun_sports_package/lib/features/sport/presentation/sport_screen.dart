import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';
import 'package:sun_sports/features/sport/presentation/desktop/screens/sport_desktop_screen.dart';
import 'package:sun_sports/features/sport/presentation/tablet/screens/sport_tablet_screen.dart';
import 'package:sun_sports/features/sport/presentation/mobile/screens/sport_mobile_screen.dart';

/// Sport Screen - V2 Version
///
/// Uses EventsV2Provider for data fetching.
/// The V2 provider auto-fetches when created, so no manual initialization needed.
class SportScreen extends ConsumerWidget {
  const SportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const ResponsiveLayout(
    mobile: SportMobileScreen(),
    tablet: SportTabletScreen(),
    desktop: SportDesktopScreen(),
  );
}
