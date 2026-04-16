import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';

/// Auth screen for tablet - reuses desktop layout
class AuthTabletScreen extends StatelessWidget {
  const AuthTabletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AuthDesktopScreen();
  }
}
