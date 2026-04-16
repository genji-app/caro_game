import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/profile/deposit/presentation/widgets/verify_bank_completion_container.dart';

/// Mobile bottom sheet for bank verification completion
class VerifyBankCompletionBottomSheet extends StatelessWidget {
  const VerifyBankCompletionBottomSheet({super.key});

  /// Show the verify bank completion bottom sheet
  static Future<void> show(BuildContext context) => showGeneralDialog(
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
        const VerifyBankCompletionBottomSheet(),
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
        child: const VerifyBankCompletionContainer(),
      ),
    );
  }
}
