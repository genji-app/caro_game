import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/sportbook_api.dart';
import 'package:co_caro_flame/s88/features/transaction/payment_config/payment_config.dart';
import 'package:co_caro_flame/s88/features/transaction/transaction.dart';
import 'package:co_caro_flame/s88/shared/profile_navigation_system/profile_navigation_system.dart';

class TransactionDetailsScreen extends ConsumerStatefulWidget {
  const TransactionDetailsScreen({required this.transaction, super.key});

  static MaterialPageRoute<void> route(Transaction transaction) =>
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transaction: transaction),
      );

  final Transaction transaction;

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(paymentConfigProvider.notifier)
          .loadFromApi(SbHttpManager.instance);
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleLabel = switch (widget.transaction.transactionSlipType) {
      TransactionSlipType.withdraw => I18n.txtWithdrawalDetails,
      TransactionSlipType.deposit => I18n.txtDepositDetails,
      TransactionSlipType.other => I18n.txtNotAvailable,
    };

    return ProfileNavigationScaffold.withCenterTitle(
      bodyPadding: EdgeInsets.zero,
      title: Text(titleLabel),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: TransactionDetailsView(widget.transaction),
        ),
      ),
    );
  }
}
