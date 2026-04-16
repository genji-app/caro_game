import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:co_caro_flame/s88/core/utils/network_manger.dart';

/// Coordinator: lắng nghe [NetworkManagerEvent.connectionRestored],
/// gọi mọi callback đã đăng ký (Single Responsibility).
class ReconnectCoordinator {
  ReconnectCoordinator() {
    _startListening();
  }

  final List<VoidCallback> _callbacks = [];
  StreamSubscription<NetworkManagerEvent>? _subscription;

  void _startListening() {
    NetworkManager.instance.startListening();
    _subscription = NetworkManager.instance.stream.listen(_onEvent);
  }

  void _onEvent(NetworkManagerEvent event) {
    if (event == NetworkManagerEvent.connectionRestored) {
      _notifyReconnected();
    }
  }

  void register(VoidCallback onReconnect) {
    if (!_callbacks.contains(onReconnect)) {
      _callbacks.add(onReconnect);
    }
  }

  void unregister(VoidCallback onReconnect) {
    _callbacks.remove(onReconnect);
  }

  void _notifyReconnected() {
    final list = List<VoidCallback>.from(_callbacks);
    for (final cb in list) {
      try {
        cb();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('ReconnectCoordinator: callback error $e\n$st');
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _callbacks.clear();
  }
}

/// Đọc ít nhất một lần khi đã login (ví dụ trong app builder) để coordinator
/// subscribe network và sẵn sàng nhận đăng ký từ các notifier.
final reconnectCoordinatorProvider = Provider<ReconnectCoordinator>((ref) {
  final coordinator = ReconnectCoordinator();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
