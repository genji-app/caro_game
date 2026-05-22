import 'orientation_policy.dart';

/// Status of the application process.
enum OrientationResultStatus {
  /// Policy was successfully applied (or at least requested to the platform).
  matched,

  /// UI mismatch detected (current layout != policy targets).
  mismatched,

  /// Platform does not support programmatic orientation control (e.g. Web).
  unsupported,

  /// An error occurred during the application process.
  failed,
}

/// Result returned from applying a policy via [OrientationController] or [OrientationStrategy].
class OrientationApplyResult {
  /// Creates a new [OrientationApplyResult].
  const OrientationApplyResult({
    required this.status,
    required this.policy,
    required this.canControlPlatform,
    this.message,
  });

  /// Status of the result.
  final OrientationResultStatus status;

  /// The policy that was applied.
  final OrientationPolicy policy;

  /// Whether the current platform supports programmatic orientation control.
  final bool canControlPlatform;

  /// Optional message for debugging or error details.
  final String? message;

  /// Helper for a successful match.
  factory OrientationApplyResult.matched(OrientationPolicy policy) => OrientationApplyResult(
        status: OrientationResultStatus.matched,
        policy: policy,
        canControlPlatform: true,
      );

  /// Helper for unsupported platforms (e.g. Web).
  factory OrientationApplyResult.unsupported(OrientationPolicy policy, {String? message}) =>
      OrientationApplyResult(
        status: OrientationResultStatus.unsupported,
        policy: policy,
        canControlPlatform: false,
        message: message,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationApplyResult &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          policy == other.policy &&
          canControlPlatform == other.canControlPlatform &&
          message == other.message;

  @override
  int get hashCode =>
      status.hashCode ^ policy.hashCode ^ canControlPlatform.hashCode ^ message.hashCode;
}
