import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/shared/responsive/responsive_builder.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/bet_details_content.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/providers/betting_popup_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

class BetDetailsBottomSheet extends ConsumerStatefulWidget {
  final BettingPopupData? data;

  const BetDetailsBottomSheet({super.key, this.data});

  @override
  ConsumerState<BetDetailsBottomSheet> createState() =>
      _BetDetailsBottomSheetState();

  static Future<void> show(BuildContext context, {BettingPopupData? data}) =>
      showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        pageBuilder: (context, animation, secondaryAnimation) =>
            BetDetailsBottomSheet(data: data),
      );
}

class _BetDetailsBottomSheetState extends ConsumerState<BetDetailsBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Initialize provider with betting data when popup opens
    if (widget.data != null) {
      // Use Future to avoid modifying provider during widget tree building
      // This resets isClosed=false immediately after initState completes
      Future(() {
        if (!mounted) return;
        ref.read(bettingPopupProvider.notifier).initialize(widget.data!);
      });
    }
  }

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, deviceType) {
      final isMobile = deviceType == DeviceType.mobile;
      final screenSize = MediaQuery.of(context).size;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final maxHeight = screenSize.height * 0.9;
      final maxWidth = isMobile ? screenSize.width : 520.0;

      Widget content = InnerShadowCard(
        child: Container(
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
                color: Colors.black.withOpacity(0.5),
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
            child: BetDetailsContent(isMobile: isMobile),
          ),
        ),
      );

      // Sử dụng Dialog cho cả mobile và tablet/desktop với alignment khác nhau
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
}
