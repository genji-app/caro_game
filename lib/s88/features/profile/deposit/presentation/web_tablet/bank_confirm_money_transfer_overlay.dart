import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/payment_method.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/entities/models/bank_account_item.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/domain/utils/deposit_navigator.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/bank_confirm_money_transfer_container.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';

/// Web/tablet overlay for Bank confirm money transfer
class BankConfirmMoneyTransferOverlay extends ConsumerStatefulWidget {
  final BankAccountItem bankAccountItem;
  final PaymentMethod paymentMethod;

  const BankConfirmMoneyTransferOverlay({
    super.key,
    required this.bankAccountItem,
    required this.paymentMethod,
  });

  @override
  ConsumerState<BankConfirmMoneyTransferOverlay> createState() =>
      _BankConfirmMoneyTransferOverlayState();
}

class _BankConfirmMoneyTransferOverlayState
    extends ConsumerState<BankConfirmMoneyTransferOverlay> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => DepositNavigator().pop<void>(context),
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
                  child: Container(
                    color: AppColors.gray950,
                    child: BankConfirmMoneyTransferContainer(
                      bankAccountItem: widget.bankAccountItem,
                      paymentMethod: widget.paymentMethod,
                      parentContext: context,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
