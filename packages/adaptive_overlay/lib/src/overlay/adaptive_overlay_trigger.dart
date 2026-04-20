import 'package:flutter/widgets.dart';

import 'adaptive_overlay.dart';
import 'adaptive_overlay_controller.dart';

/// {@template adaptive_overlay_trigger}
/// A builder widget that provides access to the nearest
/// [AdaptiveOverlayController].
///
/// This widget is commonly used to create trigger buttons (like avatars
/// or menu items) that need to open or toggle the overlay.
/// {@endtemplate}
class AdaptiveOverlayTrigger extends StatelessWidget {
  /// {@macro adaptive_overlay_trigger}
  const AdaptiveOverlayTrigger({required this.builder, super.key});

  /// The builder function used to build the trigger widget.
  final AdaptiveOverlayBuilder builder;

  @override
  Widget build(BuildContext context) {
    final controller = AdaptiveOverlay.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => builder(context, controller),
    );
  }
}
