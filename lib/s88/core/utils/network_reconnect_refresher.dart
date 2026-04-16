import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/network_manger.dart';

/// Widget gọi [onReconnected] khi internet trở lại ([NetworkManagerEvent.connectionRestored]).
/// Dùng ở từng màn hình/tab để recall API đúng màn hình đó khi có mạng lại (không refresh toàn app).
///
/// App-level ([NetworkManagerListener]) không invalidate provider; mỗi màn hình bọc nội dung
/// bằng [NetworkReconnectRefresher] và truyền [onReconnected] tương ứng (ví dụ tab Yêu thích
/// → fetchFavoriteEvents, tab Sảnh → invalidate leagueProvider + hotMatchProvider).
///
/// Ví dụ:
/// ```dart
/// NetworkReconnectRefresher(
///   onReconnected: () => ref.read(favoriteProvider.notifier).fetchFavoriteEvents(sportId),
///   child: FavoriteTabContent(),
/// )
/// ```
class NetworkReconnectRefresher extends ConsumerStatefulWidget {
  const NetworkReconnectRefresher({
    super.key,
    required this.child,
    this.onReconnected,
  });

  final Widget child;

  /// Gọi khi internet kết nối lại — thường invalidate provider của màn hình để gọi lại API.
  final VoidCallback? onReconnected;

  @override
  ConsumerState<NetworkReconnectRefresher> createState() =>
      _NetworkReconnectRefresherState();
}

class _NetworkReconnectRefresherState
    extends ConsumerState<NetworkReconnectRefresher> {
  StreamSubscription<NetworkManagerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  void _startListening() {
    NetworkManager.instance.startListening();
    _subscription = NetworkManager.instance.stream.listen((event) {
      if (event == NetworkManagerEvent.connectionRestored && mounted) {
        widget.onReconnected?.call();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
