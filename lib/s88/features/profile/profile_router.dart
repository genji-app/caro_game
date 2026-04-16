import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/betting/betting.dart';
import 'package:co_caro_flame/s88/features/phone_verification/phone_verification.dart';
import 'package:co_caro_flame/s88/features/preferences/preferences.dart';
import 'package:co_caro_flame/s88/features/profile/personal/profile_personal_screen.dart';
import 'package:co_caro_flame/s88/features/profile/profile_screen.dart';
import 'package:co_caro_flame/s88/features/security/security.dart';
import 'package:co_caro_flame/s88/features/transaction/transaction.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';

class ProfileRouter {
  static const String root = '/';
  static const String security = '/security';
  static const String settings = '/settings';
  static const String bettingHistory = '/betting-history';
  static const String transactionHistory = '/transaction-history';
  static const String phoneVerification = '/phone-verification';
  static const String personal = '/personal';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case root:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: routeSettings,
        );
      case security:
        return MaterialPageRoute(
          builder: (_) => const SecurityScreen(),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: routeSettings,
        );
      case bettingHistory:
        return MaterialPageRoute(
          builder: (_) => const BettingHistoryScreen(),
          settings: routeSettings,
        );
      case transactionHistory:
        return MaterialPageRoute(
          builder: (_) => const TransactionHistoryScreen(),
          settings: routeSettings,
        );
      case phoneVerification:
        return MaterialPageRoute(
          builder: (_) => const PhoneVerificationScreen(),
          settings: routeSettings,
        );
      case personal:
        return MaterialPageRoute(
          builder: (_) => const ProfilePersonalScreen(),
          settings: routeSettings,
        );
      default:
        return null;
    }
  }
}

/// Domain-specific navigation helpers for the Profile module.
extension ProfileNavigatorX on ProfileNavigator {
  Future<void> pushToSecurity() => pushNamed(ProfileRouter.security);

  Future<void> pushToSettings() => pushNamed(ProfileRouter.settings);

  Future<void> pushToSettingsAndRemoveUntil() async {
    if (isAtSettings) return;

    return pushNamedAndRemoveUntil(
      ProfileRouter.settings,
      (route) => route.settings.name == ProfileRouter.root,
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
