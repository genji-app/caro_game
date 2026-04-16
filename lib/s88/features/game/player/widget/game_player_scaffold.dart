import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';

/// Scaffold that wraps game content with an adaptive navigation bar.
///
/// Uses a single [Stack]-based layout internally so that [child] (which
/// typically contains the game WebView) stays at a **stable position in the
/// widget tree** regardless of orientation.
///
/// This is critical on Flutter Web because `HtmlElementView` +
/// `registerViewFactory` does not allow re-registration with the same viewId.
/// If the child were to be unmounted and remounted (as happens when switching
/// between two different widget types like Column ↔ Row), the iframe is
/// destroyed and cannot be recreated.
class GamePlayerScaffold extends StatelessWidget {
  const GamePlayerScaffold({
    required this.child,
    this.showControls = true,
    super.key,
  });

  final Widget child;
  final bool showControls;

  @override
  Widget build(BuildContext context) {
    // Read viewPadding here (before Scaffold), because Scaffold.body removes
    // system-insets from its descendants' MediaQuery, making viewPadding.top = 0
    // inside _AdaptiveGameLayout.
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return _AdaptiveGameLayout(
          isPortrait: isPortrait,
          viewPadding: viewPadding,
          showControls: showControls,
          child: child,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Unified adaptive layout (replaces GamePortraitLayout / GameLandscapeLayout)
// ---------------------------------------------------------------------------

/// A single layout widget that adapts to orientation without changing widget
/// types, ensuring the [child] is never unmounted during rotation.
///
/// Visual result is identical to the old `GamePortraitLayout` /
/// `GameLandscapeLayout` split:
/// - **Portrait**: top app bar (back button) + content below
/// - **Landscape**: left sidebar (back button) + content + right sidebar
class _AdaptiveGameLayout extends StatelessWidget {
  const _AdaptiveGameLayout({
    required this.isPortrait,
    required this.viewPadding,
    required this.showControls,
    required this.child,
  });

  final bool isPortrait;
  final EdgeInsets viewPadding;
  final bool showControls;
  final Widget child;

  /// Height of the portrait app bar content area (excluding safe area)
  static const _kAppBarContentHeight = 48.0;

  /// Width of the landscape sidebar content area (excluding safe area)
  // static const _kSidebarContentWidth = 48.0;
  static const _kSidebarContentWidth = 56.0;

  @override
  Widget build(BuildContext context) {
    // viewPadding is passed from the parent (GamePlayerScaffold) which reads it
    // before the Scaffold widget resets system insets in its descendants.
    final backgroundColor = Colors.black;

    // Compute insets for the content area based on orientation and controls.
    final topInset = (showControls && isPortrait)
        ? _kAppBarContentHeight + viewPadding.top
        : 0.0;
    final bottomInset = (showControls && isPortrait) ? viewPadding.bottom : 0.0;
    final leftInset = (showControls && !isPortrait)
        ? _kSidebarContentWidth + viewPadding.left
        : 0.0;
    final rightInset = (showControls && !isPortrait)
        ? _kSidebarContentWidth + viewPadding.right
        : 0.0;

    return Stack(
      children: [
        // ----- Layer 1: Game content (STABLE – never unmounted) -----
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          top: topInset,
          left: leftInset,
          right: rightInset,
          bottom: bottomInset,
          child: child,
        ),

        // ----- Layer 2: Navigation bar / sidebar overlay -----
        if (showControls) ...[
          if (isPortrait) ...[
            // Portrait: top app bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _kAppBarContentHeight + viewPadding.top,
              child: ColoredBox(
                color: backgroundColor,
                child: const Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: _BackButton(),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Landscape: left sidebar (with back button)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: _kSidebarContentWidth + viewPadding.left,
              child: ColoredBox(
                color: backgroundColor,
                child: const Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    child: _BackButton(),
                  ),
                ),
              ),
            ),

            // Landscape: right sidebar (decorative)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: _kSidebarContentWidth + viewPadding.right,
              child: ColoredBox(color: backgroundColor),
            ),
          ],
        ],
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 18,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(40),
        padding: EdgeInsetsGeometry.zero,
        foregroundColor: AppColorStyles.contentSecondary,
        backgroundColor: AppColorStyles.backgroundQuaternary,
      ),
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }
}
