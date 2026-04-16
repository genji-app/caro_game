import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/shared/widgets/status_information/status_information.dart';

class SliverFillInfoMessage extends StatelessWidget {
  const SliverFillInfoMessage({
    this.image,
    this.primaryMessage,
    this.secondaryMessage,
    super.key,
  }) : assert(primaryMessage != null || secondaryMessage != null);

  final Widget? image;
  final Widget? primaryMessage;
  final Widget? secondaryMessage;

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: InfoMessage(
      image: image,
      primaryMessage: primaryMessage,
      secondaryMessage: secondaryMessage,
    ),
  );
}
