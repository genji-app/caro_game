import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/bank_container_section.dart';

/// Container for Bank payment method form
class BankContainer extends StatefulWidget {
  const BankContainer({super.key});

  @override
  State<BankContainer> createState() => _BankContainerState();
}

class _BankContainerState extends State<BankContainer> {
  @override
  Widget build(BuildContext context) => const BankContainerSection();
}
