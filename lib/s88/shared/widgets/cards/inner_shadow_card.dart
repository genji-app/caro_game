import 'dart:ui';
import 'package:flutter/material.dart';

/// Widget với inner shadow có 2 điểm nhọn ở góc top-left và top-right
class InnerShadowCard extends StatelessWidget {
  final double borderRadius;
  final Color? color;

  /// Widget con bên trong
  final Widget child;

  const InnerShadowCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.topCenter,
    children: [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: color,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -0.65),
                blurRadius: 0.5,
                spreadRadius: 0.05,
                blurStyle: BlurStyle.inner,
                color: Colors.white.withOpacity(0.12),
              ),
            ],
          ),
        ),
      ),
      // Content
      child,
    ],
  );
}
