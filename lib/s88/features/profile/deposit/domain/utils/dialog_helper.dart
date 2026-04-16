import 'package:flutter/material.dart';

/// Helper functions for dialog navigation in deposit feature
///
/// Provides utilities to handle dialog stacking where popping
/// one dialog automatically shows the previous one.
class DialogHelper {
  /// Show a dialog with callback when it's popped
  ///
  /// Use this when you want to show a previous dialog after current one is popped.
  ///
  /// Example:
  /// ```dart
  /// DialogHelper.showWithCallback(
  ///   context: context,
  ///   builder: (context) => Dialog2(),
  ///   onPop: () {
  ///     // Show previous dialog
  ///     showDialog(context: rootContext, builder: (context) => Dialog1());
  ///   },
  /// );
  /// ```
  static Future<T?> showWithCallback<T>({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>, Animation<double>)
    builder,
    required VoidCallback onPop,
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    final result = await showGeneralDialog<T>(
      context: rootContext,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(
        rootContext,
      ).modalBarrierDismissLabel,
      transitionDuration: transitionDuration,
      pageBuilder: builder,
    );

    // When dialog is popped, execute callback
    if (rootContext.mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (rootContext.mounted) {
        onPop();
      }
    }

    return result;
  }

  /// Pop current dialog and show previous one
  ///
  /// This is a convenience method to pop current dialog and show the previous one.
  ///
  /// Example:
  /// ```dart
  /// DialogHelper.popAndShowPrevious(
  ///   context: context,
  ///   showPrevious: () {
  ///     showDialog(context: rootContext, builder: (context) => Dialog1());
  ///   },
  /// );
  /// ```
  static void popAndShowPrevious({
    required BuildContext context,
    required VoidCallback showPrevious,
  }) {
    Navigator.of(context, rootNavigator: true).pop();
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      if (rootContext.mounted) {
        showPrevious();
      }
    });
  }
}
