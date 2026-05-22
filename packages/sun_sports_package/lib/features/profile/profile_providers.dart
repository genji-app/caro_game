import 'package:adaptive_overlay/adaptive_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider quản lý navigatorKey cho Profile overlay.
/// Key này được giữ nguyên để preserve navigation state.
/// WARNING: Không sử dụng provider này trực tiếp để điều hướng.
/// Sử dụng ProfileNavigation.of(context) thay thế.
final profileNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

/// Provider quản lý controller hiển thị Profile.
/// Sử dụng keepAlive để giữ controller instance khi chuyển mode.
/// WARNING: Không sử dụng provider này trực tiếp để điều hướng.
/// Sử dụng ProfileNavigation.of(context) thay thế.
final profileOverlayControllerProvider = Provider<AdaptiveOverlayController>((
  ref,
) {
  final controller = AdaptiveOverlayController();

  // Keep the controller alive to preserve state across rebuilds
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
