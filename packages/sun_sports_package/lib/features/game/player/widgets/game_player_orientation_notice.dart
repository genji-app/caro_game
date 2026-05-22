import 'package:flutter/material.dart';
import 'package:orientation_guard/orientation_guard.dart';

/// A notification widget shown when the device orientation doesn't match
/// the required orientation for a game.
///
/// This widget provides the visual content (background and instructions)
/// while leaving the positioning and animation to the parent.
class GamePlayerOrientationNotice extends StatelessWidget {
  const GamePlayerOrientationNotice({required this.policy, super.key});

  final OrientationPolicy policy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: OrientationMismatchView(policy: policy),
    );
  }
}
