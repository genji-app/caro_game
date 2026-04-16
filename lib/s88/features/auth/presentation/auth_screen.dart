import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/tablet/screens/auth_tablet_screen.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_layout.dart';

/// Main auth screen with responsive layout
/// Currently only implements desktop/tablet, mobile will be added later
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const ResponsiveLayout(
    mobile: AuthDesktopScreen(), // TODO: Create mobile version
    tablet: AuthTabletScreen(),
    desktop: AuthDesktopScreen(),
  );
}
