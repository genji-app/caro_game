import '../../platform_ui/platform_ui.dart';
import 'fullscreen_strategy.dart';
import 'native_immersive_strategy.dart';

/// Factory function for native platforms (stub/default).
FullscreenStrategy createFullscreenStrategy(PlatformUiController platformUi) {
  return NativeImmersiveStrategy(platformUi);
}
