import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_mobile_v2_provider.dart';
import 'package:co_caro_flame/s88/features/bet_detail/domain/providers/bet_detail_provider.dart';
import 'package:co_caro_flame/s88/features/sport_detail/domain/providers/sport_detail_tab_provider.dart';
import 'package:co_caro_flame/s88/features/sport_detail/presentation/mobile/widgets/sport_detail_mobile_matches_section.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/navigation_enums.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/navigation_enums.dart'
    show MainContentType, MainContentTypeExtension;

/// StateNotifier để quản lý content hiện tại đang hiển thị
class MainContentNotifier extends StateNotifier<MainContentType> {
  final Ref _ref;

  MainContentNotifier(this._ref) : super(MainContentType.home);

  /// Switch sang content khác
  void switchTo(MainContentType type) {
    if (state != type) {
      final previousState = state;

      // Khi vào tournaments/leagueDetail (mobile): lưu content trước để nút back quay lại
      if (type == MainContentType.tournaments ||
          type == MainContentType.leagueDetail) {
        _ref.read(previousContentProvider.notifier).state = previousState;
      }

      state = type;

      // Clear bet detail state when leaving bet detail screen
      if (previousState == MainContentType.betDetail) {
        _clearBetDetailState();
      }

      // Clear sport detail tab state when leaving sport detail to non-bet-detail screens
      // (keep tab state when going to bet detail so user can return to same tab)
      if (previousState == MainContentType.sportDetail &&
          type != MainContentType.betDetail) {
        _clearSportDetailTabState();
      }
    }
  }

  /// Clear bet detail providers when leaving bet detail
  void _clearBetDetailState() {
    // Reset selected event to hide tracker in ShellDesktopRightSidebar
    _ref.read(selectedEventProvider.notifier).state = null;
    _ref.read(selectedLeagueProvider.notifier).state = null;
    // Clear bet detail providers to unsubscribe from websocket
    // _ref.read(betDetailProvider.notifier).clear();
    // _ref.read(betDetailMobileV2Provider.notifier).clear();
  }

  /// Clear sport detail tab state when leaving sport detail
  void _clearSportDetailTabState() {
    _ref.read(sportDetailTabProvider.notifier).state =
        SportDetailFilterType.today;
  }

  /// Switch sang home
  void goToHome() => switchTo(MainContentType.home);

  /// Switch sang sport
  void goToSport() => switchTo(MainContentType.sport);

  /// Switch sang tournaments
  void goToTournaments() => switchTo(MainContentType.tournaments);

  /// Switch sang live
  void goToLive() => switchTo(MainContentType.live);

  /// Switch sang upcoming
  void goToUpcoming() => switchTo(MainContentType.upcoming);

  /// Switch sang sun 24/7
  void goToSun247() => switchTo(MainContentType.sun247);

  /// Switch sang casino
  void goToCasino() => switchTo(MainContentType.casino);

  /// Switch sang bet detail
  /// Saves the current state for back navigation
  void goToBetDetail() {
    // Save current state before navigating to bet detail
    _ref.read(previousBetDetailContentProvider.notifier).state = state;
    switchTo(MainContentType.betDetail);
  }

  /// Go back from bet detail to the previous page
  /// Returns to sport page if came from sport, or sport detail if came from sport detail
  void goBackFromBetDetail() {
    final previousState = _ref.read(previousBetDetailContentProvider);
    if (previousState == MainContentType.sportDetail) {
      switchTo(MainContentType.sportDetail);
    } else {
      // Default to sport page
      switchTo(MainContentType.sport);
    }
    // Clear the previous state
    _ref.read(previousBetDetailContentProvider.notifier).state = null;
  }

  /// Switch sang sport detail
  void goToSportDetail() => switchTo(MainContentType.sportDetail);

  /// Switch sang league detail
  void goToLeagueDetail() => switchTo(MainContentType.leagueDetail);
}

/// Provider instance để sử dụng trong app
final mainContentProvider =
    StateNotifierProvider<MainContentNotifier, MainContentType>(
      (ref) => MainContentNotifier(ref),
    );

/// Provider to track the previous content type before navigating to sport detail
/// This allows proper back navigation (e.g., from sport detail back to home or sport)
final previousContentProvider = StateProvider<MainContentType?>((ref) => null);

/// Provider to track the previous content type before navigating to bet detail
/// This allows proper back navigation (e.g., from bet detail back to sport or sport detail)
final previousBetDetailContentProvider = StateProvider<MainContentType?>(
  (ref) => null,
);
