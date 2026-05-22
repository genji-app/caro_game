import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage parlay overlay visibility state (desktop/tablet)
///
/// This is a simple UI state provider.
/// For parlay data, use parlayStateProvider from parlay_state_provider.dart
final parlayOverlayVisibleProvider = StateProvider<bool>((ref) => false);
