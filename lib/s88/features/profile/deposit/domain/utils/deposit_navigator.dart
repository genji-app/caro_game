import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/providers/deposit_overlay_provider.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

/// Navigator for deposit dialogs that automatically handles mobile/web differences
/// and maintains dialog stack
///
/// This navigator automatically:
/// - Detects device type (mobile vs web/tablet)
/// - Shows appropriate UI (bottom sheet for mobile, overlay for web)
/// - Tracks previous dialog and automatically shows it when current one is popped
class DepositNavigator {
  static final DepositNavigator _instance = DepositNavigator._internal();
  factory DepositNavigator() => _instance;
  DepositNavigator._internal();

  /// Stack of previous dialog callbacks
  final List<Future<void> Function()> _stack = [];

  /// Flag to track if pop() was called
  /// This prevents duplicate showPrevious when showGeneralDialog returns
  bool _isPopping = false;

  /// Push a dialog with automatic device detection and previous dialog tracking
  ///
  /// [context] - BuildContext
  /// [mobileShowMethod] - Static show method for mobile bottom sheet
  /// [webShowMethod] - Function to show web overlay
  /// [showPreviousDialog] - Callback to show previous dialog when current is popped
  ///                        Receives rootContext and deviceType as parameters
  ///
  /// Example:
  /// ```dart
  /// DepositNavigator.push(
  ///   context: context,
  ///   mobileShowMethod: (ctx) => CodepayTransationBottomSheet.show(ctx, ...),
  ///   webShowMethod: (ctx) => showGeneralDialog(...),
  ///   showPreviousDialog: (rootContext, deviceType) async {
  ///     if (deviceType == DeviceType.mobile) {
  ///       await DepositMobileBottomSheet.show(rootContext);
  ///     } else {
  ///       // Access provider through container
  ///       final container = ProviderScope.containerOf(rootContext, listen: false);
  ///       container.read(depositOverlayVisibleProvider.notifier).state = true;
  ///     }
  ///   },
  /// );
  /// ```
  Future<T?> push<T>({
    required BuildContext context,
    required Future<void> Function(BuildContext) mobileShowMethod,
    required Future<T?> Function(BuildContext) webShowMethod,
    required Future<void> Function(
      BuildContext rootContext,
      DeviceType deviceType,
    )
    showPreviousDialog,
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(rootContext);

    _stack.add(() => showPreviousDialog(rootContext, deviceType));

    if (deviceType == DeviceType.mobile) {
      if (Navigator.of(rootContext).canPop()) {
        Navigator.of(rootContext).pop();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!rootContext.mounted) return null;
      }
      await mobileShowMethod(rootContext);
      return null;
    } else {
      final container = ProviderScope.containerOf(rootContext, listen: false);
      final isDepositOverlayVisible = container.read(
        depositOverlayVisibleProvider,
      );

      if (isDepositOverlayVisible) {
        container.read(depositOverlayVisibleProvider.notifier).state = false;
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!rootContext.mounted) return null;
      }

      final navigatorContext = Navigator.of(
        context,
        rootNavigator: true,
      ).context;
      if (Navigator.of(navigatorContext).canPop()) {
        Navigator.of(navigatorContext).pop();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!rootContext.mounted) {
          return null;
        }
      }

      final result = await webShowMethod(rootContext);

      _isPopping = false;

      return result;
    }
  }

  Future<T?> pushReplacement<T>({
    required BuildContext context,
    required Future<void> Function(BuildContext) mobileShowMethod,
    required Future<T?> Function(BuildContext) webShowMethod,
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final deviceType = ResponsiveBuilder.getDeviceType(rootContext);

    if (deviceType == DeviceType.mobile) {
      Navigator.of(rootContext).pop();
    } else {
      final container = ProviderScope.containerOf(rootContext, listen: false);
      container.read(depositOverlayVisibleProvider.notifier).state = false;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!rootContext.mounted) return null;

    if (deviceType == DeviceType.mobile) {
      await mobileShowMethod(rootContext);
    } else {
      return await webShowMethod(rootContext);
    }
    return null;
  }

  Future<void> pop<T>(BuildContext context, [T? result]) async {
    // Try to get root context, but if it fails, use the provided context
    BuildContext rootContext;
    try {
      rootContext = Navigator.of(context, rootNavigator: true).context;
    } catch (e) {
      // If we can't get root context, try regular navigator
      rootContext = context;
    }

    if (_isPopping) {
      // If already popping, try to pop directly with the context
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      }
      return;
    }

    _isPopping = true;

    // Check if we can pop before attempting
    final canPop = Navigator.of(rootContext).canPop();

    if (canPop) {
      Navigator.of(rootContext).pop(result);
    } else {
      // If can't pop from root, try from current context
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (_stack.isNotEmpty && rootContext.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (rootContext.mounted && _stack.isNotEmpty) {
        final showPrevious = _stack.removeLast();
        if (rootContext.mounted) {
          try {
            await showPrevious();
          } catch (e) {
            // Ignore errors
          }
        }
      }
    } else {
      try {
        final deviceType = ResponsiveBuilder.getDeviceType(rootContext);
        if (deviceType != DeviceType.mobile && rootContext.mounted) {
          final container = ProviderScope.containerOf(
            rootContext,
            listen: false,
          );
          container.read(depositOverlayVisibleProvider.notifier).state = true;
        }
        // For mobile, if stack is empty, the dialog was already popped above
        // This is the expected behavior when re-showing a dialog
      } catch (_) {
        // Ignore fallback errors
      }
    }

    _isPopping = false;
  }

  void clear() {
    _stack.clear();
  }

  /// Close all dialogs without going back to previous screen
  /// This clears the stack and pops the current dialog
  /// Use this for close button to close everything
  Future<void> closeAll<T>(BuildContext context, [T? result]) async {
    // Clear the stack first to prevent re-showing previous dialogs
    _stack.clear();

    // Try to get root context, but if it fails, use the provided context
    BuildContext rootContext;
    try {
      rootContext = Navigator.of(context, rootNavigator: true).context;
    } catch (e) {
      rootContext = context;
    }

    // Pop the current dialog
    if (Navigator.of(rootContext).canPop()) {
      Navigator.of(rootContext).pop(result);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  static Future<T?> showWebDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: builder,
    );
  }

  int get stackSize => _stack.length;
}
