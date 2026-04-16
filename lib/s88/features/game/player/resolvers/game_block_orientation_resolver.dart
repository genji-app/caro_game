import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientation_guard/orientation_guard.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';

/// Provider for [GameBlockOrientationResolver].
final gameBlockOrientationResolverProvider = Provider(
  (ref) => GameBlockOrientationResolver(),
);

/// Resolves orientation policy for a [GameBlock].
class GameBlockOrientationResolver
    extends OrientationPolicyResolver<GameBlock> {
  @override
  OrientationPolicy resolve(BuildContext context, GameBlock game) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isActuallyMobile = shortestSide < 600;

    // Determine orientations based on device category
    final List<GameOrientation> orientations;

    // We differentiate between mobile (phone) and tablet/desktop.
    // In this app, tablet and desktop are often treated similarly for games.
    if (isActuallyMobile) {
      orientations = game.mobileOrientation;
    } else if (shortestSide < 900) {
      orientations = game.tabletOrientation;
    } else {
      orientations = game.desktopOrientation;
    }

    return OrientationPolicy(
      targets: orientations.map((o) {
        return switch (o) {
          GameOrientation.portraitUp => DeviceOrientation.portraitUp,
          GameOrientation.portraitDown => DeviceOrientation.portraitDown,
          GameOrientation.landscapeLeft => DeviceOrientation.landscapeLeft,
          GameOrientation.landscapeRight => DeviceOrientation.landscapeRight,
        };
      }).toList(),
      screenUi: ScreenUiPolicy(immersive: game.forceLandscapeViewportOnIpad),
      debugLabel: 'GameBlock(${game.providerId} / isMobile: $isActuallyMobile)',
    );
  }
}
