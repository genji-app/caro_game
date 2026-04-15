import 'package:flutter/material.dart';

class DefaultSplashScreen extends StatelessWidget {
  const DefaultSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
