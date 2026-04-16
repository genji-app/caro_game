import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/search/presentations/desktop/search_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/search/presentations/mobile/search_mobile_screen.dart';
import 'package:co_caro_flame/s88/features/search/presentations/tablet/search_tablet_screen.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_layout.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const ResponsiveLayout(
    mobile: SearchMobileScreen(),
    tablet: SearchTabletScreen(),
    desktop: SearchDesktopScreen(),
  );
}
