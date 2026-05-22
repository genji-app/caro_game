import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:sun_sports/features/profile/deposit/domain/providers/deposit_providers.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/card_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/crypto_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/ewallet_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/web_tablet/giftcode_overlay.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/bank_container_section.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/codepay_container_section.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/deposit_content_shimmer.dart';

/// Payment method container for web/tablet - without Expanded widgets
/// Reuses form logic from mobile containers but adapted for web layout
class DepositPaymentMethodContainerWeb extends ConsumerStatefulWidget {
  const DepositPaymentMethodContainerWeb({super.key});

  @override
  ConsumerState<DepositPaymentMethodContainerWeb> createState() =>
      _DepositPaymentMethodContainerWebState();
}

class _DepositPaymentMethodContainerWebState
    extends ConsumerState<DepositPaymentMethodContainerWeb> {
  @override
  Widget build(BuildContext context) {
    // While the deposit config is loading for the first time, render a
    // shimmer skeleton instead of the real payment-method container. This
    // keeps the loading state consistent with the payment-methods grid
    // above and avoids showing the Codepay form (default selection) before
    // we know whether Codepay is actually available.
    final isLoading = ref.watch(isDepositConfigLoadingProvider);
    if (isLoading) {
      return const DepositContentShimmer();
    }

    final selectionState = ref.watch(depositSelectionProvider);
    final selectedMethod =
        selectionState.selectedMethod ?? PaymentMethod.codepay;

    return _buildFormContent(selectedMethod);
  }

  /// Build form content based on selected payment method
  Widget _buildFormContent(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.codepay:
        return const CodepayContainerSection();
      case PaymentMethod.bank:
        return const BankContainerSection();
      case PaymentMethod.eWallet:
        return const EWalletOverlay();
      case PaymentMethod.crypto:
        return const CryptoOverlay();
      case PaymentMethod.scratchCard:
        return const CardOverlay();
      case PaymentMethod.giftcode:
        return const GiftCodeOverlay();
    }
  }
}
