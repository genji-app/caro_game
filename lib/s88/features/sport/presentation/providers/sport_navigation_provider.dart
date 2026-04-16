import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider để manage bottom navigation selected index
/// Đồng bộ giữa tablet và mobile khi responsive
class SportNavigationNotifier extends StateNotifier<int> {
  SportNavigationNotifier() : super(3); // Default to "Thể thao" (index 3)

  void selectItem(int index) {
    state = index;
  }
}

/// Provider instance
final sportNavigationProvider =
    StateNotifierProvider<SportNavigationNotifier, int>(
      (ref) => SportNavigationNotifier(),
    );
