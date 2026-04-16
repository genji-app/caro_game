import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:co_caro_flame/s88/core/services/adapters/sport_socket_adapter.dart';
import 'package:co_caro_flame/s88/core/services/datasources/events_v2_remote_datasource.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/features/sport/data/datasources/sport_remote_datasource.dart';
import 'package:co_caro_flame/s88/features/sport/data/repositories/sport_repository_impl.dart';
import 'package:co_caro_flame/s88/features/sport/domain/repositories/sport_repository.dart';

// =============================================================================
// CORE SERVICE PROVIDERS
// =============================================================================

/// Provider for SbHttpManager singleton
final sbHttpManagerProvider = Provider<SbHttpManager>(
  (ref) => SbHttpManager.instance,
);

/// Provider for SportStorage singleton
final sportStorageProvider = Provider<SportStorage>(
  (ref) => SportStorage.instance,
);

// =============================================================================
// REPOSITORY PROVIDERS
// =============================================================================

/// Provider for SportRemoteDataSource
final sportRemoteDataSourceProvider = Provider<SportRemoteDataSource>((ref) {
  final httpManager = ref.read(sbHttpManagerProvider);
  final storage = ref.read(sportStorageProvider);
  return SportRemoteDataSourceImpl(httpManager, storage);
});

/// Provider for SportRepository
final sportRepositoryProvider = Provider<SportRepository>((ref) {
  final dataSource = ref.read(sportRemoteDataSourceProvider);
  return SportRepositoryImpl(dataSource);
});

// =============================================================================
// SPORT SOCKET ADAPTER PROVIDERS
// =============================================================================

/// Socket configuration provider (overridable for different environments)
final socketConfigProvider = Provider<socket.SocketConfig>((ref) {
  // TODO: Use httpManager.urlHomeWebsocket when ready
  // final httpManager = ref.read(sbHttpManagerProvider);
  return socket.SocketConfig.liveMode(
    url: 'wss://nowsgb.sb21.net',
    logger: kDebugMode
        ? const socket.ConsoleLogger()
        : const socket.NoOpLogger(),
    // V2 Protocol: Binary Protobuf + Base64 encoded subscriptions
    useV2Protocol: true,
    v2Language: 'vi',
    // V2 AutoRefresh intervals (reduced frequency since WebSocket is real-time)
    // LIVE: 3 min, TODAY: 5 min, EARLY: 5 min
    autoRefreshConfig: const socket.AutoRefreshConfig(
      refreshInterval: Duration(seconds: 180), // LIVE: 3 minutes
      todayRefreshInterval: Duration(seconds: 300), // TODAY: 5 minutes
      earlyRefreshInterval: Duration(seconds: 300), // EARLY: 5 minutes
    ),
  );
});

/// Main SportSocketAdapter provider (singleton)
///
/// Usage:
/// ```dart
/// final adapter = ref.read(sportSocketAdapterProvider);
/// await adapter.initialize(repository: sportRepository, sportId: 1);
/// ```
final sportSocketAdapterProvider = Provider<SportSocketAdapter>((ref) {
  // ✅ FIX: Use ref.read() - config provider is singleton, never changes
  // Using watch() creates unnecessary listeners and can cause adapter recreation
  final config = ref.read(socketConfigProvider);
  final adapter = SportSocketAdapter(config: config);

  // Fire-and-forget: dispose() handles async internally
  ref.onDispose(() {
    adapter.dispose();
  });

  return adapter;
});

// =============================================================================
// STREAM PROVIDERS
// =============================================================================

/// Connection state stream provider
///
/// Listen to WebSocket connection state changes:
/// ```dart
/// ref.listen(socketConnectionStateProvider, (prev, next) {
///   next.whenData((event) {
///     if (event.currentState == ConnectionState.connected) {
///       // Handle connected
///     }
///   });
/// });
/// ```
final socketConnectionStateProvider = StreamProvider<socket.ConnectionStateEvent>((
  ref,
) {
  // ✅ FIX: Use ref.read() instead of ref.watch() to prevent listener leaks
  // sportSocketAdapterProvider is a SINGLETON - adapter instance never changes
  // Only the streams inside emit data, so we only need to read() once
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onConnectionChanged;
});

/// Data change stream provider (granular updates)
///
/// Listen to data changes for fine-grained UI updates:
/// ```dart
/// ref.listen(socketDataChangeProvider, (prev, next) {
///   next.whenData((event) {
///     if (event.affectsEvent(eventId)) {
///       // Refresh this event's UI
///     }
///   });
/// });
/// ```
final socketDataChangeProvider = StreamProvider<SportSocketUpdate>((ref) {
  // ✅ FIX: Use ref.read() - adapter is singleton, no need to watch
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onUpdate;
});

/// Metrics stream provider (for debugging/monitoring)
///
/// Useful for performance monitoring in debug mode:
/// ```dart
/// if (kDebugMode) {
///   ref.listen(socketMetricsProvider, (prev, next) {
///     next.whenData((metrics) {
///       debugPrint('Messages/sec: ${metrics.messagesPerSecond}');
///     });
///   });
/// }
/// ```
final socketMetricsProvider = StreamProvider<socket.ProcessorMetrics>((ref) {
  // ✅ FIX: Use ref.read() - adapter is singleton, no need to watch
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onMetrics;
});

// =============================================================================
// DERIVED PROVIDERS
// =============================================================================

/// Convenience provider for checking if socket is connected
///
/// Usage:
/// ```dart
/// final isConnected = ref.watch(isSocketConnectedProvider);
/// if (!isConnected) {
///   return LoadingIndicator();
/// }
/// ```
final isSocketConnectedProvider = Provider<bool>((ref) {
  final state = ref.watch(socketConnectionStateProvider);
  return state.whenOrNull(
        data: (event) => event.currentState == socket.ConnectionState.connected,
      ) ??
      false;
});

/// Current connection state enum
final socketConnectionEnumProvider = Provider<socket.ConnectionState>((ref) {
  final state = ref.watch(socketConnectionStateProvider);
  return state.whenOrNull(data: (event) => event.currentState) ??
      socket.ConnectionState.disconnected;
});

/// Leagues change stream provider (full list updates)
///
/// Listen to complete leagues list updates:
/// ```dart
/// ref.listen(socketLeaguesProvider, (prev, next) {
///   next.whenData((leagues) {
///     // Update league state
///   });
/// });
/// ```
final socketLeaguesProvider = StreamProvider<List<LeagueData>>((ref) {
  // ✅ FIX: Use ref.read() - adapter is singleton, no need to watch
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.onLeaguesChanged;
});

/// Whether adapter has been initialized
///
/// ✅ FIX: Use ref.read() instead of ref.watch()
/// - adapter is singleton that never changes
/// - using watch() creates unnecessary listener accumulation
/// - if you need reactive updates, watch socketConnectionStateProvider instead
final isAdapterInitializedProvider = Provider<bool>((ref) {
  final adapter = ref.read(sportSocketAdapterProvider);
  return adapter.isInitialized;
});

// =============================================================================
// SPORT SOCKET INITIALIZATION HELPER
// =============================================================================

/// Initialize SportSocketAdapter after login/register
///
/// This should be called after successful login to establish sport socket connection.
/// The App widget calls this during initial load if user has saved tokens,
/// but for fresh login/register, this must be called explicitly.
///
/// Usage (in auth forms after syncFromSbLogin):
/// ```dart
/// ref.read(global_auth.authProvider.notifier).syncFromSbLogin();
/// await initializeSportSocketAfterLogin(ref);
/// ```
Future<void> initializeSportSocketAfterLogin(WidgetRef ref) async {
  if (kDebugMode) {
    debugPrint('🚀 [SportSocket] Initializing after login...');
  }

  try {
    final adapter = ref.read(sportSocketAdapterProvider);

    // Skip if already initialized
    if (adapter.isInitialized) {
      if (kDebugMode) {
        debugPrint('✅ [SportSocket] Already initialized, skipping');
      }
      return;
    }

    final repository = ref.read(sportRepositoryProvider);
    final v2DataSource = ref.read(eventsV2RemoteDataSourceProvider);
    final storage = ref.read(sportStorageProvider);

    // Load saved sportId from storage (default to 1 = Football)
    final int sportId = await storage.getSportId();

    // Initialize adapter (connects WebSocket + loads V2 API data)
    await adapter.initialize(
      repository: repository,
      v2DataSource: v2DataSource,
      sportId: sportId,
    );

    if (kDebugMode) {
      debugPrint('✅ [SportSocket] Initialized after login - sportId: $sportId');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [SportSocket] Init after login failed: $e');
    }
    // Don't rethrow - app can still work with manual API calls
  }
}
