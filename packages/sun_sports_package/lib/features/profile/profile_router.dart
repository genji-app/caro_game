import 'package:flutter/material.dart';
import 'package:sun_sports/features/betting/betting.dart';
import 'package:sun_sports/features/phone_verification/phone_verification.dart';
import 'package:sun_sports/features/preferences/preferences.dart';
import 'package:sun_sports/features/profile/personal/profile_personal_screen.dart';
import 'package:sun_sports/features/profile/profile_screen.dart';
import 'package:sun_sports/features/security/security.dart';
import 'package:sun_sports/features/transaction/transaction.dart';
import 'package:sun_sports/shared/profile_navigation_system/profile_navigation_system.dart';

class _NoPushAnimationRoute<T> extends MaterialPageRoute<T> {
  _NoPushAnimationRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}

class ProfileRouter {
  static const String root = '/';
  static const String security = '/security';
  static const String settings = '/settings';
  static const String bettingHistory = '/betting-history';
  static const String transactionHistory = '/transaction-history';
  static const String phoneVerification = '/phone-verification';
  static const String personal = '/personal';

  /// Build a route with optional animation control.
  static Route<dynamic> _buildRoute({
    required Widget screen,
    required RouteSettings settings,
    bool animate = true,
  }) {
    if (!animate) {
      return _NoPushAnimationRoute(builder: (_) => screen, settings: settings);
    }
    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    final animate = args?['no_animation'] != true;

    final screen = switch (routeSettings.name) {
      root => const ProfileScreen(),
      security => const SecurityScreen(),
      settings => const SettingsScreen(),
      bettingHistory => const BettingHistoryScreen(),
      transactionHistory => const TransactionHistoryScreen(),
      phoneVerification => const PhoneVerificationScreen(),
      personal => const ProfilePersonalScreen(),
      _ => null,
    };

    if (screen == null) return null;

    return _buildRoute(
      screen: screen,
      settings: routeSettings,
      animate: animate,
    );
  }
}

/// Domain-specific navigation helpers for the Profile module.
extension ProfileNavigatorX on ProfileNavigator {
  Future<void> pushToSecurity() => pushNamed(ProfileRouter.security);

  Future<void> pushToSettings() => pushNamed(ProfileRouter.settings);

  Future<void> pushToSettingsAndRemoveUntil() async {
    if (isAtSettings) return;

    // Capture trạng thái TRƯỚC khi _prepareNavigator() gọi _ensureOpen()
    // Vì sau _ensureOpen(), isVisible đã = true → không còn phân biệt được
    final wasHidden = !isVisible;

    return pushNamedAndRemoveUntil(
      ProfileRouter.settings,
      (route) => route.settings.name == ProfileRouter.root,
      arguments: wasHidden ? const {'no_animation': true} : null,
    );
  }

  Future<void> pushToBettingHistory() =>
      pushNamed(ProfileRouter.bettingHistory);

  Future<void> pushToTransactionHistory() =>
      pushNamed(ProfileRouter.transactionHistory);

  Future<void> pushToPhoneVerification() =>
      pushNamed(ProfileRouter.phoneVerification);

  Future<void> pushToPersonal() => pushNamed(ProfileRouter.personal);

  bool get isAtRoot => isCurrent(ProfileRouter.root);

  bool get isAtSecurity => isCurrent(ProfileRouter.security);

  bool get isAtSettings => isCurrent(ProfileRouter.settings);

  bool get isAtBettingHistory => isCurrent(ProfileRouter.bettingHistory);

  bool get isAtTransactionHistory =>
      isCurrent(ProfileRouter.transactionHistory);

  bool get isAtPhoneVerification => isCurrent(ProfileRouter.phoneVerification);

  bool get isAtPersonal => isCurrent(ProfileRouter.personal);
}
