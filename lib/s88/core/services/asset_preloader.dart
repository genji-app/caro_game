// import 'package:flutter/material.dart';
// import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_images.dart';

// /// Service để preload assets khi app khởi động để tránh delay khi hiển thị
// ///
// /// OPTIMIZATION: Chỉ preload những assets thực sự cần thiết cho first render
// /// Các assets khác sẽ được lazy load khi scroll/navigate
// class AssetPreloader {
//   /// Preload ONLY critical assets cho sidebar (chỉ những icons hiển thị ngay)
//   /// Các assets khác sẽ được lazy load khi scroll
//   static Future<void> preloadSidebarAssets(BuildContext context) async {
//     // KHÔNG block render - chạy fire-and-forget
//     _preloadSidebarAssetsInBackground(context);
//   }

//   /// Background preloading - không block UI
//   static void _preloadSidebarAssetsInBackground(BuildContext context) {
//     // Chỉ preload 5-7 icons quan trọng nhất (hiển thị trong viewport đầu tiên)
//     final criticalSvgPaths = [
//       AppIcons.iconHome,
//       AppIcons.iconHomeSelected,
//       AppIcons.liveDot,
//       AppIcons.iconSoccer,
//       AppIcons.iconSoccerSelected,
//       // Không preload hết tất cả - chỉ những gì thực sự cần
//     ];

//     // Preload TẤT CẢ tab button images để tránh delay khi switch
//     final criticalImagePaths = [
//       AppImages.sportcasinotrueactivefalse,
//       AppImages.sportcasinotrueactivetrue,
//       AppImages.sportcasinofalseactivefalse,
//       AppImages.sportcasinofalseactivetrue,
//     ];

//     // Load trong background, không chờ kết quả
//     Future<void>.microtask(() async {
//       try {
//         final futures = <Future<void>>[];

//         for (final path in criticalSvgPaths) {
//           futures.add(
//             ImageHelper.precacheSVG(context, path).catchError((_) {}),
//           );
//         }

//         for (final path in criticalImagePaths) {
//           futures.add(
//             ImageHelper.precacheAssetImage(context, path).catchError((_) {}),
//           );
//         }

//         await Future.wait(futures);

//         // Sau khi load xong critical assets, load tiếp các assets khác
//         _preloadRemainingAssets(context);
//       } catch (e) {
//         // Ignore errors
//       }
//     });
//   }

//   /// Preload các assets còn lại sau khi critical assets đã load xong
//   static void _preloadRemainingAssets(BuildContext context) {
//     Future<void>.microtask(() async {
//       try {
//         final remainingSvgPaths = [
//           AppIcons.iconTimerSelected,
//           AppIcons.iconComming,
//           AppIcons.iconBet1Selected,
//           AppIcons.iconMyOrder,
//           AppIcons.iconTrophySelected,
//           AppIcons.iconTrophy,
//           AppIcons.iconEventSelected,
//           AppIcons.iconEvent,
//           AppIcons.iconTennisSelected,
//           AppIcons.iconTennis,
//           AppIcons.iconBasketballSelected,
//           AppIcons.iconBasketball,
//           AppIcons.iconTableTennisSelected,
//           AppIcons.iconTableTennis,
//           AppIcons.iconVolleyballSelected,
//           AppIcons.iconVolleyball,
//           AppIcons.iconDownloadApp,
//           AppIcons.hr,
//           AppIcons.iconChatSelected,
//           AppIcons.iconLivechat,
//           AppIcons.iconTransferSelected,
//           AppIcons.arrowsOppositeDirection,
//           AppIcons.iconEmojiSelected,
//           AppIcons.iconTrollSport,
//           AppIcons.iconNewsSelected,
//           AppIcons.iconRemark,
//           AppIcons.iconSupportSelected,
//           AppIcons.iconSupport,
//           AppIcons.iconSettingSelected,
//           AppIcons.iconSetting,
//           AppIcons.menuSelected,
//           AppIcons.menuSelectedShadow,
//         ];

//         final remainingImagePaths = [
//           // Tab button images đã được preload trong critical assets
//           AppImages.logoBundesliga,
//           AppImages.logoChampion,
//           AppImages.logoLaliga,
//           AppImages.logoLeague1,
//           AppImages.logoPremileague,
//           AppImages.logoSeriA,
//         ];

//         final futures = <Future<void>>[];

//         for (final path in remainingSvgPaths) {
//           futures.add(
//             ImageHelper.precacheSVG(context, path).catchError((_) {}),
//           );
//         }

//         for (final path in remainingImagePaths) {
//           futures.add(
//             ImageHelper.precacheAssetImage(context, path).catchError((_) {}),
//           );
//         }

//         await Future.wait(futures);
//       } catch (e) {
//         // Ignore errors
//       }
//     });
//   }

//   /// Preload assets cho mobile sport screen - OPTIMIZED
//   /// Chỉ preload critical assets, các assets khác load khi scroll
//   static Future<void> preloadMobileSportAssets(BuildContext context) async {
//     // KHÔNG block render - chạy fire-and-forget
//     _preloadMobileSportAssetsInBackground(context);
//   }

//   /// Background preloading cho mobile sport screen
//   static void _preloadMobileSportAssetsInBackground(BuildContext context) {
//     // Chỉ preload những icons/images hiển thị trong viewport đầu tiên
//     final criticalSvgPaths = [
//       AppIcons.liveDot,
//       AppIcons.tabActive,
//       AppIcons.iconSoccer,
//       AppIcons.iconHot,
//       AppIcons.btnArrowLeft,
//       AppIcons.btnArrowRight,
//     ];

//     final criticalImagePaths = [
//       AppImages.backgroundHotTablet,
//       AppImages.logoChampion,
//     ];

//     // Load trong background, không chờ kết quả
//     Future<void>.microtask(() async {
//       try {
//         final futures = <Future<void>>[];

//         for (final path in criticalSvgPaths) {
//           futures.add(
//             ImageHelper.precacheSVG(context, path).catchError((_) {}),
//           );
//         }

//         for (final path in criticalImagePaths) {
//           futures.add(
//             ImageHelper.precacheAssetImage(context, path).catchError((_) {}),
//           );
//         }

//         await Future.wait(futures);

//         // Sau khi load xong critical assets, load tiếp các assets khác
//         _preloadRemainingMobileSportAssets(context);
//       } catch (e) {
//         // Ignore errors
//       }
//     });
//   }

//   /// Preload các mobile sport assets còn lại
//   static void _preloadRemainingMobileSportAssets(BuildContext context) {
//     Future<void>.microtask(() async {
//       try {
//         final remainingSvgPaths = [
//           AppIcons.barcelona,
//           AppIcons.wol,
//           AppIcons.iconTennis,
//           AppIcons.iconBasketball,
//           AppIcons.iconTableTennis,
//           AppIcons.iconVolleyball,
//           AppIcons.logoBayer,
//           AppIcons.psg,
//           AppIcons.chevronUp,
//           AppIcons.hr,
//           AppIcons.bottomNavSelected,
//           AppIcons.bottomNavGlow,
//         ];

//         final remainingImagePaths = [
//           AppImages.logoPremileague,
//           AppImages.logoLaliga,
//           AppImages.logoSeriA,
//           AppImages.logoBundesliga,
//           AppImages.logoLeague1,
//         ];

//         final futures = <Future<void>>[];

//         for (final path in remainingSvgPaths) {
//           futures.add(
//             ImageHelper.precacheSVG(context, path).catchError((_) {}),
//           );
//         }

//         for (final path in remainingImagePaths) {
//           futures.add(
//             ImageHelper.precacheAssetImage(context, path).catchError((_) {}),
//           );
//         }

//         await Future.wait(futures);
//       } catch (e) {
//         // Ignore errors
//       }
//     });
//   }
// }
