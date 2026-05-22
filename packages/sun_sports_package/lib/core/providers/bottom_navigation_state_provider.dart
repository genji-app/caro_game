import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider để quản lý trạng thái collapsed/expanded của bottom navigation
final bottomNavigationStateProvider =
    StateNotifierProvider<BottomNavigationStateNotifier, BottomNavigationState>(
      (ref) => BottomNavigationStateNotifier(),
    );

class BottomNavigationState {
  final bool isCollapsed;
  final bool isAnimating;

  const BottomNavigationState({
    this.isCollapsed = false,
    this.isAnimating = false,
  });

  BottomNavigationState copyWith({bool? isCollapsed, bool? isAnimating}) {
    return BottomNavigationState(
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

class BottomNavigationStateNotifier
    extends StateNotifier<BottomNavigationState> {
  BottomNavigationStateNotifier() : super(const BottomNavigationState());

  /// Collapse bottom navigation
  void collapse() {
    if (!state.isCollapsed && !state.isAnimating) {
      state = state.copyWith(isCollapsed: true, isAnimating: true);
      // Reset animating state after animation completes
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          state = state.copyWith(isAnimating: false);
        }
      });
    }
  }

  /// Expand bottom navigation
  void expand() {
    if (state.isCollapsed && !state.isAnimating) {
      state = state.copyWith(isCollapsed: false, isAnimating: true);
      // Reset animating state after animation completes
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          state = state.copyWith(isAnimating: false);
        }
      });
    }
  }

  /// Toggle between collapsed and expanded
  void toggle() {
    if (state.isCollapsed) {
      expand();
    } else {
      collapse();
    }
  }
}
