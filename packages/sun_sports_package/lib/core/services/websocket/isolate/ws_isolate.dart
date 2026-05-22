// WebSocket Isolate Module
//
// Provides background processing for WebSocket messages.
// Offloads JSON parsing and logic to isolate/worker.
//
// For Web support, generate worker JS:
// Run: dart run isolate_manager:generate -i lib/core/services/websocket/isolate -o web
// Output: web/wsIsolateWorker.js

export 'ws_isolate_types.dart';
export 'ws_isolate_processor.dart';
export 'ws_isolate_worker.dart';
