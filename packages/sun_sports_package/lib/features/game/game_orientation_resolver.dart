import 'package:caxilo_repository/caxilo_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';

/// Provider for [GameOrientationResolver].
final gameOrientationResolverProvider = Provider(
  (ref) => GameOrientationResolver(),
);

/// Resolves orientation policy for a [GameBlock].
class GameOrientationResolver extends OrientationPolicyResolver<GameBlock> {
  @override
  OrientationPolicy resolve(BuildContext context, GameBlock game) {
    final experience = OrientationExperienceClassifier.standard.classify(
      context,
    );

    // Determine orientations based on device category
    final List<GameOrientation> orientations = switch (experience) {
      OrientationExperience.mobile => game.mobileOrientation,
      OrientationExperience.tablet => game.tabletOrientation,
      OrientationExperience.largeTablet ||
      OrientationExperience.desktop => game.desktopOrientation,
    };

    return OrientationPolicy(
      targets: orientations.map((o) {
        return switch (o) {
          GameOrientation.portraitUp => DeviceOrientation.portraitUp,
          GameOrientation.portraitDown => DeviceOrientation.portraitDown,
          GameOrientation.landscapeLeft => DeviceOrientation.landscapeLeft,
          GameOrientation.landscapeRight => DeviceOrientation.landscapeRight,
        };
      }).toList(),
      debugLabel:
          'GameBlock(${game.providerId} / experience: ${experience.name})',
    );
  }
}
