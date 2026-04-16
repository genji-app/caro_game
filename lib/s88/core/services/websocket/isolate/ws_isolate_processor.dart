import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:isolate_manager/isolate_manager.dart';

import 'ws_isolate_types.dart';
import 'ws_isolate_worker.dart';

// WebSocket Isolate Processor
//
// Offloads JSON parsing and message processing to background isolate/worker.
// Main thread only receives processed data ready for state updates.
//
// Benefits:
// - JSON.decode runs in isolate (not blocking UI)
// - Message filtering/grouping runs in isolate
// - Main thread only does: receive data → state.copyWith → render
//
// Cross-platform:
// - Native: Uses Dart Isolate
// - Web: Uses Web Worker (requires compiled JS worker file)
class WsIsolateProcessor {
  /// Isolate manager instance
  IsolateManager<Map<String, dynamic>, Map<String, dynamic>>? _isolateManager;

  /// Whether the processor is initialized
  bool _isInitialized = false;

  /// Whether the processor is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the isolate manager
  ///
  /// Must be called before processing messages.
  /// - Native: Uses Dart Isolate for background processing
  /// - Web: Uses main thread (Web Worker has compatibility issues with isolate_manager)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // On Web, use main thread processing
    // Web Worker with isolate_manager has known compatibility issues
    // The main thread processing is fast enough for our use case
    if (kIsWeb) {
      debugPrint(
        'ℹ️ WsIsolateProcessor: Web platform - using optimized main thread processing',
      );
      debugPrint('   (Web Worker disabled due to compatibility issues)');
      _isInitialized = true;
      // _isolateManager stays null, process() will use main thread
      return;
    }

    debugPrint(
      '🔄 WsIsolateProcessor: Creating isolate manager (Native Isolate)...',
    );

    try {
      _isolateManager = IsolateManager.create(
        wsIsolateWorker,
        workerName: 'wsIsolateWorker',
        // For Native: uses Dart isolate for true background processing
        concurrent: 1, // Single worker for ordered processing
      );

      debugPrint('🔄 WsIsolateProcessor: Starting isolate...');

      // Add timeout to prevent infinite hanging
      await _isolateManager!.start().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ WsIsolateProcessor: Start timeout after 10s');
          throw Exception('Isolate start timeout');
        },
      );

      _isInitialized = true;
      debugPrint(
        '✅ WsIsolateProcessor: Initialized successfully (Native Isolate)',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ WsIsolateProcessor: Failed to initialize: $e');
      debugPrint('   Stack trace: $stackTrace');
      // Cleanup on failure
      _isolateManager = null;
      // Re-throw so caller knows initialization failed
      rethrow;
    }
  }

  /// Process messages in isolate (Native) or main thread (Web)
  ///
  /// Returns processed output ready for state update.
  /// - Native: Uses Dart Isolate for true background processing
  /// - Web: Uses main thread (optimized, fast enough for our use case)
  Future<WsIsolateOutput> process(WsIsolateInput input) async {
    // On Web or if isolate not available, use main thread processing
    if (_isolateManager == null) {
      return _processOnMainThread(input);
    }

    try {
      final resultMap = await _isolateManager!.compute(input.toMap());
      return WsIsolateOutput.fromMap(resultMap);
    } catch (e) {
      debugPrint(
        '⚠️ WsIsolateProcessor: Isolate error, falling back to main thread: $e',
      );
      return _processOnMainThread(input);
    }
  }

  /// Fallback: process on main thread
  WsIsolateOutput _processOnMainThread(WsIsolateInput input) {
    // Use the same worker function on main thread
    final resultMap = wsIsolateWorker(input.toMap());
    return WsIsolateOutput.fromMap(resultMap);
  }

  /// Dispose the isolate manager
  Future<void> dispose() async {
    if (_isolateManager != null) {
      await _isolateManager!.stop();
      _isolateManager = null;
    }
    _isInitialized = false;
    debugPrint('🛑 WsIsolateProcessor: Disposed');
  }
}
