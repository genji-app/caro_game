import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/codepay_container_section.dart';

/// Container for Codepay payment method form
class CodepayContainer extends StatefulWidget {
  const CodepayContainer({super.key});

  @override
  State<CodepayContainer> createState() => _CodepayContainerState();
}

class _CodepayContainerState extends State<CodepayContainer> {
  @override
  Widget build(BuildContext context) => const CodepayContainerSection();
}
