import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/repositories/game_repository/game_repository.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';

import 'new_tab_opener/new_tab_opener.dart';
import 'widget/game_player_background.dart';

/// Shown when a game provider is configured to open in a new browser tab.
///
/// Some providers (e.g. Sexy/amb-vn) crash iOS Safari when loaded inside
/// an iframe because their heavy WebGL+video content shares the same
/// WebContent process with Flutter CanvasKit. Opening in a separate tab
/// gives the game its own process with dedicated memory and GPU resources.
class NewTabGamePlaceholder extends ConsumerStatefulWidget {
  const NewTabGamePlaceholder({
    required this.game,
    required this.gameUrl,
    required this.alreadyOpened,
    required this.onOpened,
    super.key,
  });

  final GameBlock game;
  final String gameUrl;
  final bool alreadyOpened;
  final VoidCallback onOpened;

  @override
  ConsumerState<NewTabGamePlaceholder> createState() =>
      _NewTabGamePlaceholderState();
}

class _NewTabGamePlaceholderState extends ConsumerState<NewTabGamePlaceholder> {
  /// True when the popup was blocked by Safari (auto-open failed silently).
  bool _popupBlocked = false;

  @override
  void initState() {
    super.initState();
    // Auto-open game in new tab on first build.
    // NOTE: On Safari iOS, this will likely be blocked by the popup blocker
    // because there is no user gesture at this point. The _popupBlocked flag
    // will be set and the user will see a manual "Mở lại game" button.
    if (!widget.alreadyOpened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openGameTab();
      });
    }
  }

  /// Opens the game URL in a new Safari tab using a direct JS `window.open()`
  /// call to avoid Safari's popup blocker.
  ///
  /// **Safari Popup Blocker rules:**
  /// Safari only allows `window.open()` when called synchronously within
  /// the same call stack as a user interaction event (tap). Two reasons
  /// the old `url_launcher` approach was unreliable:
  ///   - `await canLaunchUrl()` introduced an async gap → broke gesture chain.
  ///   - Auto-open from `addPostFrameCallback` has no gesture → always blocked.
  ///
  /// Calling `window.open()` directly (no async gap) lets us detect a blocked
  /// popup (`null` return value) and surface a manual fallback button.
  void _openGameTab() {
    // Direct JS call — synchronous, no async gap.
    // Returns false if Safari blocked the popup.
    final popupSuccess = openNewTab(widget.gameUrl);
    if (!popupSuccess) {
      // Popup was blocked → show manual button.
      if (mounted) setState(() => _popupBlocked = true);
      return;
    }

    widget.onOpened();
  }

  @override
  Widget build(BuildContext context) {
    return GamePlayerBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(
                _popupBlocked
                    ? 'Trình duyệt đã chặn popup'
                    : 'Game đang chơi ở tab khác',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.game.gameName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Show manual open button when popup was blocked by Safari.
              if (_popupBlocked) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Mở lại game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  // Called directly from onPressed → has user gesture → Safari allows.
                  onPressed: _openGameTab,
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
