import 'dart:async';

// import 'package:co_caro_flame/s88/core/router/app_router.dart';
// import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter.dart';
// import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter_provider.dart';
// import 'package:co_caro_flame/s88/core/services/auth/sb_login.dart';
// import 'package:co_caro_flame/s88/core/services/datasources/events_v2_remote_datasource.dart';
// import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
// import 'package:co_caro_flame/s88/core/services/providers/app_init_provider.dart';
// import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
// import 'package:co_caro_flame/s88/core/services/providers/league_provider.dart' hide sportStorageProvider;
// import 'package:co_caro_flame/s88/core/services/providers/reconnect_coordinator.dart';
// import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
// import 'package:co_caro_flame/s88/core/services/system_ui/system_ui_provider.dart';
// import 'package:co_caro_flame/s88/core/services/system_ui/system_ui_service.dart';
// import 'package:co_caro_flame/s88/core/utils/audio_manager.dart';
// import 'package:co_caro_flame/s88/core/utils/extensions/cached_manager.dart';
// import 'package:co_caro_flame/s88/core/utils/network_manager_listener.dart';
// import 'package:co_caro_flame/s88/core/utils/styles/app_assets_data.dart';
// import 'package:co_caro_flame/s88/core/utils/unified_assets_preloader.dart';
// import 'package:co_caro_flame/s88/core/utils/web_icon_preloader.dart';
// import 'package:co_caro_flame/s88/features/auth/presentation/desktop/screens/auth_desktop_screen.dart';
// import 'package:co_caro_flame/s88/features/game/game_providers.dart';
// import 'package:co_caro_flame/s88/features/landing/presentation/landing_page.dart';
// import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_storage.dart';
// import 'package:co_caro_flame/s88/features/search/data/storage/casino_recent_games_storage.dart';
// import 'package:co_caro_flame/s88/features/search/data/storage/search_recent_storage.dart';
// import 'package:co_caro_flame/s88/shared/widgets/orientation/app_orientation_orchestrator.dart';
// import 'package:co_caro_flame/s88/shared/widgets/splash/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:rive/rive.dart' as rive;
// import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:terminate_restart/terminate_restart.dart';
import 'package:unlock_shorebird_kit/unlock_shorebird_kit.dart';
import 'core/app_settings.dart';
import 'core/audio_service.dart';
import 'core/restart_scope.dart';
import 'core/text_app_style.dart';
import 'screens/default_splash_screen.dart';
import 'screens/splash_screen.dart';

Future<void> _bootstrap() async {
  await AppSettings().load();
  await AudioService().init();
  TextAppStyle.precacheMultilingualFonts();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

void main() async {
  // QUAN TRỌNG: ensureInitialized() PHẢI chạy ĐẦU TIÊN, trước bất kỳ API nào
  // dùng ServicesBinding (SystemChrome, HapticFeedback, SharedPreferences...).
  // Không được gọi SystemChrome trước dòng này — sẽ crash
  // "ServicesBinding has not yet been initialized".
  WidgetsFlutterBinding.ensureInitialized();

  // QUAN TRỌNG: Initialize TerminateRestart TRƯỚC khi runApp. Nếu không,
  // restartApp(terminate: true) sẽ fail silently trên iOS → fallback widget
  // remount → Shorebird patch không apply → infinite loop.
  //
  // Cấu hình đi kèm (bắt buộc):
  // - ios/Runner/Info.plist phải có CFBundleURLTypes với URL scheme =
  //   $(PRODUCT_BUNDLE_IDENTIFIER) để iOS reopen app sau khi plugin exit().
  TerminateRestart.instance.initialize();
  //
  // final systemUi = SystemUiService();
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //
  // // Set system UI overlay style early to prevent white screen flash
  // systemUi.setSplashSystemUIOverlayStyle();
  //
  // await rive.RiveNative.init();
  //
  // // Initialize SportStorage before app runs so sync methods work
  // await SportStorage.instance.init();
  //
  // // Load brand config trước runApp() để SplashScreen có cdnImages ngay từ frame đầu tiên.
  // await SbLogin.loadBrandConfigOnly().catchError((_) {});

  await _bootstrap();

  runApp(
    const CaroApp()
    // ProviderScope(
    //   overrides: [systemUiProvider.overrideWithValue(systemUi)],
    //   child: const CaroApp(),
    // ),
  );
}

class CaroApp extends StatefulWidget {
  const CaroApp({super.key});

  @override
  State<CaroApp> createState() => _CaroAppState();
}

class _CaroAppState extends State<CaroApp> with WidgetsBindingObserver {
  // StreamSubscription<List<LeagueData>>? _leaguesSubscription;
  // StreamSubscription<socket.ConnectionStateEvent>? _connectionSubscription;
  // StreamSubscription<socket.ProcessorMetrics>? _metricsSubscription;
  // StreamSubscription<String>? _forceLogoutSubscription;
  //
  // bool _isInitialized = false;
  //
  // /// Navigator key for the logged-in router so [NetworkManagerListener] can show
  // /// dialogs using a context that is a descendant of the Navigator.
  // final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  // GoRouter? _router;
  //
  // GoRouter get _goRouter => _router ??= AppRouter.createInstance(_navigatorKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Schedule init after first frame to avoid provider issues
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!_isInitialized) {
    //     _isInitialized = true;
    //     _initApp();
    //   }
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ═══════════════════════════════════════════════════════════════════════
    // CRITICAL: Cancel ALL subscriptions to prevent memory leaks
    // ═══════════════════════════════════════════════════════════════════════
    if (kDebugMode) {
      debugPrint('🧹 [App] Disposing subscriptions...');
    }

    // _leaguesSubscription?.cancel();
    // _connectionSubscription?.cancel();
    // _metricsSubscription?.cancel();
    // _forceLogoutSubscription?.cancel();
    //
    // _leaguesSubscription = null;
    // _connectionSubscription = null;
    // _metricsSubscription = null;
    // _forceLogoutSubscription = null;

    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   AudioManager.instance.onAppLifecycleChanged(state);
  // }

  @override
  Widget build(BuildContext context) {
    // final showSplash = ref.watch(splashProvider);
    //
    // // Khi splash screen chạy xong và biến mất thì hãy setDefaultSystemUIOverlayStyle
    // ref.listen<bool>(splashProvider, (previous, next) {
    //   if (previous == true && next == false) {
    //     ref.read(systemUiProvider).setDefaultSystemUIOverlayStyle();
    //   }
    // });
    //
    // // Check auth state để hiển thị landing page cho web
    // final isAuthenticated = ref.watch(isAuthenticatedProvider);
    // final appInitState = ref.watch(appInitProvider);
    //
    // // Theme với background color đen để tránh màn hình trắng
    // final darkTheme = ThemeData.dark().copyWith(
    //   scaffoldBackgroundColor: const Color(0xFF11100F),
    // );
    // final lightTheme = ThemeData.light().copyWith(
    //   scaffoldBackgroundColor: const Color(0xFF11100F),
    // );
    //
    // // Common global wrapper
    // Widget buildBaseApp(Widget child) {
    //   return AppOrientationOrchestrator(
    //     child: child,
    //   );
    // }
    //
    // // Splash: không check internet
    // if (showSplash) {
    //   return RestartScope(
    //     child: MaterialApp(
    //       title: 'Cờ Caro',
    //       debugShowCheckedModeBanner: false,
    //       theme: ThemeData(
    //         colorScheme: ColorScheme.fromSeed(
    //           seedColor: const Color(0xFF4fc3f7),
    //           brightness: Brightness.dark,
    //         ),
    //         useMaterial3: true,
    //         scaffoldBackgroundColor: const Color(0xFF070714),
    //       ),
    //       home: SplashModeScreen(
    //         bettingScreenBuilder: () =>   buildBaseApp(
    //           MaterialApp(
    //             debugShowCheckedModeBanner: false,
    //             theme: lightTheme,
    //             darkTheme: darkTheme,
    //             home: const S88SplashScreen(),
    //           ),
    //         ),
    //         fakeScreenBuilder: () => const SplashScreen(),
    //         executeRestartWithFade: RestartScope.executeRestartApp,
    //         splashScreenBuilder: () => const DefaultSplashScreen(),
    //       ),
    //     ),
    //   );
    // }
    //
    // // Chưa login: không check internet
    // if (!isAuthenticated && appInitState.isReady) {
    //   return RestartScope(
    //     child: MaterialApp(
    //       title: 'Cờ Caro',
    //       debugShowCheckedModeBanner: false,
    //       theme: ThemeData(
    //         colorScheme: ColorScheme.fromSeed(
    //           seedColor: const Color(0xFF4fc3f7),
    //           brightness: Brightness.dark,
    //         ),
    //         useMaterial3: true,
    //         scaffoldBackgroundColor: const Color(0xFF070714),
    //       ),
    //       home: SplashModeScreen(
    //         bettingScreenBuilder: () =>  buildBaseApp(
    //           _GamePreloadTrigger(
    //             child: MaterialApp(
    //               debugShowCheckedModeBanner: false,
    //               theme: lightTheme,
    //               darkTheme: darkTheme,
    //               // Web: Landing page, Native: Login page trực tiếp
    //               home: kIsWeb
    //                   ? const LandingPage()
    //                   : const AuthDesktopScreen(showLogin: true),
    //             ),
    //           ),
    //         ),
    //         fakeScreenBuilder: () => const SplashScreen(),
    //         executeRestartWithFade: RestartScope.executeRestartApp,
    //         splashScreenBuilder: () => const DefaultSplashScreen(),
    //       ),
    //     ),
    //   );
    // }
    //
    // // Đã login: bật check internet (dialog mất mạng; khi có mạng lại đóng dialog).
    // ref.read(reconnectCoordinatorProvider);

    return RestartScope(
      child: MaterialApp(
        title: 'Cờ Caro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4fc3f7),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF070714),
        ),
        home: SplashModeScreen(
          bettingScreenBuilder: () => const SplashScreen(),
            //   buildBaseApp(
            // _GamePreloadTrigger(
            //   child: MaterialApp.router(
            //     debugShowCheckedModeBanner: false,
            //     theme: lightTheme,
            //     darkTheme: darkTheme,
            //     builder: (context, child) => NetworkManagerListener(
            //       navigatorKey: _navigatorKey,
            //       onReconnected: null,
            //       child: child ?? const SizedBox.shrink(),
            //     ),
            //     routerConfig: _goRouter,
            //   ),
            // ),
          // ),
          fakeScreenBuilder: () => const SplashScreen(),
          executeRestartWithFade: RestartScope.executeRestartApp,
          splashScreenBuilder: () => const DefaultSplashScreen(),
        ),
      ),
    );
  }

  // Future<void> _initApp() async {
  //   // Bắt đầu khởi tạo - UI sẽ hiển thị shimmer
  //   ref.read(appInitProvider.notifier).startInitializing();
  //
  //   try {
  //     // 1. Chạy SONG SONG các task không phụ thuộc nhau
  //     // - Config init (required để app hoạt động)
  //     // - DepositStorage init (independent, dùng Hive)
  //     final results = await Future.wait([
  //       SbLogin.initConfigOnly(),
  //       DepositStorage.init().catchError((_) {}),
  //       SearchRecentStorage.init().catchError((_) {}),
  //       CasinoRecentGamesStorage.init().catchError((_) {}),
  //     ]);
  //
  //     final configReady = results[0] as bool;
  //
  //     // 2. Initialize AssetsCacheManager (flutter_cache_manager)
  //     // Khởi tạo sớm để cache sẵn sàng khi cần, tránh delay lần đầu sử dụng
  //     // AssetsCacheManager sử dụng flutter_cache_manager, tự động handle cache expiration và cleanup
  //     try {
  //       AssetsCacheManager.getCacheManager();
  //       if (kDebugMode) {
  //         debugPrint('✅ AssetsCacheManager initialized successfully');
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         debugPrint('⚠️  Warning: AssetsCacheManager init failed: $e');
  //       }
  //     }
  //
  //     // 3. Register AssetsData để enable versioning cho icons/images
  //     // Khi register, ImageHelper.load() sẽ tự động dùng versioning để quản lý cache
  //     // Khi update icon/image, chỉ cần thay đổi oldVersion và newVersion trong AppAssetsData
  //     try {
  //       AssetsCacheManager.registerAssets(AppAssetsData.all);
  //       if (kDebugMode) {
  //         debugPrint(
  //           '✅ Registered ${AppAssetsData.all.length} assets for versioning',
  //         );
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         debugPrint('⚠️  Warning: Assets registration failed: $e');
  //       }
  //     }
  //
  //     // 4. Preload critical icons vào browser memory cache (web only)
  //     // Giúp icons load nhanh hơn từ memory cache (~0-5ms) thay vì disk cache (~5-20ms)
  //     if (kIsWeb && mounted) {
  //       unawaited(
  //         WebIconPreloader.preloadCriticalIcons(context).catchError((_) {}),
  //       );
  //     }
  //
  //     if (!configReady) {
  //       // Config load failed - set ready và để user login lại
  //       ref.read(appInitProvider.notifier).setReady();
  //       return;
  //     }
  //
  //     // 5. Check if user has saved tokens (phụ thuộc config đã load)
  //     final hasTokens = await SbLogin.hasValidTokens();
  //     if (!hasTokens) {
  //       // No tokens - user needs to login first, set ready để hiển thị UI
  //       ref.read(appInitProvider.notifier).setReady();
  //       return;
  //     }
  //
  //     // 6. Has tokens - try to auto-login by connecting
  //     // This will refresh token, get wsToken, connect websockets
  //     await SbLogin.connect(isReconnect: true);
  //
  //     // 7. Sync auth state to provider for UI
  //     ref.read(authProvider.notifier).syncFromSbLogin();
  //
  //     // 8. Listen for force logout events (token expired, auth error)
  //     // Note: Kick events are handled by KickEventListener in MainShellLayout
  //     _setupForceLogoutListener();
  //
  //     // 9. Initialize SportSocketAdapter (replaces legacy WsProcessorInitializer)
  //     await _initSportSocketAdapter();
  //
  //     // 9. Khởi tạo thành công - UI sẽ hiển thị nội dung
  //     ref.read(appInitProvider.notifier).setReady();
  //
  //     // 10. Load game API on app open (mobile/desktop) – Casino tab & search use this data
  //     // Populates GameRepository in-memory cache so Casino opens instantly and
  //     // casino search filters in-data (no extra API)
  //     unawaited(
  //       ref.read(gameRepositoryProvider).warmup().catchError((Object e) {
  //         if (kDebugMode) debugPrint('⚠️ Game preload failed: $e');
  //       }),
  //     );
  //   } catch (e) {
  //     // Có lỗi khi connect - clear data và reset về trạng thái logout
  //     if (kDebugMode) {
  //       debugPrint('❌ App init failed: $e');
  //     }
  //
  //     // Clear all local data và logout
  //     await ref.read(authProvider.notifier).logout();
  //
  //     // Set ready để hiển thị UI (trạng thái chưa đăng nhập)
  //     ref.read(appInitProvider.notifier).setReady();
  //   }
  // }
  //
  // /// Initialize SportSocketAdapter with API integration
  // ///
  // /// This replaces the legacy WebSocket system:
  // /// - WsProcessorInitializer
  // /// - batchUpdateListenerProvider
  // /// - All individual WebSocket listeners
  // Future<void> _initSportSocketAdapter() async {
  //   if (kDebugMode) {
  //     debugPrint('🚀 [App] Initializing SportSocketAdapter...');
  //   }
  //
  //   try {
  //     // Get providers
  //     final adapter = ref.read(sportSocketAdapterProvider);
  //     final repository = ref.read(sportRepositoryProvider);
  //     final v2DataSource = ref.read(eventsV2RemoteDataSourceProvider);
  //     final storage = ref.read(sportStorageProvider);
  //
  //     // Load saved sportId from storage (default to 1 = Football)
  //     final int sportId = await storage.getSportId();
  //
  //     // Initialize adapter (connects WebSocket + loads V2 API data)
  //     await adapter.initialize(
  //       repository: repository,
  //       v2DataSource: v2DataSource,
  //       sportId: sportId,
  //     );
  //
  //     // Setup listeners WITH PROPER SUBSCRIPTION TRACKING
  //     _setupAdapterListeners(adapter);
  //
  //     if (kDebugMode) {
  //       debugPrint(
  //         '✅ [App] SportSocketAdapter initialized - sportId: $sportId',
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('❌ [App] SportSocketAdapter init failed: $e');
  //     }
  //     // Don't rethrow - app can still work with manual API calls
  //   }
  // }
  //
  // /// Setup force logout listener (token expired, auth error)
  // /// Note: Kick events (login from another device) are handled by KickEventListener in MainShellLayout
  // void _setupForceLogoutListener() {
  //   // Cancel existing subscription if any
  //   _forceLogoutSubscription?.cancel();
  //
  //   // Listen for force logout events (token expired, auth error)
  //   _forceLogoutSubscription = SbLogin.forceLogoutStream.listen(
  //         (reason) {
  //       if (!mounted) return;
  //
  //       if (kDebugMode) {
  //         debugPrint('🚫 [App] Force logout: $reason');
  //       }
  //
  //       // Force logout - this will update auth state and show landing/auth page
  //       ref.read(authProvider.notifier).logout();
  //     },
  //     onError: (Object e) {
  //       if (kDebugMode) {
  //         debugPrint('❌ [App] forceLogoutStream error: $e');
  //       }
  //     },
  //     cancelOnError: false,
  //   );
  //
  //   if (kDebugMode) {
  //     debugPrint('🎧 [App] Force logout listener setup complete');
  //   }
  // }
  //
  // /// Setup listeners with PROPER subscription management
  // void _setupAdapterListeners(SportSocketAdapter adapter) {
  //   // ═══════════════════════════════════════════════════════════════════════
  //   // CRITICAL FIX: Store subscription references for cleanup
  //   // ═══════════════════════════════════════════════════════════════════════
  //
  //   // Cancel existing subscriptions if any (prevent duplicates)
  //   _leaguesSubscription?.cancel();
  //   _connectionSubscription?.cancel();
  //   _metricsSubscription?.cancel();
  //
  //   // Listen to leagues changes (full list updates)
  //   _leaguesSubscription = adapter.onLeaguesChanged.listen(
  //         (leagues) {
  //       // Check if widget is still mounted before updating state
  //       if (!mounted) return;
  //       ref.read(leagueProvider.notifier).setLeaguesFromAdapter(leagues);
  //     },
  //     onError: (Object e) {
  //       if (kDebugMode) {
  //         debugPrint('❌ [App] onLeaguesChanged error: $e');
  //       }
  //     },
  //     cancelOnError: false, // Don't cancel on error, keep listening
  //   );
  //
  //   // Listen to connection state for reconnection handling
  //   _connectionSubscription = adapter.onConnectionChanged.listen(
  //         (event) {
  //       if (!mounted) return;
  //
  //       if (kDebugMode) {
  //         debugPrint(
  //           '🔌 [App] Connection: ${event.previousState} → ${event.currentState}',
  //         );
  //       }
  //
  //       // Notify LeagueProvider of connection state
  //       ref
  //           .read(leagueProvider.notifier)
  //           .handleConnectionStateChange(
  //         isConnected:
  //         event.currentState == socket.ConnectionState.connected,
  //       );
  //     },
  //     onError: (Object e) {
  //       if (kDebugMode) {
  //         debugPrint('❌ [App] onConnectionChanged error: $e');
  //       }
  //     },
  //     cancelOnError: false,
  //   );
  //
  //   // Debug: Log metrics (only in debug mode)
  //   if (kDebugMode) {
  //     _metricsSubscription = adapter.onMetrics.listen((metrics) {
  //       if (!mounted) return;
  //
  //       // Only log occasionally to reduce spam
  //       if (metrics.processedTotal % 500 == 0) {
  //         debugPrint(
  //           '📊 [Metrics] Processed: ${metrics.processedPerSecond}/s, '
  //               'Pending: ${metrics.pendingQueueSize}',
  //         );
  //       }
  //     });
  //   }
  //
  //   if (kDebugMode) {
  //     debugPrint('🎧 [App] Adapter listeners setup complete');
  //   }
  // }
}

// class _GamePreloadTrigger extends StatefulWidget {
//   const _GamePreloadTrigger({required this.child});
//
//   final Widget child;
//
//   @override
//   State<_GamePreloadTrigger> createState() => _GamePreloadTriggerState();
// }
//
// class _GamePreloadTriggerState extends State<_GamePreloadTrigger> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         UnifiedAssetsPreloader.startGamePreloadInBackground(context);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.child;
// }
