import 'package:flutter/material.dart';
import 'home_screen.dart';

/// Màn hình hiển thị khi app ở chế độ [AppMode.betting] (đã unlock).
/// Đây là giao diện thật của app — wraps [HomeScreen].
class FakeModeScreen extends StatelessWidget {
  const FakeModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
