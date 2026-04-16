import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/verify_bank_container.dart';

/// Mobile bottom sheet for bank verification
class VerifyBankBottomSheet extends StatelessWidget {
  final String? selectedBankId;

  const VerifyBankBottomSheet({super.key, this.selectedBankId});

  /// Show the verify bank bottom sheet
  static Future<void> show(
    BuildContext context, {
    String? selectedBankId,
  }) => showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Slide up animation
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1), // Start from bottom
        end: Offset.zero, // End at position
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        VerifyBankBottomSheet(selectedBankId: selectedBankId),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(top: statusBarHeight),
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height),
        child: VerifyBankContainer(selectedBankId: selectedBankId),
      ),
    );
  }
}
