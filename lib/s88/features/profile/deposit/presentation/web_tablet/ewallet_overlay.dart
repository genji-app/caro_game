import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/ewallet_container.dart';

/// Web/tablet overlay for E-Wallet deposit form
class EWalletOverlay extends ConsumerStatefulWidget {
  const EWalletOverlay({super.key});

  @override
  ConsumerState<EWalletOverlay> createState() => _EWalletOverlayState();
}

class _EWalletOverlayState extends ConsumerState<EWalletOverlay> {
  @override
  Widget build(BuildContext context) {
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
        const EWalletContainer(),
      ],
    );
  }
}
