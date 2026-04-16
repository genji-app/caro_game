import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pending toast data to show after navigation/MaterialApp rebuild
class PendingToast {
  final String message;
  final String? title;
  final bool isError;

  const PendingToast({required this.message, this.title, this.isError = true});
}

/// Provider to hold pending toast that should be shown after MaterialApp rebuild
/// Used when we need to show toast but the current MaterialApp will be replaced
/// (e.g., when user is kicked and redirected to login page)
final pendingToastProvider = StateProvider<PendingToast?>((ref) => null);
