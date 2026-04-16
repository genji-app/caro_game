import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/notification/widgets/notification_dialog_body.dart';
import 'package:co_caro_flame/s88/features/notification/widgets/notification_sheet.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

class NotificationPanel {
  static Future<void> show(
    BuildContext context, {
    BuildContext? anchorContext,
  }) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    if (isMobile) {
      return showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (ctx) => const NotificationSheet(),
      );
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (ctx) => const Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: NotificationDialogBody(anchored: false),
      ),
    );
  }
}
