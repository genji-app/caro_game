import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Sự kiện từ [NetworkManager]: mất kết nối hoặc đã kết nối lại.
enum NetworkManagerEvent {
  /// Internet bị mất (chuyển từ có mạng sang mất mạng).
  connectionLost,

  /// Internet đã kết nối lại (chuyển từ mất mạng sang có mạng).
  connectionRestored,
}

/// Quản lý trạng thái internet: lắng nghe thay đổi, phát sự kiện khi mất mạng / có mạng lại.
/// UI (ví dụ [NetworkManagerListener]) subscribe [stream] để show dialog và reload.
class NetworkManager {
  NetworkManager._() {
    _connectivity = Connectivity();
  }

  static final NetworkManager instance = NetworkManager._();

  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<NetworkManagerEvent> _controller =
      StreamController<NetworkManagerEvent>.broadcast();

  bool _wasConnected = true;
  bool _isListening = false;
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 4);

  /// Stream sự kiện: [NetworkManagerEvent.connectionLost] khi mất mạng,
  /// [NetworkManagerEvent.connectionRestored] khi có mạng lại.
  Stream<NetworkManagerEvent> get stream => _controller.stream;

  void _emitIfChanged(bool connected) {
    if (!connected && _wasConnected) {
      _wasConnected = false;
      if (!_controller.isClosed) {
        _controller.add(NetworkManagerEvent.connectionLost);
      }
    } else if (connected && !_wasConnected) {
      _wasConnected = true;
      if (!_controller.isClosed) {
        _controller.add(NetworkManagerEvent.connectionRestored);
      }
    }
  }

  /// Bắt đầu lắng nghe thay đổi kết nối. Gọi từ widget có [BuildContext] (ví dụ [NetworkManagerListener]).
  /// Trên iOS/Android [onConnectivityChanged] đôi khi không fire; polling mỗi [_pollInterval] dùng làm fallback.
  Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;

    try {
      final results = await _connectivity.checkConnectivity();
      _wasConnected = _isConnected(results);
    } catch (_) {
      _wasConnected = false;
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final connected = _isConnected(results);
        _emitIfChanged(connected);
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('NetworkManager: onConnectivityChanged error: $e');
        }
      },
      cancelOnError: false,
    );

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      try {
        final results = await _connectivity.checkConnectivity();
        final connected = _isConnected(results);
        _emitIfChanged(connected);
      } catch (_) {}
    });
  }

  /// Dừng lắng nghe. Gọi khi widget dispose.
  void stopListening() {
    if (!_isListening) return;
    _isListening = false;
    _subscription?.cancel();
    _subscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  /// Kiểm tra hiện tại có internet hay không (dùng khi user bấm OK dialog mất mạng).
  Future<bool> checkIsConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isConnected(results);
    } catch (_) {
      return false;
    }
  }

  /// Đóng stream (chỉ gọi khi app shutdown nếu cần).
  void dispose() {
    stopListening();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
