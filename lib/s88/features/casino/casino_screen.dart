import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/spacing_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';

import 'casino_view.dart';

/// A unified, adaptive screen for the Casino feature.
///
/// Handles layout variations for Mobile, Tablet, and Desktop:
/// - **Mobile**: Includes the SportLiveChat header for authenticated users (if [showLiveChat] is true) and vertical scrolling.
/// - **Tablet/Desktop**: Nested inside an [Expanded] container with proper constrained widths and spacing.
class CasinoScreen extends StatelessWidget {
  const CasinoScreen({
    super.key,
    this.backgroundColor = AppColorStyles.backgroundSecondary,
    this.showLiveChat = false,
  });

  final Color? backgroundColor;

  /// Whether to show the sticky Live Chat header (primarily on mobile).
  final bool showLiveChat;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final isMobile = deviceType == DeviceType.mobile;

        if (isMobile) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: CasinoView(
              backgroundColor: backgroundColor,
              showLiveChat: showLiveChat,
              isMobile: true,
            ),
          );
        }

        final isTablet = deviceType == DeviceType.tablet;

        // return Scaffold(
        //   backgroundColor: backgroundColor,
        //   body: CasinoView(
        //     backgroundColor: backgroundColor,
        //     showLiveChat: showLiveChat,
        //     isMobile: false,
        //     padding: EdgeInsets.symmetric(
        //       horizontal: isTablet ? 0 : AppSpacingStyles.space800,
        //     ),
        //   ),
        // );

        return SizedBox.expand(
          child: CasinoView(
            backgroundColor: backgroundColor,
            showLiveChat: showLiveChat,
            isMobile: false,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 0 : AppSpacingStyles.space800,
            ),
          ),
        );
      },
    );
  }
}
