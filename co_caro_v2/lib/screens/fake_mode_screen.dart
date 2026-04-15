import 'package:flutter/material.dart';

class FakeModeScreen extends StatelessWidget {
  const FakeModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ứng dụng đang ở chế độ giới hạn.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
