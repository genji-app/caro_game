import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/crypto_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// Web/tablet overlay for Crypto deposit form
class CryptoOverlay extends ConsumerStatefulWidget {
  const CryptoOverlay({super.key});

  @override
  ConsumerState<CryptoOverlay> createState() => _CryptoOverlayState();
}

class _CryptoOverlayState extends ConsumerState<CryptoOverlay> {
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
        // Centered dialog
        Center(
          child: Material(
            color: Colors.transparent,
            elevation: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: InnerShadowCard(
                child: Container(
                  width: 640,
                  height: 823,
                  constraints: BoxConstraints(maxHeight: size.height * 0.9),
                  decoration: BoxDecoration(
                    color: AppColors.gray950,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.75),
                        offset: const Offset(-20, 4),
                        blurRadius: 200,
                      ),
                      BoxShadow(
                        offset: const Offset(0, 0.5),
                        blurRadius: 0.5,
                        spreadRadius: 0,
                        blurStyle: BlurStyle.inner,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  child: const CryptoContainer(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
