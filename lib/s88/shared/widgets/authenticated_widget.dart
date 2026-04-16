import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';

/// A wrapper widget that only shows its child when user is authenticated.
///
/// This widget checks if the user has valid tokens saved locally.
/// If not authenticated (login/register screen), it hides the child completely.
///
/// Usage:
/// ```dart
/// AuthenticatedWidget(
///   child: SportLiveChat(),
/// )
/// ```
class AuthenticatedWidget extends ConsumerWidget {
  /// The widget to show when user is authenticated
  final Widget child;

  /// Optional widget to show when user is not authenticated
  /// Defaults to SizedBox.shrink() (hidden)
  final Widget? fallback;

  const AuthenticatedWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if user is authenticated (has valid token saved locally)
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Show child if authenticated, otherwise show fallback (or hide)
    return isAuthenticated ? child : (fallback ?? const SizedBox.shrink());
  }
}
