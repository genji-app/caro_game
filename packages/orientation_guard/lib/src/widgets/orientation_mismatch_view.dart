import 'package:flutter/material.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';

/// A simple informative view displayed when the device orientation
/// doesn't match the required [policy].
class OrientationMismatchView extends StatelessWidget {
  /// Creates an [OrientationMismatchView].
  const OrientationMismatchView({
    required this.policy,
    super.key,
  });

  /// The policy being guarded.
  final OrientationPolicy policy;

  @override
  Widget build(BuildContext context) {
    if (policy.customMismatchViewBuilder != null) {
      return policy.customMismatchViewBuilder!(context);
    }

    final isLandscape = policy.targets.every((t) => t.isLandscape);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFF11100F),
        child: AbsorbPointer(
          absorbing: true,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.screen_rotation_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isLandscape ? 'Vui lòng xoay ngang thiết bị' : 'Vui lòng xoay dọc thiết bị',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLandscape
                          ? 'Màn hình này yêu cầu hướng hiển thị xoay ngang để có trải nghiệm tốt nhất.'
                          : 'Màn hình này yêu cầu hướng hiển thị dọc.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
