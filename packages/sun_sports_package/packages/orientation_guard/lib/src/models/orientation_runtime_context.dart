import 'package:flutter/foundation.dart';

/// Context information about the current runtime environment.
/// Used to resolve the appropriate [OrientationStrategy].
class OrientationRuntimeContext {
  /// Creates a new [OrientationRuntimeContext].
  const OrientationRuntimeContext({
    required this.platform,
    required this.isWeb,
  });

  /// The target platform (iOS, Android, etc).
  final TargetPlatform platform;

  /// Whether running on the Web.
  final bool isWeb;

  /// Detects the current runtime context.
  factory OrientationRuntimeContext.current() => OrientationRuntimeContext(
        platform: defaultTargetPlatform,
        isWeb: kIsWeb,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrientationRuntimeContext &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          isWeb == other.isWeb;

  @override
  int get hashCode => platform.hashCode ^ isWeb.hashCode;

  @override
  String toString() => 'OrientationRuntimeContext(platform: $platform, isWeb: $isWeb)';
}
