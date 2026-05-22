import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the expanded state of the live chat on mobile
final liveChatExpandedProvider = StateProvider<bool>((ref) => false);

/// Provider to track if live chat is sticky (pinned at top)
final liveChatStickyProvider = StateProvider<bool>((ref) => false);
