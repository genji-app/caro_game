import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:co_caro_flame/s88/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';
import 'package:co_caro_flame/s88/shared/layouts/main_shell_layout.dart';

class AppRouter {
  AppRouter._();

  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/',
      name: 'main',
      builder: (BuildContext context, GoRouterState state) =>
          const MainShellLayout(),
    ),
    GoRoute(
      path: '/auth/:showLogin',
      name: 'auth',
      builder: (BuildContext context, GoRouterState state) => AuthDesktopScreen(
        showLogin: state.pathParameters['showLogin'] == 'true',
      ),
    ),
  ];

  static final GoRouter instance = GoRouter(routes: _routes);

  /// Tạo GoRouter với [navigatorKey] để dùng chung key với NetworkManagerListener.
  static GoRouter createInstance(GlobalKey<NavigatorState> navigatorKey) =>
      GoRouter(navigatorKey: navigatorKey, routes: _routes);
}

final goRouterProvider = Provider<GoRouter>((ref) => AppRouter.instance);
