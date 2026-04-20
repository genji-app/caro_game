import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/services/orientation_controller.dart';

/// An [InheritedWidget] that provides an [OrientationController]
/// to its descendants.
class OrientationProvider extends InheritedWidget {
  /// Creates an [OrientationProvider].
  const OrientationProvider({
    required this.controller,
    required super.child,
    super.key,
  });

  /// The [OrientationController] to provide.
  final OrientationController controller;

  /// Retrieves the [OrientationController] from the nearest [OrientationProvider].
  ///
  /// Returns null if no [OrientationProvider] is found in the widget tree.
  static OrientationController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OrientationProvider>()?.controller;
  }

  @override
  bool updateShouldNotify(OrientationProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
