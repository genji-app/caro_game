import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

/// Utility class for clipboard operations in deposit feature
///
/// Provides common functions for:
/// - Copying text to clipboard
/// - Pasting text from clipboard
/// - Showing success notifications
class ClipboardUtils {
  /// Copy text to clipboard and show success notification
  ///
  /// Uses TransactionStatusDialog for notification to work in all contexts
  /// (overlays, dialogs, bottom sheets, etc.)
  ///
  /// Note: This method requires a BuildContext. If you don't have one,
  /// use copyToClipboardWithSnackBar instead.
  ///
  /// Handles exceptions gracefully if clipboard access fails.
  ///
  /// Example:
  /// ```dart
  /// await ClipboardUtils.copyToClipboard(context, 'Hello World');
  /// ```
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    if (text.isEmpty) return;
    if (!context.mounted) return;

    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (!context.mounted) return;

      AppToast.showSuccess(context, message: 'Đã sao chép vào clipboard');
    } catch (e) {
      // Clipboard may be unavailable on some platforms
      // Silently fail to avoid crashing the app
    }
  }

  /// Copy text to clipboard and show success notification using ScaffoldMessenger
  ///
  /// Use this version when you have a BuildContext and want to use SnackBar
  /// instead of Toast. Only works when Scaffold ancestor is present.
  ///
  /// Handles exceptions gracefully if clipboard access fails.
  ///
  /// Example:
  /// ```dart
  /// await ClipboardUtils.copyToClipboardWithSnackBar(context, 'Hello World');
  /// ```
  static Future<void> copyToClipboardWithSnackBar(
    BuildContext context,
    String text,
  ) async {
    if (text.isEmpty) return;
    if (!context.mounted) return;

    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép vào clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Clipboard may be unavailable on some platforms
      // Silently fail to avoid crashing the app
    }
  }

  /// Get text from clipboard
  ///
  /// Returns the clipboard text if available, null otherwise.
  /// Handles exceptions gracefully if clipboard access fails.
  ///
  /// Example:
  /// ```dart
  /// final text = await ClipboardUtils.getClipboardText();
  /// if (text != null) {
  ///   controller.text = text;
  /// }
  /// ```
  static Future<String?> getClipboardText() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      // Clipboard may be unavailable or empty, return null safely
      return null;
    }
  }

  /// Paste text from clipboard to a TextEditingController
  ///
  /// Updates the controller's text and optionally calls a callback
  /// to notify parent widgets/providers of the change.
  ///
  /// Safely handles cases where clipboard is empty or unavailable.
  /// No action is taken if clipboard is empty or access fails.
  ///
  /// Example:
  /// ```dart
  /// await ClipboardUtils.pasteToController(
  ///   controller: _serialNumberController,
  ///   onPaste: (text) => ref.read(formProvider.notifier).updateSerialNumber(text),
  /// );
  /// ```
  static Future<void> pasteToController({
    required TextEditingController controller,
    void Function(String text)? onPaste,
  }) async {
    try {
      final clipboardText = await getClipboardText();
      if (clipboardText != null && clipboardText.isNotEmpty) {
        controller.text = clipboardText;
        onPaste?.call(clipboardText);
      }
      // If clipboard is empty or null, silently do nothing (expected behavior)
    } catch (e) {
      // Handle any unexpected errors gracefully
      // Clipboard access may fail on some platforms
    }
  }
}
