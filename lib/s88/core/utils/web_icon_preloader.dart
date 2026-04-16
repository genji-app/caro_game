import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

/// Helper để preload icons vào browser memory cache trên web
/// Giúp icons load nhanh hơn từ memory cache thay vì disk cache
///
/// Usage:
/// ```dart
/// // Preload critical icons on app startup
/// await WebIconPreloader.preloadCriticalIcons(context);
/// ```
class WebIconPreloader {
  /// Preload critical icons vào browser memory cache
  ///
  /// Icons sẽ được load vào memory cache, giúp load nhanh hơn (~0-5ms)
  /// thay vì từ disk cache (~5-20ms)
  static Future<void> preloadCriticalIcons(BuildContext context) async {
    if (!kIsWeb) return;

    // Critical icons hiển thị ngay khi app load
    final criticalIcons = [
      AppIcons.iconCurrencyUnit,
      AppIcons.iconHome,
      AppIcons.iconSoccer,
      AppIcons.iconMenu,
      AppIcons.iconBet,
      AppIcons.iconCasino,
      AppIcons.iconHomeSport,
      AppIcons.iconComingSport,
      AppIcons.iconFavoriteSport,
    ];

    await _preloadIcons(context, criticalIcons);
  }

  /// Preload all icons vào browser memory cache
  ///
  /// Warning: Chỉ dùng nếu cần preload tất cả icons
  /// Có thể tốn thời gian và bandwidth
  static Future<void> preloadAllIcons(BuildContext context) async {
    if (!kIsWeb) return;

    // Lấy tất cả icons từ AppIcons
    // Note: Cần update list này khi có icons mới
    final allIcons = [
      AppIcons.iconCurrencyUnit,
      AppIcons.iconHome,
      AppIcons.iconSoccer,
      AppIcons.iconMenu,
      AppIcons.iconBet,
      AppIcons.iconCasino,
      AppIcons.iconBasketballSelected,
      AppIcons.iconBet1Selected,
      AppIcons.iconChatSelected,
      AppIcons.iconEmojiSelected,
      AppIcons.iconFootballSelected,
      AppIcons.iconMenuSelected,
      AppIcons.iconMobileSelected,
      AppIcons.iconNewsSelected,
      AppIcons.iconSettingSelected,
      AppIcons.iconSupportSelected,
      AppIcons.iconTennisSelected,
      AppIcons.iconTimerSelected,
      AppIcons.iconTransferSelected,
      AppIcons.iconHomeSport,
      AppIcons.iconComingSport,
      AppIcons.iconFavoriteSport,

      // Game icons
      AppIcons.icArcade,
      AppIcons.icBling,
      AppIcons.icCard,
      AppIcons.icDice,
      AppIcons.icFish,
      AppIcons.icHome,
      AppIcons.icJackpot,
      AppIcons.icLive,
      AppIcons.icRoulette,
      AppIcons.icSlots,
      AppIcons.icFootball,
      AppIcons.icArcadeYellow,
      AppIcons.icBlingYellow,
      AppIcons.icCardYellow,
      AppIcons.icDiceYellow,
      AppIcons.icFishYellow,
      AppIcons.icHomeYellow,
      AppIcons.icJackpotYellow,
      AppIcons.icLiveYellow,
      AppIcons.icRouletteYellow,
      AppIcons.icSlotsYellow,
      AppIcons.icFootballYellow,
      AppIcons.icSunwin,
      AppIcons.icSunwinBw,
    ];

    await _preloadIcons(context, allIcons);
  }

  /// Preload custom list of icons
  static Future<void> preloadIcons(
    BuildContext context,
    List<String> iconUrls,
  ) async {
    if (!kIsWeb) return;
    await _preloadIcons(context, iconUrls);
  }

  /// Internal method để preload icons
  static Future<void> _preloadIcons(
    BuildContext context,
    List<String> iconUrls,
  ) async {
    if (!kIsWeb || iconUrls.isEmpty) return;

    try {
      // Preload icons in parallel (không block UI)
      final futures = iconUrls.map((url) async {
        try {
          // Check if SVG or image
          final isSvg = url.toLowerCase().endsWith('.svg');

          if (isSvg) {
            await ImageHelper.precacheSVG(context, url);
          } else {
            await ImageHelper.precacheNetworkImage(context, url);
          }
        } catch (e) {
          // Ignore individual icon errors
        }
      });

      await Future.wait(futures);
    } catch (e) {
      // Ignore errors
    }
  }
}
