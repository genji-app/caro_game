import 'package:flutter/material.dart';

/// Manager to handle dialog stack for deposit feature
///
/// Flutter's Navigator only allows one dialog at a time.
/// This manager helps maintain a stack of dialogs and automatically
/// shows the previous dialog when the current one is popped.
class DialogStackManager {
  static final DialogStackManager _instance = DialogStackManager._internal();
  factory DialogStackManager() => _instance;
  DialogStackManager._internal();

  /// Stack of dialog builders
  final List<_DialogItem> _stack = [];

  /// Push a dialog to the stack and show it
  ///
  /// [context] - BuildContext to show the dialog
  /// [builder] - Function that returns the dialog widget
  /// [barrierDismissible] - Whether the dialog can be dismissed by tapping outside
  /// [barrierColor] - Color of the barrier
  /// [transitionDuration] - Duration of the transition animation
  Future<T?> push<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    // Add current dialog to stack
    final dialogItem = _DialogItem(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      transitionDuration: transitionDuration,
    );
    _stack.add(dialogItem);

    // Show the dialog
    final result = await showGeneralDialog<T>(
      context: rootContext,
      barrierColor: dialogItem.barrierColor,
      barrierDismissible: dialogItem.barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        rootContext,
      ).modalBarrierDismissLabel,
      transitionDuration: dialogItem.transitionDuration,
      pageBuilder: dialogItem.builder,
    );

    // When dialog is popped, remove from stack
    _stack.removeLast();

    // If there are previous dialogs in stack, show the last one
    if (_stack.isNotEmpty && rootContext.mounted) {
      final previousDialog = _stack.last;
      await Future<void>.delayed(
        const Duration(milliseconds: 200),
      ); // Small delay for transition
      if (rootContext.mounted) {
        await showGeneralDialog(
          context: rootContext,
          barrierColor: previousDialog.barrierColor,
          barrierDismissible: previousDialog.barrierDismissible,
          barrierLabel: MaterialLocalizations.of(
            rootContext,
          ).modalBarrierDismissLabel,
          transitionDuration: previousDialog.transitionDuration,
          pageBuilder: previousDialog.builder,
        );
      }
    }

    return result;
  }

  /// Push a dialog by replacing the current one (doesn't add to stack)
  ///
  /// Use this when you want to replace current dialog without maintaining it in stack
  Future<T?> pushReplacement<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    // Remove current dialog from stack if exists
    if (_stack.isNotEmpty) {
      _stack.removeLast();
      Navigator.of(rootContext).pop();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    // Add new dialog to stack
    final dialogItem = _DialogItem(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      transitionDuration: transitionDuration,
    );
    _stack.add(dialogItem);

    // Show the new dialog
    return await showGeneralDialog<T>(
      context: rootContext,
      barrierColor: dialogItem.barrierColor,
      barrierDismissible: dialogItem.barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        rootContext,
      ).modalBarrierDismissLabel,
      transitionDuration: dialogItem.transitionDuration,
      pageBuilder: dialogItem.builder,
    );
  }

  /// Pop current dialog
  void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context, rootNavigator: true).pop(result);
  }

  /// Pop all dialogs
  void popAll(BuildContext context) {
    _stack.clear();
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);
  }

  /// Check if there are dialogs in stack
  bool get hasDialogs => _stack.isNotEmpty;

  /// Get current stack size
  int get stackSize => _stack.length;

  /// Clear the stack (without popping dialogs)
  void clear() {
    _stack.clear();
  }
}

/// Internal class to store dialog information
class _DialogItem {
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
  builder;
  final bool barrierDismissible;
  final Color barrierColor;
  final Duration transitionDuration;

  _DialogItem({
    required this.builder,
    required this.barrierDismissible,
    required this.barrierColor,
    required this.transitionDuration,
  });
}
