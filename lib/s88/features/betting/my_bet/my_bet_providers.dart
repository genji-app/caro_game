import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/providers.dart';
import 'package:co_caro_flame/s88/features/profile/profile.dart';

import 'my_bet_notifier.dart';
import 'my_bet_overlay/my_bet_overlay.dart';

/// Provider that listens to the active bet count stream from repository
final activeBetCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(myBetRepositoryProvider);
  return repo.activeBetCountStream;
});

/// Provider to manage my bet slip state
final myBetNotifierProvider = NotifierProvider<MyBetNotifier, MyBetState>(
  MyBetNotifier.new,
);

/// Provider to manage parlay overlay visibility state (desktop/tablet)
final myBetOverlayVisibleProvider =
    NotifierProvider<MyBetOverlayNotifier, bool>(
      ProfileAwareMyBetOverlayNotifier.new,
    );

/// A specialized [MyBetOverlayNotifier] that ensures the profile overlay is closed
/// before opening the betting overlay.
class ProfileAwareMyBetOverlayNotifier extends MyBetOverlayNotifier {
  @override
  void open() {
    _closeProfileIfOpen();
    super.open();
  }

  @override
  void toggle() {
    if (!state) {
      _closeProfileIfOpen();
    }
    super.toggle();
  }

  void _closeProfileIfOpen() {
    final profileController = ref.read(profileOverlayControllerProvider);
    if (profileController.isVisible) {
      profileController.close();
    }
  }
}
