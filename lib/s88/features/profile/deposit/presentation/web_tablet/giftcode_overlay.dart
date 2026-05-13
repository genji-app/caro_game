import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/giftcode_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// Web/tablet overlay for Giftcode deposit form
class GiftCodeOverlay extends ConsumerStatefulWidget {
  const GiftCodeOverlay({super.key});

  @override
  ConsumerState<GiftCodeOverlay> createState() => _GiftCodeOverlayState();
}

class _GiftCodeOverlayState extends ConsumerState<GiftCodeOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        const GiftCodeContainer(),
      ],
    );
  }
}
