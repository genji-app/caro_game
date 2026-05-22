import 'dart:async';

import 'package:flutter/material.dart';

/// Patch-ready snackbar. [executeRestartWithFade] should run fade-out then
/// process restart (e.g. [RestartScope.executeRestartApp] → [TerminateRestart]).
void executeShowShorebirdRestartSnackbar(
  BuildContext context, {
  required Future<bool> Function(BuildContext context) executeRestartWithFade,
  String message = 'Bản mới đã được cập nhật. Hãy khởi động lại app.',
  String restartActionLabel = 'Khởi động lại',
}) {
  if (!context.mounted) {
    return;
  }
  final ThemeData theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(height: 1.2),
      ),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: restartActionLabel,
        onPressed: () {
          if (!context.mounted) {
            return;
          }
          unawaited(executeRestartWithFade(context));
        },
      ),
    ),
  );
}
