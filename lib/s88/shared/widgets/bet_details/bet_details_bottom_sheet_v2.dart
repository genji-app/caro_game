import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:co_caro_flame/s88/core/utils/platform_utils.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_rive.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_content.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data_v2.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/providers/betting_popup_v2_provider.dart';

/// BetDetailsBottomSheet for V2 models
class BetDetailsBottomSheetV2 extends ConsumerStatefulWidget {
  final BettingPopupDataV2? data;
  final bool isVibrating;
  final bool isBottomSheet;

  const BetDetailsBottomSheetV2({
    super.key,
    this.data,
    this.isVibrating = false,
    this.isBottomSheet = false,
  });

  @override
  ConsumerState<BetDetailsBottomSheetV2> createState() =>
      _BetDetailsBottomSheetV2State();

  static Future<void> show(
    BuildContext context, {
    BettingPopupDataV2? data,
    bool isVibrating = false,
  }) {
    // Native mobile hoặc Web với màn hình mobile → dùng showModalBottomSheet
    final isMobileScreen = ResponsiveBuilder.isMobile(context);
    final useBottomSheet =
        PlatformUtils.isMobile || (PlatformUtils.isWeb && isMobileScreen);

    if (useBottomSheet) {
      return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        builder: (context) => BetDetailsBottomSheetV2(
          data: data,
          isVibrating: isVibrating,
          isBottomSheet: true,
        ),
      );
    }

    // Desktop web → dùng showGeneralDialog
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) =>
          BetDetailsBottomSheetV2(data: data, isVibrating: isVibrating),
    );
  }
}

class _BetDetailsBottomSheetV2State
    extends ConsumerState<BetDetailsBottomSheetV2> {
  late File fileBorder;
  late File fileBackground;
  late RiveWidgetController controllerBorder;
  late RiveWidgetController controllerBackground;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize provider with betting data when popup opens
    if (widget.data != null) {
      Future(() {
        if (!mounted) return;
        ref.read(bettingPopupV2Provider.notifier).initialize(widget.data!);
      });
    }
    initRive();
  }

  void initRiveBorder() async {
    try {
      fileBorder = (await File.url(
          AppRive.animCardBig, riveFactory: Factory.rive))!;
      controllerBorder = RiveWidgetController(fileBorder);
      if (mounted) {
        setState(() => isInitialized = true);
      }
    } catch (e) {
      debugPrint('Rive init error: $e');
    }
  }

  void initRiveBackground() async {
    try {
      fileBackground = (await File.url(
        AppRive.animCardBigGlow,
        riveFactory: Factory.rive,
      ))!;
      controllerBackground = RiveWidgetController(fileBackground);
      if (mounted) {
        setState(() => isInitialized = true);
      }
    } catch (e) {
      debugPrint('Rive init error: $e');
    }
  }

  void initRive() {
    initRiveBorder();
    initRiveBackground();
  }

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, deviceType) {
      final isMobile = deviceType == DeviceType.mobile;
      final screenSize = MediaQuery.of(context).size;
      final maxHeight = screenSize.height * 0.9;
      final maxWidth = isMobile ? screenSize.width : 520.0;

      final content = Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
              minWidth: isMobile ? 0 : 402,
              maxHeight: maxHeight,
              maxWidth: maxWidth,
            ),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundSecondary,
              borderRadius: isMobile
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 80,
                  offset: const Offset(0, -40),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: isMobile
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              // TODO: Create BetDetailsContentV2 that uses V2 provider
              // For now, reuse existing content (it will use legacy provider)
              child: BetDetailsContent(
                isMobile: isMobile,
                isVibrating: widget.isVibrating,
                isBottomSheet: widget.isBottomSheet,
              ),
            ),
          ),
          if (widget.isVibrating)
            Positioned.fill(child: IgnorePointer(child: _buildRiveborder())),
        ],
      );

      // Nếu dùng showModalBottomSheet, không cần Dialog wrapper
      if (widget.isBottomSheet) {
        return MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: content,
        );
      }

      // Nếu dùng showGeneralDialog, cần Dialog wrapper
      return MediaQuery.removePadding(
        context: context,
        removeBottom: isMobile,
        child: Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.bottomCenter,
          insetPadding: isMobile
              ? EdgeInsets.zero
              : EdgeInsets.only(
                  bottom: 48,
                  left: (screenSize.width - maxWidth) / 2,
                  right: (screenSize.width - maxWidth) / 2,
                ),
          child: content,
        ),
      );
    },
  );

  Widget _buildRiveborder() {
    if (!isInitialized) {
      return const SizedBox.shrink();
    }
    return RiveWidget(controller: controllerBorder, fit: Fit.fill);
  }

  Widget _buildRivebackground() {
    if (!isInitialized) {
      return const SizedBox.shrink();
    }
    return RiveWidget(controller: controllerBackground, fit: Fit.cover);
  }
}
