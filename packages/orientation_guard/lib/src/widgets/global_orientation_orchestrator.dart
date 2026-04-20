import 'package:flutter/material.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';
import 'package:orientation_guard/src/widgets/orientation_guard.dart';
import 'package:orientation_guard/src/widgets/orientation_provider.dart';

/// A shared global widget that orchestrates orientation policies
/// using a provider-based architecture.
class GlobalOrientationOrchestrator extends StatefulWidget {
  /// Creates a [GlobalOrientationOrchestrator].
  const GlobalOrientationOrchestrator({
    required this.controller,
    required this.child,
    this.defaultPolicy = const OrientationPolicy(
      targets: DeviceOrientations.portrait,
      debugLabel: 'GlobalDefaultPortrait',
    ),
    super.key,
  });

  /// The shared controller instance.
  final OrientationController controller;

  /// The child widget (usually MaterialApp).
  final Widget child;

  /// The policy used when no override is present.
  final OrientationPolicy defaultPolicy;

  @override
  State<GlobalOrientationOrchestrator> createState() => _GlobalOrientationOrchestratorState();
}

class _GlobalOrientationOrchestratorState extends State<GlobalOrientationOrchestrator> {
  @override
  Widget build(BuildContext context) {
    return OrientationProvider(
      controller: widget.controller,
      child: OrientationGuard(
        policy: widget.defaultPolicy,
        child: widget.child,
      ),
    );
  }
}

/// A specialized widget to temporarily override the orientation policy
/// of the global orchestrator from anywhere in the tree.
class OrientationOverride extends StatelessWidget {
  /// Creates an [OrientationOverride].
  const OrientationOverride({
    required this.policy,
    required this.child,
    super.key,
  });

  /// The policy to use instead of the global default.
  final OrientationPolicy policy;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OrientationGuard(
      policy: policy,
      child: child,
    );
  }
}
